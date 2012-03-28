//
//  EventBlockDrawer.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-22.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarViewDelegate.h"

#define MIN_TIME_INTERVAL	3600/2

#define BORDER_COLOR		[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define EVENT_DX			65.0

@interface EventBlock : NSObject {
	id<CalendarViewDelegate> delegate;
	
	NSTimeInterval _startTime;
	NSTimeInterval _endTime;
}

@property (retain) id delegate;

@property (setter=setStartTime) NSTimeInterval startTime;
@property (setter=setEndTime) NSTimeInterval endTime;

- (void)drawInContext:(CGContextRef)context;

@end
