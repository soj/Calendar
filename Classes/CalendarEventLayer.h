#import <QuartzCore/QuartzCore.h>

#define UI_DEPTH_BORDER_WIDTH   7.0
#define UI_DEPTH_BORDER_HEIGHT  5.0

@interface CalendarEventLayer : CALayer

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic, strong) CALayer *parent;

- (id)initWithParent:(CALayer*)parent;

- (CGRect)defaultFrame;
- (CGRect)activeFrame;
- (CGRect)squashFrameWithProgress:(float)prog;

@end
