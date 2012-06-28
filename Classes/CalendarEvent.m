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
    _catField = [[ShadowedTextField alloc] init];
    
	[_nameField setDelegate:self];
    [_catField setDelegate:self];
    
    [self resizeTextFields];
	
	[self addSubview:_nameField];
	[self addSubview:_catField];
	
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

- (void)setCategory:(Category*)cat {
	[_catField setText:cat.name];
}

- (void)setTitle:(NSString*)title {
    [_nameField setText:title];
}

- (void)setFocus {
	[_nameField becomeFirstResponder];
}

- (void)resizeTextFields {
    [_nameField setFrame:CGRectMake(BORDER_PADDING_X, BORDER_PADDING_Y,
                                    [self frame].size.width - BORDER_PADDING_X * 2,
                                    TEXT_FIELD_HEIGHT)];
    [_catField setFrame:CGRectMake(BORDER_PADDING_X, BORDER_PADDING_Y + TEXT_FIELD_HEIGHT,
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
	if (!_catField.text.length) {
		[_delegate showCategoryChooserWithDelegate:self];
	}
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == _catField) {
		[_delegate showCategoryChooserWithDelegate:self];
		return NO;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _nameField) {
        [_delegate calendarEvent:self didChangeTitle:[textField text]];   
    }
}

#pragma mark -
#pragma mark CategoryChooserDelegate Methods

- (void)categoryChooser:(CategoryChooserController*)chooser didSelectCategory:(Category*)cat {
	[_catField setText:[cat name]];
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
	float startComps[4] = {1, 0.3, 0, 1};
	float endComps[4] = {1, 0.176, 0, 1};
	CGColorRef startColor = CGColorCreate(space, startComps);
	CGColorRef endColor = CGColorCreate(space, endComps);
	NSArray *colors = [NSArray arrayWithObjects:(__bridge_transfer id)startColor, (__bridge_transfer id)endColor, nil];
	CGFloat locations[] = {0, 1};
	CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge_retained CFArrayRef)colors, locations);
	CGPoint startPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
	CGPoint endPoint = CGPointMake([UIScreen mainScreen].bounds.size.width, height);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGColorSpaceRelease(space);

	// Draw the border
	CGRect borderRect = CGRectInset(eventRect, 1, 1);
	CGContextSetRGBStrokeColor(context, BORDER_COLOR);
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
