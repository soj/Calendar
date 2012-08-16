#import "DepthLayer.h"

@implementation DepthLayer

@synthesize depthWidth, darkenedColor;

- (id)initWithParent:(CALayer *)parent {
    if (self == [super initWithParent:parent]) {
        [self setNeedsDisplayOnBoundsChange:YES];
        self.hidden = YES;
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"depthWidth"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (CGRect)defaultFrame {
    return CGRectMake(-UI_DEPTH_BORDER_WIDTH, -UI_DEPTH_BORDER_HEIGHT,
                      self.parent.bounds.size.width, self.parent.bounds.size.height);
    
/*    [_depthLayer setFrame:CGRectMake(-UI_DEPTH_BORDER_WIDTH, -UI_DEPTH_BORDER_HEIGHT,
                                     self.frame.size.width, self.frame.size.height)];
    [_depthLayer setBounds:CGRectMake(0, 0, _depthLayer.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                                      _depthLayer.frame.size.height + UI_DEPTH_BORDER_HEIGHT)];*/
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
    if (finished) {
        self.depthWidth = self.bounds.size.width;
    }
}

- (void)drawInContext:(CGContextRef)context {
    float width = self.depthWidth;
    float height = self.bounds.size.height;
    float x = self.bounds.size.width + UI_DEPTH_BORDER_WIDTH - width;
    
    CGPoint rightLines[] = {
        CGPointMake(x + width - UI_DEPTH_BORDER_WIDTH, 0),
        CGPointMake(x + width, UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(x + width, height),
        CGPointMake(x + width - UI_DEPTH_BORDER_WIDTH, height - UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(x + width - UI_DEPTH_BORDER_WIDTH, 0),
    };
    CGContextAddLines(context, rightLines, 5);
    CGContextSetFillColorWithColor(context, [self.darkenedColor CGColor]);
    CGContextFillPath(context);
    
    CGPoint bottomLines[] = {
        CGPointMake(x + width - UI_DEPTH_BORDER_WIDTH, height - UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(x + width, height),
        CGPointMake(x + UI_DEPTH_BORDER_WIDTH, height),
        CGPointMake(x, height - UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(x + width - UI_DEPTH_BORDER_WIDTH, height - UI_DEPTH_BORDER_HEIGHT)
    };
    CGContextAddLines(context, bottomLines, 5);
    CGContextSetFillColorWithColor(context, [self.baseColor CGColor]);
    CGContextFillPath(context);
}

@end
