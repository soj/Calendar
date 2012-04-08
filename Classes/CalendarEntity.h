//
//  CalendarEntity.h
//  calendar
//
//  Created by Fravic Fernando on 12-04-03.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarViewDelegate.h"

#define MIN_TIME_INTERVAL	3600/2

@interface CalendarEntity : UIView {
	id<CalendarViewDelegate> _delegate;
	
	NSObject *_entKey;
	NSTimeInterval _startTime;
	NSTimeInterval _endTime;
	BOOL _removeWhenInvisible;
}

@property (retain) id delegate;
@property (retain) NSObject *entKey;
@property BOOL removeWhenInvisible;
@property (setter=setStartTime) NSTimeInterval startTime;
@property (setter=setEndTime) NSTimeInterval endTime;

- (id)initWithSize:(CGSize)size startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime andDelegate:(id)delegate;

@end
