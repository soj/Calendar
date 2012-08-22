#import "CategoryLayer.h"

@implementation CategoryLayer

- (void)setBaseColor:(UIColor *)baseColor {
    self.backgroundColor = baseColor.CGColor;
}

- (CGRect)defaultFrame {
    return CGRectMake(UI_HIGHLIGHT_PADDING, UI_HIGHLIGHT_PADDING,
                      0, UI_CATEGORY_BOX_SIZE);
}

- (CGRect)activeFrame {
    CGRect def = [super activeFrame];
    return CGRectMake(def.origin.x, def.origin.y,
                      UI_CATEGORY_BOX_SIZE, def.size.height);
}

- (CGRect)squashFrameWithProgress:(float)prog {
    CGRect def = [self activeFrame];
    return CGRectMake(def.origin.x + prog, def.origin.y,
                      def.size.width, def.size.height);
}

@end
