module menu;

import std.string;

import raylib;

import constants;
import types;
import utils;

MenuState initMenuState() {
    MenuState menuState;

    // initialize menuitem array
    string[] menuItemStrings = ["Sprint", "Blitz", "Settings", "Quit"];
    MenuItem[] menuItems = new MenuItem[menuItemStrings.length];

    // use menuitem array length to determine true locations of menu items
    for (int i = 0; i < menuItems.length; i++) {
        menuItems[i] = MenuItem(Coord(screenCenter.x, screenCenter.y + i * (padding + menuItemHeight)),
            menuItemWidth, menuItemHeight, menuItemStrings[i]);
    }

    menuState.menuItems = menuItems;

    return menuState;
}

bool menuItemHovered(MenuItem menuItem) {
    auto mousePos = GetMousePosition();
    // center.x - width/2 < mousePos.x < center.x + width/2
    // center.y - height/2 < mousePos.y < center.y + height/2
    if (((menuItem.loc.x - (menuItemWidth >> 1)) < mousePos.x)
        && ((menuItem.loc.x + (menuItemWidth >> 1)) > mousePos.x)
        && ((menuItem.loc.y - (menuItemHeight >> 1)) < mousePos.y)
        && ((menuItem.loc.y + (menuItemHeight >> 1)) > mousePos.y)) {
        return true;
    }
    return false;
}

MenuState processMenu(MenuState menuState, ColorScheme cs) {
    // reset flags to false
    menuState.shouldClose = false;
    menuState.openSprint = false;
    menuState.openBlitz = false;
    menuState.openSettings = false;

    MenuItem[] menuItems = menuState.menuItems;

    MenuState stateToReturn = menuState;

    // track state of menuItem based on mouse click
    for (int i = 0; i < menuItems.length; i++) {
        auto menuItem = menuItems[i];
        if (menuItemHovered(menuItem)) {
            menuItem.hovered = true;
            if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                menuItem.selected = true;
            } else {
                menuItem.selected = false;
            }
            if (IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_LEFT)) {
                menuItem.justPressed = true;
            } else {
                menuItem.justPressed = false;
            }
        } else {
            menuItem.hovered = false;
            menuItem.selected = false;
            menuItem.justPressed = false;
        }
        menuItems[i] = menuItem;
    }

    // perform action if button was released
    foreach (menuItem; menuItems) {
        if (menuItem.justPressed) {
            switch (menuItem.text) {
            case "Quit":
                // quit the game - close the window etc.
                stateToReturn.shouldClose = true;
                return stateToReturn;
            case "Sprint":
                stateToReturn.openSprint = true;
                return stateToReturn;
            case "Blitz":
                stateToReturn.openBlitz = true;
                return stateToReturn;
            case "Settings":
                stateToReturn.openSettings = true;
                return stateToReturn;
            default:
                break;
            }
        }
    }

    // draw

    // draw title: 
    // just text at 25% Y & 50% X
    drawTextCentered(toStringz(gameTitle), Coord(screenCenter.x,
            screenCenter.y >> 1), titleFontSize, cs.medium);

    // draw menu items:
    // for each menu item, draw the rectangle
    // and then draw the text on top
    foreach (menuItem; menuItems) {
        Color btnBgColor;
        if (menuItem.selected) {
            btnBgColor = cs.btnselect;
        } else if (menuItem.hovered) {
            btnBgColor = cs.btnhover;
        } else {
            btnBgColor = cs.btnbg;
        }
        DrawRectangle(menuItem.loc.x - (menuItemWidth >> 1),
            menuItem.loc.y - (menuItemHeight >> 1), menuItemWidth, menuItemHeight, btnBgColor);

        drawTextCentered(toStringz(menuItem.text), menuItem.loc, menuLabelFontSize, cs.btnfg);
    }

    return stateToReturn;
}
