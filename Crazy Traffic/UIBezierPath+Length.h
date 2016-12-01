@import UIKit;

typedef struct BezierSubpath {
    CGPoint startPoint;
    CGPoint controlPoint1;
    CGPoint controlPoint2;
    CGPoint endPoint;
    CGFloat length;
    CGPathElementType type;
} BezierSubpath;

@interface UIBezierPath (Length)

- (CGFloat)length;

- (CGPoint)pointAtPercentOfLength:(CGFloat)percent tangent:(CGFloat *)tan;
- (CGPoint)pointAtPercentOfLength:(CGFloat)percent;
- (BezierSubpath)pathAtPercentOfLength:(CGFloat)percent tangent:(CGFloat *)tan;
- (float) quadTan:(CGFloat) t a:(CGPoint) start b:(CGPoint) c1 c:(CGPoint) end;

@end
