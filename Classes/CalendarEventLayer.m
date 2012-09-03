#import "CalendarEventLayer.h"

@implementation CalendarEventLayer

@synthesize baseColor, parent;

- (id)init {
    if (self = [super init]) {
        self.anchorPoint = CGPointZero;
        [self disableAnims];
    }
    return self;
}

- (id)initWithParent:(CALayer*)parentLayer {
    if (self == [self init]) {
        self.parent = parentLayer;
        self.contentsScale = parent.contentsScale;
    }
    return self;
}

- (void)disableAnims {
    NSMutableDictionary *disableAnims = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                         [NSNull null], @"bounds",
                                         [NSNull null], @"position",
                                         [NSNull null], @"frame",
                                         nil];
    self.actions = disableAnims;
}

- (CGRect)defaultFrame {
    return CGRectMake(0, 0, self.parent.frame.size.width, self.parent.frame.size.height);
}

- (CGRect)activeFrame {
    CGRect def = [self defaultFrame];
    return CGRectMake(def.origin.x - UI_DEPTH_BORDER_WIDTH,
                      def.origin.y - UI_DEPTH_BORDER_HEIGHT,
                      def.size.width, def.size.height);
}

- (CGRect)squashFrameWithProgress:(float)prog active:(BOOL)active {
    return active ? [self activeFrame] : [self defaultFrame];
}

@end