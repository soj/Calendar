#import "LayerDelegate.h"

@implementation ComplexAnimLayer

@synthesize animValue;

static NSString *animPropName = @"animValue";

+ (NSString *)animPropName {
    return animPropName;
}

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:animPropName]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

@end

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

- (ComplexAnimLayer*)makeComplexAnimLayerWithName:(NSString*)name {
    ComplexAnimLayer *newLayer = [[ComplexAnimLayer alloc] init];
    [self prepareAnimLayer:newLayer withName:name];
    return newLayer;
}

@end