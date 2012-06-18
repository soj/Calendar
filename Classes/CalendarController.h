#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CalendarDayDelegate.h"
#import "CalendarDayController.h"
#import "CategoryChooserController.h"

#define PIXELS_PER_HOUR			100.0
#define PIXELS_PER_DAY			320.0

@interface CalendarController : UIViewController <CalendarDayDelegate, CategoryChooserDelegate, UIScrollViewDelegate> {
	Calendar *_calendar;
	UIScrollView *_scrollView;
	
	NSMutableDictionary *_calendarDays;
	NSTimeInterval _today, _yesterday, _tomorrow;
	float _pixelsPerHour;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (void)createDayControllerForStartTime:(NSTimeInterval)time;
- (void)setToday:(NSTimeInterval)today;

@end
