#import "RailLayer.h"

#import "UIConstants.h"

@implementation RailLayer

- (void)setBaseColor:(UIColor *)baseColor {
    [super setBaseColor:baseColor];
    self.backgroundColor = baseColor.CGColor;
}

- (CGRect)defaultFrame {
    return CGRectMake(self.parent.frame.size.width - UI_RAIL_COLOR_WIDTH, 0,
                      UI_RAIL_COLOR_WIDTH, self.parent.frame.size.height);
}

@end
