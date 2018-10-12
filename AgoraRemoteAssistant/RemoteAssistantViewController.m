//
//  RemoteAssistantViewController.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/11.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "RemoteAssistantViewController.h"
#import "AgoraRemoteAssistantCenter.h"

@interface RemoteAssistantViewController ()
@property (weak) IBOutlet NSView *videoView;

@end

@implementation RemoteAssistantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    if ([[AgoraRemoteAssistantCenter sharedInstance] startRemoteAssistant:self.videoView]) {
        [self.view.window toggleFullScreen:nil];
    }
}

- (void)close {
    [[AgoraRemoteAssistantCenter sharedInstance] stopRemoteAssistant];
    
    if ((self.view.window.styleMask & NSWindowStyleMaskFullScreen) == NSWindowStyleMaskFullScreen) {
        [self.view.window toggleFullScreen:nil];
    }
    [self performSegueWithIdentifier:@"backToMain" sender:nil];
}

@end
