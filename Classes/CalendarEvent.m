#import <QuartzCore/QuartzCore.h>

#import "CalendarEvent.h"
#import "Category.h"
#import "CalendarMath.h"

@implementation CalendarEvent

@synthesize eventId=_eventId, delegate=_delegate;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {
    _multitaskIndex = 0;
    _numMultitasks = 1;
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
    [_nameField setEnabled:YES];
	[_nameField becomeFirstResponder];
}

- (void)resizeTextFields {
    [_nameField setFrame:CGRectMake(BORDER_PADDING_X, BORDER_PADDING_Y,
                                    [self frame].size.width - BORDER_PADDING_X * 2,
                                    TEXT_FIELD_HEIGHT)];
}

- (CGRect)reframe {
    int width = ([[CalendarMath getInstance] dayWidth] - EVENT_DX - RIGHT_RAIL_WIDTH) / _numMultitasks;
    int multitaskDX = width * _multitaskIndex;
    
    return CGRectMake(EVENT_DX + multitaskDX, [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)],
                      width,
                      [[CalendarMath getInstance] pixelsPerHour] * (_endTime - _startTime) / SECONDS_PER_HOUR);
}

- (void)setMultitaskIndex:(int)index outOf:(int)numMultitasks { 
    NSAssert(numMultitasks >= 1, @"numMultitasks must be at least 1");
    NSAssert(index < numMultitasks, @"index cannot be greater than number of multitasks");
    
    _multitaskIndex = index;
    _numMultitasks = numMultitasks;
    [self setFrame:[self reframe]];
    [self resizeTextFields];
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_nameField resignFirstResponder];
    [_nameField setEnabled:NO];
	[_delegate showCategoryChooser];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _nameField) {
        [_delegate calendarEvent:self didChangeTitle:[textField text]];   
    }
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
