//
//  CalendarView.m
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "CalendarView.h"


@implementation CalendarView

@synthesize delegate, topTime=_topTime, pixelsPerHour=_pixelsPerHour;

- (id)initWithCoder:(NSCoder*)decoder {
	[super initWithCoder:decoder];
	
	_eventBlocks = [[NSMutableArray alloc] init];
	return self;
}

- (void)drawDayLine:(int)hour inContext:(CGContextRef)context {
}

- (void)drawHourLine:(int)hour inContext:(CGContextRef)context {
}

- (void)drawHalfHourLine:(int)hour inContext:(CGContextRef)context {
}

- (void)drawInContext:(CGContextRef)context {
	// Draw background
	CGContextSetRGBFillColor(context, BG_BLACK, BG_BLACK, BG_BLACK, 1.0);
	CGContextFillRect(context, CGRectMake(0.0, 0.0, 320.0, 480.0));
	
	// Draw lines on every hour
	int numHoursVisible = SCREEN_H / _pixelsPerHour + 2;  // +2 for top and bottom margins
	int firstHourOffset = (int)_topTime % SECONDS_PER_HOUR;
	int firstHour = ((int)_topTime - firstHourOffset) / SECONDS_PER_HOUR;
	
	CGContextSetRGBStrokeColor(context, LINES_WHITE, LINES_WHITE, LINES_WHITE, 1.0);
	[[UIColor colorWithRed:LINES_WHITE green:LINES_WHITE blue:LINES_WHITE alpha:1.0] setFill];
	CGContextSetAllowsFontSubpixelPositioning(context, 1);
	CGContextSetShouldSubpixelPositionFonts(context, 1);
	
	// Start at first hour - 1 to make first half hours visible
	for (int hour = firstHour - 1; hour < firstHour + numHoursVisible; hour++) {
		float yPos = (hour * SECONDS_PER_HOUR - _topTime) / SECONDS_PER_HOUR * _pixelsPerHour;
		
		// Determine whether this is a day or hour line
		NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(hour * SECONDS_PER_HOUR)];
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:date];
		NSInteger calHour = [components hour];
		NSDateFormatter *dateFrmt = [[NSDateFormatter alloc] init];
		if (calHour == 0) {
			CGContextSetLineWidth(context, 5.0);
			
			CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_BIG_DY);
			[dateFrmt setDateFormat:@"EEE"];
			[[dateFrmt stringFromDate:date] drawAtPoint:textPoint withFont:[UIFont boldSystemFontOfSize:LINE_BIG_FONT_SIZE]];
			
			textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_SUB_DY);
			[dateFrmt setDateFormat:@"MMM dd"];
			[[dateFrmt stringFromDate:date] drawAtPoint:textPoint withFont:[UIFont systemFontOfSize:LINE_FONT_SIZE]];
		} else {
			CGContextSetLineWidth(context, 1.0);
			
			CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_DY);
			[dateFrmt setDateFormat:@"h a"];
			[[[dateFrmt stringFromDate:date] lowercaseString] drawAtPoint:textPoint withFont:[UIFont systemFontOfSize:LINE_FONT_SIZE]];
		}
		[dateFrmt release];
		
		// Draw main line
		CGContextMoveToPoint(context, TIME_LINES_X, yPos);
		CGContextAddLineToPoint(context, TIME_LINES_X + SCREEN_W, yPos);
		CGContextStrokePath(context);
		
		// Draw half hour line
		CGContextSetLineWidth(context, 1.0);
		CGFloat lineDashPattern[] = {10, 10};
		CGContextSetLineDash(context, 0, lineDashPattern, 2);
		CGContextMoveToPoint(context, TIME_LINES_X, yPos + _pixelsPerHour / 2);
		CGContextAddLineToPoint(context, TIME_LINES_X + SCREEN_W, yPos + _pixelsPerHour / 2);
		CGContextStrokePath(context);
		CGContextSetLineDash(context, 0, NULL, 0);
	}
	
	// Draw children
	NSEnumerator *e = [_eventBlocks objectEnumerator];
	EventBlock *block;
	int timespan = [UIScreen mainScreen].bounds.size.height / _pixelsPerHour * SECONDS_PER_HOUR;
	while (block = [e nextObject]) {
		if ((block.startTime > _topTime &&
			 block.startTime < _topTime + timespan) ||
			(block.endTime > _topTime &&
			 block.endTime < _topTime + timespan)) {
				[block drawInContext:context];
		}
	}
}

- (void)drawRect:(CGRect)rect {
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)addEventBlock:(EventBlock*)eventBlock {
	[_eventBlocks addObject:eventBlock];
	[eventBlock retain];
}

- (void)update {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate touchDown:self];
}

- (void)dealloc {
    [super dealloc];
}


@end
