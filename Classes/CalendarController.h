#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CalendarDayController.h"
#import "CategoryChooserController.h"

@interface CalendarController : UIViewController <CalendarDayDelegate, UIScrollViewDelegate> {
	Calendar *_calendar;
	UIScrollView *_scrollView;
    CategoryChooserController *_catController;
	
	NSMutableDictionary *_calendarDays;
	NSTimeInterval _today, _yesterday, _tomorrow;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (void)createDayControllerForStartTime:(NSTimeInterval)time;
- (void)setToday:(NSTimeInterval)today;
- (void)prepareToExit;

@end
