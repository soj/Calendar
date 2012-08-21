#import "CategoryLayer.h"

@implementation CategoryLayer

- (void)setBaseColor:(UIColor *)baseColor {
    self.backgroundColor = baseColor.CGColor;
}

- (CGRect)defaultFrame {
    return CGRectMake(UI_HIGHLIGHT_PADDING, UI_HIGHLIGHT_PADDING,
                      0, UI_HIGHLIGHT_HEIGHT);
}

- (CGRect)activeFrame {
    return CGRectMake(UI_HIGHLIGHT_PADDING, UI_HIGHLIGHT_PADDING,
                      UI_HIGHLIGHT_HEIGHT, UI_HIGHLIGHT_HEIGHT);
}

- (CGRect)squashFrameWithProgress:(float)prog {
    CGRect def = [self activeFrame];
    return CGRectMake(def.origin.x + prog, def.origin.y,
                      def.size.width, def.size.height);
}

@end
