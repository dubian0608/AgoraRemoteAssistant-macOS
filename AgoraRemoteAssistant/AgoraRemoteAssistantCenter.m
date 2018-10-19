//
//  AgoraRemoteAssistantCenter.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/10.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "AgoraRemoteAssistantCenter.h"
#import "AgoraRemoteOperation.h"
#import "AgoraRemoteAssistantView.h"
#import "AgoraKeyboardControl.h"
#import "AgoraMouseControl.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import <AgoraSigKit/AgoraSigKit.h>

static NSString * const kAppID = @"0c0b4b61adf94de1befd7cdd78a50444";

@interface AgoraRemoteAssistantCenter () <AgoraRemoteAssistantViewDelegate, AgoraRtcEngineDelegate>
{
    BOOL _joined;
    NSMutableArray *_remoteUsers;
    
    NSString *_operatingRemoteUser;
    
    AgoraRtcEngineKit *agoraRtc;
    AgoraAPI *agoraSig;
    AgoraKeyboardControl *keyboard;
    AgoraMouseControl *mouse;
    
    NSView *parentView;
    AgoraRemoteAssistantView *videoView;
    NSMutableArray *mouseClickCache;
    CGSize remoteVideoSize;
    CGSize localVideoSize;
    CGSize screenSize;
}
@end

@implementation AgoraRemoteAssistantCenter

+ (instancetype)sharedInstance {
    static AgoraRemoteAssistantCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [self leave];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        agoraRtc = [AgoraRtcEngineKit sharedEngineWithAppId:kAppID delegate:self];
        [agoraRtc setChannelProfile:AgoraChannelProfileCommunication];
        [agoraRtc enableVideo];
        
        [self initSig];
        
        keyboard = [AgoraKeyboardControl getInstance];
        mouse = [AgoraMouseControl getInstance];
        
        screenSize = NSScreen.mainScreen.frame.size;
    }
    return self;
}

- (BOOL)joined {
    return _joined;
}

- (NSArray *)remoteUsers {
    return _remoteUsers;
}

- (BOOL)join {
    if (self.channel.length == 0 || self.account.length == 0) {
        return NO;
    }
    
    if (self.joined) {
        [self leave];
        _joined = NO;
    }
    
    [agoraSig login2:kAppID account:self.account token:@"_no_need_token" uid:0 deviceID:0 retry_time_in_s:10 retry_count:3];
    
    _joined = YES;
    return _joined;
}

- (void)leave {
    [self stopRemoteAssistant];
    
    [agoraSig logout];
    _joined = NO;
    _remoteUsers = nil;
    _selectedRemoteUser = nil;
}

- (BOOL)startRemoteAssistant:(NSView *)view {
    if ([agoraRtc getCallId]) {
        return NO;
    }
    
    parentView = view;
    videoView = nil;
    remoteVideoSize = CGSizeZero;
    
    if (view) {
        [self sendControlCommand:AgoraRemoteOperationTypeStartAssistant info:nil];
    }
    
    NSInteger localUid = [self.account integerValue];
    __weak typeof(self) weakSelf = self;
    
    [agoraRtc enableLocalVideo:NO];
    [agoraRtc joinChannelByToken:nil channelId:self.channel info:nil uid:localUid joinSuccess:^(NSString * channel, NSUInteger uid, NSInteger elapsed) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && !strongSelf->parentView) {
            [strongSelf->agoraRtc enableLocalVideo:YES];
            [strongSelf->agoraRtc startScreenCapture:0 withCaptureFreq:15 bitRate:0 andRect:CGRectZero];
            [strongSelf->agoraRtc setVideoResolution:strongSelf->screenSize andFrameRate:15 bitrate:2000];
        }
    }];
    
    return YES;
}

- (void)stopRemoteAssistant {
    if (![agoraRtc getCallId]) {
        return;
    }
    
    if (parentView) {
        [self clearMouseClickCache];
        mouseClickCache = nil;
        
        [self sendControlCommand:AgoraRemoteOperationTypeStopAssistant info:nil];
        
        [videoView removeFromSuperview];
        videoView = nil;
        parentView = nil;
    }
    else {
        _operatingRemoteUser = nil;
    }
    
    [agoraRtc leaveChannel:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteAssistantStoped object:nil userInfo:nil];
}

- (void)sendControlCommand:(AgoraRemoteOperationType)type info:(NSDictionary *)info {
    AgoraRemoteOperation *command = [[AgoraRemoteOperation alloc] initWithType:type
                                                                     timeStamp:[NSDate date].timeIntervalSince1970
                                                                     extraInfo:info];
    NSString *msg = [command convertToJsonString];
    [agoraSig messageInstantSend:self.selectedRemoteUser uid:0 msg:msg msgID:nil];
}

- (void)cacheMouseOperation:(AgoraRemoteOperationType)type info:(NSDictionary *)info {
    AgoraRemoteOperation *command = [[AgoraRemoteOperation alloc] initWithType:type
                                                                     timeStamp:[NSDate date].timeIntervalSince1970
                                                                     extraInfo:info];
    [mouseClickCache addObject:command];
}

- (void)clearMouseClickCache {
    if (mouseClickCache.count > 0) {
        [NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendCacheMouseOperations) object:nil];
        
        [mouseClickCache removeAllObjects];
    }
}

- (void)sendCacheMouseOperations {
    if (mouseClickCache.count > 0) {
        [NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendCacheMouseOperations) object:nil];
        
        for (AgoraRemoteOperation *command in mouseClickCache) {
            NSString *msg = [command convertToJsonString];
            [agoraSig messageInstantSend:self.selectedRemoteUser uid:0 msg:msg msgID:nil];
        }
        [mouseClickCache removeAllObjects];
    }
}

#pragma mark - private methods

- (void)initSig {
    __weak typeof(self) weakSelf = self;
    agoraSig = [AgoraAPI getInstanceWithoutMedia:kAppID];
    //    signalEngine.onLog = ^(NSString *txt){
    //        NSLog(@"%@", txt);
    //    };
    agoraSig.onError = ^(NSString* name, AgoraEcode ecode, NSString* desc) {
        NSLog(@"onError, name: %@, code:%lu, desc: %@", name, ecode, desc);
    };
    agoraSig.onLoginFailed = ^(AgoraEcode ecode) {
        NSLog(@"Login failed, error: %lu", ecode);
    };
    agoraSig.onLoginSuccess = ^(uint32_t uid, int fd) {
        NSLog(@"Login successfully");
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->agoraSig channelJoin:strongSelf.channel];
    };
    agoraSig.onLogout = ^(AgoraEcode ecode) {
        if (ecode != AgoraEcode_LOGOUT_E_USER) {
            NSLog(@"onLogout, ecode: %lu", ecode);
        }
    };
    agoraSig.onChannelJoinFailed = ^(NSString *channelID, AgoraEcode ecode) {
        NSLog(@"Join sig channel failed, error: %lu", ecode);
    };
    agoraSig.onChannelJoined = ^(NSString *channelID) {
        NSLog(@"Join sig channel successfully");
    };
    agoraSig.onChannelLeaved = ^(NSString *channelID, AgoraEcode ecode) {
        if (ecode != AgoraEcode_LEAVECHANNEL_E_BYUSER) {
            NSLog(@"onChannelLeaved, ecode: %lu", ecode);
        }
    };
    agoraSig.onChannelUserList = ^(NSMutableArray *accounts, NSMutableArray *uids) {
        __strong typeof(self) strongSelf = weakSelf;
        [accounts removeObject:strongSelf.account];
        NSLog(@"onChannelUserList, accounts: %@", accounts);
        
        strongSelf->_remoteUsers = accounts;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:strongSelf->_remoteUsers userInfo:nil];
    };
    agoraSig.onChannelUserJoined = ^(NSString *account, uint32_t uid) {
        NSLog(@"onChannelUserJoined, account: %@", account);
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_remoteUsers addObject:account];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:strongSelf->_remoteUsers userInfo:nil];
    };
    agoraSig.onChannelUserLeaved = ^(NSString *account, uint32_t uid) {
        NSLog(@"onChannelUserLeaved, account: %@", account);
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_remoteUsers removeObject:account];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:strongSelf->_remoteUsers userInfo:nil];
    };
    agoraSig.onMessageInstantReceive = ^(NSString *account, uint32_t uid, NSString *msg) {
        NSArray<AgoraRemoteOperation *> *operations = [AgoraRemoteOperation parseJsonString:msg];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            for (AgoraRemoteOperation *operation in operations) {
                if (operation.type == AgoraRemoteOperationTypeStartAssistant) {
                    if ([strongSelf startRemoteAssistant:nil]) {
                        strongSelf->_operatingRemoteUser = account;
                    }
                }
                else if ([account isEqualToString:strongSelf->_operatingRemoteUser]) {
                    if (operation.type == AgoraRemoteOperationTypeStopAssistant) {
                        [strongSelf stopRemoteAssistant];
                    }
                    else {
                        [strongSelf handleRemoteOperation:operation];
                    }
                }
            }
        });
    };
}

- (void)handleRemoteOperation:(AgoraRemoteOperation *)operation {
    CGPoint position = CGPointZero;
    if (operation.type >= AgoraRemoteOperationTypeMouseLeftButtonDown &&
        operation.type <= AgoraRemoteOperationTypeMouseMove) {
        NSDictionary *point = operation.extraInfo[@"point"];
        CGFloat x = [point[@"x"] floatValue];
        CGFloat y = [point[@"y"] floatValue];
        if (CGSizeEqualToSize(localVideoSize, screenSize)) {
            position = CGPointMake(x, y);
        }
        else {
            position.x = x / localVideoSize.width * screenSize.width;
            position.y = y / localVideoSize.height * screenSize.height;
        }
    }
    
    switch (operation.type) {
        case AgoraRemoteOperationTypeMouseLeftButtonDown:
            [mouse leftMouseDown:NO position:position];
            break;
            
        case AgoraRemoteOperationTypeMouseLeftButtonUp:
            [mouse leftMouseUp:NO position:position];
            break;
            
        case AgoraRemoteOperationTypeMouseLeftButtonDoubleClick:
            [mouse leftMouseDown:YES position:position];
            [mouse leftMouseUp:YES position:position];
            break;
            
        case AgoraRemoteOperationTypeMouseRightButtonDown:
            [mouse rightMouseDown:NO position:position];
            break;
            
        case AgoraRemoteOperationTypeMouseRightButtonUp:
            [mouse rightMouseUp:NO position:position];
            break;
            
        case AgoraRemoteOperationTypeMouseRightButtonDoubleClick:
            [mouse rightMouseDown:YES position:position];
            [mouse rightMouseUp:YES position:position];
            break;
            
        case AgoraRemoteOperationTypeMouseMove:
            [mouse moveMouseTo:position];
            break;
            
        case AgoraRemoteOperationTypeMouseWheel:
        {
            NSDictionary *point = operation.extraInfo[@"scrolDelta"];
            int x = [point[@"x"] intValue];
            int y = [point[@"y"] intValue];
            if (abs(x) > abs(y)) {
                [mouse mouseScrollHorizontal:x];
            }
            else if (y != 0) {
                [mouse mouseScrollVertical:y];
            }
        }
            break;
            
        case AgoraRemoteOperationTypeKeyboardKeyPress:
        {
            CGKeyCode keyCode = [operation.extraInfo[@"keyCode"] unsignedShortValue];
            [keyboard sendKeyDown:keyCode];
            [keyboard sendKeyUp:keyCode];
        }
            break;
            
        case AgoraRemoteOperationTypeKeyboardKeyDown:
        {
            CGKeyCode keyCode = [operation.extraInfo[@"keyCode"] unsignedShortValue];
            [keyboard sendKeyDown:keyCode];
        }
            break;
            
        case AgoraRemoteOperationTypeKeyboardKeyUp:
        {
            CGKeyCode keyCode = [operation.extraInfo[@"keyCode"] unsignedShortValue];
            [keyboard sendKeyUp:keyCode];
        }
            break;
            
        default:
            break;
    }
}

- (void)addVideoView {
    videoView = [[AgoraRemoteAssistantView alloc] initWithFrame:CGRectZero];
    videoView.delegate = self;
    videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [videoView addToView:parentView];
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:videoView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:parentView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:videoView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:parentView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    
    NSLayoutConstraint *leadingRequired = [NSLayoutConstraint constraintWithItem:videoView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:parentView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *trailingRequired = [NSLayoutConstraint constraintWithItem:videoView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                                           toItem:parentView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *topRequired = [NSLayoutConstraint constraintWithItem:videoView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:0];
    NSLayoutConstraint *bottomRequired = [NSLayoutConstraint constraintWithItem:videoView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationLessThanOrEqual
                                                                         toItem:parentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0];
    
    NSLayoutConstraint *leadingOptional = [NSLayoutConstraint constraintWithItem:videoView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:parentView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *trailingOptional = [NSLayoutConstraint constraintWithItem:videoView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:parentView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *topOptional = [NSLayoutConstraint constraintWithItem:videoView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:0];
    NSLayoutConstraint *bottomOptional = [NSLayoutConstraint constraintWithItem:videoView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:parentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0];
    
    leadingOptional.priority = NSLayoutPriorityDefaultLow;
    trailingOptional.priority = NSLayoutPriorityDefaultLow;
    topOptional.priority = NSLayoutPriorityDefaultLow;
    bottomOptional.priority = NSLayoutPriorityDefaultLow;
    
    [parentView addConstraints:@[centerX, centerY,
                                 leadingRequired, trailingRequired, topRequired, bottomRequired,
                                 leadingOptional, trailingOptional, topOptional, bottomOptional]];
    
    mouseClickCache = [NSMutableArray arrayWithCapacity:2];
}

#pragma mark - AgoraRemoteAssistantViewDelegate

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseLeftButtonDown:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick {
    CGFloat x = position.x / view.bounds.size.width * remoteVideoSize.width;
    CGFloat y = (1 - position.y / view.bounds.size.height) * remoteVideoSize.height;
    NSDictionary *info = @{@"point": @{@"x": @(x), @"y": @(y)}};
    if (isDoubleClick) {
        [self clearMouseClickCache];
    }
    else {
        [self sendCacheMouseOperations];
    }
    [self cacheMouseOperation:AgoraRemoteOperationTypeMouseLeftButtonDown info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseLeftButtonUp:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick {
    CGFloat x = position.x / view.bounds.size.width * remoteVideoSize.width;
    CGFloat y = (1 - position.y / view.bounds.size.height) * remoteVideoSize.height;
    NSDictionary *info = @{@"point": @{@"x": @(x), @"y": @(y)}};
    if (isDoubleClick) {
        [self sendCacheMouseOperations];
        [self sendControlCommand:AgoraRemoteOperationTypeMouseLeftButtonDoubleClick info:info];
    }
    else {
        [self cacheMouseOperation:AgoraRemoteOperationTypeMouseLeftButtonUp info:info];
        [self performSelector:@selector(sendCacheMouseOperations) withObject:nil afterDelay:NSEvent.doubleClickInterval];
    }
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseRightButtonDown:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick {
    CGFloat x = position.x / view.bounds.size.width * remoteVideoSize.width;
    CGFloat y = (1 - position.y / view.bounds.size.height) * remoteVideoSize.height;
    NSDictionary *info = @{@"point": @{@"x": @(x), @"y": @(y)}};
    if (isDoubleClick) {
        [self clearMouseClickCache];
    }
    else {
        [self sendCacheMouseOperations];
    }
    [self cacheMouseOperation:AgoraRemoteOperationTypeMouseRightButtonDown info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseRightButtonUp:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick {
    CGFloat x = position.x / view.bounds.size.width * remoteVideoSize.width;
    CGFloat y = (1 - position.y / view.bounds.size.height) * remoteVideoSize.height;
    NSDictionary *info = @{@"point": @{@"x": @(x), @"y": @(y)}};
    if (isDoubleClick) {
        [self sendCacheMouseOperations];
        [self sendControlCommand:AgoraRemoteOperationTypeMouseRightButtonDoubleClick info:info];
    }
    else {
        [self cacheMouseOperation:AgoraRemoteOperationTypeMouseRightButtonUp info:info];
        [self performSelector:@selector(sendCacheMouseOperations) withObject:nil afterDelay:NSEvent.doubleClickInterval];
    }
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseMove:(CGPoint)position {
    CGFloat x = position.x / view.bounds.size.width * remoteVideoSize.width;
    CGFloat y = (1 - position.y / view.bounds.size.height) * remoteVideoSize.height;
    NSDictionary *info = @{@"point": @{@"x": @(x), @"y": @(y)}};
    [self sendCacheMouseOperations];
    [self sendControlCommand:AgoraRemoteOperationTypeMouseMove info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseScrollHorizontal:(CGFloat)scrolDeltaX mouseScrollVertical:(CGFloat)scrolDeltaY {
    NSDictionary *info = @{@"scrolDelta": @{@"x": @(scrolDeltaX), @"y": @(scrolDeltaY)}};
    [self sendCacheMouseOperations];
    [self sendControlCommand:AgoraRemoteOperationTypeMouseWheel info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyPress:(unichar)keyCode {
    NSDictionary *info = @{@"keyCode": @(keyCode)};
    [self sendControlCommand:AgoraRemoteOperationTypeKeyboardKeyPress info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyDown:(unichar)keyCode {
    NSDictionary *info = @{@"keyCode": @(keyCode)};
    [self sendControlCommand:AgoraRemoteOperationTypeKeyboardKeyDown info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyUp:(unichar)keyCode {
    NSDictionary *info = @{@"keyCode": @(keyCode)};
    [self sendControlCommand:AgoraRemoteOperationTypeKeyboardKeyUp info:info];
}

#pragma mark - AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    NSLog(@"rtc engine error: %ld", errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    if (parentView == nil) {
        return;
    }
    
    NSInteger remoteUid = [self.selectedRemoteUser integerValue];
    if (uid != remoteUid) {
        return;
    }
    
    remoteVideoSize = size;
    
    if (videoView == nil) {
        [self addVideoView];
        
        AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
        canvas.uid = remoteUid;
        canvas.view = videoView;
        canvas.renderMode = AgoraVideoRenderModeFit;
        [agoraRtc setupRemoteVideo:canvas];
    }
    else {
        NSArray *constraints = videoView.constraints;
        [videoView removeConstraints:constraints];
    }
    
    NSLayoutConstraint *ratioConstraint = [NSLayoutConstraint constraintWithItem:videoView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:videoView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:size.width/size.height
                                                                        constant:0];
    [videoView addConstraint:ratioConstraint];
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine videoSizeChangedOfUid:(NSUInteger)uid size:(CGSize)size rotation:(NSInteger)rotation {
    if (uid == 0) {
        localVideoSize = size;
        return;
    }
    
    if (videoView == nil) {
        return;
    }
    
    NSInteger remoteUid = [self.selectedRemoteUser integerValue];
    if (uid != remoteUid) {
        return;
    }
    
    remoteVideoSize = size;
    
    NSArray *constraints = videoView.constraints;
    [videoView removeConstraints:constraints];
    
    NSLayoutConstraint *ratioConstraint = [NSLayoutConstraint constraintWithItem:videoView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:videoView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:size.width/size.height
                                                                        constant:0];
    [videoView addConstraint:ratioConstraint];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if ([self.selectedRemoteUser integerValue] == uid) {
        [self stopRemoteAssistant];
    }
}

@end
