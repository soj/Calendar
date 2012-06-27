#import <UIKit/UIKit.h>
#import "CalendarController.h"

@class CalendarViewController;

@interface calendarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CalendarController *viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet CalendarController *viewController;

@end

