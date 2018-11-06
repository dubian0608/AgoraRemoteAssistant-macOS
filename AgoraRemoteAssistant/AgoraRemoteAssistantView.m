//
//  AgoraRemoteAssistantView.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/14.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "AgoraRemoteAssistantView.h"
#import <Carbon/Carbon.h>

@interface AgoraRemoteAssistantView ()
{
    bool capsLockDown;
    bool shiftDown;
    bool fnDown;
    bool controlDown;
    bool optionDown;
    bool commandDown;
}
@property (assign) BOOL mouseInside;
@end

@implementation AgoraRemoteAssistantView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)addToView:(NSView *)parentView {
    [parentView addSubview:self];
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseEntered handler:^NSEvent *(NSEvent *event) {
//        NSLog(@"mouseEntered: %@", event);
//        self.mouseInside = YES;
//        return event;
//    }];
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseExited handler:^NSEvent *(NSEvent *event) {
//        NSLog(@"mouseExited: %@", event);
//        self.mouseInside = NO;
//        return event;
//    }];
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyUp handler:^NSEvent *(NSEvent *event) {
//        if (self.mouseInside) {
//            [self keyUp:event];
//            return nil;
//        }
//        else {
//            return event;
//        }
//    }];
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskFlagsChanged handler:^NSEvent *(NSEvent *event) {
//        if (self.mouseInside) {
//            [self flagsChanged:event];
//            return nil;
//        }
//        else {
//            return event;
//        }
//    }];
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^NSEvent *(NSEvent *event) {
//        if (self.mouseInside) {
//            [self mouseMoved:event];
//            return nil;
//        }
//        else {
//            return event;
//        }
//    }];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

//- (BOOL)acceptsFirstResponder {
//    return YES;
//}
//
//- (BOOL)acceptsFirstMouse:(NSEvent *)event {
//    NSLog(@"acceptsFirstMouse: %@", event);
//    return YES;
//}
//
//- (BOOL)becomeFirstResponder {
//    NSLog(@"becomeFirstResponder");
//    return YES;
//}
//
//- (BOOL)resignFirstResponder {
//    NSLog(@"resignFirstResponder");
//    return YES;
//}

- (void)flagsChanged:(NSEvent *)event {
    NSLog(@"resignFirstResponder: %@", event);
    NSEventModifierFlags flags = event.modifierFlags;
    if (!capsLockDown && (flags & NSEventModifierFlagCapsLock) == NSEventModifierFlagCapsLock) {
         [self.delegate remoteAssistantView:self keyboardKeyDown:kVK_CapsLock];
        capsLockDown = YES;
    }
    else if (capsLockDown && (flags & NSEventModifierFlagCapsLock) != NSEventModifierFlagCapsLock) {
        [self.delegate remoteAssistantView:self keyboardKeyUp:kVK_CapsLock];
        capsLockDown = NO;
    }
    else if (!shiftDown && (flags & NSEventModifierFlagShift) == NSEventModifierFlagShift) {
        [self.delegate remoteAssistantView:self keyboardKeyDown:kVK_Shift];
        shiftDown = YES;
    }
    else if (shiftDown && (flags & NSEventModifierFlagShift) != NSEventModifierFlagShift) {
        [self.delegate remoteAssistantView:self keyboardKeyUp:kVK_Shift];
        shiftDown = NO;
    }
    else if (!controlDown && (flags & NSEventModifierFlagControl) == NSEventModifierFlagControl) {
        [self.delegate remoteAssistantView:self keyboardKeyDown:kVK_Control];
        controlDown = YES;
    }
    else if (controlDown && (flags & NSEventModifierFlagControl) != NSEventModifierFlagControl) {
        [self.delegate remoteAssistantView:self keyboardKeyUp:kVK_Shift];
        controlDown = NO;
    }
    else if (!optionDown && (flags & NSEventModifierFlagOption) == NSEventModifierFlagOption) {
        [self.delegate remoteAssistantView:self keyboardKeyDown:kVK_Option];
        optionDown = YES;
    }
    else if (optionDown && (flags & NSEventModifierFlagOption) != NSEventModifierFlagOption) {
        [self.delegate remoteAssistantView:self keyboardKeyUp:kVK_Option];
        optionDown = NO;
    }
    else if (!commandDown && (flags & NSEventModifierFlagCommand) == NSEventModifierFlagCommand) {
        [self.delegate remoteAssistantView:self keyboardKeyDown:kVK_Command];
        commandDown = YES;
    }
    else if (commandDown && (flags & NSEventModifierFlagCommand) != NSEventModifierFlagCommand) {
        [self.delegate remoteAssistantView:self keyboardKeyUp:kVK_Command];
        commandDown = NO;
    }
    else if (!fnDown && (flags & NSEventModifierFlagFunction) == NSEventModifierFlagFunction) {
        [self.delegate remoteAssistantView:self keyboardKeyDown:kVK_Function];
        fnDown = YES;
    }
    else if (fnDown && (flags & NSEventModifierFlagFunction) != NSEventModifierFlagFunction) {
        [self.delegate remoteAssistantView:self keyboardKeyUp:kVK_Function];
        fnDown = NO;
    }
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"keyDown: %@", event);
    [self.delegate remoteAssistantView:self keyboardKeyDown:event.keyCode];
    //[self.delegate remoteAssistantView:self keyboardKeyDown:[event.characters characterAtIndex:0]];
}

- (void)keyUp:(NSEvent *)event {
    NSLog(@"keyUp: %@", event);
    [self.delegate remoteAssistantView:self keyboardKeyUp:event.keyCode];
    //[self.delegate remoteAssistantView:self keyboardKeyUp:[event.characters characterAtIndex:0]];
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"mouseDown: %@", event);
    if (self.window.firstResponder != self) {
        [self.window makeFirstResponder:self];
    }
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    [self.delegate remoteAssistantView:self mouseLeftButtonDown:location isDoubleClick:event.clickCount == 2];
}

- (void)mouseUp:(NSEvent *)event {
    NSLog(@"mouseUp: %@", event);
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    [self.delegate remoteAssistantView:self mouseLeftButtonUp:location isDoubleClick:event.clickCount == 2];
}

- (void)rightMouseDown:(NSEvent *)event {
    NSLog(@"rightMouseDown: %@", event);
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    [self.delegate remoteAssistantView:self mouseRightButtonDown:location isDoubleClick:event.clickCount == 2];
}

- (void)rightMouseUp:(NSEvent *)event {
    NSLog(@"rightMouseUp: %@", event);
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    [self.delegate remoteAssistantView:self mouseRightButtonUp:location isDoubleClick:event.clickCount == 2];
}

- (void)mouseDragged:(NSEvent *)event {
    NSLog(@"mouseDragged: %@", event);
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    [self.delegate remoteAssistantView:self mouseMove:location];
}

- (void)mouseMoved:(NSEvent *)event {
    NSLog(@"mouseMoved: %@", event);
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    [self.delegate remoteAssistantView:self mouseMove:location];
}

- (void)scrollWheel:(NSEvent *)event {
    NSLog(@"scrollWheel: %@", event);
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    if (event.hasPreciseScrollingDeltas) {
        if (event.phase == NSEventPhaseBegan) {
            [self.delegate remoteAssistantView:self mouseMove:location];
        }
        [self.delegate remoteAssistantView:self mouseScroll:location deltaX:event.scrollingDeltaX deltaY:event.scrollingDeltaY];
    }
    else {
        [self.delegate remoteAssistantView:self mouseMove:location];
        [self.delegate remoteAssistantView:self mouseScroll:location deltaX:event.scrollingDeltaX * 10 deltaY:event.scrollingDeltaY * 10];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    NSLog(@"mouseEntered");
    self.mouseInside = YES;
}

- (void)mouseExited:(NSEvent *)event {
    NSLog(@"mouseExited");
    self.mouseInside = NO;
}

@end
