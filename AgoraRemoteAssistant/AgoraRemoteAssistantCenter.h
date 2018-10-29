//
//  AgoraRemoteAssistantCenter.h
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/10.
//  Copyright © 2018 Agora. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kNotificationRemoteUserListUpdated      @"kNotificationRemoteUserListUpdated"
#define kNotificationRemoteAssistantStoped      @"kNotificationRemoteAssistantStoped"

@interface AgoraRemoteAssistantCenter : NSObject

+ (instancetype)sharedInstance;

@property (copy) NSString *channel;
@property (assign) NSUInteger localUid;
@property (assign, readonly) BOOL joined;
@property (copy, readonly) NSArray *remoteUsers;
@property (assign) NSUInteger selectedRemoteUser;

- (BOOL)join;
- (void)leave;
- (BOOL)startRemoteAssistant:(NSView *)view;
- (void)stopRemoteAssistant;

@end
