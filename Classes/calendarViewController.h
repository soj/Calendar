//
//  calendarViewController.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarViewDelegate.h"
#import "CalendarView.h"
#import "EventBlock.h"

#define SCROLL_DECEL	0.98
#define SCROLL_RATIO	1.0
#define SCROLL_MAX		15000.0
#define TIMER_INTERVAL	0.03
#define PIXELS_PER_HOUR	100.0

@interface calendarViewController : UIViewController <CalendarViewDelegate> {
	CalendarView *_calendarView;
	NSTimer *_updateTimer;
	EventBlock *_activeEventBlock;
	
	float _scrollVel;
}

- (NSTimeInterval)pixelToTime:(float)pixel;
- (void)createGestureRecognizers;
- (void)runLoop;

@end

