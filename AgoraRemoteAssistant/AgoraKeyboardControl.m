#import "AgoraKeyboardControl.h"
#import <Carbon/Carbon.h>
#import <CoreServices/CoreServices.h>

@interface AgoraKeyboardControl()
{
    bool shiftDown;
    bool fnDown;
    bool ctrlDown;
    bool altDown;
    bool cmdDown;
}
@end

@implementation AgoraKeyboardControl

+ (AgoraKeyboardControl *)getInstance {
    static AgoraKeyboardControl *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[AgoraKeyboardControl alloc] init];
    });
    
    return instance;
}

- (void)sendKeyPress:(CGKeyCode)key
{
    if (key)
    {
        [self sendKeyDown:key];
        [self sendKeyUp:key];
    }
}

- (void)sendKeyDown:(CGKeyCode)key
{
    [self sendKeyDown:key char:0];
}

- (void)sendKeyDown:(CGKeyCode)key char:(UniChar)c
{
    if (key == kVK_Shift) shiftDown = true;
    else if (key == kVK_Function) fnDown = true;
    else if (key == kVK_Control) ctrlDown = true;
    else if (key == kVK_Option) altDown = true;
    else if (key == kVK_Command) cmdDown = true;

    CGEventSourceRef source = NULL;
    if (shiftDown || ctrlDown || altDown || cmdDown)
    {
        source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    }

    CGEventRef command = CGEventCreateKeyboardEvent(source, key, true);
    CGEventFlags flags = 0;
    bool flagsAreInitialized = false;
    if (c) CGEventKeyboardSetUnicodeString(command, 1, &c);
    if (shiftDown)
    {
        // as this is the first if condition, it is impossible that there is already a flag set
        flags = kCGEventFlagMaskShift;
        flagsAreInitialized = true;
    }
    if (fnDown)
    {
        if (flagsAreInitialized) flags = flags | kCGEventFlagMaskSecondaryFn;
        else flags = kCGEventFlagMaskSecondaryFn;
        flagsAreInitialized = true;
    }
    if (ctrlDown)
    {
        if (flagsAreInitialized) flags = flags | kCGEventFlagMaskControl;
        else flags = kCGEventFlagMaskControl;
        flagsAreInitialized = true;
    }
    if (altDown)
    {
        if (flagsAreInitialized) flags = flags | kCGEventFlagMaskAlternate;
        else flags = kCGEventFlagMaskAlternate;
        flagsAreInitialized = true;
    }
    if (cmdDown)
    {
        if (flagsAreInitialized) flags = flags | kCGEventFlagMaskCommand;
        else flags = kCGEventFlagMaskCommand;
        flagsAreInitialized = true;
    }
    if (flagsAreInitialized) CGEventSetFlags(command, flags);
    CGEventPost(kCGAnnotatedSessionEventTap, command);
    CFRelease(command);
}

- (void)sendKeyUp:(CGKeyCode)key
{
    [self sendKeyUp:key char:0];
}

- (void)sendKeyUp:(CGKeyCode)key char:(UniChar)c
{
    if (key == kVK_Shift) shiftDown = false;
    else if (key == kVK_Function) fnDown = false;
    else if (key == kVK_Control) ctrlDown = false;
    else if (key == kVK_Option) altDown = false;
    else if (key == kVK_Command) cmdDown = false;

    CGEventRef command = CGEventCreateKeyboardEvent(NULL, key, false);
    if (c) CGEventKeyboardSetUnicodeString(command, 1, &c);
    CGEventPost(kCGAnnotatedSessionEventTap, command);
    CFRelease(command);
}

- (void)sendShortcut:(int)keyCode
{
    switch (keyCode)
    {
        case KEYCODE_COPY:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_C];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_PASTE:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_V];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_SELECT_ALL:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_A];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_CUT:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_X];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_SHOW_DESKTOP:
        {
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:[self keycodeToKey:KEYCODE_F3]];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        }
        case KEYCODE_ZOOM_IN:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_KeypadPlus];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_ZOOM_OUT:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_KeypadMinus];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_CLOSE:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_Q];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_CANCEL:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_Period];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_REFRESH:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_R];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_FULLSCREEN:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_CONTROL]];
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_F];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_CONTROL]];
            break;
        case KEYCODE_UNDO:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_ANSI_Z];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_BROWSER_BACK:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_LeftArrow];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        case KEYCODE_BROWSER_FORWARD:
            [self sendKeyDown:[self keycodeToKey:KEYCODE_COMMAND]];
            [self sendKeyPress:kVK_RightArrow];
            [self sendKeyUp:[self keycodeToKey:KEYCODE_COMMAND]];
            break;
        default:
            //Logger::Instance()->add("Unkown keyboard command"];
            break;
    }
}

- (CGKeyCode)keycodeToKey:(int)keyCode
{
    switch (keyCode)
    {
    case KEYCODE_BACK:
        return kVK_Delete;
    case KEYCODE_CAPS_LOCK:
        shiftDown = (shiftDown) ? false : true;
        return KEYCODE_UNKOWN;
    case KEYCODE_DEL:
        return kVK_Delete;
    case KEYCODE_ENTER:
        return kVK_Return;
    case KEYCODE_ESCAPE:
        return kVK_Escape;
    case KEYCODE_INSERT:
        return kVK_ForwardDelete;
    case KEYCODE_MOVE_END:
        return kVK_End;
    case KEYCODE_MOVE_HOME:
        return kVK_Home;
    case KEYCODE_PAGE_DOWN:
        return kVK_PageDown;
    case KEYCODE_PAGE_UP:
        return kVK_PageUp;
    case KEYCODE_SPACE:
        return kVK_Space;
    case KEYCODE_TAB:
        return kVK_Tab;
    case KEYCODE_UP:
        return kVK_UpArrow;
    case KEYCODE_DOWN:
        return kVK_DownArrow;
    case KEYCODE_LEFT:
        return kVK_LeftArrow;
    case KEYCODE_RIGHT:
        return kVK_RightArrow;
    case KEYCODE_ALT:
        return kVK_Option;
    case KEYCODE_CONTROL:
        return kVK_Control;
    case KEYCODE_COMMAND:
        return kVK_Command;
    case KEYCODE_FUNCTION:
        return kVK_Function;
    case KEYCODE_SHIFT:
        return kVK_Shift;
    case KEYCODE_DEL_FORWARD:
        return kVK_ForwardDelete;
    case KEYCODE_F1:
        return kVK_F1;
    case KEYCODE_F2:
        return kVK_F2;
    case KEYCODE_F3:
        return kVK_F3;
    case KEYCODE_F4:
        return kVK_F4;
    case KEYCODE_F5:
        return kVK_F5;
    case KEYCODE_F6:
        return kVK_F6;
    case KEYCODE_F7:
        return kVK_F7;
    case KEYCODE_F8:
        return kVK_F8;
    case KEYCODE_F9:
        return kVK_F9;
    case KEYCODE_F10:
        return kVK_F10;
    case KEYCODE_F11:
        return kVK_F11;
    case KEYCODE_F12:
        return kVK_F12;
    default:
        return KEYCODE_UNKOWN;
    }
}

@end
