#import <UIKit/UIKit.h>

#define MIN_TIME_INTERVAL	SECONDS_PER_HOUR / 2

@interface CalendarEntity : UIView {	
    NSTimeInterval _baseTime;
	NSTimeInterval _startTime;
	NSTimeInterval _endTime;
}

@property (nonatomic, setter=setStartTime:) NSTimeInterval startTime;
@property (nonatomic, setter=setEndTime:) NSTimeInterval endTime;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
- (void)drawInContext:(CGContextRef)context;

- (CGRect)reframe;

@end
