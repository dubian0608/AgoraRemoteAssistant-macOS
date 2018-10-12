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
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseLeftButtonDown:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseLeftButtonUp:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseLeftButtonDoubleClick:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseRightButtonDown:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseRightButtonUp:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseRightButtonDoubleClick:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseMove:(CGPoint)position;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view mouseScrollHorizontal:(CGFloat)scrolDeltaX mouseScrollVertical:(CGFloat)scrolDeltaY;

- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyPress:(unichar)keyCode;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyDown:(unichar)keyCode;
- (void)remoteAssistantView:(AgoraRemoteAssistantView *)view keyboardKeyUp:(unichar)keyCode;
@end

@interface AgoraRemoteAssistantView : NSView

@property (weak) id<AgoraRemoteAssistantViewDelegate> delegate;

- (void)addToView:(NSView *)parentView;

@end

NS_ASSUME_NONNULL_END
