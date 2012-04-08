//
//  calendarViewController.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityManager.h"
#import "CalendarViewDelegate.h"
#import "CalendarDay.h"
#import "EventBlock.h"

#define PIXELS_PER_HOUR			100.0
#define TIME_INTERVAL_BUFFER	SECONDS_PER_HOUR * 24
#define SCROLL_BUFFER			TIME_INTERVAL_BUFFER / SECONDS_PER_HOUR * PIXELS_PER_HOUR

@interface CalendarViewController : UIViewController <CalendarViewDelegate, UIScrollViewDelegate> {
	EntityManager *_entityManager;
	
	EventBlock *_activeEventBlock;
	NSMutableSet *_visibleEntities;
		
	NSTimeInterval _baseTime;
	NSTimeInterval _topTime;
	float _pixelsPerHour;
}

- (int)getScreenHeight;
- (int)getScreenWidth;

- (void)createCalendarDayIfNecessary;
- (BOOL)visibilityChange;
- (BOOL)getEntityVisibility:(CalendarEntity*)ent;
- (void)createGestureRecognizers;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (NSTimeInterval)pixelToTime:(float)pixel;
- (float)getPixelsPerHour;

@end

