#import "LayerAnimationFactory.h"

@implementation LayerAnimationFactory

+ (void)animate:(CALayer*)layer toFrame:(CGRect)frame {
    [self animateBoundsOfLayer:layer to:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self animatePositionOfLayer:layer to:frame.origin];
}

+ (void)animateBoundsOfLayer:(CALayer*)layer to:(CGRect)bounds {
    CABasicAnimation *resize = [CABasicAnimation animationWithKeyPath:@"bounds"];
    resize.fromValue = [NSValue valueWithCGRect:layer.bounds];
    resize.toValue = [NSNumber valueWithCGRect:bounds];
    resize.duration = UI_ANIM_DURATION_RAISE;
    resize.fillMode = kCAFillModeForwards;
    resize.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    layer.bounds = bounds;
    resize.delegate = layer;
    [layer addAnimation:resize forKey:@"bounds"];
}

+ (void)animatePositionOfLayer:(CALayer*)layer to:(CGPoint)pos {
    CABasicAnimation *moveBox = [CABasicAnimation animationWithKeyPath:@"position"];
    moveBox.fromValue = [NSValue valueWithCGPoint:layer.position];
    moveBox.toValue = [NSValue valueWithCGPoint:pos];
    moveBox.duration = UI_ANIM_DURATION_RAISE;
    moveBox.fillMode = kCAFillModeForwards;
    moveBox.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    layer.position = pos;
    moveBox.delegate = layer;
    [layer addAnimation:moveBox forKey:@"position"];
}

+ (void)animate:(CALayer *)layer toAlpha:(float)alpha {
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithFloat:layer.opacity];
    fadeIn.toValue = [NSNumber numberWithFloat:alpha];
    fadeIn.duration = UI_ANIM_DURATION_RAISE;
    fadeIn.fillMode = kCAFillModeForwards;
    layer.opacity = alpha;
    [layer addAnimation:fadeIn forKey:@"opacity"];    
}

@end
