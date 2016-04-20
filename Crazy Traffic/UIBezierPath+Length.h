@import UIKit;

@interface UIBezierPath (Length)

- (CGFloat)length;

- (CGPoint)pointAtPercentOfLength:(CGFloat)percent tangent:(CGFloat *)tan;
- (CGPoint)pointAtPercentOfLength:(CGFloat)percent;

@end
