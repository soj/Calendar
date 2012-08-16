#import <QuartzCore/QuartzCore.h>

@interface CalendarEventLayer : CALayer

@property (nonatomic, retain) UIColor *baseColor;
@property (nonatomic, retain) CALayer *parent;

- (id)initWithParent:(CALayer*)parent;

- (CGRect)defaultFrame;
- (CGRect)activeFrame;
- (CGRect)squashFrameWithProgress:(float)prog;

@end
