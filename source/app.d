import std.stdio;
import std.conv : to;
import std.string;
import std.math.rounding : round;

import raylib;

import constants;
import types;
import utils;
import settings;
import menu;
import game;

void main() {
    SetTraceLogLevel(TraceLogLevel.LOG_ERROR); // Only show errors
    InitWindow(screenWidth, screenHeight, toStringz(gameTitle));
    SetTargetFPS(fps);
    // don't use a single key to exit
    // use Esc key to move back in menus (by default)
    SetExitKey(-1);

    string[Color] colorNameMapping = getColorNameMapping("data/colornames.json");

    GameState gameState;

    MenuState menuState = initMenuState();

    SettingsState settingsState = initSettingsState();

    SettingsState settingsStateTemp = settingsState;

    Scene currentScene = Scene.MENU;

    bool shouldExit = false;

    while (!shouldExit && !WindowShouldClose()) {

        BeginDrawing();
        ClearBackground(settingsState.colorScheme.bg);

        // debug: track scene
        const(char)* SceneString = toStringz(format("Scene: %s", currentScene));
        DrawText(SceneString, 0, 0, 20, settingsState.colorScheme.fg);
        // track version
        const(char)* VersionString = toStringz("v0.0.1");
        DrawText(VersionString, 0, screenHeight - 20, 20, settingsState.colorScheme.fg);
        // draw fps counter
        const(char)* FPSString = toStringz("FPS: " ~ to!string(GetFPS()));
        DrawText(FPSString, screenWidth - 110, screenHeight - 20, 20,
            settingsState.colorScheme.fg);

        switch (currentScene) {
        case Scene.MENU:
            menuState = processMenu(menuState, settingsState.colorScheme);
            if (menuState.shouldClose) {
                shouldExit = true;
            }
            if (menuState.openSprint) {
                currentScene = Scene.SPRINT;
                gameState = initGameState(GameType.SPRINT);
            }
            if (menuState.openBlitz) {
                currentScene = Scene.BLITZ;
                gameState = initGameState(GameType.BLITZ);
            }
            if (menuState.openSettings) {
                currentScene = Scene.SETTINGS;
            }
            break;
        case Scene.SETTINGS:
            settingsStateTemp = processSettings(settingsState,
                settingsStateTemp, colorNameMapping);
            if (settingsStateTemp.shouldExit) {
                currentScene = Scene.MENU;
            }
            // switch tab if needed
            if (settingsStateTemp.switchTab) {
                settingsState.tab = settingsStateTemp.tab;
            }
            // if update requested, update relevant settings
            if (settingsStateTemp.saveColorScheme) {
                settingsState.colorScheme = settingsStateTemp.colorScheme;
            }
            if (settingsStateTemp.saveHandling) {
                settingsState.handling = settingsStateTemp.handling;
            }
            if (settingsStateTemp.saveKeymap) {
                settingsState.keymap = settingsStateTemp.keymap;
            }
            break;
        case Scene.SPRINT, Scene.BLITZ:
            gameState = processGame(settingsState, gameState);
            if (gameState.shouldExit) {
                currentScene = Scene.MENU;
            }
            break;
        default:
            throw new Exception(format("Unknown Scene: %s", currentScene));
            break;
        }

        EndDrawing();
    }

    CloseWindow();
}
