#import <UIKit/UIKit.h>
#import "CalendarDay.h"
#import "CalendarEvent.h"
#import "Event.h"

#define EDGE_DRAG_PIXELS		40.0f

typedef enum {
    kDragStartTime,
    kDragEndTime,
    kDragBoth
} DragType;

@protocol CalendarDayDelegate
- (void)showCategoryChooserWithDelegate:(id<CategoryChooserDelegate>)delegate;
- (void)createEventWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
@end

@interface CalendarDayController : UIViewController <UIScrollViewDelegate, CalendarEventDelegate> {
	id<CalendarDayDelegate> _delegate;
	CalendarDay *_calendarDay;
	CalendarEvent *_activeEventBlock;
	NSMutableSet *_eventBlocks;
    
    UIPanGestureRecognizer *_eventBlockPan;
	
	NSTimeInterval _startTime;
	NSTimeInterval _topTime;
	
	DragType _dragType;
    NSTimeInterval _prevDragTime;
}

@property (readonly) NSTimeInterval startTime;

- (id)initWithStartTime:(NSTimeInterval)startTime andDelegate:(id <CalendarDayDelegate>)delegate;
- (void)setEvents:(NSArray*)events;

- (void)createGestureRecognizers;
- (void)createCalendarDay;
- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)time;
- (void)checkForEventBlocksParallelTo:(CalendarEvent*)event;
- (void)setActiveEventBlock:(CalendarEvent*)event;
- (void)unsetActiveEventBlock;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

