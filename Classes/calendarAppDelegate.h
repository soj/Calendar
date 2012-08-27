#import <UIKit/UIKit.h>
#import "CalendarController.h"

#define MIXPANEL_TOKEN  @"854d677f3512a9daebe2f09f43768bd9"

@class CalendarViewController;

@interface calendarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CalendarController *viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet CalendarController *viewController;

@end

