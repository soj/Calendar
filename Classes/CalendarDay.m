#import "CalendarDay.h"
#import "CalendarMath.h"

@implementation CalendarDay

@synthesize currentTime=_currentTime;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime{
	self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime];
	
	if (self) {
		CGRect bounds = self.bounds;
		bounds.origin.y = -20;
		bounds.size.height = bounds.size.height + 20;
		[self setBounds:bounds];
	}
	
	return self;
}

- (CGRect)reframe {
    return CGRectMake(0, [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)] + TOP_OFFSET,
                      [[CalendarMath getInstance] dayWidth],
                      [[CalendarMath getInstance] pixelsPerHour] * HOURS_PER_DAY);
}

- (NSString*)dateStringFromTime:(NSTimeInterval)time withFormat:(NSString*)format {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
	NSDateFormatter *dateFrmt = [[NSDateFormatter alloc] init];
	[dateFrmt setDateFormat:format];
	return [[dateFrmt stringFromDate:date] lowercaseString];
}

- (float)yPosFromTime:(NSTimeInterval)time {
	return [[CalendarMath getInstance] timeOffsetToPixel:(time - _startTime)];
}

- (void)drawLineAtY:(int)yPos inContext:(CGContextRef)context {
	CGContextMoveToPoint(context, TIME_LINES_X, yPos);
	CGContextAddLineToPoint(context, TIME_LINES_X + [self frame].size.width, yPos);
	CGContextStrokePath(context);
}

- (void)drawFullBleedLineAtY:(int)yPos inContext:(CGContextRef)context {
	CGContextMoveToPoint(context, 0, yPos);
	CGContextAddLineToPoint(context, 0 + [self frame].size.width, yPos);
	CGContextStrokePath(context);
}

- (void)drawDayLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time];

	CGContextSetLineWidth(context, 5.0);
	[self drawLineAtY:yPos inContext:context];

	CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_BIG_DY);
	[[self dateStringFromTime:time withFormat:@"EEE"] drawAtPoint:textPoint withFont:[UIFont boldSystemFontOfSize:LINE_BIG_FONT_SIZE]];
	
	textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_SUB_DY);
	[[self dateStringFromTime:time withFormat:@"MMM dd"] drawAtPoint:textPoint withFont:[UIFont systemFontOfSize:LINE_FONT_SIZE]];
}

- (void)drawHourLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time];
	
	CGContextSetLineWidth(context, 1.0);
	[self drawLineAtY:yPos inContext:context];
	
	CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_DY);
	[[self dateStringFromTime:time withFormat:@"h a"] drawAtPoint:textPoint withFont:[UIFont systemFontOfSize:LINE_FONT_SIZE]];
}

- (void)drawHalfHourLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time] - [[CalendarMath getInstance] pixelsPerHour] / 2;
	
	CGContextSetLineWidth(context, 1.0);
	CGFloat lineDashPattern[] = {10, 10};
	CGContextSetLineDash(context, 0, lineDashPattern, 2);
	
	[self drawLineAtY:yPos inContext:context];
	
	CGContextSetLineDash(context, 0, NULL, 0);	
}

- (void)drawCurrentTimeLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time];

	CGContextSetLineWidth(context, 1.0);
	CGContextSetRGBStrokeColor(context, LINES_RED);
	[self drawFullBleedLineAtY:yPos inContext:context];
	CGContextSetRGBStrokeColor(context, LINES_WHITE);
}

- (void)drawInContext:(CGContextRef)context {	
	CGContextSetRGBStrokeColor(context, LINES_WHITE);
	CGContextSetRGBFillColor(context, LINES_WHITE);
	
	[self drawDayLine:_startTime inContext:context];
	
	for (int time = _startTime + SECONDS_PER_HOUR; time < _startTime + SECONDS_PER_DAY; time += SECONDS_PER_HOUR) {
		[self drawHalfHourLine:time inContext:context];
		[self drawHourLine:time inContext:context];
	}
	
	[self drawCurrentTimeLine:_currentTime inContext:context];
}

@end
