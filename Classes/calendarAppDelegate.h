#import <UIKit/UIKit.h>

@class CalendarViewController;

@interface calendarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CalendarViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CalendarViewController *viewController;

@end

