#import "CalendarEventLayer.h"

#define UI_DEPTH_BORDER_DARKEN  0.8

@interface DepthLayer : CalendarEventLayer

@property (nonatomic) float depthWidth;
@property (nonatomic, strong) UIColor *darkenedColor;

@end
