#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"
#import "CalendarDayController.h"

#define PIXELS_PER_HOUR			100.0
#define PIXELS_PER_DAY			320.0

@interface CalendarController : UIViewController <CalendarDayDelegate, UIScrollViewDelegate> {
	NSMutableDictionary *_calendarDays;
	
	NSTimeInterval _today, _yesterday, _tomorrow;
	float _pixelsPerHour;
}

- (void)createDayControllerForStartTime:(NSTimeInterval)time;
- (void)setToday:(NSTimeInterval)today;

@end
