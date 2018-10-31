//
//  AgoraRemoteAssistantView.h
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/14.
//  Copyright © 2018 Agora. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class AgoraRemoteAssistantView;

@protocol AgoraRemoteAssistantViewDelegate <NSObject>
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseLeftButtonDown:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseLeftButtonUp:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseRightButtonDown:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseRightButtonUp:(CGPoint)position isDoubleClick:(BOOL)isDoubleClick;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseMove:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseScrollHorizontal:(NSInteger)scrolDeltaX mouseScrollVertical:(NSInteger)scrolDeltaY;

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyPress:(CGKeyCode)keyCode;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyDown:(CGKeyCode)keyCode;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyUp:(CGKeyCode)keyCode;
@end

@interface AgoraRemoteAssistantView : NSView

@property (weak) id<AgoraRemoteAssistantViewDelegate> delegate;

- (void)addToView:(NSView *)parentView;

@end

NS_ASSUME_NONNULL_END
