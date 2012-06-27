#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"

#define MIN_TIME_INTERVAL	SECONDS_PER_HOUR / 2

@interface CalendarEntity : UIView {
	id<CalendarDayDelegate> _delegate;
	
    NSTimeInterval _baseTime;
	NSTimeInterval _startTime;
	NSTimeInterval _endTime;
}

@property (strong) id delegate;
@property (nonatomic, setter=setStartTime:) NSTimeInterval startTime;
@property (nonatomic, setter=setEndTime:) NSTimeInterval endTime;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate;
- (void)drawInContext:(CGContextRef)context;

- (CGRect)reframe;

@end
