#import "BoxLayer.h"

@implementation BoxLayer

- (id)initWithParent:(CALayer *)parent {
    if (self == [super initWithParent:parent]) {
        self.name = @"Box";
        self.borderWidth = UI_BOX_BORDER_WIDTH;
        self.backgroundColor = [UI_EVENT_BG_COLOR CGColor];
    }
    return self;
}

- (void)setBaseColor:(UIColor *)baseColor {
    [super setBaseColor:baseColor];
    self.borderColor = baseColor.CGColor;
}

- (CGRect)squashFrameWithProgress:(float)prog {
    CGRect def = [self activeFrame];
    return CGRectMake(def.origin.x + prog, def.origin.y,
                      def.size.width - prog, def.size.height);
}

@end
