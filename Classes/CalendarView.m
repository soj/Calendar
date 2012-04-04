//
//  CalendarView.m
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "CalendarView.h"


@implementation CalendarView

@synthesize delegate, topTime=_topTime, pixelsPerHour=_pixelsPerHour, baseTime=_baseTime;

- (id)initWithCoder:(NSCoder*)decoder {
	[super initWithCoder:decoder];
	
	_eventBlocks = [[NSMutableArray alloc] init];
	_visibleEntities = [[NSMutableSet alloc] init];
	return self;
}

- (BOOL)visibilityChange {
	NSMutableSet *compSet = [[NSMutableSet alloc] init];
	NSArray *visibleHours = [self getVisibleHours];
	NSArray *visibleEventBlocks = [self getVisibleEventBlocks];
	BOOL change = NO;
	
	[compSet addObjectsFromArray:visibleHours];
	[compSet addObjectsFromArray:visibleEventBlocks];
	
	if (![compSet isEqualToSet:_visibleEntities]) {
		[_visibleEntities release];
		_visibleEntities = compSet;
		
		change = YES;
	}
	
	[visibleHours release];
	[visibleEventBlocks release];
	return change;
}

- (NSArray*)getVisibleHours {
	NSMutableArray *visibleHours = [[NSMutableArray alloc] init];
	
	int numHoursVisible = SCREEN_H / _pixelsPerHour + 2;  // +2 for top and bottom margins
	int firstHourOffset = (int)_topTime % SECONDS_PER_HOUR;
	int firstHour = ((int)_topTime - firstHourOffset) / SECONDS_PER_HOUR;
	
	for (int i = firstHour; i < firstHour + numHoursVisible; i++) {
		[visibleHours addObject:[NSNumber numberWithInt:i]];
	}
	
	return visibleHours;
}

- (NSArray*)getVisibleEventBlocks {
	NSMutableArray *eventBlocks = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [_eventBlocks objectEnumerator];
	EventBlock *block;
	int timespan = [UIScreen mainScreen].bounds.size.height / _pixelsPerHour * SECONDS_PER_HOUR;
	while (block = [e nextObject]) {
		if ((block.startTime > _topTime &&
			 block.startTime < _topTime + timespan) ||
			(block.endTime > _topTime &&
			 block.endTime < _topTime + timespan)) {
			[eventBlocks addObject:block];
		}
	}
	
	return eventBlocks;
}

- (NSInteger)calendarHourFromReferenceHour:(int)refHour {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(refHour * SECONDS_PER_HOUR)];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:date];
	NSInteger calHour = [components hour];
	return calHour;
}

- (BOOL)isMidnight:(int)refHour {
	return [self calendarHourFromReferenceHour:refHour] == 0;
}

- (NSString*)dateStringFromRefHour:(int)refHour withFormat:(NSString*)format {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(refHour * SECONDS_PER_HOUR)];
	NSDateFormatter *dateFrmt = [[NSDateFormatter alloc] init];
	[dateFrmt setDateFormat:format];
	return [[dateFrmt stringFromDate:date] lowercaseString];
}

- (float)yPosFromRefHour:(int)refHour {
	return [delegate timeToPixel:(refHour * SECONDS_PER_HOUR)];
}

- (void)drawLineAtY:(int)yPos inContext:(CGContextRef)context {
	CGContextMoveToPoint(context, TIME_LINES_X, yPos);
	CGContextAddLineToPoint(context, TIME_LINES_X + SCREEN_W, yPos);
	CGContextStrokePath(context);
}

- (void)drawDayLine:(int)refHour inContext:(CGContextRef)context {
	float yPos = [self yPosFromRefHour:refHour];

	CGContextSetLineWidth(context, 5.0);
	[self drawLineAtY:yPos inContext:context];

	CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_BIG_DY);
	[[self dateStringFromRefHour:refHour withFormat:@"EEE"] drawAtPoint:textPoint withFont:[UIFont boldSystemFontOfSize:LINE_BIG_FONT_SIZE]];
	
	textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_SUB_DY);
	[[self dateStringFromRefHour:refHour withFormat:@"MMM dd"] drawAtPoint:textPoint withFont:[UIFont systemFontOfSize:LINE_FONT_SIZE]];
}

- (void)drawHourLine:(int)refHour inContext:(CGContextRef)context {
	float yPos = [self yPosFromRefHour:refHour];
	
	CGContextSetLineWidth(context, 1.0);
	[self drawLineAtY:yPos inContext:context];
	
	CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_DY);
	[[self dateStringFromRefHour:refHour withFormat:@"h a"] drawAtPoint:textPoint withFont:[UIFont systemFontOfSize:LINE_FONT_SIZE]];
}

- (void)drawHalfHourLine:(int)refHour inContext:(CGContextRef)context {
	float yPos = [self yPosFromRefHour:refHour] + _pixelsPerHour / 2;
	
	CGContextSetLineWidth(context, 1.0);
	CGFloat lineDashPattern[] = {10, 10};
	CGContextSetLineDash(context, 0, lineDashPattern, 2);
	
	[self drawLineAtY:yPos inContext:context];
	
	CGContextSetLineDash(context, 0, NULL, 0);	
}

- (void)drawCalendarLinesInContext:(CGContextRef)context {
	NSArray *visibleHours = [self getVisibleHours];
	
	CGContextSetRGBStrokeColor(context, LINES_WHITE, LINES_WHITE, LINES_WHITE, 1.0);
	[[UIColor colorWithRed:LINES_WHITE green:LINES_WHITE blue:LINES_WHITE alpha:1.0] setFill];
	
	NSEnumerator *e = [visibleHours objectEnumerator];
	NSNumber *hour;
	while (hour = [e nextObject]) {
		if ([self isMidnight:[hour intValue]]) {
			[self drawDayLine:[hour intValue] inContext:context];
		} else {
			[self drawHourLine:[hour intValue] inContext:context];
		}
		
		[self drawHalfHourLine:[hour intValue] inContext:context];
	}
	
	[visibleHours release];
}

- (void)drawEventBlocksInContext:(CGContextRef)context {
	NSArray *visibleEvents = [self getVisibleEventBlocks];
	
	NSEnumerator *e = [visibleEvents objectEnumerator];
	EventBlock *block;
	while (block = [e nextObject]) {
		[block drawInContext:context];
	}
	
	[visibleEvents release];
}

- (void)drawInContext:(CGContextRef)context {
	[self drawCalendarLinesInContext:context];
	[self drawEventBlocksInContext:context];
}

- (void)drawRect:(CGRect)rect {
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)addEventBlock:(EventBlock*)eventBlock {
	[_eventBlocks addObject:eventBlock];
	[eventBlock retain];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate touchDown:self];
}

- (void)dealloc {
    [super dealloc];
}


@end
