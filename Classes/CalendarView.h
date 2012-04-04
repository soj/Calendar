//
//  CalendarView.h
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarViewDelegate.h"
#import "EventBlock.h"

#define SCREEN_H			480.0
#define SCREEN_W			320.0
#define TIME_LINES_X		50.0
#define LINE_TEXT_X			5.0
#define LINE_TEXT_DY		-9.0
#define LINE_TEXT_BIG_DY	-16.0
#define LINE_TEXT_SUB_DY	6.0
#define LINE_FONT_SIZE		13.0
#define LINE_BIG_FONT_SIZE	20.0

#define BG_BLACK			0.05
#define LINES_WHITE			0.9

#define SECONDS_PER_HOUR	3600

@interface CalendarView : UIView {
	id<CalendarViewDelegate> delegate;
	
	NSMutableSet *_visibleEntities;
	NSMutableArray *_eventBlocks;
	float _pixelsPerHour;
	NSTimeInterval _topTime;  // The timeSinceReferenceDate corresponding to the top of the screen
	NSTimeInterval _baseTime;
}

@property (retain) id delegate;
@property NSTimeInterval topTime;
@property NSTimeInterval baseTime;
@property float pixelsPerHour;

- (void)addEventBlock:(EventBlock*)eventBlock;

- (NSArray*)getVisibleHours;
- (NSArray*)getVisibleEventBlocks;
- (BOOL)visibilityChange;

- (BOOL)isMidnight:(int)refHour;
- (NSInteger)calendarHourFromReferenceHour:(int)refHour;
- (float)yPosFromRefHour:(int)refHour;
- (NSString*)dateStringFromRefHour:(int)refHour withFormat:(NSString*)format;

- (void)drawInContext:(CGContextRef)context;
- (void)drawCalendarLinesInContext:(CGContextRef)context;
- (void)drawEventBlocksInContext:(CGContextRef)context;
- (void)drawHourLine:(int)refHour inContext:(CGContextRef)context;
- (void)drawDayLine:(int)refHour inContext:(CGContextRef)context;
- (void)drawLineAtY:(int)yPos inContext:(CGContextRef)context;

@end
