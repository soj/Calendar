//
//  CalendarEntityFactory.m
//  calendar
//
//  Created by Fravic Fernando on 12-04-04.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "CalendarEntityFactory.h"


@implementation CalendarEntityFactory

@synthesize view=_view;

+ (CalendarEntity*)createCalendarEntityWithSize:size startTime:topTimeOffset endTime:endTime andDelegate:self {
	
}

+ (CalendarDay*)createCalendarDayEntityWithSize:size startTime:startTime endTime:endTime andDelegate:self {
}

@end
