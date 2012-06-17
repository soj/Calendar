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
		
	NSTimeInterval _baseTime;
	NSTimeInterval _topTime;
}

- (id)initWithDelegate:(id <CalendarDayDelegate>)delegate;
- (void)createGestureRecognizers;
- (CalendarDay*)createCalendarDayWithStartTime:(NSTimeInterval)startTime;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

