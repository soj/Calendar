#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"
#import "CalendarDay.h"
#import "CalendarEvent.h"

#define EVENT_DX			65.0
#define RIGHT_RAIL_WIDTH	45.0

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
- (void)chooseCategory:(Category*)cat;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

