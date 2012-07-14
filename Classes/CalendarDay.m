#import "CalendarDay.h"
#import "CalendarMath.h"

@implementation CalendarDay

@synthesize currentTime=_currentTime;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime{
	self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime];
	
	if (self) {
		CGRect bounds = self.bounds;
		bounds.origin.y = -DAY_TOP_OFFSET;
		bounds.size.height = bounds.size.height + DAY_TOP_OFFSET;
		[self setBounds:bounds];
	}
	
	return self;
}

- (CGRect)reframe {
    return CGRectMake(0, [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)] + DAY_TOP_OFFSET,
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

- (void)drawRightFacingTriangleAtX:(float)xPos y:(float)yPos inContext:(CGContextRef)context {
    static const float triangleWidth = 12.5;
    static const float triangleHeight = 17.5;
    
    CGContextMoveToPoint(context, xPos, yPos);
    CGContextAddLineToPoint(context, xPos - triangleWidth, yPos - triangleHeight/2);
    CGContextAddLineToPoint(context, xPos - triangleWidth, yPos + triangleHeight/2);
    CGContextFillPath(context);
}

- (void)drawDayLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time];

	CGContextSetLineWidth(context, 5.0);
	[self drawLineAtY:yPos inContext:context];

	CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_BIG_DY);
	[[self dateStringFromTime:time withFormat:@"EEE"] drawAtPoint:textPoint withFont:MEDIUM_BOLD_FONT];
	
	textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_SUB_DY);
	[[self dateStringFromTime:time withFormat:@"MMM dd"] drawAtPoint:textPoint withFont:SMALL_FONT];
}

- (void)drawHourLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time] + 1;  // Add 1 because it's a 2pt line
	
	CGContextSetLineWidth(context, 1.0);
	[self drawLineAtY:yPos inContext:context];
	
	CGPoint textPoint = CGPointMake(LINE_TEXT_X, yPos + LINE_TEXT_DY);
    NSString *hourString = [self dateStringFromTime:time withFormat:@"h"];
    NSString *ampmString = [[self dateStringFromTime:time withFormat:@"a"] substringToIndex:1];
    CGSize hourStringSize = [hourString sizeWithFont:MEDIUM_BOLD_FONT];
    [hourString drawAtPoint:textPoint withFont:MEDIUM_BOLD_FONT];
    [ampmString drawAtPoint:CGPointMake(textPoint.x + hourStringSize.width, textPoint.y) withFont:MEDIUM_LIGHT_FONT];
}

- (void)drawHalfHourLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time] - [[CalendarMath getInstance] pixelsPerHour] / 2 + 1;   // Add 1 because it's a 2pt line
	
	CGContextSetLineWidth(context, 1.0);
	CGFloat lineDashPattern[] = {10, 10};
	CGContextSetLineDash(context, 0, lineDashPattern, 2);
	
	[self drawLineAtY:yPos inContext:context];
	
	CGContextSetLineDash(context, 0, NULL, 0);	
}

- (void)drawCurrentTimeLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time] - 1;

	CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBFillColor(context, CURRENT_LINE_COLOR);
	CGContextSetRGBStrokeColor(context, CURRENT_LINE_COLOR);
	[self drawFullBleedLineAtY:yPos inContext:context];
    [self drawRightFacingTriangleAtX:57 y:yPos inContext:context];
	CGContextSetRGBStrokeColor(context, DAY_LINE_COLOR);
    CGContextSetRGBFillColor(context, DAY_LINE_COLOR);
}

- (void)drawInContext:(CGContextRef)context {	
	CGContextSetRGBStrokeColor(context, DAY_LINE_COLOR);
	CGContextSetRGBFillColor(context, DAY_LINE_COLOR);
	
	[self drawDayLine:_startTime inContext:context];
	
	for (int time = _startTime + SECONDS_PER_HOUR; time < _startTime + SECONDS_PER_DAY; time += SECONDS_PER_HOUR) {
		[self drawHalfHourLine:time inContext:context];
		[self drawHourLine:time inContext:context];
	}
	
	[self drawCurrentTimeLine:_currentTime inContext:context];
}

@end
