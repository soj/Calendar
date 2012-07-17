#import <QuartzCore/QuartzCore.h>

#import "CalendarEvent.h"
#import "Category.h"
#import "CalendarMath.h"

@implementation CalendarEvent

@synthesize eventId=_eventId, delegate=_delegate, hasFocus=_hasFocus;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {    
    self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime];
    
    if (self) {
        _delegate = delegate;
        
        self.layer.backgroundColor = [UI_EVENT_BG_COLOR CGColor];

        _boxLayer = [_sublayerDelegate makeLayerWithName:@"Box"];
        _boxLayer.borderWidth = UI_BOX_BORDER_WIDTH;
        [self disableAnimationsOnLayer:_boxLayer];
        
        _railLayer = [_sublayerDelegate makeLayerWithName:@"Rail"];
        [self disableAnimationsOnLayer:_railLayer];
        
        _depthLayer = [_sublayerDelegate makeLayerWithName:@"Depth"];
        [_depthLayer setNeedsDisplayOnBoundsChange:YES];
        [_depthLayer setHidden:YES];
        [self disableAnimationsOnLayer:_depthLayer];
        
        [self.layer addSublayer:_boxLayer];
        [self.layer addSublayer:_depthLayer];
        [self.layer addSublayer:_railLayer];
        
        _nameField = [[UITextField alloc] init];
        [_nameField setFont:UI_NAME_FONT];
        [_nameField setTextColor:UI_NAME_COLOR];
        [_nameField setReturnKeyType:UIReturnKeyDone];
        [_nameField setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [_nameField setDelegate:self];
        [_nameField setEnabled:NO];
        [self addSubview:_nameField];
        
        [self resizeTextFields];
        [self reframeLayers];
    }
		
	return self;
}

- (void)setStartTime:(NSTimeInterval)startTime {
	[super setStartTime:startTime];
    [self setFrame:[self reframe]];
    [self reframeLayers];
}

- (void)setEndTime:(NSTimeInterval)endTime {
	[super setEndTime:endTime];
    [self setFrame:[self reframe]];
    [self reframeLayers];
}

- (void)setIsActive:(BOOL)isActive {
    _isActive = isActive;
    [_depthLayer setHidden:!_isActive];
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [[_baseColor colorByChangingAlphaTo:UI_BOX_BG_ALPHA] CGColor];
    } else {
        _boxLayer.backgroundColor = [UI_EVENT_BG_COLOR CGColor];
    }
}

- (void)setColor:(UIColor*)color {
    _baseColor = color;
    _boxLayer.borderColor = [_baseColor CGColor];
    _railLayer.backgroundColor = [_baseColor CGColor];
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [[_baseColor colorByChangingAlphaTo:UI_BOX_BG_ALPHA] CGColor];
    }
    
    [self setNeedsDisplay];
    [_depthLayer setNeedsDisplay];
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

#pragma mark -
#pragma mark Framing Helpers

- (void)resizeTextFields {
    [_nameField setFrame:CGRectMake(UI_BORDER_PADDING_X, UI_BORDER_PADDING_Y,
                                    [self frame].size.width - UI_BORDER_PADDING_X * 2 - UI_RAIL_COLOR_WIDTH,
                                    UI_NAME_FIELD_HEIGHT)];
}

- (CGRect)reframe {
    int width = ([[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING);
    return CGRectMake(UI_EVENT_DX,
                      [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)] + UI_BORDER_MARGIN_Y,
                      width,
                      [[CalendarMath getInstance] pixelsPerHour] * (_endTime - _startTime) / SECONDS_PER_HOUR - UI_BORDER_MARGIN_Y * 2);
}

- (void)reframeLayers {
    [_boxLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_railLayer setFrame:CGRectMake(self.frame.size.width - UI_RAIL_COLOR_WIDTH, 0,
                                    UI_RAIL_COLOR_WIDTH, self.frame.size.height)];
    [_depthLayer setFrame:CGRectMake(0, 0, self.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                                     self.frame.size.height + UI_DEPTH_BORDER_HEIGHT)];
}

- (void)disableAnimationsOnLayer:(CALayer*)layer {
    NSMutableDictionary *disableAnims = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                         [NSNull null], @"bounds",
                                         [NSNull null], @"position",
                                         nil];
    layer.actions = disableAnims;
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

- (void)drawDepthLayer:(CALayer*)layer inContext:(CGContextRef)context {
    CGPoint rightLines[] = {
        CGPointMake(_boxLayer.bounds.size.width, 0),
        CGPointMake(layer.bounds.size.width, UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(layer.bounds.size.width, layer.bounds.size.height),
        CGPointMake(_boxLayer.bounds.size.width, _boxLayer.bounds.size.height),
        CGPointMake(_boxLayer.bounds.size.width, 0)
    };
    CGContextAddLines(context, rightLines, 5);
    CGContextSetFillColorWithColor(context, [[_baseColor colorByDarkeningColor:UI_DEPTH_BORDER_DARKEN] CGColor]);
    CGContextFillPath(context);
    
    CGPoint bottomLines[] = {
        CGPointMake(_boxLayer.frame.size.width, _boxLayer.frame.size.height),
        CGPointMake(layer.frame.size.width, layer.frame.size.height),
        CGPointMake(UI_DEPTH_BORDER_WIDTH, layer.frame.size.height),
        CGPointMake(0, _boxLayer.frame.size.height),
        CGPointMake(_boxLayer.frame.size.width, _boxLayer.frame.size.height)
    };
    CGContextAddLines(context, bottomLines, 5);
    CGContextSetFillColorWithColor(context, [_baseColor CGColor]);
    CGContextFillPath(context);
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [_boxLayer setNeedsDisplay];
}

@end
