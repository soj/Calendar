#import <QuartzCore/QuartzCore.h>

#import "CalendarEvent.h"
#import "Category.h"
#import "CalendarMath.h"

@implementation CalendarEvent

@synthesize eventId=_eventId, delegate=_delegate, hasFocus=_hasFocus, hasCategory=_hasCategory;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {    
    self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime];
    
    if (self) {
        _delegate = delegate;
        
        _boxLayer = [_sublayerDelegate makeLayerWithName:@"Box"];
        _boxLayer.borderWidth = UI_BOX_BORDER_WIDTH;
        _boxLayer.backgroundColor = [UI_EVENT_BG_COLOR CGColor];
        [self disableAnimationsOnLayer:_boxLayer];
        
        _highlightLayer = [_sublayerDelegate makeLayerWithName:@"Highlight"];
        [_highlightLayer setNeedsDisplayOnBoundsChange:YES];
        [self disableAnimationsOnLayer:_highlightLayer];
        _highlightLayer.hidden = YES;

        _railLayer = [_sublayerDelegate makeLayerWithName:@"Rail"];
        _railLayer.frame = CGRectMake(_boxLayer.frame.size.width - UI_RAIL_COLOR_WIDTH, 0,
                                      UI_RAIL_COLOR_WIDTH, self.frame.size.height);
        [self disableAnimationsOnLayer:_railLayer];
        
        _depthLayer = [_sublayerDelegate makeLayerWithName:@"Depth"];
        [_depthLayer setNeedsDisplayOnBoundsChange:YES];
        [self disableAnimationsOnLayer:_depthLayer];
        _depthLayer.hidden = YES;
        
        _depthMask = [CAShapeLayer layer];
        _depthMask.fillColor = [[UIColor blackColor] CGColor];
        _depthMask.frame = CGRectMake(UI_DEPTH_BORDER_WIDTH, UI_DEPTH_BORDER_HEIGHT + UI_BOX_BORDER_WIDTH,
                                      self.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                                      self.frame.size.height + UI_DEPTH_BORDER_HEIGHT);
        _depthMask.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, _depthMask.frame.size.width,
                                                                      _depthMask.frame.size.height)].CGPath;
        [self disableAnimationsOnLayer:_depthMask];
        
        _categoryLayer = [CAShapeLayer layer];
        _categoryLayer.anchorPoint = CGPointZero;
        _categoryLayer.frame = CGRectMake(UI_HIGHLIGHT_PADDING, UI_HIGHLIGHT_PADDING,
                                          0, UI_HIGHLIGHT_HEIGHT);
        
        [self.layer addSublayer:_depthLayer];
        [self.layer addSublayer:_boxLayer];
        [self.layer addSublayer:_highlightLayer];
        [self.layer addSublayer:_railLayer];
        [self.layer addSublayer:_categoryLayer];
        _depthLayer.mask = _depthMask;

        _nameField = [[UITextView alloc] init];
        [_nameField setFont:UI_NAME_FONT];
        [_nameField setTextColor:UI_NAME_COLOR];
        [_nameField setReturnKeyType:UIReturnKeyDone];
        [_nameField setDelegate:self];
        [_nameField setEditable:NO];
        [_nameField setScrollEnabled:NO];
        [_nameField setBackgroundColor:[UIColor clearColor]];
        [_nameField setContentInset:UIEdgeInsetsMake(-8,-8,0,0)];
        [self addSubview:_nameField];
        
        [_nameField setFrame:CGRectMake(UI_BORDER_PADDING_X, UI_BORDER_PADDING_Y,
                                        [self frame].size.width - UI_BORDER_PADDING_X * 2 - UI_RAIL_COLOR_WIDTH,
                                        MIN(UI_NAME_FIELD_HEIGHT, self.frame.size.height))];
        
        [_nameField setUserInteractionEnabled:NO];
                
        [self setIsActive:NO];
    }
		
	return self;
}

- (void)setStartTime:(NSTimeInterval)startTime {
	[super setStartTime:startTime];
    [_boxLayer removeAllAnimations];
    [self setFrame:[self reframe]];
}

- (void)setEndTime:(NSTimeInterval)endTime {
	[super setEndTime:endTime];
    [_boxLayer removeAllAnimations];
    [self setFrame:[self reframe]];
}

- (void)setIsActive:(BOOL)isActive {
    if (isActive == _isActive) return;
    
    _isActive = isActive;
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [UIColor colorForFadeBetweenFirstColor:_baseColor
                                                               secondColor:UI_EVENT_BG_COLOR
                                                                   atRatio:UI_BOX_BG_WHITENESS].CGColor;
        
        [self animateAlphaOfLayer:_railLayer to:1.0];

        [self animateBoundsOfLayer:_categoryLayer to:CGRectMake(0, 0, 0, UI_HIGHLIGHT_HEIGHT)];
        [self animateOffsetOfLayer:_categoryLayer to:CGPointMake(_categoryLayer.position.x + UI_DEPTH_BORDER_WIDTH, _categoryLayer.position.y + UI_DEPTH_BORDER_HEIGHT)];
        
        [self animateOffsetToInactivePosition:_boxLayer];
        [self animateOffsetToInactivePosition:_highlightLayer];
        [self animateOffsetToInactivePosition:_depthMask];
        [self animateOffsetToInactivePosition:_railLayer];
        
        CGPoint nameFieldPos = CGPointMake(_nameField.layer.position.x + UI_DEPTH_BORDER_WIDTH -
                                           UI_HIGHLIGHT_HEIGHT - UI_BORDER_PADDING_X,
                                           _nameField.layer.position.y + UI_DEPTH_BORDER_HEIGHT);
        [self animateOffsetOfLayer:_nameField.layer to:nameFieldPos];
        
        [self performSelector:@selector(hideDepthLayer) withObject:self afterDelay:UI_ANIM_DURATION_RAISE];
    } else {
        _boxLayer.backgroundColor = [UI_EVENT_BG_COLOR CGColor];
        [self showDepthLayer];
        
        [self animateAlphaOfLayer:_railLayer to:0];

        [self animateBoundsOfLayer:_categoryLayer to:CGRectMake(0, 0, UI_HIGHLIGHT_HEIGHT, UI_HIGHLIGHT_HEIGHT)];
        [self animateOffsetOfLayer:_categoryLayer to:CGPointMake(_categoryLayer.position.x - UI_DEPTH_BORDER_WIDTH, _categoryLayer.position.y - UI_DEPTH_BORDER_HEIGHT)];
        
        [self animateOffsetToActivePosition:_boxLayer];
        [self animateOffsetToActivePosition:_highlightLayer];
        [self animateOffsetToActivePosition:_depthMask];
        [self animateOffsetToActivePosition:_railLayer];
        
        CGPoint nameFieldPos = CGPointMake(_nameField.layer.position.x - UI_DEPTH_BORDER_WIDTH +
                                           UI_HIGHLIGHT_HEIGHT + UI_BORDER_PADDING_X,
                                           _nameField.layer.position.y - UI_DEPTH_BORDER_HEIGHT);
        [self animateOffsetOfLayer:_nameField.layer to:nameFieldPos];
    }
}

- (void)setColor:(UIColor*)color {
    _baseColor = color;
    _boxLayer.borderColor = [_baseColor CGColor];
    _railLayer.backgroundColor = [_baseColor CGColor];
    _categoryLayer.backgroundColor = [_baseColor CGColor];
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [UIColor colorForFadeBetweenFirstColor:_baseColor
                                                               secondColor:UI_EVENT_BG_COLOR
                                                                   atRatio:UI_BOX_BG_WHITENESS].CGColor;
    }
    
    [self setNeedsDisplay];
    [_depthLayer setNeedsDisplay];
}

- (void)setTitle:(NSString*)title {
    [_nameField setText:title];
}

- (void)setNameFocus {
    _hasFocus = YES;
    [_nameField setUserInteractionEnabled:YES];
    [_nameField setEditable:YES];
    
    [_nameField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:UI_ANIM_DURATION_RAISE];
}

- (void)setCategoryFocus {
    _hasFocus = YES;
    [_delegate showCategoryChooser];
}

- (void)resignFocus {
    _hasFocus = NO;
    [_nameField resignFirstResponder];
    [_nameField setUserInteractionEnabled:NO];
    [_nameField setEditable:NO];
    [_delegate dismissCategoryChooser];
}

- (void)highlightArea:(HighlightArea)area {
    _highlightArea = area;
    [_highlightLayer setNeedsDisplay];
    _highlightLayer.hidden = NO;
}

- (void)unhighlight {
    [self performSelector:@selector(hideHighlightLayer) withObject:self afterDelay:0.1];
}

#pragma mark -
#pragma mark Framing Helpers

- (CGRect)reframe {
    NSTimeInterval length = _endTime - _startTime;
    float natWidth = [[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING;
    float deletionProg = MIN(_deletionProgress, natWidth - UI_DELETION_WIDTH);
    float x = UI_EVENT_DX + deletionProg;
    float y = [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)] + UI_BORDER_MARGIN_Y;
    float width = (natWidth - deletionProg);
    width = MAX(width, UI_DELETION_WIDTH);
    float height = [[CalendarMath getInstance] pixelsPerHour] * length / SECONDS_PER_HOUR - UI_BORDER_MARGIN_Y * 2;
    return CGRectMake(x, y, MAX(width, 0), MAX(height, 0));
}

- (void)layoutSubviews {
    [_nameField setFrame:CGRectMake(_nameField.frame.origin.x, _nameField.frame.origin.y,
                                    [self frame].size.width - UI_BORDER_PADDING_X * 2 - UI_RAIL_COLOR_WIDTH,
                                    self.frame.size.height - UI_BORDER_PADDING_Y * 2)];
    
    [_boxLayer setFrame:CGRectMake(_boxLayer.frame.origin.x, _boxLayer.frame.origin.y,
                                   self.frame.size.width, self.frame.size.height)];
    
    _highlightLayer.frame = _boxLayer.frame;
    
    [_railLayer setFrame:CGRectMake(_railLayer.frame.origin.x, _railLayer.frame.origin.y,
                                    _railLayer.frame.size.width, self.frame.size.height)];
    
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

- (void)setDeletionProgress:(float)dX {
    if (dX < 0) dX = 0;
    
    _deletionProgress = dX;
    [_boxLayer removeAllAnimations];
    [self setFrame:[self reframe]];
}

- (void)nullDeletionProgress {
    _deletionProgress = 0;
    
    [self animateBoundsOfLayer:_boxLayer to:CGRectMake(0, 0,
                                                       [self reframe].size.width, [self reframe].size.height)];
    [self animateOffsetOfLayer:_boxLayer to:CGPointMake([self reframe].size.width/2 - UI_DEPTH_BORDER_WIDTH, [self reframe].size.height/2 - UI_DEPTH_BORDER_HEIGHT)];
    
    [UIView animateWithDuration:UI_ANIM_DURATION_RAISE
                     animations:^{
                         self.frame = [self reframe];
                     }
    ];
}

- (BOOL)pointInsideTextView:(CGPoint)pt {
    CGRect rect = CGRectMake(_nameField.frame.origin.x, _nameField.frame.origin.y,
                             _nameField.contentSize.width, _nameField.contentSize.height);
    return CGRectContainsPoint(rect, pt);
}

- (BOOL)pointInsideCatView:(CGPoint)pt {
    return CGRectContainsPoint(_categoryLayer.frame, pt);
}

- (void)showDepthLayer {
    _depthLayer.hidden = NO;
}

- (void)hideDepthLayer {
    _depthLayer.hidden = YES;
}

- (void)hideHighlightLayer {
    _highlightLayer.hidden = YES;
}

- (void)animateAlphaOfLayer:(CALayer*)layer to:(float)alpha {
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithFloat:layer.opacity];
    fadeIn.toValue = [NSNumber numberWithFloat:alpha];
    fadeIn.duration = UI_ANIM_DURATION_RAISE;
    fadeIn.removedOnCompletion = NO;
    fadeIn.fillMode = kCAFillModeForwards;
    layer.opacity = alpha;
    [layer addAnimation:fadeIn forKey:@"opacity"];
}

- (void)animateBoundsOfLayer:(CALayer*)layer to:(CGRect)bounds {
    CABasicAnimation *resize = [CABasicAnimation animationWithKeyPath:@"bounds"];
    resize.fromValue = [NSValue valueWithCGRect:layer.bounds];
    resize.toValue = [NSNumber valueWithCGRect:bounds];
    resize.duration = UI_ANIM_DURATION_RAISE;
    resize.removedOnCompletion = NO;
    resize.fillMode = kCAFillModeForwards;
    resize.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    layer.bounds = bounds;
    [layer addAnimation:resize forKey:@"bounds"];
}

- (void)animateOffsetOfLayer:(CALayer*)layer to:(CGPoint)pos {
    CABasicAnimation *moveBox = [CABasicAnimation animationWithKeyPath:@"position"];
    moveBox.fromValue = [NSValue valueWithCGPoint:layer.position];
    moveBox.toValue = [NSValue valueWithCGPoint:pos];
    moveBox.duration = UI_ANIM_DURATION_RAISE;
    moveBox.fillMode = kCAFillModeForwards;
    moveBox.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
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

- (void)beginHackToStopAutoScrollOnTextField:(UITextView*)textView {
    UIScrollView *wrap = [[UIScrollView alloc] initWithFrame:textView.frame];
    [textView.superview addSubview:wrap];
    CGRect frame = textView.frame;
    textView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [wrap addSubview:textView];
}

- (void)endHackToStopAutoScrollOnTextField:(UITextView*)textView {
    UIScrollView *wrap = (UIScrollView*)textView.superview;
    [wrap.superview addSubview:textView];
    CGRect frame = textView.frame;
    textView.frame = CGRectMake(wrap.frame.origin.x, wrap.frame.origin.y, frame.size.width, frame.size.height);
    [wrap removeFromSuperview];
}

- (void)textViewDidBeginEditing:(UITextView*)textView {
    [self beginHackToStopAutoScrollOnTextField:textView];
}

- (void)textViewDidEndEditing:(UITextView*)textView {
    if (textView == _nameField) {
        NSString *trimmed = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        textView.text = trimmed;
        [_delegate calendarEvent:self didChangeTitle:trimmed];
        
        [_nameField resignFirstResponder];
        [_nameField setEditable:NO];
        
        if (!_hasCategory) {
            [_delegate showCategoryChooser];
        }
    }
    
    [self endHackToStopAutoScrollOnTextField:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == _nameField && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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

- (void)drawUpperHighlightLayer:(CALayer*)layer inContext:(CGContextRef)context {
    CGPoint points[] = {
        CGPointMake(layer.frame.size.width - UI_HIGHLIGHT_PADDING - UI_HIGHLIGHT_LINE_SIZE, UI_HIGHLIGHT_PADDING),
        CGPointMake(layer.frame.size.width - UI_HIGHLIGHT_PADDING, UI_HIGHLIGHT_PADDING),
        CGPointMake(layer.frame.size.width - UI_HIGHLIGHT_PADDING, UI_HIGHLIGHT_LINE_SIZE + UI_HIGHLIGHT_PADDING)
    };
    CGContextAddLines(context, points, 3);
    CGContextStrokePath(context);
}

- (void)drawLowerHighlightLayer:(CALayer*)layer inContext:(CGContextRef)context {
    CGPoint pointsLeft[] = {
        CGPointMake(UI_HIGHLIGHT_PADDING, layer.frame.size.height - UI_HIGHLIGHT_PADDING - UI_HIGHLIGHT_LINE_SIZE),
        CGPointMake(UI_HIGHLIGHT_PADDING, layer.frame.size.height - UI_HIGHLIGHT_PADDING),
        CGPointMake(UI_HIGHLIGHT_PADDING + UI_HIGHLIGHT_LINE_SIZE, layer.frame.size.height - UI_HIGHLIGHT_PADDING)
    };
    CGContextAddLines(context, pointsLeft, 3);
    CGContextStrokePath(context);
    
    CGPoint pointsRight[] = {
        CGPointMake(layer.frame.size.width - UI_HIGHLIGHT_PADDING - UI_HIGHLIGHT_LINE_SIZE,
                    layer.frame.size.height - UI_HIGHLIGHT_PADDING),
        CGPointMake(layer.frame.size.width - UI_HIGHLIGHT_PADDING,
                    layer.frame.size.height - UI_HIGHLIGHT_PADDING),
        CGPointMake(layer.frame.size.width - UI_HIGHLIGHT_PADDING,
                    layer.frame.size.height - UI_HIGHLIGHT_LINE_SIZE - UI_HIGHLIGHT_PADDING)
    };
    CGContextAddLines(context, pointsRight, 3);
    CGContextStrokePath(context);
}

- (void)drawHighlightLayer:(CALayer*)layer inContext:(CGContextRef)context {
    CGContextSetStrokeColorWithColor(context, _baseColor.CGColor);
    CGContextSetLineWidth(context, UI_HIGHLIGHT_WIDTH);

    CGRect highlight;
    float highlightHeight = UI_HIGHLIGHT_PADDING + UI_HIGHLIGHT_HEIGHT;
    
    CGColorRef fill = [UIColor colorForFadeBetweenFirstColor:_baseColor
                                                 secondColor:UI_EVENT_BG_COLOR
                                                     atRatio:UI_BOX_BG_WHITENESS].CGColor;
    switch (_highlightArea) {
        case kHighlightTop: {
            highlight = CGRectMake(UI_BOX_BORDER_WIDTH, UI_BOX_BORDER_WIDTH,
                                   layer.frame.size.width - UI_BOX_BORDER_WIDTH * 2, highlightHeight);
            CGContextSetFillColorWithColor(context, fill);
            CGContextFillRect(context, highlight);
            break;
        }
        case kHighlightBottom: {
            highlight = CGRectMake(UI_BOX_BORDER_WIDTH, layer.frame.size.height - highlightHeight - UI_BOX_BORDER_WIDTH,
                                   layer.frame.size.width - UI_BOX_BORDER_WIDTH * 2, highlightHeight);
            CGContextSetFillColorWithColor(context, fill);
            CGContextFillRect(context, highlight);
            break;
        }
        case kHighlightAll: {
            highlight = CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height);
            highlight = CGRectInset(highlight, UI_BOX_BORDER_WIDTH * 2, UI_BOX_BORDER_WIDTH * 2);
            CGContextSetFillColorWithColor(context, fill);
            CGContextFillRect(context, highlight);
            break;
        }
    }
        
    switch (_highlightArea) {
        case kHighlightTop: {
            [self drawUpperHighlightLayer:layer inContext:context];
            break;
        }
        case kHighlightBottom: {
            [self drawLowerHighlightLayer:layer inContext:context];
            break;
        }
        case kHighlightAll: {
            [self drawUpperHighlightLayer:layer inContext:context];
            [self drawLowerHighlightLayer:layer inContext:context];
            break;
        }
    }
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [_boxLayer setNeedsDisplay];
}

@end
