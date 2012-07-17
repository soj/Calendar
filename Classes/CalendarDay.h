#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CalendarEntity.h"
#import "LayerDelegate.h"

#define UI_TIME_LINES_X         52.5
#define UI_TIME_LINES_FULL_X    65.0
#define UI_LINE_TEXT_X			5.0
#define UI_LINE_TEXT_DY         -20.0
#define UI_LINE_TEXT_BIG_DY     -16.0
#define UI_LINE_TEXT_SUB_DY     6.0

#define UI_TEXT_COLOR           0.059, 0.059, 0.059, 1.0
#define UI_TIME_LINE_COLOR      0.56, 0.56, 0.56, 1.0
#define UI_CURRENT_LINE_COLOR	1.0, 0.6, 0.6, 1.0

#define UI_DAY_TOP_OFFSET		15

#define UI_MEDIUM_BOLD_FONT    [UIFont fontWithName:@"Helvetica-Bold" size:22.0]
#define UI_MEDIUM_FONT         [UIFont fontWithName:@"Helvetica" size:22.0]
#define UI_MEDIUM_LIGHT_FONT   [UIFont fontWithName:@"Helvetica-Light" size:22.0]
#define UI_SMALL_FONT          [UIFont fontWithName:@"Helvetica" size:13.0]

#define UI_ANIM_DURATION_FADE  0.25;


@interface CalendarDay : CalendarEntity {
    CALayer *_timeLinesLayer;    
	NSTimeInterval _currentTime;
}

@property (nonatomic) NSTimeInterval currentTime;

- (void)fadeOutTimeLines;
- (void)fadeInTimeLines;

@end
