module types;

import raylib;

struct Coord {
    int x, y;
}

enum Scene {
    MENU,
    SETTINGS,
    SPRINT,
    BLITZ
}

enum GameType {
    SPRINT,
    BLITZ
}

enum PieceType {
    I,
    J,
    L,
    O,
    S,
    Z,
    T
}

// rotations: zero (initial), right, left, or two
enum PieceRotation {
    Z,
    R,
    L,
    T
}

struct PieceOrientation {
    PieceType pieceType;
    PieceRotation pieceRotation;
}

struct PieceRotationMotion {
    PieceRotation pieceRotation;
    bool clockwise;
}

struct PieceRotationMovement {
    PieceType pieceType;
    PieceRotation pieceRotation;
    bool clockwise;
}

struct Mino {
    PieceType minoType;
    // x is col 0..9 and y is row 0..22
    Coord minoLocation;
    bool minoIsGarbage;
}

struct BoardState {
    // store garbage locations here - coords of each garbage piece
    Mino[] garbageMinos;
}

struct PieceState {
    // store state of current piece here
    // current rotation
    PieceRotation pieceRotation = PieceRotation.Z;
    // piece type (enum)
    PieceType pieceType;
    // piece mino locations
    Mino[] pieceMinos;
}

struct GameState {
    long gameStartTime;
    long gameTimeElapsed = 0;

    bool shouldExit = false;
    GameType gameType;
    // current garbage locations
    BoardState boardState;
    // current piece state
    PieceState pieceState;

    // if relevant (touching piece/board on bottom of a mino), frames since lock delay kicked in
    int framesSinceGroundTouched = 0;

    // amount of time (in frames) since das/arr started
    int dasTimer = 0;
    int arrTimer = 0;
    // left = -1, right = 1, none = 0
    int moveDirection = 0;

    // keep track of soft drop motion
    bool isSoftDropping = false;
    int sdfTimer = 0;

    // other game-related info
    int gameTime;
    int gameScore;
    int gameLevel;

    // used for determining when to generate new bag
    int bagIndex;

    // start with gravity = 2 * fps - set that in init function of game state
    int gravityFrames;
    // keep track of time since gravity drop
    int gravityTimer = 0;

    // store held piece
    PieceType heldPiece;
    bool pieceHeld = false;
    bool pieceJustHeld = false;
    // keep track of pieces yet to come
    PieceType[] pieceQueue;
}

struct MenuItem {
    Coord loc;
    int width;
    int height;
    string text;
    // mouse is hovering over button
    bool hovered = false;
    // mouse is down and hovering on button
    bool selected = false;
    // mouse is not down but was on prev frame,
    // and is still hovering
    bool justPressed = false;
}

struct MenuState {
    bool shouldClose = false;
    bool openSprint = false;
    bool openBlitz = false;
    bool openSettings = false;

    MenuItem[] menuItems;
}

enum SettingsTab {
    KEYMAP,
    HANDLING,
    COLORS
}

struct SettingsState {
    // whether to go back to menus
    bool shouldExit = false;

    // which tab in settings the user is on
    // default to showing keymap
    bool switchTab = false;
    SettingsTab tab = SettingsTab.KEYMAP;

    SettingsTabButton[] settingsTabButtons;

    // used to pass updated settings
    // back to main loop
    bool saveHandling = false;
    Handling handling;
    bool saveColorScheme = false;
    ColorScheme colorScheme;
    bool saveKeymap = false;
    Keymap keymap;

    // used to keep track of currently selected color slider
    // default is "red" (0, 1, 2 <=> r, g, b)
    int colorSliderSelected = 0;
}

struct SettingsTabButton {
    SettingsTab tabType;
    Coord loc;
    int width;
    int height;
    string text;
    // mouse is hovering over button
    bool hovered = false;
    // mouse is down and hovering on button
    bool selected = false;
    // mouse is not down but was on prev frame,
    // and is still hovering
    bool justPressed = false;
}

// default keymap
struct Keymap {
    // game controls
    int moveLeft = KeyboardKey.KEY_LEFT;
    int moveRight = KeyboardKey.KEY_RIGHT;
    int rotateLeft = KeyboardKey.KEY_Z;
    int rotateRight = KeyboardKey.KEY_X;
    int rotate180 = KeyboardKey.KEY_A;
    int softDrop = KeyboardKey.KEY_DOWN;
    int hardDrop = KeyboardKey.KEY_SPACE;
    int hold = KeyboardKey.KEY_C;
    int restart = KeyboardKey.KEY_F4;
    // menu controls
    // menuBack: if in settings, sprint, or blitz,
    // go back to top level menu
    int menuBack = KeyboardKey.KEY_ESCAPE;
}

struct ColorScheme {
    // only choose from the 4096 possible colors
    // to align with UI considerations
    // (R, G, B only allowed in multiples of 16)
    // basically just means each hex color code
    // must be 3 characters

    // button colors/bg colors (for UI)
    Color bg = Color(0, 0, 0);
    Color fg = Color(238, 238, 238);
    Color btnbg = Color(51, 51, 51);
    Color btnfg = Color(255, 255, 255);
    Color btnhover = Color(102, 102, 102);
    Color btnselect = Color(153, 153, 153);

    // piece colors (not exactly guideline?)
    Color pieceI = Color(0, 170, 255);
    Color pieceT = Color(136, 0, 255);
    Color pieceO = Color(255, 204, 0);
    Color pieceS = Color(34, 204, 0);
    Color pieceZ = Color(255, 0, 0);
    Color pieceL = Color(204, 119, 0);
    Color pieceJ = Color(17, 85, 255);

    // good/bad/medium colors (for UI)
    Color good = Color(0, 204, 34);
    Color medium = Color(221, 170, 0);
    Color bad = Color(255, 0, 0);
}

struct Handling {
    // only permit adjustments in increments
    // of 1, to make it easier to deal with
    // arr and das are measured in frames
    int arr = 0;
    int das = 6;
    // sdf has no units but is 1..31 (gravity mult)
    // if sdf is 31, treat it like inf (instant)
    int sdf = 31;
}
