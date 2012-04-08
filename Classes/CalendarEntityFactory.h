//
//  CalendarEntityFactory.h
//  calendar
//
//  Created by Fravic Fernando on 12-04-04.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarEntity.h"
#import "CalendarDay.h"


@interface CalendarEntityFactory : NSObject {

}

@property (retain) UIView *view;

+ (CalendarEntity*)createCalendarEntityWithSize:size startTime:startTime endTime:endTime andDelegate:self;
+ (CalendarDay*)createCalendarDayEntityWithSize:size startTime:startTime endTime:endTime andDelegate:self;


@end
