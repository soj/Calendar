#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"
#import "CalendarDayController.h"

#define PIXELS_PER_HOUR			100.0

@interface CalendarController : UIViewController <CalendarDayDelegate, UIScrollViewDelegate> {
	NSMutableDictionary *_calendarDays;
	
	float _pixelsPerHour;
}

- (void)createDateControllerForDay:(int)day;

@end
