#import <QuartzCore/QuartzCore.h>

#import "CalendarEvent.h"
#import "Category.h"
#import "CalendarMath.h"

@implementation CalendarEvent

@synthesize eventId=_eventId, delegate=_delegate, hasFocus=_hasFocus;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
    _delegate = delegate;
    
    self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime];
    
    _nameField = [[ShadowedTextField alloc] init];
    [_nameField setDelegate:self];
    [_nameField setEnabled:NO];
    
    [self resizeTextFields];
	
	[self addSubview:_nameField];
	
	return self;
}

- (void)setStartTime:(NSTimeInterval)startTime {
	[super setStartTime:startTime];
    [self setFrame:[self reframe]];
}

- (void)setEndTime:(NSTimeInterval)endTime {
	[super setEndTime:endTime];
    [self setFrame:[self reframe]];
}

- (void)setColor:(UIColor*)color {
    _baseColor = color;
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString*)title {
    [_nameField setText:title];
}

- (void)setFocus {
    _hasFocus = YES;
    [_nameField setEnabled:YES];
	[_nameField becomeFirstResponder];
}

- (void)resignFocus {
    _hasFocus = NO;
    [_nameField resignFirstResponder];
    [_nameField setEnabled:NO];
}

- (void)resizeTextFields {
    [_nameField setFrame:CGRectMake(BORDER_PADDING_X, BORDER_PADDING_Y,
                                    [self frame].size.width - BORDER_PADDING_X * 2,
                                    TEXT_FIELD_HEIGHT)];
}

- (CGRect)reframe {
    int width = ([[CalendarMath getInstance] dayWidth] - EVENT_DX - RIGHT_RAIL_WIDTH);
    
    return CGRectMake(EVENT_DX,
                      [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)],
                      width,
                      [[CalendarMath getInstance] pixelsPerHour] * (_endTime - _startTime) / SECONDS_PER_HOUR);
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (void)beginHackToStopAutoScrollOnTextField:(UITextField*)textField {
    UIScrollView *wrap = [[UIScrollView alloc] initWithFrame:textField.frame];
    [textField.superview addSubview:wrap];
    CGRect frame = textField.frame;
    textField.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [wrap addSubview:textField];
}

- (void)endHackToStopAutoScrollOnTextField:(UITextField*)textField {
    UIScrollView *wrap = (UIScrollView*)textField.superview;
    [wrap.superview addSubview:textField];
    CGRect frame = textField.frame;
    textField.frame = CGRectMake(wrap.frame.origin.x, wrap.frame.origin.y, frame.size.width, frame.size.height);
    [wrap removeFromSuperview];
}

- (void)textFieldDidBeginEditing:(UITextField*)textField {
    [self beginHackToStopAutoScrollOnTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	[_nameField resignFirstResponder];
    [_nameField setEnabled:NO];
	[_delegate showCategoryChooser];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    if (textField == _nameField) {
        [_delegate calendarEvent:self didChangeTitle:[textField text]];   
    }
    
    [self endHackToStopAutoScrollOnTextField:textField];
}

#pragma mark -
#pragma mark Drawing

- (void)drawInContext:(CGContextRef)context {
	// Set the rectangle area
    float height = [[CalendarMath getInstance] timeOffsetToPixel:(_endTime - _startTime)];
	float width = [self frame].size.width;
	CGRect eventRect = CGRectMake(0, 0, width, height);
	CGContextSaveGState(context);
	CGContextClipToRect(context, eventRect);
	
	// Draw the grandient background
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGColorRef startColor = CGColorCreate(space, CGColorGetComponents([_baseColor CGColor]));
	CGColorRef endColor = CGColorCreate(space, CGColorGetComponents([[_baseColor colorByDarkeningColor:BG_GRADIENT_DARKEN] CGColor]));
	NSArray *colors = [NSArray arrayWithObjects:(__bridge_transfer id)startColor, (__bridge_transfer id)endColor, nil];
	CGFloat locations[] = {0, 1};
	CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge_retained CFArrayRef)colors, locations);
	CGPoint startPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
	CGPoint endPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, height);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGColorSpaceRelease(space);

	// Draw the border
	CGContextSetRGBStrokeColor(context, BORDER_COLOR);
	CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, 0);
    CGPoint borderPoints[] = {
        CGPointMake(width, 0),
        CGPointMake(width, height),
        CGPointMake(0, height),
        CGPointMake(0, 0)
    };
    CGContextAddLines(context, borderPoints, sizeof(borderPoints)/sizeof(borderPoints[0]));
    CGContextStrokePath(context);
	
	// Draw the top highlight
	CGContextSetBlendMode(context, kCGBlendModeOverlay);
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, width, 0);
	CGContextStrokePath(context);
    
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextRestoreGState(context);
}

@end
