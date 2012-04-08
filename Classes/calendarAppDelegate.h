//
//  calendarAppDelegate.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalendarViewController;

@interface calendarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CalendarViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CalendarViewController *viewController;

@end

