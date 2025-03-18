module game;

import std.stdio;
import std.random;
import std.algorithm.searching : canFind;
import std.format;
import std.range;
import std.conv;
import std.datetime : SysTime, Clock;

import raylib;

import constants;
import types;
import utils;

Color getPieceColor(PieceType pieceType, bool minoIsGarbage, SettingsState settingsState) {
    if (minoIsGarbage) {
        return settingsState.colorScheme.btnbg;
    }
    switch (pieceType) {
    case PieceType.I:
        return settingsState.colorScheme.pieceI;
    case PieceType.J:
        return settingsState.colorScheme.pieceJ;
    case PieceType.L:
        return settingsState.colorScheme.pieceL;
    case PieceType.S:
        return settingsState.colorScheme.pieceS;
    case PieceType.Z:
        return settingsState.colorScheme.pieceZ;
    case PieceType.O:
        return settingsState.colorScheme.pieceO;
    case PieceType.T:
        return settingsState.colorScheme.pieceT;
    default:
        return settingsState.colorScheme.fg;
    }
}

PieceType[] generatePieceBag() {
    PieceType[] pieceTypes = [
        PieceType.I, PieceType.J, PieceType.L, PieceType.S, PieceType.Z,
        PieceType.O, PieceType.T
    ];
    return randomShuffle(pieceTypes);
}

PieceType[] generateInitialPieceQueue() {
    return generatePieceBag() ~ generatePieceBag();
}

PieceType[] topUpQueue(PieceType[] currentQueue) {
    // add another bag to the queue
    return currentQueue ~ generatePieceBag();
}

Mino[] generateInitialPieceMinos(PieceType pieceType) {
    Mino[] minos;
    switch (pieceType) {
    case PieceType.J, PieceType.L, PieceType.T, PieceType.Z, PieceType.S:
        // pieces of length 3 span the 4th to 6th cells
        // pivot points are on the 21st row
        const byte[][] pieceMinoOffsets = rotatedMinoOffsets[PieceOrientation(pieceType,
                PieceRotation.Z)];
        Coord pivotLocation = Coord(4, 21);
        foreach (offsetArr; pieceMinoOffsets) {
            minos ~= Mino(pieceType, Coord(pivotLocation.x + offsetArr[0],
                    pivotLocation.y + offsetArr[1]), false);
        }
        break;
    case PieceType.I:
        // spans from 4th to 7th cells
        // pivot not aligned with a square
        foreach (i; 3 .. 7) {
            minos ~= Mino(pieceType, Coord(i, 21), false);
        }
        break;
    case PieceType.O:
        // spans from 5th to 6th cells
        // pivot not relevant
        minos ~= [
            Mino(pieceType, Coord(4, 21), false),
            Mino(pieceType, Coord(4, 22), false),
            Mino(pieceType, Coord(5, 21), false),
            Mino(pieceType, Coord(5, 22), false)
        ];
        break;
    default:
        throw new Exception(format("unknown piece type encountered: %s", pieceType));
    }
    return minos;
}

PieceState dropPiece(PieceState pieceState) {
    // drop the piece by 1 row (doesn't check for collisions)
    for (int i = 0; i < pieceState.pieceMinos.length; i++) {
        pieceState.pieceMinos[i].minoLocation.y -= 1;
    }
    return pieceState;
}

PieceState dropPieceWithoutModification(PieceState pieceState) {
    // drop the piece by 1 row (doesn't check for collisions)
    // doesn't modify the piece state, creates a new one
    PieceState pieceStateToReturn = pieceState;
    pieceStateToReturn.pieceMinos = pieceState.pieceMinos.dup;
    for (int i = 0; i < pieceState.pieceMinos.length; i++) {
        pieceStateToReturn.pieceMinos[i].minoLocation.y -= 1;
    }
    return pieceStateToReturn;
}

GameState initGameState(GameType gameType) {
    GameState gameState;

    gameState.gameStartTime = Clock.currStdTime();

    gameState.gameType = gameType;

    gameState.pieceQueue = generateInitialPieceQueue();
    gameState.bagIndex = 0;

    BoardState boardState;
    gameState.boardState = boardState;

    PieceState pieceState;
    pieceState.pieceType = gameState.pieceQueue[0];
    gameState.pieceQueue.popFront();
    pieceState.pieceMinos = generateInitialPieceMinos(pieceState.pieceType);
    gameState.pieceState = pieceState;

    gameState.gravityFrames = gravityFrames;

    return gameState;
}

void drawMino(Mino mino, SettingsState settingsState) {
    Coord minoLoc = mino.minoLocation;
    DrawRectangle(boardTopLeftX + (minoWidth * minoLoc.x), boardBottomLeftY - (minoHeight * minoLoc.y),
        minoWidth, minoHeight, getPieceColor(mino.minoType, mino.minoIsGarbage, settingsState));
}

void drawNextQueueMino(Mino mino, int minoIndex, SettingsState settingsState) {
    int perIndexOffset = 3 * minoIndex;
    Coord minoLoc = mino.minoLocation;
    DrawRectangle(nextQueueLeftX + (nextMinoWidth * minoLoc.x) + nextMinoWidth,
        boardTopLeftY + nextMinoHeight * (perIndexOffset + 2 - minoLoc.y) + perIndexOffset * nextMinoMargin, nextMinoWidth,
        nextMinoHeight, getPieceColor(mino.minoType, mino.minoIsGarbage, settingsState));
}

void drawHoldMino(Mino mino, SettingsState settingsState) {
    Coord minoLoc = mino.minoLocation;
    DrawRectangle(boardTopLeftX + (nextMinoWidth * minoLoc.x) - (nextMinoWidth << 3),
        boardTopLeftY + nextMinoHeight * (2 - minoLoc.y) + nextMinoMargin, nextMinoWidth,
        nextMinoHeight, getPieceColor(mino.minoType, mino.minoIsGarbage, settingsState));
}

void drawGhostMino(Mino mino, SettingsState settingsState) {
    Coord minoLoc = mino.minoLocation;
    DrawRectangle(boardTopLeftX + (minoWidth * minoLoc.x), boardBottomLeftY - (minoHeight * minoLoc.y),
        minoWidth, minoHeight, getPieceColor(mino.minoType, mino.minoIsGarbage, settingsState));
    // fill center of each ghost mino with bg color
    DrawRectangle(boardTopLeftX + (minoWidth * minoLoc.x) + ghostPieceBorder,
        boardBottomLeftY - (minoHeight * minoLoc.y) + ghostPieceBorder, minoWidth - (ghostPieceBorder << 1),
        minoHeight - (ghostPieceBorder << 1), settingsState.colorScheme.bg);
}

void drawBoard(SettingsState settingsState) {
    // draw border
    DrawRectangle(boardTopLeftX - boardBorder, boardTopLeftY - boardBorder, boardWidth + (boardBorder << 1),
        boardDrawnHeight + (boardBorder << 1), settingsState.colorScheme.btnbg);
    // draw actual board with bg color
    DrawRectangle(boardTopLeftX, boardTopLeftY, boardWidth, boardDrawnHeight,
        settingsState.colorScheme.bg);
    // draw grid lines
    foreach (row; 1 .. 20) {
        DrawRectangle(boardTopLeftX - (gridLineWidth >> 1), boardTopLeftY - (gridLineWidth >> 1) + (row * minoHeight),
            boardWidth, gridLineWidth, settingsState.colorScheme.btnbg);
    }
    foreach (col; 1 .. 10) {
        DrawRectangle(boardTopLeftX - (gridLineWidth >> 1) + (col * minoWidth), boardTopLeftY - (gridLineWidth >> 1),
            gridLineWidth, boardDrawnHeight, settingsState.colorScheme.btnbg);
    }
}

void drawCurrentPiece(GameState gameState, SettingsState settingsState) {
    foreach (pieceMino; gameState.pieceState.pieceMinos) {
        drawMino(pieceMino, settingsState);
    }
}

void drawGhostPiece(GameState gameState, SettingsState settingsState) {
    PieceState ghostPieceState;
    ghostPieceState.pieceRotation = gameState.pieceState.pieceRotation;
    ghostPieceState.pieceType = gameState.pieceState.pieceType;
    ghostPieceState.pieceMinos = gameState.pieceState.pieceMinos.dup;

    while (!dropWouldCollidePiece(ghostPieceState, gameState)) {
        ghostPieceState = dropPiece(ghostPieceState);
    }
    if (ghostPieceState == gameState.pieceState) {
        // already have dropped piece, no need to draw ghost piece
    } else {
        foreach (ghostMino; ghostPieceState.pieceMinos) {
            drawGhostMino(ghostMino, settingsState);
        }
    }
}

void drawHoldPiece(GameState gameState, SettingsState settingsState) {
    if (gameState.pieceHeld) {
        PieceType holdPieceType = gameState.heldPiece;
        Mino[] holdPieceMinos = generateInitialPieceMinos(holdPieceType);
        int minX = 100, minY = 100;
        foreach (holdPieceMino; holdPieceMinos) {
            minX = minVal(minX, holdPieceMino.minoLocation.x);
            minY = minVal(minY, holdPieceMino.minoLocation.y);
        }
        foreach (holdPieceMino; holdPieceMinos) {
            if (gameState.pieceJustHeld) {
                // grey out the mino if player just held
                holdPieceMino.minoIsGarbage = true;
            }
            holdPieceMino.minoLocation.x -= minX;
            holdPieceMino.minoLocation.y -= minY;
            drawHoldMino(holdPieceMino, settingsState);
        }
    }
}

void drawNextPiece(GameState gameState, SettingsState settingsState) {
    for (int i = 0; i < nextPieces; i++) {
        PieceType nextPieceType = gameState.pieceQueue[i];
        Mino[] nextPieceMinos = generateInitialPieceMinos(nextPieceType);
        // subtract by min x and min y to get to bottom left
        int minX = 100, minY = 100;
        foreach (nextPieceMino; nextPieceMinos) {
            minX = minVal(minX, nextPieceMino.minoLocation.x);
            minY = minVal(minY, nextPieceMino.minoLocation.y);
        }
        foreach (nextPieceMino; nextPieceMinos) {
            nextPieceMino.minoLocation.x -= minX;
            nextPieceMino.minoLocation.y -= minY;
            drawNextQueueMino(nextPieceMino, i, settingsState);
        }
    }
}

void drawGarbage(GameState gameState, SettingsState settingsState) {
    foreach (garbageMino; gameState.boardState.garbageMinos) {
        drawMino(garbageMino, settingsState);
    }
}

bool dropWouldCollide(GameState gameState) {
    PieceState droppedPieceState = dropPieceWithoutModification(gameState.pieceState);
    foreach (droppedMino; droppedPieceState.pieceMinos) {
        if (droppedMino.minoLocation.y <= 0)
            return true;
    }
    foreach (mino; gameState.boardState.garbageMinos) {
        foreach (droppedMino; droppedPieceState.pieceMinos) {
            if (mino.minoLocation.x == droppedMino.minoLocation.x
                && mino.minoLocation.y == droppedMino.minoLocation.y)
                return true;
        }
    }
    return false;
}

bool dropWouldCollidePiece(PieceState pieceState, GameState gameState) {
    PieceState droppedPieceState = dropPieceWithoutModification(pieceState);
    foreach (droppedMino; droppedPieceState.pieceMinos) {
        if (droppedMino.minoLocation.y <= 0)
            return true;
    }
    foreach (mino; gameState.boardState.garbageMinos) {
        foreach (droppedMino; droppedPieceState.pieceMinos) {
            if (mino.minoLocation.x == droppedMino.minoLocation.x
                && mino.minoLocation.y == droppedMino.minoLocation.y)
                return true;
        }
    }
    return false;
}

bool isLegalMinoLocation(Coord coord) {
    return coord.x >= 0 && coord.x <= 9 && coord.y >= 0;
}

bool allLegalMinoLocations(Mino[] minos) {
    foreach (mino; minos) {
        if (!isLegalMinoLocation(mino.minoLocation))
            return false;
    }
    return true;
}

bool noMinoOverlap(Mino[] minosA, Mino[] minosB) {
    foreach (minoA; minosA) {
        foreach (minoB; minosB) {
            if (minoA.minoLocation.x == minoB.minoLocation.x
                && minoA.minoLocation.y == minoB.minoLocation.y)
                return false;
        }
    }
    return true;
}

GameState attemptMove(GameState gameState) {
    int moveDirection = gameState.moveDirection;
    Mino[] movedMinos = [];
    foreach (mino; gameState.pieceState.pieceMinos) {
        movedMinos ~= Mino(mino.minoType, Coord(mino.minoLocation.x + moveDirection,
                mino.minoLocation.y), mino.minoIsGarbage);
    }
    if (allLegalMinoLocations(movedMinos) && noMinoOverlap(movedMinos,
            gameState.boardState.garbageMinos)) {
        gameState.pieceState.pieceMinos = movedMinos;
    }
    return gameState;
}

GameState rotatePiece(GameState gameState, bool clockwise) {
    // O pieces do not rotate
    if (gameState.pieceState.pieceType == PieceType.O) {
        return gameState;
    }
    PieceRotationMovement pieceRotationMovement = PieceRotationMovement(
        gameState.pieceState.pieceType, gameState.pieceState.pieceRotation, clockwise);
    PieceRotation nextRotationState = pieceRotationMap[PieceRotationMotion(
            gameState.pieceState.pieceRotation, clockwise)];
    const byte[][] currentMinoOffsetArr = rotatedMinoOffsets[PieceOrientation(
            gameState.pieceState.pieceType, gameState.pieceState.pieceRotation)];
    const byte[][] rotatedMinoOffsetArr = rotatedMinoOffsets[PieceOrientation(
            gameState.pieceState.pieceType, nextRotationState)];
    Mino[] rotatedMinos = [];
    foreach (i, mino; gameState.pieceState.pieceMinos) {
        rotatedMinos ~= Mino(mino.minoType,
            Coord(mino.minoLocation.x - currentMinoOffsetArr[i][0] + rotatedMinoOffsetArr[i][0],
                mino.minoLocation.y - currentMinoOffsetArr[i][1] + rotatedMinoOffsetArr[i][1]),
            mino.minoIsGarbage);
    }
    bool allCollided = true;
    int test = 0;
    foreach (offsetArr; pieceRotationTests[pieceRotationMovement]) {
        // update rotated mino locations to use these offsets
        for (int i = 0; i < rotatedMinos.length; i++) {
            rotatedMinos[i].minoLocation.x += offsetArr[0];
            rotatedMinos[i].minoLocation.y += offsetArr[1];
        }
        // check for collisions
        bool collisionDetected = !allLegalMinoLocations(rotatedMinos)
            || !noMinoOverlap(rotatedMinos, gameState.boardState.garbageMinos);

        if (!collisionDetected) {
            allCollided = false;
            break;
        } else {
        }
        // if collided, undo the offsets
        for (int i = 0; i < rotatedMinos.length; i++) {
            rotatedMinos[i].minoLocation.x -= offsetArr[0];
            rotatedMinos[i].minoLocation.y -= offsetArr[1];
        }
        test++;
    }

    if (allCollided) {
        // can't rotate this piece at all
        return gameState;
    } else {
        // apply current rotation
        gameState.pieceState.pieceMinos = rotatedMinos;
        // actually set piece rotation to new one
        gameState.pieceState.pieceRotation = nextRotationState;
        return gameState;
    }

}

GameState rotatePiece180(GameState gameState) {
    // O pieces do not rotate
    if (gameState.pieceState.pieceType == PieceType.O) {
        return gameState;
    }
    PieceRotation nextRotationState = pieceRotationMap180[gameState.pieceState.pieceRotation];
    const byte[][] currentMinoOffsetArr = rotatedMinoOffsets[PieceOrientation(
            gameState.pieceState.pieceType, gameState.pieceState.pieceRotation)];
    const byte[][] rotatedMinoOffsetArr = rotatedMinoOffsets[PieceOrientation(
            gameState.pieceState.pieceType, nextRotationState)];
    Mino[] rotatedMinos = [];
    foreach (i, mino; gameState.pieceState.pieceMinos) {
        rotatedMinos ~= Mino(mino.minoType,
            Coord(mino.minoLocation.x - currentMinoOffsetArr[i][0] + rotatedMinoOffsetArr[i][0],
                mino.minoLocation.y - currentMinoOffsetArr[i][1] + rotatedMinoOffsetArr[i][1]),
            mino.minoIsGarbage);
    }

    // only try first offset - don't introduce tests for 180-spins

    // check for collisions
    bool collisionDetected = false;
    collisionDetection: foreach (garbageMino; gameState.boardState.garbageMinos) {
        foreach (mino; rotatedMinos) {
            if (!isLegalMinoLocation(mino.minoLocation)) {
                collisionDetected = true;
                break collisionDetection;
            }
            if (mino.minoLocation.x == garbageMino.minoLocation.x
                && mino.minoLocation.y == garbageMino.minoLocation.y) {
                collisionDetected = true;
                break collisionDetection;
            }

        }
    }

    if (collisionDetected) {
        // can't rotate this piece at all
        return gameState;
    } else {
        // apply current rotation
        gameState.pieceState.pieceMinos = rotatedMinos;
        // actually set piece rotation to new one
        gameState.pieceState.pieceRotation = nextRotationState;
        return gameState;
    }

}

GameState getNewPiece(GameState gameState) {
    // check if new queue needed (5 pieces into latest bag)
    if (gameState.bagIndex % 7 == nextPieces) {
        gameState.pieceQueue = topUpQueue(gameState.pieceQueue);
    }

    PieceState newPieceState;
    newPieceState.pieceType = gameState.pieceQueue[0];
    // remove piece since it has been used
    gameState.pieceQueue.popFront();
    newPieceState.pieceMinos = generateInitialPieceMinos(newPieceState.pieceType);
    gameState.pieceState = newPieceState;
    gameState.bagIndex++;

    return gameState;
}

GameState processPiecePlacement(GameState gameState) {
    // turn the previous piece into garbage
    foreach (mino; gameState.pieceState.pieceMinos) {
        mino.minoIsGarbage = true;
        gameState.boardState.garbageMinos ~= mino;
    }

    gameState = getNewPiece(gameState);
    gameState.pieceJustHeld = false;

    // process any new line clears
    Mino[] postClearGarbageMinos = [];
    int[] clearedLines = [];
    // if line should be cleared, then sum(mino.x+1 for mino in minos[yindex]) will give some known result
    // can just check for that
    int requiredMinoXSum = 55; // sum(1..10) = 55
    for (int i = 0; i <= 22; i++) {
        int currentRowSum = 0;
        foreach (mino; gameState.boardState.garbageMinos) {
            if (mino.minoLocation.y == i) {
                currentRowSum += mino.minoLocation.x + 1;
            }
        }
        if (currentRowSum == requiredMinoXSum) {
            clearedLines ~= i;
        } else if (currentRowSum > requiredMinoXSum) {
            throw new Exception(format("how can the mino row sum be greater than 55...? got ",
                    currentRowSum));
        }
    }
    foreach (garbageMino; gameState.boardState.garbageMinos) {
        bool shouldBeCleared = false;
        int heightToFall = 0;
        foreach (j; clearedLines) {
            if (garbageMino.minoLocation.y == j) {
                shouldBeCleared = true;
            } else if (garbageMino.minoLocation.y > j) {
                heightToFall++;
            }
        }
        if (!shouldBeCleared) {
            garbageMino.minoLocation.y -= heightToFall;
            postClearGarbageMinos ~= garbageMino;
        }
    }
    gameState.boardState.garbageMinos = postClearGarbageMinos;

    return gameState;
}

GameState processGame(SettingsState settingsState, GameState gameState) {
    // undo exit flags etc.
    gameState.shouldExit = false;

    // update game time
    gameState.gameTimeElapsed = Clock.currStdTime() - gameState.gameStartTime;

    // process keypresses

    if (IsKeyPressed(settingsState.keymap.menuBack)) {
        gameState.shouldExit = true;
        return gameState;
    }

    if (IsKeyPressed(settingsState.keymap.hold)) {
        // hold piece if possible
        if (!gameState.pieceJustHeld) {
            // just held piece, can't hold again
            if (gameState.pieceHeld) {
                // swap held piece with current piece
                PieceType tmpPieceType = gameState.heldPiece;
                gameState.heldPiece = gameState.pieceState.pieceType;
                // generate new piece with held type
                PieceState pieceState;
                pieceState.pieceType = tmpPieceType;
                // gameState.pieceQueue.popFront();
                pieceState.pieceMinos = generateInitialPieceMinos(pieceState.pieceType);
                gameState.pieceState = pieceState;
            } else {
                // holding piece for first time, so need to also pop from queue etc.
                gameState.heldPiece = gameState.pieceState.pieceType;
                gameState = getNewPiece(gameState);
                gameState.pieceHeld = true;
            }
            gameState.pieceJustHeld = true;
        }
    }

    if (IsKeyPressed(settingsState.keymap.hardDrop)) {
        // hard drop piece
        // while piece would not collide, decrease Y
        while (!dropWouldCollide(gameState)) {
            gameState.pieceState = dropPiece(gameState.pieceState);
        }
        gameState = processPiecePlacement(gameState);
    }

    if (IsKeyPressed(settingsState.keymap.rotateRight)) {
        gameState = rotatePiece(gameState, true);
    }

    if (IsKeyPressed(settingsState.keymap.rotateLeft)) {
        gameState = rotatePiece(gameState, false);
    }

    if (IsKeyPressed(settingsState.keymap.rotate180)) {
        gameState = rotatePiece180(gameState);
    }

    if (IsKeyDown(settingsState.keymap.moveLeft)) {
        if (gameState.moveDirection != -1) {
            // reset when switching directions
            gameState.moveDirection = -1;
            gameState.dasTimer = 0;
            gameState.arrTimer = 0;
            gameState = attemptMove(gameState);
        }
    } else if (IsKeyDown(settingsState.keymap.moveRight)) {
        if (gameState.moveDirection != 1) {
            // reset when switching directions
            gameState.moveDirection = 1;
            gameState.dasTimer = 0;
            gameState.arrTimer = 0;
            gameState = attemptMove(gameState);
        }
    } else {
        gameState.moveDirection = 0;
        gameState.dasTimer = 0;
        gameState.arrTimer = 0;
    }

    if (IsKeyDown(settingsState.keymap.softDrop)) {
        if (!gameState.isSoftDropping) {
            gameState.isSoftDropping = true;
        }
    } else {
        gameState.isSoftDropping = false;
    }

    // update das/arr timers
    if (gameState.moveDirection != 0) {
        // key is held
        if (gameState.dasTimer < settingsState.handling.das) {
            gameState.dasTimer++;
        } else {
            if (settingsState.handling.arr == 0) {
                // handle 0 arr case separately
                // just brute force attempt 10 moves
                // will always just hit the wall
                for (int i = 0; i < 10; i++)
                    gameState = attemptMove(gameState);
            } else {
                if (gameState.arrTimer <= 0) {
                    gameState = attemptMove(gameState);
                    gameState.arrTimer = settingsState.handling.arr;
                } else {
                    gameState.arrTimer--;
                }
            }
        }
    }

    // apply downward piece motion due to sdf and gravity
    // if soft dropping, apply drop speed multiplier
    if (gameState.isSoftDropping) {
        // note - can set sdf to 0 which will disable sd
        if (settingsState.handling.sdf > 0) {
            if (settingsState.handling.sdf == 31) {
                // sdf=31 means sdf=inf
                while (!dropWouldCollide(gameState)) {
                    gameState.pieceState = dropPiece(gameState.pieceState);
                }
            } else {
                if (gameState.sdfTimer >= 2 / settingsState.handling.sdf) {
                    // method of sdf implementation: divide gravity frames by sdf
                    // to shorten piece falling time interval
                    if (!dropWouldCollide(gameState)) {
                        gameState.pieceState = dropPiece(gameState.pieceState);
                    } else {
                        // piece has collided, process piece touching ground/garbage
                    }
                    gameState.sdfTimer = 0;
                } else {
                    gameState.sdfTimer++;
                }
            }
        }
    } else {
        // apply gravity motion
        if (gameState.gravityTimer > gameState.gravityFrames) {
            if (!dropWouldCollide(gameState)) {
                gameState.pieceState = dropPiece(gameState.pieceState);
            }
            gameState.gravityTimer = 0;
        } else {
            gameState.gravityTimer++;
        }
    }

    drawBoard(settingsState);

    // note - should draw ghost first, so actual piece can overlap on top
    drawGhostPiece(gameState, settingsState);
    drawCurrentPiece(gameState, settingsState);

    drawGarbage(gameState, settingsState);
    drawNextPiece(gameState, settingsState);
    drawHoldPiece(gameState, settingsState);

    return gameState;
}
