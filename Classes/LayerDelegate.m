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

- (CALayer*)prepareAnimLayer:(CALayer*)layer withName:(NSString*)name {
    layer.name = name;
    layer.delegate = self;
    layer.contentsScale = _view.layer.contentsScale;
    layer.anchorPoint = CGPointZero;
    layer.position = CGPointZero;
    layer.bounds = CGRectMake(0, 0, _view.frame.size.width, _view.frame.size.height);
    [layer setNeedsDisplay];
    return layer;
}

- (CALayer*)makeLayerWithName:(NSString*)name {
    CALayer *newLayer = [CALayer layer];
    return [self prepareAnimLayer:newLayer withName:name];
}

@end