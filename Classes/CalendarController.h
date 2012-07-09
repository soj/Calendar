#import <UIKit/UIKit.h>
#import "Calendar.h"
#import "CalendarDayController.h"
#import "CategoryChooserController.h"

// TODO: Make this a setting
#define SHOW_NOTIFICATIONS      YES

#define MIN_NOTIFICATION_FUTURE SECONDS_PER_MINUTE * 15

@interface CalendarController : UIViewController <CalendarDayDelegate, UIScrollViewDelegate> {
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
