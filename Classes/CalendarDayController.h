#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"
#import "CalendarDay.h"
#import "CalendarEvent.h"

#define TIME_INTERVAL_BUFFER	SECONDS_PER_HOUR * 24
#define SCROLL_BUFFER			TIME_INTERVAL_BUFFER / SECONDS_PER_HOUR * PIXELS_PER_HOUR

@interface CalendarDayController : UIViewController <UIScrollViewDelegate> {
	id<CalendarDayDelegate> _delegate;
	CalendarEvent *_activeEventBlock;
	NSMutableSet *_eventBlocks;
		
	NSTimeInterval _startTime;
	NSTimeInterval _topTime;
}

@property (readonly) NSTimeInterval startTime;

- (id)initWithStartTime:(NSTimeInterval)startTime andDelegate:(id <CalendarDayDelegate>)delegate;
- (void)createGestureRecognizers;
- (void)createCalendarDay;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

