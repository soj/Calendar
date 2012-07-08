#import "UIGestureRecognizer+Tools.h"

@implementation UIGestureRecognizer (Tools)

- (void)cancel {
    self.enabled = NO;
    self.enabled = YES;
}

@end
