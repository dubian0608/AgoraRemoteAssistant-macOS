//
//  AgoraBackgroundView.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/10.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "AgoraBackgroundView.h"

@implementation AgoraBackgroundView

- (void)updateLayer {
    self.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
}

@end
