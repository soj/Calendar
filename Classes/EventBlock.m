//
//  EventBlockDrawer.m
//  calendar
//
//  Created by Fravic Fernando on 12-03-22.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "EventBlock.h"


@implementation EventBlock

@synthesize delegate, startTime=_startTime, endTime=_endTime;

- (void)setStartTime:(NSTimeInterval)startTime {
	_startTime = startTime;
	if (_endTime - startTime < MIN_TIME_INTERVAL) {
		_endTime = startTime + MIN_TIME_INTERVAL;
	}
}

- (void)setEndTime:(NSTimeInterval)endTime {
	_endTime = endTime;
	if (endTime - _startTime < MIN_TIME_INTERVAL) {
		_endTime = _startTime + MIN_TIME_INTERVAL;
	}
}

- (void)drawInContext:(CGContextRef)context {
	// Set the rectangle area
	float topPx = [delegate timeToPixel:_startTime];
	float bottomPx = [delegate timeToPixel:_endTime];
	float leftPx = EVENT_DX;
	float rightPx = [UIScreen mainScreen].bounds.size.width;
	CGRect eventRect = CGRectMake(leftPx, topPx, rightPx - leftPx, bottomPx - topPx);
	CGContextSaveGState(context);
	CGContextClipToRect(context, eventRect);
	
	// Draw the grandient background
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	float startComps[4] = {1, 0.3, 0, 1};
	float endComps[4] = {1, 0.176, 0, 1};
	CGColorRef startColor = CGColorCreate(space, startComps);
	CGColorRef endColor = CGColorCreate(space, endComps);
	NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
	CGFloat locations[] = {0, 1};
	CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGPoint startPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, topPx); //TODO
	CGPoint endPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, bottomPx); //TODO
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGColorSpaceRelease(space);

	// Draw the border
	CGRect borderRect = CGRectInset(eventRect, 1, 1);
	CGFloat *comps = CGColorGetComponents([BORDER_COLOR CGColor]);
	CGContextSetRGBStrokeColor(context, comps[0], comps[1], comps[2], comps[3]);
	CGContextSetLineWidth(context, 2.0);
	CGContextStrokeRect(context, borderRect);
	
	// Draw the top highlight
	CGContextSetBlendMode(context, kCGBlendModeOverlay);
	CGContextSetLineWidth(context, 5.0);
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.5);
	CGContextMoveToPoint(context, leftPx, topPx);
	CGContextAddLineToPoint(context, rightPx, topPx);
	CGContextStrokePath(context);
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextRestoreGState(context);
}

@end
