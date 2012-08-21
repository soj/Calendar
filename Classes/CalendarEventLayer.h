#import <QuartzCore/QuartzCore.h>

@interface CalendarEventLayer : CALayer

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic, strong) CALayer *parent;

- (id)initWithParent:(CALayer*)parent;

- (CGRect)defaultFrame;
- (CGRect)activeFrame;
- (CGRect)squashFrameWithProgress:(float)prog;

@end
