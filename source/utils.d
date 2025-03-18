module utils;

import std.stdio;
import std.conv;
import std.json;
import std.file;

import raylib;

import types;

string intToHexCharString(int val) {
    if (0 <= val && val < 10) {
        return to!string(val);
    }
    switch (val) {
    case 10:
        return "A";
    case 11:
        return "B";
    case 12:
        return "C";
    case 13:
        return "D";
    case 14:
        return "E";
    case 15:
        return "F";
    default:
        return "X";
    }
}

int minVal(int a, int b) {
    return a > b ? b : a;
}

int maxVal(int a, int b) {
    return a > b ? a : b;
}

void drawTextCentered(const(char)* text, Coord loc, int size, Color c) {
    int spacing = 2;
    auto font = GetFontDefault();
    auto textDim = MeasureTextEx(font, text, to!float(size), to!float(spacing));
    DrawText(text, loc.x - to!int(textDim.x / 2), loc.y - to!int(textDim.y / 2), size, c);
}

string[Color] getColorNameMapping(string mappingFilePath) {
    // get color name <-> rgb color mapping
    // from json file
    string colorNameJsonString = cast(string) read(mappingFilePath);
    JSONValue colorNameJson = parseJSON(colorNameJsonString);
    if (!colorNameJson.type == JSONType.object) {
        writeln("Invalid JSON format.");
    }
    string[Color] colorNameMapping;
    foreach (name, color; colorNameJson.object) {
        // writeln("Color: ", color, " => Name: ", name.str);
        JSONValue[] rgbArrs = color.array;
        foreach (rgbArrVal; rgbArrs) {
            auto rgbArr = rgbArrVal.array;
            Color nameColor = Color(to!ubyte(rgbArr[0].integer),
                to!ubyte(rgbArr[1].integer), to!ubyte(rgbArr[2].integer));
            colorNameMapping[nameColor] = name;
        }
    }
    return colorNameMapping;
}
