//
//  WindowController.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/10.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "WindowController.h"
#import "RemoteAssistantViewController.h"

@interface WindowController () <NSWindowDelegate>

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window.delegate = self;
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if ([self.window.contentViewController isMemberOfClass:[RemoteAssistantViewController class]]) {
        [(RemoteAssistantViewController *)self.window.contentViewController close];
        return NO;
    }
    return YES;
}

@end
