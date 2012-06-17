#import <UIKit/UIKit.h>
#import "CalendarController.h"

@class CalendarViewController;

@interface calendarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CalendarController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CalendarController *viewController;

@end

