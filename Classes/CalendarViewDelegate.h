//
//  TouchViewDelegate.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarViewDelegate
- (float)timeToPixel:(NSTimeInterval)time;
- (NSTimeInterval)pixelToTime:(float)pixel;
- (float)getPixelsPerHour;
- (NSTimeInterval)getVisibleTimeInterval;
- (NSInteger)calendarHourFromReferenceHour:(int)refHour;
@end
