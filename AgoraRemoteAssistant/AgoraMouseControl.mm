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

- (void)leftMouseDown:(BOOL)isDoubleClick
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventLeftMouseDown,
                                                 [self getCursorPositionCGPoint],
                                                 kCGMouseButtonLeft);
    if (isDoubleClick)
    {
        CGEventSetIntegerValueField(mouseEv, kCGMouseEventClickState, 2);
    }
    CGEventPost(kCGHIDEventTap, mouseEv);
    CFRelease(mouseEv);
}

- (void)leftMouseUp:(BOOL)isDoubleClick
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventLeftMouseUp,
                                                 [self getCursorPositionCGPoint],
                                                 kCGMouseButtonLeft);
    if (isDoubleClick)
    {
        CGEventSetIntegerValueField(mouseEv, kCGMouseEventClickState, 2);
    }
    CGEventPost(kCGHIDEventTap, mouseEv);
    CFRelease(mouseEv);
}

- (void)moveMouseTo:(CGPoint)point
{
    UInt32 maxDisplays = 4;
    CGDirectDisplayID displayID[maxDisplays];
    CGDisplayCount c = 0;
    CGDisplayCount *count = &c;
    CGGetDisplaysWithPoint(point,
                           maxDisplays,
                           displayID,
                           count);
    if (*count > 0)
    {
        CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                     kCGEventMouseMoved,
                                                     point,
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
                                                            kCGScrollEventUnitLine,  // kCGScrollEventUnitLine  //kCGScrollEventUnitPixel
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
                                                            kCGScrollEventUnitLine,  // kCGScrollEventUnitLine  //kCGScrollEventUnitPixel
                                                            2, //CGWheelCount 1 = y 2 = xy 3 = xyz
                                                            0,
                                                            scrollLength);
    
    CGEventPost(kCGHIDEventTap, scrollEvent);
    
    CFRelease(scrollEvent);
}

- (void)rightMouseDown
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventRightMouseDown,
                                                 [self getCursorPositionCGPoint],
                                                 kCGMouseButtonRight);
    CGEventPost(kCGHIDEventTap, mouseEv);
    CFRelease(mouseEv);
}

- (void)rightMouseUp
{
    CGEventRef mouseEv = CGEventCreateMouseEvent(NULL,
                                                 kCGEventRightMouseUp,
                                                 [self getCursorPositionCGPoint],
                                                 kCGMouseButtonRight);
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

