#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"

#define MIN_TIME_INTERVAL	3600/2

@interface CalendarEntity : UIView {
	id<CalendarDayDelegate> _delegate;
	
	NSObject *_entKey;
    NSTimeInterval _baseTime;
	NSTimeInterval _startTime;
	NSTimeInterval _endTime;
}

@property (retain) id delegate;
@property (retain) NSObject *entKey;
@property (setter=setStartTime) NSTimeInterval startTime;
@property (setter=setEndTime) NSTimeInterval endTime;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate;
- (void)drawInContext:(CGContextRef)context;

- (CGRect)reframe;

@end
