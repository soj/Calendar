#import "CalendarEvent.h"
#import <QuartzCore/QuartzCore.h>

@implementation CalendarEvent

- (id)initWithSize:(CGSize)size startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
	[super initWithSize:size startTime:startTime endTime:endTime andDelegate:delegate];
		
	_textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 100)];
	[_textField setTextColor:[UIColor whiteColor]];
	[_textField layer].shadowColor = [[UIColor blackColor] CGColor];
	[_textField layer].shadowOffset = CGSizeMake(0, -1);
	[_textField layer].shadowOpacity = 0.4;
	[_textField layer].shadowRadius = 0;
	[_textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
	[_textField setReturnKeyType:UIReturnKeyDone];
	[_textField setDelegate:self];
	[_textField setAdjustsFontSizeToFitWidth:YES];
	[_textField setMinimumFontSize:16.0];
	[_textField setFont:[UIFont systemFontOfSize:25.0]];
	[self addSubview:_textField];
	
	return self;
}

- (void)setFocus {
	[_textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_textField resignFirstResponder];
	return YES;
}

- (void)drawInContext:(CGContextRef)context {
	// Set the rectangle area
	float topPx = 0;
	float bottomPx = [_delegate timeOffsetToPixel:(_endTime - _startTime)] - [self frame].origin.y;
	float leftPx = EVENT_DX;
	float rightPx = [self frame].size.width;
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
