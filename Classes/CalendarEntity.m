//
//  CalendarEntity.m
//  calendar
//
//  Created by Fravic Fernando on 12-04-03.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "CalendarEntity.h"


@implementation CalendarEntity

@synthesize delegate=_delegate, startTime=_startTime, endTime=_endTime, entKey=_entKey, removeWhenInvisible=_removeWhenInvisible;

- (id)initWithSize:(CGSize)size startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
	[super init];
	
	[self setRemoveWhenInvisible:YES];
	[self setStartTime:startTime];
	[self setEndTime:endTime];
	[self setDelegate:delegate];
	
	[self setFrame:CGRectMake(0, [_delegate timeToPixel:_startTime], size.width, size.height)];
	[self setBackgroundColor:[UIColor clearColor]];
		
	return self;
}

- (void)setStartTime:(NSTimeInterval)startTime {
	_startTime = startTime;
	if (_endTime - startTime < MIN_TIME_INTERVAL) {
		_endTime = startTime + MIN_TIME_INTERVAL;
	}
	
	[self setNeedsDisplay];
}

- (void)setEndTime:(NSTimeInterval)endTime {
	_endTime = endTime;
	if (endTime - _startTime < MIN_TIME_INTERVAL) {
		_endTime = _startTime + MIN_TIME_INTERVAL;
	}
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)dealloc {
    [super dealloc];
}


@end
