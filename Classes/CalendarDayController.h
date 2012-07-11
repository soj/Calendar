#import <UIKit/UIKit.h>
#import "CalendarDay.h"
#import "CalendarEvent.h"
#import "Event.h"

#define EDGE_DRAG_PIXELS		30.0f
#define FINGER_TAP_TIME_OFFSET  SECONDS_PER_MINUTE * 15

typedef enum {
    kDragStartTime,
    kDragEndTime,
    kDragBoth,
    kDragLinkedStartTime,
    kDragLinkedEndTime
} DragType;

@protocol CalendarDayDelegate
- (void)showCategoryChooserWithDelegate:(id<CategoryChooserDelegate>)delegate;
- (void)dismissCategoryChooser;
- (Event*)createEventWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

- (void)updateEvent:(NSString*)eventId title:(NSString*)title;
- (void)updateEvent:(NSString*)eventId startTime:(NSTimeInterval)startTime;
- (void)updateEvent:(NSString*)eventId endTime:(NSTimeInterval)endTime;
- (void)updateEvent:(NSString*)eventId category:(Category*)category;
- (void)deleteEvent:(NSString*)eventId;
- (BOOL)eventIsValid:(NSString*)eventId;
@end

@interface CalendarDayController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, CalendarEventDelegate, CategoryChooserDelegate> {
	id<CalendarDayDelegate> _delegate;
	CalendarDay *_calendarDay;
	CalendarEvent *_activeEventBlock;
	NSMutableSet *_eventBlocks;
    
    UIPanGestureRecognizer *_eventBlockPan;
	
	NSTimeInterval _startTime;
	NSTimeInterval _topTime;
	
	DragType _dragType;
    NSTimeInterval _dragEventTimeOffset;
}

@property (readonly) NSTimeInterval startTime;

- (id)initWithStartTime:(NSTimeInterval)startTime andDelegate:(id <CalendarDayDelegate>)delegate;
- (void)setEvents:(NSArray*)events;
- (void)scrollToEntity:(CalendarEntity*)ent;
- (void)scrollToTime:(NSTimeInterval)time;

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
- (CalendarEvent*)createEventBlockWithExistingEvent:(Event*)event;
- (CalendarEvent*)createNewEventWithStartTime:(NSTimeInterval)time;

- (void)createGestureRecognizers;
- (void)createCalendarDay;

- (void)setActiveEventBlock:(CalendarEvent*)event;
- (void)unsetActiveEventBlock;

- (NSTimeInterval)boundaryBeforeTime:(NSTimeInterval)time;
- (NSTimeInterval)boundaryAfterTime:(NSTimeInterval)time;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

