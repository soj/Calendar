#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"
#import "CalendarDay.h"
#import "CalendarEvent.h"

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
- (void)checkForEventBlocksParallelTo:(CalendarEvent*)event;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

