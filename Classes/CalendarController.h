//
//  CalendarController.h
//  calendar
//
//  Created by Fravic Fernando on 12-06-16.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarDayDelegate.h"

#define PIXELS_PER_HOUR			100.0

@interface CalendarController : UIViewController <CalendarDayDelegate, UIScrollViewDelegate> {
	float _pixelsPerHour;
}

@end
