#import "CalendarDay.h"
#import "CalendarMath.h"

#import "UIConstants.h"

#define UI_DAY_BOTTOM_PADDING   20.0

@implementation CalendarDay

@synthesize currentTime=_currentTime;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime{
	self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime];
	
	if (self) {
        _backgroundLayer = [_sublayerDelegate makeLayerWithName:@"Background"];
        [self.layer addSublayer:_backgroundLayer];
        
        _fullTimeLinesLayer = [_sublayerDelegate makeLayerWithName:@"FullTimelines"];
        _fullTimeLinesLayer.opacity = 0;
        [self.layer addSublayer:_fullTimeLinesLayer];
        
        _timeLinesLayer = [_sublayerDelegate makeLayerWithName:@"Timelines"];
        [self.layer addSublayer:_timeLinesLayer];
	}
	
	return self;
}

- (CGRect)reframe {
    return CGRectMake(0, 0,
                      [[CalendarMath getInstance] dayWidth],
                      [[CalendarMath getInstance] pixelsPerHour] * HOURS_PER_DAY + UI_DAY_TOP_OFFSET + UI_DAY_BOTTOM_PADDING);
}

- (void)fadeInTimeLines {
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithFloat:_fullTimeLinesLayer.opacity];
    fadeIn.toValue = [NSNumber numberWithFloat:1.0];
    fadeIn.duration = UI_ANIM_DURATION_FADE;
    fadeIn.removedOnCompletion = NO;
    fadeIn.fillMode = kCAFillModeForwards;
    _fullTimeLinesLayer.opacity = 1.0;
    [_fullTimeLinesLayer addAnimation:fadeIn forKey:@"opacity"];
}

- (void)fadeOutTimeLines {
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = [NSNumber numberWithFloat:_fullTimeLinesLayer.opacity];
    fadeOut.toValue = [NSNumber numberWithFloat:0];
    fadeOut.duration = UI_ANIM_DURATION_FADE;
    fadeOut.removedOnCompletion = NO;
    fadeOut.fillMode = kCAFillModeForwards;
    _fullTimeLinesLayer.opacity = 0.0;
    [_fullTimeLinesLayer addAnimation:fadeOut forKey:@"opacity"];
}

#pragma mark -
#pragma mark Drawing Helpers

- (NSString*)dateStringFromTime:(NSTimeInterval)time withFormat:(NSString*)format {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
	NSDateFormatter *dateFrmt = [[NSDateFormatter alloc] init];
	[dateFrmt setDateFormat:format];
	return [[dateFrmt stringFromDate:date] lowercaseString];
}

- (float)yPosFromTime:(NSTimeInterval)time {
	return [[CalendarMath getInstance] timeOffsetToPixel:(time - _startTime)] + UI_DAY_TOP_OFFSET;
}

#pragma mark -
#pragma mark Shape Drawing

- (void)drawBackgroundInContext:(CGContextRef)context {
    CGContextSetFillColorWithColor(context, UI_LEFT_RAIL_BG_COLOR.CGColor);
    CGContextFillRect(context, CGRectMake(0, -UI_DAY_TOP_OFFSET,
                                          UI_TIME_LINES_FULL_X + UI_LEFT_RAIL_PADDING,
                                          self.frame.size.height + UI_DAY_TOP_OFFSET));
}

- (void)drawLineAtY:(int)yPos startX:(int)startX endX:(int)endX inContext:(CGContextRef)context {
	CGContextMoveToPoint(context, startX, yPos);
	CGContextAddLineToPoint(context, endX, yPos);
	CGContextStrokePath(context);
}

- (void)drawFullBleedLineAtY:(int)yPos inContext:(CGContextRef)context {
	CGContextMoveToPoint(context, 0, yPos);
	CGContextAddLineToPoint(context, 0 + self.frame.size.width, yPos);
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

#pragma mark -
#pragma mark Time Line Drawing

- (void)drawDayLine:(NSTimeInterval)time shortened:(BOOL)shortened inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time];

    CGContextSetRGBStrokeColor(context, UI_TIME_LINE_COLOR);
    CGContextSetRGBFillColor(context, UI_TIME_LINE_COLOR);
    CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, UI_TIME_LINE_WIDTH);
    
    if (shortened) {
        [self drawLineAtY:yPos startX:UI_TIME_LINES_X endX:UI_TIME_LINES_FULL_X inContext:context];
    } else {
        [self drawLineAtY:yPos startX:UI_TIME_LINES_FULL_X endX:self.frame.size.width inContext:context];
    }
}

- (void)drawHourLine:(NSTimeInterval)time shortened:(BOOL)shortened inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time];
    
    CGContextSetRGBStrokeColor(context, UI_TIME_LINE_COLOR);
    CGContextSetRGBFillColor(context, UI_TIME_LINE_COLOR);
    CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, UI_TIME_LINE_WIDTH);
    
    if (shortened) {
        [self drawLineAtY:yPos startX:UI_TIME_LINES_X endX:UI_TIME_LINES_FULL_X inContext:context];
    } else {
        [self drawLineAtY:yPos startX:UI_TIME_LINES_FULL_X endX:self.frame.size.width inContext:context];
    }
}

- (void)drawHalfHourLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time] - [[CalendarMath getInstance] pixelsPerHour] / 2;
    
    CGContextSetRGBStrokeColor(context, UI_TIME_LINE_COLOR);
    CGContextSetRGBFillColor(context, UI_TIME_LINE_COLOR);
    CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, UI_TIME_LINE_WIDTH);
    
	CGFloat lineDashPattern[] = {10, 10};
	CGContextSetLineDash(context, 0, lineDashPattern, 2);
	
    [self drawLineAtY:yPos startX:UI_TIME_LINES_X endX:self.frame.size.width inContext:context];
	
	CGContextSetLineDash(context, 0, NULL, 0);	
}

- (void)drawCurrentTimeLine:(NSTimeInterval)time inContext:(CGContextRef)context {
	float yPos = [self yPosFromTime:time] - 1;

    CGContextSetRGBStrokeColor(context, UI_CURRENT_LINE_COLOR);
    CGContextSetRGBFillColor(context, UI_CURRENT_LINE_COLOR);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, UI_CURRENT_LINE_WIDTH);

	[self drawFullBleedLineAtY:yPos inContext:context];
    [self drawRightFacingTriangleAtX:57 y:yPos inContext:context];
}

#pragma mark -
#pragma mark Text Drawing

- (void)drawDayTextForTime:(NSTimeInterval)time inContext:(CGContextRef)context {
    float yPos = [self yPosFromTime:time];
    
    UIGraphicsPushContext(context);
    CGContextSetRGBStrokeColor(context, UI_TEXT_COLOR);
    CGContextSetRGBFillColor(context, UI_TEXT_COLOR);
    CGContextSetShouldAntialias(context, YES);

    CGPoint textPoint = CGPointMake(UI_LINE_TEXT_X, yPos + UI_LINE_TEXT_BIG_DY);
	[[self dateStringFromTime:time withFormat:@"EEE"] drawAtPoint:textPoint withFont:UI_MEDIUM_BOLD_FONT];
	
	textPoint = CGPointMake(UI_LINE_TEXT_X, yPos + UI_LINE_TEXT_SUB_DY);
	[[self dateStringFromTime:time withFormat:@"MMM dd"] drawAtPoint:textPoint withFont:UI_SMALL_FONT];
    
    UIGraphicsPopContext();
}

- (void)drawHourTextForTime:(NSTimeInterval)time inContext:(CGContextRef)context {
    float yPos = [self yPosFromTime:time];
    CGPoint textPoint = CGPointMake(UI_LINE_TEXT_X, yPos + UI_LINE_TEXT_DY);
    NSString *hourString = [self dateStringFromTime:time withFormat:@"h"];
    NSString *ampmString = [[self dateStringFromTime:time withFormat:@"a"] substringToIndex:1];
    CGSize hourStringSize = [hourString sizeWithFont:UI_MEDIUM_BOLD_FONT];
    
    UIGraphicsPushContext(context);
    CGContextSetRGBStrokeColor(context, UI_TEXT_COLOR);
    CGContextSetRGBFillColor(context, UI_TEXT_COLOR);
    CGContextSetShouldAntialias(context, YES);
    
    [hourString drawAtPoint:textPoint withFont:UI_MEDIUM_BOLD_FONT];
    [ampmString drawAtPoint:CGPointMake(textPoint.x + hourStringSize.width, textPoint.y) withFont:UI_MEDIUM_LIGHT_FONT];
    
    UIGraphicsPopContext();
}

#pragma mark -
#pragma mark Draw Delegates

- (void)drawBackgroundLayer:(CALayer*)layer inContext:(CGContextRef)context {
    [self drawBackgroundInContext:context];
}

- (void)drawFullTimelinesLayer:(CALayer*)layer inContext:(CGContextRef)context {
    [self drawDayLine:_startTime shortened:NO inContext:context];
    
    for (int time = _startTime + SECONDS_PER_HOUR; time < _startTime + SECONDS_PER_DAY; time += SECONDS_PER_HOUR) {
        [self drawHalfHourLine:time inContext:context];
        [self drawHourLine:time shortened:NO inContext:context];
    }
}

- (void)drawTimelinesLayer:(CALayer*)layer inContext:(CGContextRef)context {
	[self drawCurrentTimeLine:_currentTime inContext:context];    
    [self drawDayTextForTime:_startTime inContext:context];
    [self drawDayLine:_startTime shortened:YES inContext:context];
    
    for (int time = _startTime + SECONDS_PER_HOUR; time < _startTime + SECONDS_PER_DAY; time += SECONDS_PER_HOUR) {
		[self drawHourTextForTime:time inContext:context];
        [self drawHourLine:time shortened:YES inContext:context];
	}
}

@end
