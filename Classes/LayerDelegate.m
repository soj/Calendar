#import "LayerDelegate.h"

@implementation LayerDelegate

- (id)initWithView:(UIView*)view {
    self = [super init];
    if (self != nil) {
        _view = view;
    }
    return self;
}

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context {
    NSString* methodName = [NSString stringWithFormat: @"draw%@Layer:inContext:", layer.name];
    SEL selector = NSSelectorFromString(methodName);
    if ([_view respondsToSelector:selector]) {
        [_view performSelector:selector withObject:layer withObject:(__bridge id)context];
    }
}

- (CALayer*)makeLayerWithName:(NSString*)name {
    CALayer *newLayer = [CALayer layer];
    newLayer.name = @"Box";
    newLayer.delegate = self;
    newLayer.frame = CGRectMake(0, 0, _view.frame.size.width, _view.frame.size.height);
    newLayer.bounds = _view.bounds;
    newLayer.contentsScale = _view.layer.contentsScale;
    [newLayer setNeedsDisplay];
    return newLayer;
}

@end