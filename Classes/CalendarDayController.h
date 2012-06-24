#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"
#import "CalendarDay.h"
#import "CalendarEvent.h"
#import "Event.h"

#define EDGE_DRAG_PIXELS		40.0f

@interface CalendarDayController : UIViewController <UIScrollViewDelegate> {
	id<CalendarDayDelegate> _delegate;
	CalendarDay *_calendarDay;
	CalendarEvent *_activeEventBlock;
	NSMutableSet *_eventBlocks;
	
	NSTimeInterval _startTime;
	NSTimeInterval _topTime;
	NSTimeInterval _initDragTime;
	
	BOOL _dragStartTime;
	float _initDragPos;
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

