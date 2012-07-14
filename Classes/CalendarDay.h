#import <UIKit/UIKit.h>
#import "CalendarEntity.h"

#define TIME_LINES_X		50.0
#define LINE_TEXT_X			5.0
#define LINE_TEXT_DY		-20.0
#define LINE_TEXT_BIG_DY	-16.0
#define LINE_TEXT_SUB_DY	6.0

#define DAY_LINE_COLOR		0.059, 0.059, 0.059, 1.0
#define CURRENT_LINE_COLOR	1.0, 0.6, 0.6, 1.0

#define DAY_TOP_OFFSET		15.0f

#define MEDIUM_BOLD_FONT    [UIFont fontWithName:@"Helvetica-Bold" size:22.0]
#define MEDIUM_FONT         [UIFont fontWithName:@"Helvetica" size:22.0]
#define MEDIUM_LIGHT_FONT   [UIFont fontWithName:@"Helvetica-Light" size:22.0]
#define SMALL_FONT          [UIFont fontWithName:@"Helvetica" size:13.0]


@interface CalendarDay : CalendarEntity {
	NSTimeInterval _currentTime;
}

@property (nonatomic) NSTimeInterval currentTime;

- (float)yPosFromTime:(NSTimeInterval)time;
- (NSString*)dateStringFromTime:(NSTimeInterval)time withFormat:(NSString*)format;

- (void)drawHourLine:(NSTimeInterval)time inContext:(CGContextRef)context;
- (void)drawDayLine:(NSTimeInterval)time inContext:(CGContextRef)context;
- (void)drawCurrentTimeLine:(NSTimeInterval)time inContext:(CGContextRef)context;
- (void)drawLineAtY:(int)yPos inContext:(CGContextRef)context;
- (void)drawFullBleedLineAtY:(int)yPos inContext:(CGContextRef)context;

@end
