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

@end