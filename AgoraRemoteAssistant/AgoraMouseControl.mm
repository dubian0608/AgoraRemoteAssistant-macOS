#import "AgoraMouseControl.h"
#import "AgoraKeyboardControl.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation AgoraMouseControl

+ (AgoraMouseControl *)getInstance {
    static AgoraMouseControl *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[AgoraMouseControl alloc] init];
    });
    
    return instance;
}

- (CGPoint)getCursorPositionCGPoint
{
    CGEventRef event = CGEventCreate(NULL);
    return CGEventGetLocation(event);
}

- (void)leftMouseDown:(BOOL)isDoubleClick position:(CGPoint)position
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventLeftMouseDown,
                                                 position,
                                                 kCGMouseButtonLeft);
    if (isDoubleClick)
    {
        CGEventSetIntegerValueField(mouseEv, kCGMouseEventClickState, 2);
    }
    CGEventPost(kCGHIDEventTap, mouseEv);
    CFRelease(mouseEv);
}

- (void)leftMouseUp:(BOOL)isDoubleClick position:(CGPoint)position
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventLeftMouseUp,
                                                 position,
                                                 kCGMouseButtonLeft);
    if (isDoubleClick)
    {
        CGEventSetIntegerValueField(mouseEv, kCGMouseEventClickState, 2);
    }
    CGEventPost(kCGHIDEventTap, mouseEv);
    CFRelease(mouseEv);
}

- (void)moveMouseTo:(CGPoint)position
{
    UInt32 maxDisplays = 4;
    CGDirectDisplayID displayID[maxDisplays];
    CGDisplayCount c = 0;
    CGDisplayCount *count = &c;
    CGGetDisplaysWithPoint(position,
                           maxDisplays,
                           displayID,
                           count);
    if (*count > 0)
    {
        CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                     kCGEventMouseMoved,
                                                     position,
                                                     kCGMouseButtonLeft);
        CGEventPost(kCGHIDEventTap, mouseEv);
        CFRelease(mouseEv);
    }
}

- (void)mouseScrollVertical:(int)scrollLength
{
    // length of scroll from -10 to 10 higher values lead to undef behaviour
    //scrollDirection = (scrollDirection < -10) ? -10 : ((scrollDirection > 10) ? 10 : scrollDirection);
    CGEventRef scrollEvent = CGEventCreateScrollWheelEvent (NULL,
                                                            kCGScrollEventUnitPixel,  // kCGScrollEventUnitLine  //
                                                            1, //CGWheelCount 1 = y 2 = xy 3 = xyz
                                                            scrollLength);
    
    CGEventPost(kCGHIDEventTap, scrollEvent);
    
    CFRelease(scrollEvent);
}

- (void)mouseScrollHorizontal:(int)scrollLength
{
    // length of scroll from -10 to 10 higher values lead to undef behaviour
    //scrollDirection = (scrollDirection < -10) ? -10 : ((scrollDirection > 10) ? 10 : scrollDirection);
    CGEventRef scrollEvent = CGEventCreateScrollWheelEvent (NULL,
                                                            kCGScrollEventUnitPixel,  // kCGScrollEventUnitLine  //kCGScrollEventUnitPixel
                                                            2, //CGWheelCount 1 = y 2 = xy 3 = xyz
                                                            0,
                                                            scrollLength);
    
    CGEventPost(kCGHIDEventTap, scrollEvent);
    
    CFRelease(scrollEvent);
}

- (void)rightMouseDown:(BOOL)isDoubleClick position:(CGPoint)position
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventRightMouseDown,
                                                 position,
                                                 kCGMouseButtonRight);
    if (isDoubleClick)
    {
        CGEventSetIntegerValueField(mouseEv, kCGMouseEventClickState, 2);
    }
    CGEventPost(kCGHIDEventTap, mouseEv);
    CFRelease(mouseEv);
}

- (void)rightMouseUp:(BOOL)isDoubleClick position:(CGPoint)position
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventRightMouseUp,
                                                 position,
                                                 kCGMouseButtonRight);
    if (isDoubleClick)
    {
        CGEventSetIntegerValueField(mouseEv, kCGMouseEventClickState, 2);
    }
    CGEventPost(kCGHIDEventTap, mouseEv);
    CFRelease(mouseEv);
}

- (void)zoom:(int)value count:(int)count
{
    for (int i = 0; i < count; ++i)
    {
        int keycode = (value == 1) ? KEYCODE_ZOOM_IN : KEYCODE_ZOOM_OUT;
        [AgoraKeyboardControl.getInstance sendShortcut:keycode];
    }
}

@end

