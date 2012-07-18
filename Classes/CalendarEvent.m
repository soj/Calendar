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
        _railLayer.frame = CGRectMake(_boxLayer.frame.size.width - UI_RAIL_COLOR_WIDTH, 0,
                                      UI_RAIL_COLOR_WIDTH, self.frame.size.height);
        [self disableAnimationsOnLayer:_railLayer];
        
        _depthLayer = [_sublayerDelegate makeLayerWithName:@"Depth"];
        [_depthLayer setNeedsDisplayOnBoundsChange:YES];
        [_depthLayer setHidden:YES];
        [self disableAnimationsOnLayer:_depthLayer];
        
        _depthMask = [CAShapeLayer layer];
        _depthMask.fillColor = [[UIColor blackColor] CGColor];
        _depthMask.frame = CGRectMake(UI_DEPTH_BORDER_WIDTH, UI_DEPTH_BORDER_HEIGHT,
                                      self.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                                      self.frame.size.height + UI_DEPTH_BORDER_HEIGHT);
        _depthMask.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, _depthMask.frame.size.width,
                                                                      _depthMask.frame.size.height)].CGPath;
        [self disableAnimationsOnLayer:_depthMask];
        
        [self.layer addSublayer:_depthLayer];
        [self.layer addSublayer:_boxLayer];
        [self.layer addSublayer:_railLayer];
        _depthLayer.mask = _depthMask;

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
    if (isActive == _isActive) return;
    
    _isActive = isActive;
    [_depthLayer setHidden:!_isActive];
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [[_baseColor colorByChangingAlphaTo:UI_BOX_BG_ALPHA] CGColor];
        _railLayer.opacity = 1.0;
        
        [self animateOffsetToInactivePosition:_boxLayer];
        [self animateOffsetToInactivePosition:_railLayer];
        [self animateOffsetToInactivePosition:_depthMask];
        [self animateOffsetToInactivePosition:_nameField.layer];
    } else {
        _boxLayer.backgroundColor = [UI_EVENT_BG_COLOR CGColor];
        _railLayer.opacity = 0.0;
        
        [self animateOffsetToActivePosition:_boxLayer];
        [self animateOffsetToActivePosition:_railLayer];
        [self animateOffsetToActivePosition:_depthMask];
        [self animateOffsetToActivePosition:_nameField.layer];
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
    NSTimeInterval length = _endTime - _startTime;
    float y = [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)] + UI_BORDER_MARGIN_Y;
    float width = ([[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING);
    float height =  [[CalendarMath getInstance] pixelsPerHour] * length / SECONDS_PER_HOUR - UI_BORDER_MARGIN_Y * 2;
    return CGRectMake(UI_EVENT_DX, y, width, height);
}

- (void)reframeLayers {
    [_boxLayer setFrame:CGRectMake(_boxLayer.frame.origin.x, _boxLayer.frame.origin.y,
                                   _boxLayer.frame.size.width, self.frame.size.height)];
    [_railLayer setFrame:CGRectMake(_railLayer.frame.origin.x, _railLayer.frame.origin.y,
                                    UI_RAIL_COLOR_WIDTH, self.frame.size.height)];
    
    [_depthLayer setFrame:CGRectMake(-UI_DEPTH_BORDER_WIDTH/2, -UI_DEPTH_BORDER_HEIGHT/2,
                                     self.frame.size.width, self.frame.size.height)];
    [_depthLayer setBounds:CGRectMake(0, 0, _depthLayer.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                                      _depthLayer.frame.size.height + UI_DEPTH_BORDER_HEIGHT)];
    
    _depthMask.frame = CGRectMake(_depthMask.frame.origin.x, _depthMask.frame.origin.y,
                                  self.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                                  self.frame.size.height + UI_DEPTH_BORDER_HEIGHT);
    _depthMask.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, _depthMask.frame.size.width,
                                                                  _depthMask.frame.size.height)].CGPath;
}

- (void)animateOffsetOfLayer:(CALayer*)layer to:(CGPoint)pos {
    CABasicAnimation *moveBox = [CABasicAnimation animationWithKeyPath:@"position"];
    moveBox.fromValue = [NSValue valueWithCGPoint:layer.position];
    moveBox.toValue = [NSValue valueWithCGPoint:pos];
    moveBox.duration = UI_ANIM_DURATION_RAISE;
    moveBox.fillMode = kCAFillModeForwards;
    [layer setPosition:pos];
    [layer addAnimation:moveBox forKey:@"activeInactive"];
}

- (void)animateOffsetToActivePosition:(CALayer*)layer {
    CGPoint newPos = CGPointMake(layer.position.x - UI_DEPTH_BORDER_WIDTH,
                                 layer.position.y - UI_DEPTH_BORDER_HEIGHT);
    [self animateOffsetOfLayer:layer to:newPos];
}

- (void)animateOffsetToInactivePosition:(CALayer*)layer {
    CGPoint newPos = CGPointMake(layer.position.x + UI_DEPTH_BORDER_WIDTH,
                                 layer.position.y + UI_DEPTH_BORDER_HEIGHT);
    [self animateOffsetOfLayer:layer to:newPos];
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
        CGPointMake(layer.bounds.size.width - UI_DEPTH_BORDER_WIDTH, 0),
        CGPointMake(layer.bounds.size.width, UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(layer.bounds.size.width, layer.bounds.size.height),
        CGPointMake(layer.bounds.size.width - UI_DEPTH_BORDER_WIDTH, layer.bounds.size.height - UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(layer.bounds.size.width - UI_DEPTH_BORDER_WIDTH, 0)
    };
    CGContextAddLines(context, rightLines, 5);
    CGContextSetFillColorWithColor(context, [[_baseColor colorByDarkeningColor:UI_DEPTH_BORDER_DARKEN] CGColor]);
    CGContextFillPath(context);
    
    CGPoint bottomLines[] = {
        CGPointMake(layer.bounds.size.width - UI_DEPTH_BORDER_WIDTH, layer.bounds.size.height - UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(layer.bounds.size.width, layer.bounds.size.height),
        CGPointMake(UI_DEPTH_BORDER_WIDTH, layer.bounds.size.height),
        CGPointMake(0, layer.bounds.size.height - UI_DEPTH_BORDER_HEIGHT),
        CGPointMake(layer.bounds.size.width - UI_DEPTH_BORDER_WIDTH, layer.bounds.size.height - UI_DEPTH_BORDER_HEIGHT)
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
