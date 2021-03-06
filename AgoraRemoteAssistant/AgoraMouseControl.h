#import <Foundation/Foundation.h>

@interface AgoraMouseControl : NSObject

+ (AgoraMouseControl *)getInstance;
    
- (CGPoint)getCursorPositionCGPoint;
- (void)leftMouseDown:(BOOL)isDoubleClick position:(CGPoint)position;
- (void)leftMouseUp:(BOOL)isDoubleClick position:(CGPoint)position;
- (void)moveMouseTo:(CGPoint)position;
- (void)mouseScrollVertical:(int)scrollLength;
- (void)mouseScrollHorizontal:(int)scrollLength;
- (void)rightMouseDown:(BOOL)isDoubleClick position:(CGPoint)position;
- (void)rightMouseUp:(BOOL)isDoubleClick position:(CGPoint)position;
- (void)zoom:(int)value count:(int)count;

@end
