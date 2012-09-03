#import <QuartzCore/QuartzCore.h>

#define UI_DEPTH_BORDER_WIDTH       7.0
#define UI_DEPTH_BORDER_HEIGHT      5.0

#define UI_BOX_BORDER_WIDTH         1.0

#define UI_BOX_BORDER_PADDING_X     10.0
#define UI_BOX_BORDER_PADDING_Y     5.0
#define UI_BOX_BORDER_MARGIN_Y      2.0

#define UI_EVENT_BG_COLOR       [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]

@interface CalendarEventLayer : CALayer

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic, strong) CALayer *parent;

- (id)initWithParent:(CALayer*)parent;

- (CGRect)defaultFrame;
- (CGRect)activeFrame;
- (CGRect)squashFrameWithProgress:(float)prog active:(BOOL)active;

@end
