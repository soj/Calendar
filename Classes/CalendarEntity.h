#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"

#define MIN_TIME_INTERVAL	3600/2

@interface CalendarEntity : UIView {
	id<CalendarDayDelegate> _delegate;
	
	NSObject *_entKey;
	NSTimeInterval _startTime;
	NSTimeInterval _endTime;
}

@property (retain) id delegate;
@property (retain) NSObject *entKey;
@property (setter=setStartTime) NSTimeInterval startTime;
@property (setter=setEndTime) NSTimeInterval endTime;

- (id)initWithSize:(CGSize)size startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime andDelegate:(id)delegate;
- (void)drawInContext:(CGContextRef)context;

@end
