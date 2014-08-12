#import <UIKit/UIKit.h>
#import "CalendarDay.h"
#import "CalendarEvent.h"
#import "Event.h"

#define MIN_EVENT_TIME_INTERVAL     SECONDS_PER_HOUR / 2

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

	CalendarDay *_calendarDay;
	CalendarEvent *_activeEventBlock;
	NSMutableSet *_eventBlocks;
    
    UIPanGestureRecognizer *_eventBlockPan;
    UIPanGestureRecognizer *_eventBlockHorizontalPan;
    UILongPressGestureRecognizer *_eventBlockLongPress;
	
	NSTimeInterval _startTime;
	NSTimeInterval _topTime;
	
	DragType _dragType;
    NSTimeInterval _dragEventTimeOffset;
}

@property (readonly) NSTimeInterval startTime;
@property (nonatomic,weak) id <CalendarDayDelegate> delegate;
@property (nonatomic,strong) NSTimer *timer;

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

