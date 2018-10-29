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

static NSString * const kAppID = @"012ac3f2bbad46dfa702e8b2ef628954";

@interface AgoraRemoteAssistantCenter () <AgoraRemoteAssistantViewDelegate, AgoraRtcEngineDelegate>
{
    BOOL _joined;
    NSMutableArray *_remoteUsers;
    NSInteger _remoteUid;
    
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
        _remoteUsers = [[NSMutableArray alloc] init];
        
        agoraRtc = [AgoraRtcEngineKit sharedEngineWithAppId:kAppID delegate:self];
        [agoraRtc setChannelProfile:AgoraChannelProfileCommunication];
        [agoraRtc enableVideo];
        [agoraRtc disableAudio];
        
        [self initSig];
        
        keyboard = [AgoraKeyboardControl getInstance];
        mouse = [AgoraMouseControl getInstance];
        
        screenSize = NSScreen.mainScreen.frame.size;
        self.channel = @"baluoteliz";
        self.localUid = 67890;
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
    if (self.channel.length == 0 || self.localUid == 0) {
        return NO;
    }
    
    if (self.joined) {
        [self leave];
    }
    
    [agoraRtc enableLocalVideo:NO];
    [agoraRtc setDefaultMuteAllRemoteAudioStreams:YES];
    [agoraRtc joinChannelByToken:nil channelId:self.channel info:nil uid:self.localUid joinSuccess:nil];
    NSString *account = [NSString stringWithFormat:@"%ld", self.localUid];
    [agoraSig login2:kAppID account:account token:@"_no_need_token" uid:0 deviceID:0 retry_time_in_s:10 retry_count:3];
    
    _joined = YES;
    return _joined;
}

- (void)leave {
    [self stopRemoteAssistant];
    
    [agoraRtc leaveChannel:nil];
    [agoraSig logout];
    
    [_remoteUsers removeAllObjects];
    _selectedRemoteUser = 0;
    _joined = NO;
}

- (BOOL)startRemoteAssistant:(NSView *)view {
    if (_remoteUid != 0) {
        return NO;
    }
    
    if (view) {
        parentView = view;
        videoView = nil;
        remoteVideoSize = CGSizeZero;
        _remoteUid = self.selectedRemoteUser;
        [agoraRtc muteRemoteVideoStream:_remoteUid mute:NO];
        [self sendControlCommand:AgoraRemoteOperationTypeStartAssistant info:nil];
    }
    else {
        [agoraRtc startScreenCapture:0 withCaptureFreq:15 bitRate:0 andRect:CGRectZero];
        [agoraRtc enableLocalVideo:YES];
        [agoraRtc setVideoResolution:screenSize andFrameRate:15 bitrate:2000];
        //[agoraRtc setVideoResolution:CGSizeMake(1280, 800) andFrameRate:15 bitrate:2000];
    }
    
    return YES;
}

- (void)stopRemoteAssistant {
    if (_remoteUid == 0) {
        return;
    }
    
    if (parentView) {
        [self clearMouseClickCache];
        mouseClickCache = nil;
        
        [self sendControlCommand:AgoraRemoteOperationTypeStopAssistant info:nil];
        
        AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
        canvas.uid = _remoteUid;
        [agoraRtc setupRemoteVideo:canvas];
        [agoraRtc muteRemoteVideoStream:_remoteUid mute:YES];
        
        [videoView removeFromSuperview];
        videoView = nil;
        parentView = nil;
    }
    else {
        [agoraRtc enableLocalVideo:NO];
    }
    
    _remoteUid = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteAssistantStoped object:nil userInfo:nil];
}

- (void)sendControlCommand:(AgoraRemoteOperationType)type info:(NSDictionary *)info {
    AgoraRemoteOperation *command = [[AgoraRemoteOperation alloc] initWithType:type
                                                                     timeStamp:[NSDate date].timeIntervalSince1970
                                                                     extraInfo:info];
    NSString *msg = [command convertToJsonString];
    NSString *remoteUser = [NSString stringWithFormat:@"%ld", _remoteUid];
    [agoraSig messageInstantSend:remoteUser uid:0 msg:msg msgID:nil];
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
            NSString *remoteUser = [NSString stringWithFormat:@"%ld", self.selectedRemoteUser];
            [agoraSig messageInstantSend:remoteUser uid:0 msg:msg msgID:nil];
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
//    agoraSig.onChannelJoinFailed = ^(NSString *channelID, AgoraEcode ecode) {
//        NSLog(@"Join sig channel failed, error: %lu", ecode);
//    };
//    agoraSig.onChannelJoined = ^(NSString *channelID) {
//        NSLog(@"Join sig channel successfully");
//    };
//    agoraSig.onChannelLeaved = ^(NSString *channelID, AgoraEcode ecode) {
//        if (ecode != AgoraEcode_LEAVECHANNEL_E_BYUSER) {
//            NSLog(@"onChannelLeaved, ecode: %lu", ecode);
//        }
//    };
//    agoraSig.onChannelUserList = ^(NSMutableArray *accounts, NSMutableArray *uids) {
//        __strong typeof(self) strongSelf = weakSelf;
//        [accounts removeObject:strongSelf.account];
//        NSLog(@"onChannelUserList, accounts: %@", accounts);
//
//        strongSelf->_remoteUsers = accounts;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:strongSelf->_remoteUsers userInfo:nil];
//    };
//    agoraSig.onChannelUserJoined = ^(NSString *account, uint32_t uid) {
//        NSLog(@"onChannelUserJoined, account: %@", account);
//        __strong typeof(self) strongSelf = weakSelf;
//        [strongSelf->_remoteUsers addObject:account];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:strongSelf->_remoteUsers userInfo:nil];
//    };
//    agoraSig.onChannelUserLeaved = ^(NSString *account, uint32_t uid) {
//        NSLog(@"onChannelUserLeaved, account: %@", account);
//        __strong typeof(self) strongSelf = weakSelf;
//        [strongSelf->_remoteUsers removeObject:account];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:strongSelf->_remoteUsers userInfo:nil];
//    };
    agoraSig.onMessageInstantReceive = ^(NSString *account, uint32_t uid, NSString *msg) {
        NSArray<AgoraRemoteOperation *> *operations = [AgoraRemoteOperation parseJsonString:msg];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            for (AgoraRemoteOperation *operation in operations) {
                if (operation.type == AgoraRemoteOperationTypeStartAssistant) {
                    if ([strongSelf startRemoteAssistant:nil]) {
                        strongSelf->_remoteUid = [account integerValue];
                    }
                }
                else if ([account integerValue] == strongSelf->_remoteUid) {
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
            unichar agoraKeyCode = [operation.extraInfo[@"keyCode"] unsignedShortValue];
            CGKeyCode keyCode = [AgoraRemoteOperation agoraKeyCodeToCGKeyCode:agoraKeyCode];
            if (keyCode != USHRT_MAX) {
                [keyboard sendKeyDown:keyCode];
                [keyboard sendKeyUp:keyCode];
            }
        }
            break;
            
        case AgoraRemoteOperationTypeKeyboardKeyDown:
        {
            unichar agoraKeyCode = [operation.extraInfo[@"keyCode"] unsignedShortValue];
            CGKeyCode keyCode = [AgoraRemoteOperation agoraKeyCodeToCGKeyCode:agoraKeyCode];
            if (keyCode != USHRT_MAX) {
                [keyboard sendKeyDown:keyCode];
            }
        }
            break;
            
        case AgoraRemoteOperationTypeKeyboardKeyUp:
        {
            unichar agoraKeyCode = [operation.extraInfo[@"keyCode"] unsignedShortValue];
            CGKeyCode keyCode = [AgoraRemoteOperation agoraKeyCodeToCGKeyCode:agoraKeyCode];
            if (keyCode != USHRT_MAX) {
                [keyboard sendKeyUp:keyCode];
            }
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

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyPress:(CGKeyCode)keyCode {
    CGKeyCode agoraKeyCode = [AgoraRemoteOperation cgKeyCodeToAgoraKeyCode:keyCode];
    NSDictionary *info = @{@"keyCode": @(agoraKeyCode)};
    [self sendControlCommand:AgoraRemoteOperationTypeKeyboardKeyPress info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyDown:(CGKeyCode)keyCode {
    CGKeyCode agoraKeyCode = [AgoraRemoteOperation cgKeyCodeToAgoraKeyCode:keyCode];
    NSDictionary *info = @{@"keyCode": @(agoraKeyCode)};
    [self sendControlCommand:AgoraRemoteOperationTypeKeyboardKeyDown info:info];
}

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyUp:(CGKeyCode)keyCode {
    CGKeyCode agoraKeyCode = [AgoraRemoteOperation cgKeyCodeToAgoraKeyCode:keyCode];
    NSDictionary *info = @{@"keyCode": @(agoraKeyCode)};
    [self sendControlCommand:AgoraRemoteOperationTypeKeyboardKeyUp info:info];
}

#pragma mark - AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    NSLog(@"join channel success");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"remote user joined, uid: %ld", uid);
    [_remoteUsers addObject:@(uid)];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:_remoteUsers userInfo:nil];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    NSLog(@"remote user offline, uid: %ld", uid);
    if (self.selectedRemoteUser == uid) {
        [self stopRemoteAssistant];
    }
    
    [_remoteUsers removeObject:@(uid)];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoteUserListUpdated object:_remoteUsers userInfo:nil];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    if (parentView == nil) {
        return;
    }
    
    if (uid != _remoteUid) {
        return;
    }
    
    remoteVideoSize = size;
    
    if (videoView == nil) {
        [self addVideoView];
        
        AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
        canvas.uid = uid;
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
    
    if (uid != _remoteUid) {
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

@end
