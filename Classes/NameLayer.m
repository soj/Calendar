#import "NameLayer.h"

#import "UIConstants.h"

@implementation NameLayer

- (CGRect)defaultFrame {
    return CGRectMake(UI_BOX_BORDER_PADDING_X + UI_NAME_FIELD_OFFSET_X,
                      UI_BOX_BORDER_PADDING_Y + UI_NAME_FIELD_OFFSET_Y,
                      self.parent.frame.size.width - UI_BOX_BORDER_PADDING_X * 2 - UI_RAIL_COLOR_WIDTH,
                      self.parent.frame.size.height - UI_BOX_BORDER_PADDING_Y * 2);
}

- (CGRect)activeFrame {
    CGRect def = [super activeFrame];
    return CGRectMake(def.origin.x + UI_CATEGORY_BOX_SIZE,
                      def.origin.y,
                      self.parent.frame.size.width - UI_CATEGORY_BOX_SIZE -
                        UI_BOX_BORDER_PADDING_X * 2,
                      def.size.height);
}

- (CGRect)squashFrameWithProgress:(float)prog active:(BOOL)active {
    CGRect def = [self activeFrame];
    return CGRectMake(def.origin.x + prog, def.origin.y,
                      def.size.width - prog, def.size.height);
}

@end
