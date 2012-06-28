#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CalendarDayDelegate.h"
#import "CalendarDayController.h"
#import "CategoryChooserController.h"

#define PIXELS_PER_HOUR			100.0
#define PIXELS_PER_DAY			320.0

#define EVENT_TIME_GRANULARITY	15 * SECONDS_PER_MINUTE

@interface CalendarController : UIViewController <CalendarDayDelegate, UIScrollViewDelegate> {
	Calendar *_calendar;
	UIScrollView *_scrollView;
    CategoryChooserController *_catController;
	
	NSMutableDictionary *_calendarDays;
	NSTimeInterval _today, _yesterday, _tomorrow;
	float _pixelsPerHour;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (void)createDayControllerForStartTime:(NSTimeInterval)time;
- (void)setToday:(NSTimeInterval)today;
- (void)prepareToExit;

- (NSTimeInterval)floorTime:(NSTimeInterval)time toHour:(int)hour andMinutes:(int)minutes;

@end
