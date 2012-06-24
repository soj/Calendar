#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"
#import "CalendarDay.h"
#import "CalendarEvent.h"
#import "Event.h"

@interface CalendarDayController : UIViewController <UIScrollViewDelegate> {
	id<CalendarDayDelegate> _delegate;
	CalendarEvent *_activeEventBlock;
	NSMutableSet *_eventBlocks;
		
	NSTimeInterval _startTime;
	NSTimeInterval _topTime;
}

@property (readonly) NSTimeInterval startTime;

- (id)initWithStartTime:(NSTimeInterval)startTime andDelegate:(id <CalendarDayDelegate>)delegate;
- (void)setEvents:(NSArray*)events;

- (void)createGestureRecognizers;
- (void)createCalendarDay;
- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)time;
- (void)checkForEventBlocksParallelTo:(CalendarEvent*)event;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

