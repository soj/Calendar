#import "CalendarEventLayer.h"

@implementation CalendarEventLayer

@synthesize baseColor, parent;

- (id)initWithParent:(CALayer*)parentLayer {
    if (self == [super init]) {
        self.parent = parentLayer;
        
        self.contentsScale = parent.contentsScale;
        self.anchorPoint = CGPointZero;
        
        [self disableAnims];
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
}

- (CGRect)activeFrame {
}

- (CGRect)squashFrameWithProgress:(float)prog {
}

@end