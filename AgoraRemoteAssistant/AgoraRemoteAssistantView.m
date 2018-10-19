//
//  AgoraRemoteAssistantView.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/14.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "AgoraRemoteAssistantView.h"

@interface AgoraRemoteAssistantView ()
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
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"keyDown: %@", event);
    [self.delegate remoteAssistantView:self keyboardKeyDown:[event.characters characterAtIndex:0]];
}

- (void)keyUp:(NSEvent *)event {
    NSLog(@"keyUp: %@", event);
    [self.delegate remoteAssistantView:self keyboardKeyUp:[event.characters characterAtIndex:0]];
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
    [self.delegate remoteAssistantView:self mouseScrollHorizontal:event.scrollingDeltaX mouseScrollVertical:event.scrollingDeltaY];
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
