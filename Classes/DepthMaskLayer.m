#import "DepthMaskLayer.h"

@implementation DepthMaskLayer

- (id)initWithParent:(CALayer *)parent {
    if (self = [super initWithParent:parent]) {
        self.backgroundColor = [UIColor redColor].CGColor;
    }
    return self;
}

- (CGRect)defaultFrame {
    return CGRectMake(UI_DEPTH_BORDER_WIDTH, UI_DEPTH_BORDER_HEIGHT,
                      self.parent.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                      self.parent.frame.size.height + UI_DEPTH_BORDER_HEIGHT);
}

@end
