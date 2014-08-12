#import "DepthLayer.h"
#import "UIColor+Tools.h"

@implementation DepthLayer

@synthesize depthWidth, darkenedColor;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"depthWidth"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)initWithParent:(CALayer *)parent {
    if (self = [super initWithParent:parent]) {
        self.name = @"Depth";
        [self setNeedsDisplayOnBoundsChange:YES];
    }
    return self;
}

- (id)initWithLayer:(DepthLayer*)layer {
    // During animation, CA makes a copy of the layer via this method
    // Instance variables are *not* automatically copied over, so do it here
    self.parent = layer.parent;
    self.baseColor = layer.baseColor;
    self.darkenedColor = layer.darkenedColor;
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    // Depth width is necessary to make the layer redraw at every frame of animation
    self.depthWidth = frame.size.width;
}

- (void)setBaseColor:(UIColor *)baseColor {
    [super setBaseColor:baseColor];
    self.darkenedColor = [self.baseColor colorByDarkeningColor:UI_DEPTH_BORDER_DARKEN];
}

- (CGRect)defaultFrame {
    return CGRectMake(-UI_DEPTH_BORDER_WIDTH, -UI_DEPTH_BORDER_HEIGHT,
                      self.parent.bounds.size.width + UI_DEPTH_BORDER_WIDTH,
                      self.parent.bounds.size.height + UI_DEPTH_BORDER_HEIGHT);
}

- (CGRect)activeFrame {
    return [self defaultFrame];
}

- (CGRect)squashFrameWithProgress:(float)prog active:(BOOL)active {
    CGRect def = [super squashFrameWithProgress:prog active:active];
    return CGRectMake(def.origin.x + prog, def.origin.y,
                      def.size.width - prog, def.size.height);
}

- (void)drawInContext:(CGContextRef)context {
    int width = floorf(self.depthWidth);
    int height = floorf(self.bounds.size.height);
    int x = floorf(self.bounds.size.width - width);
    
    CGContextClearRect(context, self.bounds);
    
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
