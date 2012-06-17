#import "CalendarDay.h"


@implementation CalendarDay

- (id)initWithSize:(CGSize)size startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
	[super initWithSize:size startTime:startTime endTime:endTime andDelegate:delegate];
	
	return self;
}

- (BOOL)isMidnight:(int)refHour {
	return [_delegate calendarHourFromReferenceHour:refHour] == 0;
}

- (NSString*)dateStringFromRefHour:(int)refHour withFormat:(NSString*)format {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(refHour * SECONDS_PER_HOUR)];
	NSDateFormatter *dateFrmt = [[NSDateFormatter alloc] init];
	[dateFrmt setDateFormat:format];
	return [[dateFrmt stringFromDate:date] lowercaseString];
}

- (float)yPosFromRefHour:(int)refHour {
	return [_delegate timeOffsetToPixel:(refHour * SECONDS_PER_HOUR)] - [self frame].origin.y + OVERFLOW_TOP;
}

- (void)drawLineAtY:(int)yPos inContext:(CGContextRef)context {
	CGContextMoveToPoint(context, TIME_LINES_X, yPos);
	CGContextAddLineToPoint(context, TIME_LINES_X + [self frame].size.width, yPos);
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
	float yPos = [self yPosFromRefHour:refHour] + [_delegate getPixelsPerHour] / 2;
	
	CGContextSetLineWidth(context, 1.0);
	CGFloat lineDashPattern[] = {10, 10};
	CGContextSetLineDash(context, 0, lineDashPattern, 2);
	
	[self drawLineAtY:yPos inContext:context];
	
	CGContextSetLineDash(context, 0, NULL, 0);	
}

- (void)drawInContext:(CGContextRef)context {	
	CGContextSetRGBStrokeColor(context, LINES_WHITE, LINES_WHITE, LINES_WHITE, 1.0);
	[[UIColor colorWithRed:LINES_WHITE green:LINES_WHITE blue:LINES_WHITE alpha:1.0] setFill];
	
	int topHour = _startTime / SECONDS_PER_HOUR;
	int bottomHour = _endTime / SECONDS_PER_HOUR;
	for (int i = topHour; i < bottomHour; i++) {
		if ([self isMidnight:i]) {
			[self drawDayLine:i inContext:context];
		} else {
			[self drawHourLine:i inContext:context];
		}
		
		[self drawHalfHourLine:i inContext:context];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
