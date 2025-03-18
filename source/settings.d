module settings;

import std.stdio;
import std.string;
import std.conv;
import std.math.rounding : round;

import raylib;

import constants;
import types;
import utils;

SettingsState initSettingsState() {
    SettingsState settingsState = SettingsState();
    settingsState.colorScheme = ColorScheme();
    settingsState.handling = Handling();
    settingsState.keymap = Keymap();

    string[] settingsTabStrings = ["Controls", "Handling", "Colors"];
    SettingsTab[] settingsTabTags = [
        SettingsTab.KEYMAP, SettingsTab.HANDLING, SettingsTab.COLORS
    ];
    SettingsTabButton[] settingsTabButtons = new SettingsTabButton[settingsTabStrings.length];

    foreach (i, tabString; settingsTabStrings) {
        int tabX = to!int((2 * i + 1) * settingsTabWidth + settingsTabBarX);
        settingsTabButtons[i] = SettingsTabButton(settingsTabTags[i], Coord(tabX,
                settingsTabBarY), settingsTabWidth, settingsTabHeight, tabString);
    }

    settingsState.settingsTabButtons = settingsTabButtons;

    return settingsState;
}

bool settingsTabHovered(SettingsTabButton settingsTabButton) {
    auto mousePos = GetMousePosition();
    // for tabs loc is top left corner
    if ((settingsTabButton.loc.x < mousePos.x)
        && ((settingsTabButton.loc.x + settingsTabWidth) > mousePos.x)
        && (settingsTabButton.loc.y < mousePos.y)
        && ((settingsTabButton.loc.y + settingsTabHeight) > mousePos.y)) {
        return true;
    }
    return false;
}

SettingsState setColor(SettingsState settingsStateTemp, int colorIndex, Color color) {
    // should refactor this in a perfect world but cba
    switch (colorIndex) {
    case 0:
        settingsStateTemp.colorScheme.good = color;
        break;
    case 1:
        settingsStateTemp.colorScheme.medium = color;
        break;
    case 2:
        settingsStateTemp.colorScheme.bad = color;
        break;
    case 3:
        settingsStateTemp.colorScheme.bg = color;
        break;
    case 4:
        settingsStateTemp.colorScheme.fg = color;
        break;
    case 5:
        settingsStateTemp.colorScheme.btnbg = color;
        break;
    case 6:
        settingsStateTemp.colorScheme.btnfg = color;
        break;
    case 7:
        settingsStateTemp.colorScheme.btnhover = color;
        break;
    case 8:
        settingsStateTemp.colorScheme.btnselect = color;
        break;
    case 9:
        settingsStateTemp.colorScheme.pieceI = color;
        break;
    case 10:
        settingsStateTemp.colorScheme.pieceJ = color;
        break;
    case 11:
        settingsStateTemp.colorScheme.pieceL = color;
        break;
    case 12:
        settingsStateTemp.colorScheme.pieceO = color;
        break;
    case 13:
        settingsStateTemp.colorScheme.pieceS = color;
        break;
    case 14:
        settingsStateTemp.colorScheme.pieceT = color;
        break;
    case 15:
        settingsStateTemp.colorScheme.pieceZ = color;
        break;
    default:
        break;
    }
    return settingsStateTemp;
}

SettingsState processSettings(SettingsState settingsState,
    SettingsState settingsStateTemp, string[Color] colorNameMapping) {
    SettingsTabButton[] settingsTabs = settingsState.settingsTabButtons;

    // make sure to zero out fields in temp state
    // because temp state is retained frame by frame
    settingsStateTemp.shouldExit = false;
    settingsStateTemp.switchTab = false;
    settingsStateTemp.saveColorScheme = false;
    settingsStateTemp.saveHandling = false;
    settingsStateTemp.saveKeymap = false;

    // if "menu back" key pressed,
    // exit from settings menu
    if (IsKeyPressed(settingsState.keymap.menuBack)) {
        settingsState.shouldExit = true;
        return settingsState;
    }

    // draw tab menu

    // if tab selected, then set tab to
    // whatever tab was selected
    // (need to know where tab rendered)

    // draw selected tab with different color

    // track state of settingsTabButton based on mouse click
    for (int i = 0; i < settingsTabs.length; i++) {
        auto settingsTab = settingsTabs[i];
        if (settingsTabHovered(settingsTab)) {
            settingsTab.hovered = true;
            if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                settingsTab.selected = true;
            } else {
                settingsTab.selected = false;
            }
            if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                settingsTab.justPressed = true;
            } else {
                settingsTab.justPressed = false;
            }
        } else {
            settingsTab.hovered = false;
            settingsTab.selected = false;
            settingsTab.justPressed = false;
        }
        settingsTabs[i] = settingsTab;
    }

    SettingsTab activeTabType = settingsState.tab;

    // mark as active if button was released
    foreach (settingsTab; settingsTabs) {
        if (settingsTab.justPressed) {
            activeTabType = settingsTab.tabType;
            settingsStateTemp.tab = settingsTab.tabType;
            settingsStateTemp.switchTab = true;
        }
    }

    // draw "settings" title

    drawTextCentered(toStringz("settings"), Coord(screenWidth >> 1,
            screenHeightMargin >> 1), titleFontSize >> 1, settingsState.colorScheme.medium);

    // draw line under all tabs to delineate from content
    DrawRectangle(settingsTabBarX, settingsTabBarY + settingsTabHeight,
        settingsTabFullWidth, settingsTabBorderWidth, settingsState.colorScheme.btnfg);

    // draw each tab as a rectangle

    foreach (tab; settingsTabs) {
        int tabX = tab.loc.x, tabY = tab.loc.y;
        Color tabBg;
        if (tab.selected) {
            tabBg = settingsState.colorScheme.btnselect;
        } else if (tab.hovered) {
            tabBg = settingsState.colorScheme.btnhover;
        } else {
            tabBg = settingsState.colorScheme.btnbg;
        }
        // if selected, then draw a rectangle around the tab
        // and overlay the bottom part with bg color
        // to give the illusion that the tab is selected
        if (activeTabType == tab.tabType) {
            DrawRectangle(tabX - settingsTabBorderWidth, tabY - settingsTabBorderWidth,
                tab.width + (2 * settingsTabBorderWidth),
                tab.height + (2 * settingsTabBorderWidth), settingsState.colorScheme.btnfg);
            DrawRectangle(tabX, tabY + settingsTabHeight, settingsTabWidth,
                settingsTabBorderWidth, tabBg);
        }
        DrawRectangle(tabX, tabY, tab.width, tab.height, tabBg);
        drawTextCentered(toStringz(tab.text), Coord(tabX + (tab.width >> 1),
                tabY + (tab.height >> 1)), settingsTabFontSize, settingsState.colorScheme.btnfg);

    }

    // used to determine whether something is hovered
    auto mousePos = GetMousePosition();

    // will process changes differently depending
    // on the settings tab that is currently open
    switch (activeTabType) {
    case SettingsTab.COLORS:

        // idea: similar to keymap on the left side,
        // and have 3 16-element sliders on the right
        // for selecting the color

        // ui method: hover over color box to select,
        // then use rotate left/right to select the slider,
        // and use move left/right to inc/dec the slider

        // ui will show current values of r, g, b for the selection,
        // and also show the hex digit for each of them
        // (there will be only one hex digit of course)

        // similar buttons on bottom of screen -
        // save, undo unsaved, reset to default

        // draw color boxes

        auto cs = settingsStateTemp.colorScheme;

        Color[] colors = [
            cs.good, cs.medium, cs.bad, cs.bg, cs.fg, cs.btnbg, cs.btnfg,
            cs.btnhover, cs.btnselect, cs.pieceI, cs.pieceJ, cs.pieceL,
            cs.pieceO, cs.pieceS, cs.pieceT, cs.pieceZ
        ];

        string[] colorNames = [
            "good", "medium", "bad", "bg 1", "fg 1", "bg 2", "fg 2", "bg 3",
            "bg 4", "piece I", "piece J", "piece L", "piece O", "piece S",
            "piece T", "piece Z"
        ];

        // can use this function call to set color when needed:
        // setColor(settingsStateTemp, colorIndex, color);

        // 16 colors, so can do 8 rows of 2

        const int rows = 4, cols = 4;

        const int colorBoxTopLeftX = screenWidthMargin + (screenWidthMargin >> 1);
        const int colorBoxTopLeftY = settingsTabBarY + settingsTabHeight + (screenWidthMargin >> 1);
        const int colorBoxMargin = screenWidthMargin >> 2;
        const int colorBoxTextWidth = (screenWidthMargin << 2) - (screenWidthMargin);
        const int colorBoxWidth = screenWidthMargin;
        const int colorBoxHeight = colorBoxWidth;
        const int colorBoxHighlightBorderWidth = settingsTabBorderWidth;

        const int colorBoxDescFontSize = titleFontSize >> 1;

        const int colorSliderAreaTopLeftX = colorBoxTopLeftX;
        const int colorSliderAreaTopLeftY = colorBoxTopLeftY + (rows + 2) * (
            colorBoxHeight + colorBoxMargin);
        const int colorSliderSeparatorWidth = settingsTabBorderWidth;

        // draw instructions text - centered X, and Y between boxes and separator
        string colorBoxInstructions = "hover over a square to change the associated color";
        int instructionsTextCenterX = screenWidth >> 1;
        int instructionsTextCenterY = colorSliderAreaTopLeftY - (colorBoxHeight + colorBoxMargin);
        drawTextCentered(toStringz(colorBoxInstructions), Coord(instructionsTextCenterX,
                instructionsTextCenterY), titleFontSize >> 1, settingsState.colorScheme.btnfg);

        string colorSliderInstructions = "use move left/right to select a slider, and rotate left/right to set it";
        int sliderInstructionsTextCenterX = screenWidth >> 1;
        int sliderInstructionsTextCenterY = colorSliderAreaTopLeftY - (
            (colorBoxHeight + colorBoxMargin) >> 1);

        bool someColorBoxSelected = false;
        int selectedColorIndex = -1;
        Color selectedColor = settingsState.colorScheme.bg;

        Color colorSliderItemColor = settingsState.colorScheme.btnhover;
        Color colorSliderTextColor = settingsState.colorScheme.btnhover;

        foreach (i, color; colors) {
            int row = to!int(i) / cols;
            int col = to!int(i) % cols;

            int topLeftX = colorBoxTopLeftX + ((colorBoxMargin << 1) + colorBoxTextWidth) * col;
            int topLeftY = colorBoxTopLeftY + ((colorBoxMargin << 1) + colorBoxHeight) * row;

            Color colorBoxBorderBG = settingsState.colorScheme.btnbg;
            if ((topLeftX < mousePos.x) && ((topLeftX + colorBoxWidth) > mousePos.x)
                && (topLeftY < mousePos.y) && ((topLeftY + colorBoxHeight) > mousePos.y)) {
                // mark hovered box as selected
                colorBoxBorderBG = settingsState.colorScheme.fg;

                someColorBoxSelected = true;
                selectedColorIndex = to!int(i);
                selectedColor = color;
            }

            DrawRectangle(topLeftX - colorBoxHighlightBorderWidth, topLeftY - colorBoxHighlightBorderWidth,
                colorBoxHeight + (colorBoxHighlightBorderWidth << 1),
                colorBoxHeight + (colorBoxHighlightBorderWidth << 1), colorBoxBorderBG);

            // draw actual color box, in relevant color
            DrawRectangle(topLeftX, topLeftY, colorBoxWidth, colorBoxHeight, color);

            // draw name of color
            int descTextXPos = topLeftX + colorBoxWidth + colorBoxMargin;
            int descTextYPos = topLeftY + (colorBoxHeight >> 2);
            DrawText(toStringz(colorNames[i]), descTextXPos, descTextYPos,
                colorBoxDescFontSize, settingsState.colorScheme.fg);
        }

        if (someColorBoxSelected) {
            // un-grey-out slider items and text
            colorSliderItemColor = settingsState.colorScheme.fg;
            colorSliderTextColor = settingsState.colorScheme.fg;
        }

        // draw slider items

        // draw instructions for how to use sliders
        drawTextCentered(toStringz(colorSliderInstructions), Coord(sliderInstructionsTextCenterX,
                sliderInstructionsTextCenterY), titleFontSize >> 1, colorSliderTextColor);

        // draw line to separate colors from sliders
        DrawRectangle(colorSliderAreaTopLeftX, colorSliderAreaTopLeftY,
            screenWidth - (colorBoxTopLeftX << 1), colorSliderSeparatorWidth,
            colorSliderItemColor);

        // if a color has been selected, then display its current r/g/b
        // values on the sliders

        // store slider type as int - 0 = r, 1 = g, 2 = b
        // default is red
        int sliderSelected = settingsStateTemp.colorSliderSelected;

        const int sliderMin = 0;
        const int sliderMax = 15;

        const int currentColorDisplayX = colorSliderAreaTopLeftX + (colorBoxMargin << 1);
        const int currentColorDisplayY = colorSliderAreaTopLeftY + (colorBoxMargin << 1);
        const int currentColorDisplayWidth = colorBoxWidth << 1;
        const int currentColorDisplayHeight = colorBoxHeight << 1;
        const int currentColorDisplayBorderWidth = settingsTabBorderWidth;

        const Color currentColorDisplayBorderColor = settingsState.colorScheme.btnbg;

        const int sliderWidth = colorBoxWidth << 2;
        const int sliderHeight = colorBoxHeight >> 1;
        const int sliderDescFontSize = titleFontSize >> 1;
        const int sliderValFontSize = titleFontSize >> 1;
        const int sliderHeightMargin = sliderHeight >> 1;
        const int sliderTotalHeight = sliderHeight + sliderHeightMargin;

        const int sliderTopLeftX = currentColorDisplayX + currentColorDisplayWidth + (
            colorBoxMargin << 2);
        const int sliderTopLeftY = currentColorDisplayY;

        const int sliderDescX = sliderTopLeftX + (colorBoxMargin << 1) + sliderWidth;

        const int colorNameCenterX = sliderDescX + (
            (screenWidth - sliderDescX - (screenWidthMargin << 1)) >> 1);
        const int colorNameCenterY = currentColorDisplayY + (currentColorDisplayHeight >> 1);
        const int colorNameFontSize = titleFontSize >> 1;

        if (someColorBoxSelected) {
            // first, check if slider has been modified by keypress
            // if so, use the modified value for more responsive feedback

            if (IsKeyPressed(settingsState.keymap.moveLeft)) {
                // move one slider left, mod 3
                sliderSelected = (sliderSelected + 1) % 3;
                settingsStateTemp.colorSliderSelected = sliderSelected;
            } else if (IsKeyPressed(settingsState.keymap.moveRight)) {
                // move one slider right, mod 3 (prevent negatives with +3)
                sliderSelected = (sliderSelected - 1 + 3) % 3;
                settingsStateTemp.colorSliderSelected = sliderSelected;
            }

            int r = selectedColor.r;
            int g = selectedColor.g;
            int b = selectedColor.b;

            int sliderChange = 0;
            if (IsKeyPressed(settingsState.keymap.rotateRight)) {
                // rotate right -> increase slider value
                sliderChange = 1;
            } else if (IsKeyPressed(settingsState.keymap.rotateLeft)) {
                // rotate left -> decrease slider value
                sliderChange = -1;
            }

            int x;
            switch (sliderSelected) {
            case 0: // r
                x = minVal(sliderMax, maxVal(sliderMin, ((r >> 4) + sliderChange))) << 4;
                r = x + (x >> 4);
                break;
            case 1: // g
                x = minVal(sliderMax, maxVal(sliderMin, ((g >> 4) + sliderChange))) << 4;
                g = x + (x >> 4);
                break;
            case 2: // b
                x = minVal(sliderMax, maxVal(sliderMin, ((b >> 4) + sliderChange))) << 4;
                b = x + (x >> 4);
                break;
            default:
                break;
            }

            Color currentColor = selectedColor;

            if (sliderChange != 0) {
                currentColor = Color(to!ubyte(r), to!ubyte(g), to!ubyte(b));
                settingsStateTemp = setColor(settingsStateTemp, selectedColorIndex, currentColor);
            }

            // draw big color box on left side

            // first draw border

            DrawRectangle(currentColorDisplayX - currentColorDisplayBorderWidth,
                currentColorDisplayY - currentColorDisplayBorderWidth,
                currentColorDisplayWidth + (currentColorDisplayBorderWidth << 1),
                currentColorDisplayHeight + (currentColorDisplayBorderWidth << 1),
                currentColorDisplayBorderColor);

            DrawRectangle(currentColorDisplayX, currentColorDisplayY,
                currentColorDisplayWidth, currentColorDisplayHeight, currentColor);

            // draw actual sliders

            // draw horizontally for best space usage

            string[] sliderNames = ["r", "g", "b"];
            int[] sliderVals = [r, g, b];

            foreach (i, sliderName; sliderNames) {
                const int thisSliderTopLeftY = sliderTopLeftY + (
                    to!int(i) * (sliderHeight + sliderHeightMargin));

                Color sliderBG = settingsState.colorScheme.btnhover;
                if (sliderSelected == i) {
                    sliderBG = settingsState.colorScheme.fg;
                }
                // draw center bar
                DrawRectangle(sliderTopLeftX, thisSliderTopLeftY + (sliderHeight >> 2) + (sliderHeight >> 3),
                    sliderWidth, sliderHeight >> 2, sliderBG);

                // draw slider name to the left of bar
                drawTextCentered(toStringz(sliderName), Coord(sliderTopLeftX - (colorBoxMargin << 1),
                        thisSliderTopLeftY + (sliderHeight >> 1)), sliderDescFontSize, sliderBG);

                // draw progress line
                int sliderValue = sliderVals[i];
                float sliderProgressPercent = to!float(sliderValue / 16) / to!float(sliderMax);
                // writefln("slider = %s, percent = %f, val = %d", sliderName, sliderProgressPercent, sliderValue);
                int sliderProgressX = to!int(sliderProgressPercent * sliderWidth);
                DrawRectangle(sliderTopLeftX + sliderProgressX,
                    thisSliderTopLeftY, sliderHeight >> 2, sliderHeight, sliderBG);

                // draw slider value to right of slider
                drawTextCentered(toStringz(intToHexCharString(sliderValue / 16)), Coord(sliderDescX,
                        thisSliderTopLeftY + (sliderHeight >> 1)), sliderDescFontSize, sliderBG);
            }

            // draw actual color name!
            // based on xkcd rgb color names
            string currentColorName = "";
            if (currentColor in colorNameMapping) {
                currentColorName = colorNameMapping[currentColor];
                // writefln("color selected = %s", currentColorName);
            } else {
                // writefln("could NOT find color %d, %d, %d", currentColor.r, currentColor.g, currentColor.b);
            }

            drawTextCentered(toStringz(currentColorName), Coord(colorNameCenterX,
                    colorNameCenterY), colorNameFontSize, colorSliderTextColor);

        } else {
            // if no color is selected -
            // still draw sliders etc. but make them greyed out & don't draw values

            // draw big color box on left side

            // first draw border

            DrawRectangle(currentColorDisplayX - currentColorDisplayBorderWidth,
                currentColorDisplayY - currentColorDisplayBorderWidth,
                currentColorDisplayWidth + (currentColorDisplayBorderWidth << 1),
                currentColorDisplayHeight + (currentColorDisplayBorderWidth << 1),
                currentColorDisplayBorderColor);

            // draw "current color" in bg color
            // because nothing is selected

            DrawRectangle(currentColorDisplayX, currentColorDisplayY, currentColorDisplayWidth,
                currentColorDisplayHeight, settingsState.colorScheme.bg);

            // draw actual sliders

            // draw horizontally for best space usage

            string[] sliderNames = ["r", "g", "b"];

            foreach (i, sliderName; sliderNames) {
                const int thisSliderTopLeftY = sliderTopLeftY + (
                    to!int(i) * (sliderHeight + sliderHeightMargin));

                Color sliderBG = settingsState.colorScheme.btnhover;
                // draw center bar
                DrawRectangle(sliderTopLeftX, thisSliderTopLeftY + (sliderHeight >> 2) + (sliderHeight >> 3),
                    sliderWidth, sliderHeight >> 2, sliderBG);
                // no need to draw progress line
            }

        }

        // draw save/undo unsaved/reset buttons

        // 3 action buttons - each 1/3 of the inner space (minus 2 * margin)
        const int innerHorizontalSpace = screenWidth - 2 * screenWidthMargin;
        const int colorSchemeActionButtonMargin = screenWidthMargin >> 1;
        const int colorSchemeActionButtonWidth = (innerHorizontalSpace - (screenWidthMargin)) / 3;
        const int colorSchemeActionButtonHeight = (colorSchemeActionButtonMargin << 1) - (
            colorSchemeActionButtonMargin >> 2);
        const int colorSchemeActionButtonsTopLeftX = screenWidthMargin;
        const int colorSchemeActionButtonsTopLeftY = currentColorDisplayY
            + currentColorDisplayHeight + colorBoxHeight;

        string[] colorSchemeActionButtonNames = [
            "save changes", "undo unsaved changes", "reset all to default"
        ];
        foreach (i, key; colorSchemeActionButtonNames) {
            int topLeftX = colorSchemeActionButtonsTopLeftX + to!int(i) * (
                colorSchemeActionButtonWidth + colorSchemeActionButtonMargin);
            int topLeftY = colorSchemeActionButtonsTopLeftY;

            // determine if any key is selected,
            // based on mouse pos
            // for tabs loc is top left corner
            Color colorSchemeActionButtonBG = settingsState.colorScheme.btnbg;
            if ((topLeftX < mousePos.x) && ((topLeftX + colorSchemeActionButtonWidth) > mousePos.x)
                && (topLeftY < mousePos.y)
                && ((topLeftY + colorSchemeActionButtonHeight) > mousePos.y)) {

                // hovered - set to hover color
                colorSchemeActionButtonBG = settingsState.colorScheme.btnhover;

                if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                    // selected - set to selected color
                    colorSchemeActionButtonBG = settingsState.colorScheme.btnselect;
                }

                // apply logic for button selection
                if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                    switch (key) {
                    case "save changes":
                        settingsStateTemp.saveColorScheme = true;
                        break;
                    case "undo unsaved changes":
                        settingsStateTemp.colorScheme = settingsState.colorScheme;
                        break;
                    case "reset all to default":
                        settingsStateTemp.colorScheme = ColorScheme();
                        break;
                    default:
                        break;
                    }
                }

            }
            DrawRectangle(topLeftX, topLeftY, colorSchemeActionButtonWidth,
                colorSchemeActionButtonHeight, colorSchemeActionButtonBG); // draw button text
            int actionTextXCenter = topLeftX + (colorSchemeActionButtonWidth >> 1);
            int actionTextYCenter = topLeftY + (colorSchemeActionButtonHeight >> 1);
            drawTextCentered(toStringz(to!string(key)), Coord(actionTextXCenter,
                    actionTextYCenter), sliderDescFontSize, settingsState.colorScheme.btnfg);
        }

        break;
    case SettingsTab.HANDLING: // create three sliders - arr, das, sdf

        string[] sliderNames = ["arr", "das", "sdf"];
        const int[][] sliderValues = [
            [5, 4, 3, 2, 1, 0],
            [
                20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2,
                1, 0
            ],
            [
                31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17,
                16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
            ]
        ];
        const int innerScreenWidth = screenWidth - (screenWidthMargin << 1);
        const int sliderHeight = screenWidthMargin;
        const int sliderWidth = screenWidthMargin << 3;
        const int sliderTotalHeight = sliderHeight + screenHeightMargin;

        const int sliderDescFontSize = titleFontSize >> 1;
        const int sliderValFontSize = titleFontSize >> 1;

        foreach (i, string key; sliderNames) {
            // idea: use "move left" and "move right"
            // to increment/decrement each slider

            int sliderValue;
            switch (key) {
            case "arr":
                sliderValue = settingsStateTemp.handling.arr;
                break;
            case "das":
                sliderValue = settingsStateTemp.handling.das;
                break;
            case "sdf":
                sliderValue = settingsStateTemp.handling.sdf;
                break;
            default:
                break;
            }

            const int sliderTopLeftX = settingsTabBarX + (screenWidthMargin << 2)
                - screenWidthMargin;
            const int sliderTopLeftY = settingsTabHeight + settingsTabBarY + (
                screenHeightMargin << 1) + sliderTotalHeight * to!int(i);
            Color sliderBG = settingsState.colorScheme.btnbg;
            if ((sliderTopLeftX < mousePos.x) && ((sliderTopLeftX + sliderWidth) > mousePos.x)
                && (sliderTopLeftY < mousePos.y) && ((sliderTopLeftY + sliderHeight) > mousePos.y)) {
                // selected - set to hover color
                sliderBG = settingsState.colorScheme.btnhover; // check for slider movement by user
                bool sliderValueUpdated = false;
                if (IsKeyPressed(settingsState.keymap.moveRight)) {
                    if (sliderValue < sliderValues[i][0]) {
                        sliderValue++;
                        sliderValueUpdated = true;
                    }
                } else if (IsKeyPressed(settingsState.keymap.moveLeft)) {
                    if (sliderValue > 0) {
                        sliderValue--;
                        sliderValueUpdated = true;
                    }
                }
                if (sliderValueUpdated) {
                    switch (key) {
                    case "arr":
                        settingsStateTemp.handling.arr = sliderValue;
                        break;
                    case "das":
                        settingsStateTemp.handling.das = sliderValue;
                        break;
                    case "sdf":
                        settingsStateTemp.handling.sdf = sliderValue;
                        break;
                    default:
                        break;
                    }
                }
            }

            // draw slider desc text
            const int descTextXPos = sliderTopLeftX - screenWidthMargin;
            const int descTextYPos = sliderTopLeftY + (sliderHeight >> 2);
            DrawText(toStringz(key), descTextXPos, descTextYPos,
                sliderDescFontSize, settingsState.colorScheme.btnfg); // draw slider val text
            const int valTextXPos = sliderTopLeftX + (
                screenWidthMargin >> 1) + sliderWidth + (screenWidthMargin >> 2);
            const int valTextYPos = sliderTopLeftY + (sliderHeight >> 2);
            string sliderValueText = to!string(sliderValue);
            if (key == "sdf" && sliderValue == 31) {
                sliderValueText = "inf";
            }
            DrawText(toStringz(sliderValueText), valTextXPos, valTextYPos,
                sliderValFontSize, settingsState.colorScheme.btnfg); // draw center line of slider
            DrawRectangle(sliderTopLeftX, sliderTopLeftY + (sliderHeight >> 2) + (sliderHeight >> 3), // account for slider progress bar overflow
                sliderWidth + (sliderHeight >> 2), sliderHeight >> 2, sliderBG); // draw vertical bar at current value of slider
            const int sliderProgressX = to!int(
                to!float(sliderValue) / to!float(sliderValues[i][0]) * sliderWidth);
            DrawRectangle(sliderTopLeftX + sliderProgressX, sliderTopLeftY,
                sliderHeight >> 2, sliderHeight, sliderBG);
        }

        // 3 action buttons - each 1/3 of the inner space (minus 2 * margin)
        const int innerHorizontalSpace = screenWidth - 2 * screenWidthMargin;
        const int handlingActionButtonMargin = screenWidthMargin >> 1;
        const int handlingActionButtonWidth = (innerHorizontalSpace - (screenWidthMargin)) / 3;
        const int handlingActionButtonHeight = (handlingActionButtonMargin << 1) - (
            handlingActionButtonMargin >> 2);
        const int handlingActionButtonsTopLeftX = screenWidthMargin;
        const int handlingActionButtonsTopLeftY = settingsTabBarY + settingsTabHeight + (
            screenHeightMargin << 1) + sliderTotalHeight * (to!int(sliderNames.length) + 1);

        string[] handlingActionButtonNames = [
            "save changes", "undo unsaved changes", "reset all to default"
        ];
        foreach (i, key; handlingActionButtonNames) {
            int topLeftX = handlingActionButtonsTopLeftX + to!int(i) * (
                handlingActionButtonWidth + handlingActionButtonMargin);
            int topLeftY = handlingActionButtonsTopLeftY;

            // determine if any key is selected,
            // based on mouse pos
            // for tabs loc is top left corner
            Color handlingActionButtonBG = settingsState.colorScheme.btnbg;
            if ((topLeftX < mousePos.x) && ((topLeftX + handlingActionButtonWidth) > mousePos.x)
                && (topLeftY < mousePos.y) && ((topLeftY + handlingActionButtonHeight) > mousePos.y)) {

                // hovered - set to hover color
                handlingActionButtonBG = settingsState.colorScheme.btnhover;

                if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                    // selected - set to selected color
                    handlingActionButtonBG = settingsState.colorScheme.btnselect;
                }

                // apply logic for button selection
                if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                    switch (key) {
                    case "save changes":
                        settingsStateTemp.saveHandling = true;
                        break;
                    case "undo unsaved changes":
                        settingsStateTemp.handling = settingsState.handling;
                        break;
                    case "reset all to default":
                        settingsStateTemp.handling = Handling();
                        break;
                    default:
                        break;
                    }
                }

            }
            DrawRectangle(topLeftX, topLeftY, handlingActionButtonWidth,
                handlingActionButtonHeight, handlingActionButtonBG); // draw button text
            int actionTextXCenter = topLeftX + (handlingActionButtonWidth >> 1);
            int actionTextYCenter = topLeftY + (handlingActionButtonHeight >> 1);
            drawTextCentered(toStringz(to!string(key)), Coord(actionTextXCenter,
                    actionTextYCenter), sliderDescFontSize, settingsState.colorScheme.btnfg);
        }

        // draw instructions text - centered X, and Y between actions and keys
        string handlingInstructions = "hover over a slider and use the \"move left/right\" keys to set it";
        int instructionsTextCenterX = screenWidth >> 1;
        int instructionsTextCenterY = settingsTabHeight + settingsTabBarY + screenHeightMargin;
        drawTextCentered(toStringz(handlingInstructions), Coord(instructionsTextCenterX,
                instructionsTextCenterY), titleFontSize >> 1, settingsState.colorScheme.btnfg);
        break;
    case SettingsTab.KEYMAP:

        // use temp keymap when showing keys
        Keymap km = settingsStateTemp.keymap;
        int[] keys = [
            km.moveLeft, km.moveRight, km.rotateLeft, km.rotateRight,
            km.rotate180, km.hardDrop, km.hold, km.restart, km.softDrop
        ];
        string[] keyNames = [
            "move left", "move right", "rotate left", "rotate right",
            "rotate 180", "hard drop", "hold", "restart", "soft drop"
        ]; // check: make sure keys are not duped
        bool[int] keyDuped;
        foreach (key; keys) {
            if (key in keyDuped) {
                keyDuped[key] = true;
            } else {
                keyDuped[key] = false;
            }

        }
        bool keyDupesFound = keyDuped.length < keys.length;
        const int itemsPerRow = 3;
        const int numRows = to!int(round(to!float(keys.length) / itemsPerRow));

        // key button width is at most 1/4 of text
        // and give an additional 1/8 (half button size)
        // as a margin between keys/text/etc.
        // total space to work with: width - 2 * margin

        const int innerScreenWidth = screenWidth - 2 * screenWidthMargin;

        // [ ] --- [ ] --- [ ] --- 
        // ^ key ^ text   ^ margin
        // total width = items/row * (key + text + 2 * margin)

        const int horizontalSpacePerItem = innerScreenWidth / itemsPerRow;

        // key = text/4; margin = text/8
        // thus, key = 2 * margin and text = 8 * margin
        // total is 2 + 8 + 2(1) = 12 * margin

        const int keyButtonWidthMargin = horizontalSpacePerItem / 12;
        const int keyButtonTextWidth = keyButtonWidthMargin << 3;
        const int keyButtonWidth = keyButtonTextWidth >> 2;
        // for height, just use same params as width
        // but double the width margin so it looks more balanced

        const int keyButtonHeight = keyButtonWidth;
        const int keyButtonHeightMargin = keyButtonWidthMargin << 1;

        const int verticalSpacePerItem = keyButtonHeight + keyButtonHeightMargin;

        const int keyButtonTopLeftX = settingsTabBarX + keyButtonWidthMargin;
        const int keyButtonTopLeftY = settingsTabBarY + settingsTabHeight + keyButtonHeightMargin;

        // just use title font size / 2
        const int keyButtonDescFontSize = titleFontSize >> 1;
        const int keyButtonFontSize = titleFontSize >> 1;

        // use same highlight border as for tabs
        const int keyButtonHighlightBorderWidth = settingsTabBorderWidth;

        foreach (i, key; keys) {
            // rows of 4 keys each. so:
            // formula for row: divide by 4
            // formula for col: mod 4
            int row = to!int(i) / 3;
            int col = to!int(i) % 3;
            int topLeftX = keyButtonTopLeftX + col * (
                keyButtonWidth + keyButtonWidthMargin * 2 + keyButtonTextWidth);
            int topLeftY = keyButtonTopLeftY + row * (keyButtonHeight + keyButtonHeightMargin); // if key is actually currently pressed, light up button
            // so that user can see what key int refers to
            // also light up if duped, but in "bad" color
            if (IsKeyDown(key) || keyDuped[key]) {
                int topLeftXHL = topLeftX - keyButtonHighlightBorderWidth;
                int topLeftYHL = topLeftY - keyButtonHighlightBorderWidth;
                Color borderColor = settingsState.colorScheme.btnfg;
                if (keyDuped[key]) {
                    borderColor = settingsState.colorScheme.bad;
                }
                DrawRectangle(topLeftXHL, topLeftYHL, keyButtonWidth + (keyButtonHighlightBorderWidth << 1),
                    keyButtonHeight + (keyButtonHighlightBorderWidth << 1), borderColor);
            }

            // determine if any key is selected,
            // based on mouse pos
            // for tabs loc is top left corner
            Color keyButtonBG = settingsState.colorScheme.btnbg;
            if ((topLeftX < mousePos.x) && ((topLeftX + keyButtonWidth) > mousePos.x)
                && (topLeftY < mousePos.y) && ((topLeftY + keyButtonHeight) > mousePos.y)) {
                // selected - set to hover color
                keyButtonBG = settingsState.colorScheme.btnhover;
                // also check if key is pressed - if so, replace key with
                // pressed key
                int keyPressed = GetKeyPressed();
                if (keyPressed > 0) {
                    switch (i) {
                    case 0:
                        settingsStateTemp.keymap.moveLeft = keyPressed;
                        break;
                    case 1:
                        settingsStateTemp.keymap.moveRight = keyPressed;
                        break;
                    case 2:
                        settingsStateTemp.keymap.rotateLeft = keyPressed;
                        break;
                    case 3:
                        settingsStateTemp.keymap.rotateRight = keyPressed;
                        break;
                    case 4:
                        settingsStateTemp.keymap.rotate180 = keyPressed;
                        break;
                    case 5:
                        settingsStateTemp.keymap.hardDrop = keyPressed;
                        break;
                    case 6:
                        settingsStateTemp.keymap.hold = keyPressed;
                        break;
                    case 7:
                        settingsStateTemp.keymap.restart = keyPressed;
                        break;
                    case 8:
                        settingsStateTemp.keymap.softDrop = keyPressed;
                        break;
                    default:
                        break;
                    }
                }
            }

            DrawRectangle(topLeftX, topLeftY, keyButtonWidth, keyButtonHeight, keyButtonBG); // draw associated text next to key button
            int descTextXPos = topLeftX + keyButtonWidth + keyButtonWidthMargin;
            int descTextYPos = topLeftY + (keyButtonHeight >> 2);
            DrawText(toStringz(keyNames[i]), descTextXPos, descTextYPos,
                keyButtonDescFontSize, settingsState.colorScheme.btnfg); // draw current value of key (just use the int for now)
            int keyTextXCenter = topLeftX + (keyButtonWidth >> 1);
            int keyTextYCenter = topLeftY + (keyButtonHeight >> 1);
            drawTextCentered(toStringz(to!string(key)), Coord(keyTextXCenter,
                    keyTextYCenter), keyButtonFontSize, settingsState.colorScheme.btnfg);
        }

        // draw save and reset buttons

        // just draw them in the last row beneath the key buttons
        // and make them as wide as button + margin + text

        const int keyActionButtonsTopLeftX = keyButtonTopLeftX;
        const int keyActionButtonsTopLeftY = keyButtonTopLeftY + (numRows + 1)
            * verticalSpacePerItem;
        const int keyActionButtonWidth = horizontalSpacePerItem - keyButtonWidthMargin;
        const int keyActionButtonHeight = keyButtonHeight;

        string[] keyActionButtonNames = [
            "save changes", "undo unsaved changes", "reset all to default"
        ];
        foreach (i, key; keyActionButtonNames) {
            int topLeftX = keyActionButtonsTopLeftX + to!int(i) * (
                keyActionButtonWidth + keyButtonWidthMargin);
            int topLeftY = keyActionButtonsTopLeftY;

            // determine if any key is selected,
            // based on mouse pos
            // for tabs loc is top left corner
            Color keyActionButtonBG = settingsState.colorScheme.btnbg;
            if ((topLeftX < mousePos.x) && ((topLeftX + keyActionButtonWidth) > mousePos.x)
                && (topLeftY < mousePos.y) && ((topLeftY + keyActionButtonHeight) > mousePos.y)) {

                // hovered - set to hover color
                keyActionButtonBG = settingsState.colorScheme.btnhover;

                if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                    // selected - set to selected color
                    keyActionButtonBG = settingsState.colorScheme.btnselect;
                }

                // apply logic for button selection
                if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                    switch (key) {
                    case "save changes":
                        // only permit saving if no dupes
                        if (!keyDupesFound) {
                            settingsStateTemp.saveKeymap = true;
                        }
                        break;
                    case "undo unsaved changes":
                        settingsStateTemp.keymap = settingsState.keymap;
                        break;
                    case "reset all to default":
                        settingsStateTemp.keymap = Keymap();
                        break;
                    default:
                        break;
                    }
                }

            }

            // if key dupes found do NOT permit saving keybinds; mark as bad
            if (keyDupesFound && (key == "save changes")) {
                keyActionButtonBG = settingsState.colorScheme.bad;
            }

            DrawRectangle(topLeftX, topLeftY, keyActionButtonWidth,
                keyActionButtonHeight, keyActionButtonBG); // draw button text
            int actionTextXCenter = topLeftX + (keyActionButtonWidth >> 1);
            int actionTextYCenter = topLeftY + (keyActionButtonHeight >> 1);
            drawTextCentered(toStringz(to!string(key)), Coord(actionTextXCenter,
                    actionTextYCenter), keyButtonFontSize, settingsState.colorScheme.btnfg);
        }

        // draw instructions text - centered X, and Y between actions and keys
        string keymapInstructions = "hover over a square and press a key to set it to the pressed key";
        int instructionsTextCenterX = screenWidth >> 1;
        int instructionsTextCenterY = keyActionButtonsTopLeftY - (
            keyButtonWidth + keyButtonWidthMargin);
        drawTextCentered(toStringz(keymapInstructions), Coord(instructionsTextCenterX,
                instructionsTextCenterY), titleFontSize >> 1, settingsState.colorScheme.btnfg); // draw error text - centered X, and Y below actions
        if (keyDupesFound) {
            string errorMessage = "cannot save with duped key(s) selected";
            int errorTextCenterX = screenWidth >> 1;
            int errorTextCenterY = keyButtonTopLeftY + (numRows + 2) * verticalSpacePerItem;
            drawTextCentered(toStringz(errorMessage), Coord(errorTextCenterX,
                    errorTextCenterY), titleFontSize >> 1, settingsState.colorScheme.bad);
        }

        break;
    default:
        break;
    }

    return settingsStateTemp;
}
