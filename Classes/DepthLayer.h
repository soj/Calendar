#import "CalendarEventLayer.h"

#define UI_DEPTH_BORDER_WIDTH   7.0
#define UI_DEPTH_BORDER_HEIGHT  5.0

@interface DepthLayer : CalendarEventLayer

@property (nonatomic) float depthWidth;
@property (nonatomic, retain) UIColor *darkenedColor;

@end
