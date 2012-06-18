#import "CalendarEvent.h"
#import <QuartzCore/QuartzCore.h>
#import "Category.h"

@implementation CalendarEvent

- (id)initWithFrame:(CGRect)frame startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
	[super initWithFrame:frame startTime:startTime endTime:endTime andDelegate:delegate];
	
	_nameField = [[ShadowedTextField alloc] initWithFrame:CGRectMake(BORDER_PADDING_X, BORDER_PADDING_Y,
																	[self frame].size.width - BORDER_PADDING_X * 2,
																	100)];
	[_nameField setDelegate:self];
	
	_catField = [[ShadowedTextField alloc] initWithFrame:CGRectMake(BORDER_PADDING_X, BORDER_PADDING_Y + 30,
																	 [self frame].size.width - BORDER_PADDING_X * 2,
																	 100)];
	[_catField setDelegate:self];
	
	[self addSubview:_nameField];
	[self addSubview:_catField];
	
	return self;
}

- (void)setCategory:(Category*)cat {
	[_catField setText:cat.name];
}

- (void)setFocus {
	[_nameField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_nameField resignFirstResponder];
	[_delegate showCategoryChooser];
	return YES;
}

- (void)drawInContext:(CGContextRef)context {
	// Set the rectangle area
	float height = [_delegate timeOffsetToPixel:(_endTime - _startTime)];
	float width = [self frame].size.width;
	CGRect eventRect = CGRectMake(0, 0, width, height);
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
	CGPoint startPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
	CGPoint endPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, height);
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
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, width, 0);
	CGContextStrokePath(context);
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextRestoreGState(context);
}

@end
