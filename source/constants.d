module constants;

import std.conv;

import types;

const string gameTitle = "dtris";
const int titleFontSize = 40;

const int fps = 60;

const int screenWidth = 1000;
const int screenHeight = 1000;
const Coord screenCenter = Coord(screenWidth / 2, screenHeight / 2);

const int menuLabelFontSize = 20;
const int menuItemWidth = screenWidth >> 2;
const int menuItemHeight = screenHeight >> 4;
const int padding = menuItemHeight >> 3;

// screen margin on all sides is 1/16
const int screenWidthMargin = screenWidth >> 4;
const int screenHeightMargin = screenHeight >> 4;

// assume 3 different settings tabs, so
// 5 = 3 + 2 total horizontal units
// for the tab bar on top
const int numTabBarUnits = 3 + (3 + 1);
const int settingsTabFullWidth = screenWidth - (screenWidthMargin << 1);
const int settingsTabWidth = settingsTabFullWidth / numTabBarUnits;
// writefln("tab width, screen width, screen width margin: %d, %d, %d", tabWidth, screenWidth, screenWidthMargin);
const int settingsTabHeight = (screenHeight - (screenHeightMargin << 1)) >> 4;
const int settingsTabBarY = screenHeightMargin;
const int settingsTabBarX = screenWidthMargin;
const int settingsTabFontSize = titleFontSize >> 1;
const int settingsTabBorderWidth = settingsTabWidth >> 5;

// limiting factor is screen height
// need to have margins on top and bottom of screenMargin
// force to closest multiple of 22 with div and mult by 22
// we need 22 so that we can draw the pieces as they spawn
const int boardHeight = ((screenHeight - (screenHeightMargin << 1)) / 22) * 22;
const int minoHeight = boardHeight / 22;
const int minoWidth = minoHeight;
const int boardWidth = 10 * minoWidth;
const int boardTopLeftX = (screenWidth >> 1) - (boardWidth >> 1);
const int boardDrawnHeight = boardHeight - (minoHeight << 1);
const int boardTopLeftY = screenHeightMargin + boardHeight - boardDrawnHeight;
const int boardBottomLeftY = boardTopLeftY + boardDrawnHeight;

// for minos in next queue (and also hold piece)
const float nextMinoScale = 0.5;
const int nextMinoHeight = to!int(minoHeight * nextMinoScale);
const int nextMinoWidth = to!int(minoWidth * nextMinoScale);
const int nextMinoMargin = nextMinoHeight >> 1;
const int nextQueueLeftX = boardTopLeftX + boardWidth + (screenWidthMargin >> 2);

// ghost piece constants
const int ghostPieceBorder = minoWidth >> 3;

const int boardBorder = minoWidth >> 3;

const int gridLineWidth = 2;

const int nextPieces = 5;
// half a second from the tetris guideline
const int lockDelayFrames = 30;
// just say that gravity takes 2 frames to kick in
const int gravityFrames = fps << 1;

// piece configurations

const PieceRotation[PieceRotationMotion] pieceRotationMap = [
    PieceRotationMotion(PieceRotation.Z, false): PieceRotation.L,
    PieceRotationMotion(PieceRotation.Z, true): PieceRotation.R,
    PieceRotationMotion(PieceRotation.R, false): PieceRotation.Z,
    PieceRotationMotion(PieceRotation.R, true): PieceRotation.T,
    PieceRotationMotion(PieceRotation.L, false): PieceRotation.T,
    PieceRotationMotion(PieceRotation.L, true): PieceRotation.Z,
    PieceRotationMotion(PieceRotation.T, false): PieceRotation.R,
    PieceRotationMotion(PieceRotation.T, true): PieceRotation.L,
];

const PieceRotation[PieceRotation] pieceRotationMap180 = [
    PieceRotation.Z: PieceRotation.T, PieceRotation.T: PieceRotation.Z,
    PieceRotation.R: PieceRotation.L, PieceRotation.L: PieceRotation.R,
];

// actual piece rotations
// map Z -> R, Z -> L, etc. for each piece
// and each mino of each piece
// doesn't include O as it doesn't move
const byte[][][PieceOrientation] rotatedMinoOffsets = [
    PieceOrientation(PieceType.I, PieceRotation.Z): [
        [-2, 1], [-1, 1], [0, 1], [1, 1]
    ],
    PieceOrientation(PieceType.I, PieceRotation.R): [
        [0, 2], [0, 1], [0, 0], [0, -1]
    ],
    PieceOrientation(PieceType.I, PieceRotation.T): [
        [1, 0], [0, 0], [-1, 0], [-2, 0]
    ],
    PieceOrientation(PieceType.I, PieceRotation.L): [
        [-1, -1], [-1, 0], [-1, 1], [-1, 2]
    ],
    PieceOrientation(PieceType.J, PieceRotation.Z): [
        [-1, 1], [-1, 0], [0, 0], [1, 0]
    ],
    PieceOrientation(PieceType.J, PieceRotation.R): [
        [1, 1], [0, 1], [0, 0], [0, -1]
    ],
    PieceOrientation(PieceType.J, PieceRotation.T): [
        [1, -1], [1, 0], [0, 0], [-1, 0]
    ],
    PieceOrientation(PieceType.J, PieceRotation.L): [
        [-1, -1], [0, -1], [0, 0], [0, 1]
    ],
    PieceOrientation(PieceType.L, PieceRotation.Z): [
        [1, 1], [1, 0], [0, 0], [-1, 0]
    ],
    PieceOrientation(PieceType.L, PieceRotation.R): [
        [1, -1], [0, -1], [0, 0], [0, 1]
    ],
    PieceOrientation(PieceType.L, PieceRotation.T): [
        [-1, -1], [-1, 0], [0, 0], [1, 0]
    ],
    PieceOrientation(PieceType.L, PieceRotation.L): [
        [-1, 1], [0, 1], [0, 0], [0, -1]
    ],
    PieceOrientation(PieceType.S, PieceRotation.Z): [
        [1, 1], [0, 1], [0, 0], [-1, 0]
    ],
    PieceOrientation(PieceType.S, PieceRotation.R): [
        [1, -1], [1, 0], [0, 0], [0, 1]
    ],
    PieceOrientation(PieceType.S, PieceRotation.T): [
        [-1, -1], [0, -1], [0, 0], [1, 0]
    ],
    PieceOrientation(PieceType.S, PieceRotation.L): [
        [-1, 1], [-1, 0], [0, 0], [0, -1]
    ],
    PieceOrientation(PieceType.Z, PieceRotation.Z): [
        [-1, 1], [0, 1], [0, 0], [1, 0]
    ],
    PieceOrientation(PieceType.Z, PieceRotation.R): [
        [1, 1], [1, 0], [0, 0], [0, -1]
    ],
    PieceOrientation(PieceType.Z, PieceRotation.T): [
        [1, -1], [0, -1], [0, 0], [-1, 0]
    ],
    PieceOrientation(PieceType.Z, PieceRotation.L): [
        [-1, -1], [-1, 0], [0, 0], [0, 1]
    ],
    PieceOrientation(PieceType.T, PieceRotation.Z): [
        [-1, 0], [0, 0], [1, 0], [0, 1]
    ],
    PieceOrientation(PieceType.T, PieceRotation.R): [
        [0, 1], [0, 0], [0, -1], [1, 0]
    ],
    PieceOrientation(PieceType.T, PieceRotation.T): [
        [1, 0], [0, 0], [-1, 0], [0, -1]
    ],
    PieceOrientation(PieceType.T, PieceRotation.L): [
        [0, -1], [0, 0], [0, 1], [-1, 0]
    ],
];

// rotation tests, in order
// use offsets when specifying the tests
// each offset is x diff, y diff
// where x and y are the usual x and y, so y is down to up
// not inverted (so, like the typical 2d graph)
// offsets courtesy of hard drop wiki https://harddrop.com/wiki/SRS
// will just need to subtract these on the Y side instead of adding
// when drawing the actual graphics
const byte[][][PieceRotationMovement] pieceRotationTests = [
    PieceRotationMovement(PieceType.J, PieceRotation.Z, true): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.J, PieceRotation.Z, false): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.J, PieceRotation.R, true): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.J, PieceRotation.R, false): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.J, PieceRotation.T, true): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.J, PieceRotation.T, false): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.J, PieceRotation.L, true): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],
    PieceRotationMovement(PieceType.J, PieceRotation.L, false): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],

    PieceRotationMovement(PieceType.L, PieceRotation.Z, true): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.L, PieceRotation.Z, false): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.L, PieceRotation.R, true): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.L, PieceRotation.R, false): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.L, PieceRotation.T, true): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.L, PieceRotation.T, false): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.L, PieceRotation.L, true): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],
    PieceRotationMovement(PieceType.L, PieceRotation.L, false): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],

    PieceRotationMovement(PieceType.S, PieceRotation.Z, true): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.S, PieceRotation.Z, false): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.S, PieceRotation.R, true): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.S, PieceRotation.R, false): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.S, PieceRotation.T, true): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.S, PieceRotation.T, false): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.S, PieceRotation.L, true): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],
    PieceRotationMovement(PieceType.S, PieceRotation.L, false): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],

    PieceRotationMovement(PieceType.T, PieceRotation.Z, true): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.T, PieceRotation.Z, false): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.T, PieceRotation.R, true): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.T, PieceRotation.R, false): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.T, PieceRotation.T, true): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.T, PieceRotation.T, false): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.T, PieceRotation.L, true): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],
    PieceRotationMovement(PieceType.T, PieceRotation.L, false): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],

    PieceRotationMovement(PieceType.Z, PieceRotation.Z, true): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.Z, PieceRotation.Z, false): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.Z, PieceRotation.R, true): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.Z, PieceRotation.R, false): [
        [0, 0], [+1, 0], [+1, -1], [0, +2], [+1, +2]
    ],
    PieceRotationMovement(PieceType.Z, PieceRotation.T, true): [
        [0, 0], [+1, 0], [+1, +1], [0, -2], [+1, -2]
    ],
    PieceRotationMovement(PieceType.Z, PieceRotation.T, false): [
        [0, 0], [-1, 0], [-1, +1], [0, -2], [-1, -2]
    ],
    PieceRotationMovement(PieceType.Z, PieceRotation.L, true): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],
    PieceRotationMovement(PieceType.Z, PieceRotation.L, false): [
        [0, 0], [-1, 0], [-1, -1], [0, +2], [-1, +2]
    ],

    PieceRotationMovement(PieceType.I, PieceRotation.Z, true): [
        [0, 0], [-2, 0], [+1, 0], [-2, -1], [+1, +2]
    ],
    PieceRotationMovement(PieceType.I, PieceRotation.Z, false): [
        [0, 0], [-1, 0], [+2, 0], [-1, +2], [+2, -1]
    ],
    PieceRotationMovement(PieceType.I, PieceRotation.R, true): [
        [0, 0], [-1, 0], [+2, 0], [-1, +2], [+2, -1]
    ],
    PieceRotationMovement(PieceType.I, PieceRotation.R, false): [
        [0, 0], [+2, 0], [-1, 0], [+2, +1], [-1, -2]
    ],
    PieceRotationMovement(PieceType.I, PieceRotation.T, true): [
        [0, 0], [+2, 0], [-1, 0], [+2, +1], [-1, -2]
    ],
    PieceRotationMovement(PieceType.I, PieceRotation.T, false): [
        [0, 0], [+1, 0], [-2, 0], [+1, -2], [-2, +1]
    ],
    PieceRotationMovement(PieceType.I, PieceRotation.L, true): [
        [0, 0], [+1, 0], [-2, 0], [+1, -2], [-2, +1]
    ],
    PieceRotationMovement(PieceType.I, PieceRotation.L, false): [
        [0, 0], [-2, 0], [+1, 0], [-2, -1], [+1, +2]
    ],
];
