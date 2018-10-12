#import <Foundation/Foundation.h>

@interface AgoraMouseControl : NSObject

+ (AgoraMouseControl *)getInstance;
    
- (CGPoint)getCursorPositionCGPoint;
- (void)leftMouseDown:(BOOL)isDoubleClick;
- (void)leftMouseUp:(BOOL)isDoubleClick;
- (void)moveMouseTo:(CGPoint)point;
- (void)mouseScrollVertical:(int)scrollLength;
- (void)mouseScrollHorizontal:(int)scrollLength;
- (void)rightMouseDown;
- (void)rightMouseUp;
- (void)zoom:(int)value count:(int)count;

@end
