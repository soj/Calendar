#import <QuartzCore/QuartzCore.h>

#import "CalendarEvent.h"
#import "Category.h"
#import "CalendarMath.h"
#import "LayerAnimationFactory.h"

@implementation CalendarEvent

@synthesize eventId=_eventId, delegate=_delegate, hasFocus=_hasFocus, hasCategory=_hasCategory;

- (id)initWithBaseTime:(NSTimeInterval)baseTime startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime andDelegate:(id)delegate {    
    self = [super initWithBaseTime:baseTime startTime:startTime endTime:endTime];
    
    if (self) {
        _delegate = delegate;
        
        _boxLayer = [[BoxLayer alloc] initWithParent:self.layer];
        [_boxLayer setFrame:[_boxLayer defaultFrame]];

        _depthLayer = [[DepthLayer alloc] initWithParent:self.layer];
        [_depthLayer setFrame:[_depthLayer defaultFrame]];
        _depthLayer.hidden = YES;
        
        _highlightLayer = [[HighlightLayer alloc] initWithParent:self.layer];
        [_highlightLayer setFrame:[_highlightLayer defaultFrame]];
        _highlightLayer.hidden = YES;

        _railLayer = [[RailLayer alloc] initWithParent:self.layer];
        [_railLayer setFrame:[_railLayer defaultFrame]];
        
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
        
        [self.layer addSublayer:_boxLayer];
        [self.layer addSublayer:_depthLayer];
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
        
        [_nameField setFrame:CGRectMake(UI_BOX_BORDER_PADDING_Y, UI_BOX_BORDER_PADDING_Y,
                                        [self frame].size.width - UI_BOX_BORDER_PADDING_Y * 2 - UI_RAIL_COLOR_WIDTH,
                                        MIN(UI_NAME_FIELD_HEIGHT, self.frame.size.height))];
        
        [_nameField setUserInteractionEnabled:NO];
                
        [self setIsActive:NO];
    }
		
	return self;
}

- (void)setStartTime:(NSTimeInterval)startTime {
	[super setStartTime:startTime];
    [self removeAllAnimations];
    [self setFrame:[self reframe]];
}

- (void)setEndTime:(NSTimeInterval)endTime {
	[super setEndTime:endTime];
    [self removeAllAnimations];
    [self setFrame:[self reframe]];
}

- (void)setIsActive:(BOOL)isActive {
    if (isActive == _isActive) return;
    
    _isActive = isActive;
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [UIColor colorForFadeBetweenFirstColor:_baseColor
                                                               secondColor:UI_EVENT_BG_COLOR
                                                                   atRatio:UI_BOX_BG_WHITENESS].CGColor;
        
        [self animateBoundsOfLayer:_categoryLayer to:CGRectMake(0, 0, 0, UI_HIGHLIGHT_HEIGHT)];
        [self animateOffsetOfLayer:_categoryLayer to:CGPointMake(_categoryLayer.position.x + UI_DEPTH_BORDER_WIDTH, _categoryLayer.position.y + UI_DEPTH_BORDER_HEIGHT)];
        
        [LayerAnimationFactory animate:_boxLayer toFrame:[_boxLayer defaultFrame]];
        [LayerAnimationFactory animate:_highlightLayer toFrame:[_highlightLayer defaultFrame]];
        [LayerAnimationFactory animate:_railLayer toFrame:[_railLayer defaultFrame]];
        [LayerAnimationFactory animate:_railLayer toAlpha:1.0];
        
        [self animateOffsetToInactivePosition:_depthMask];
        
        CGPoint nameFieldPos = CGPointMake(_nameField.layer.position.x + UI_DEPTH_BORDER_WIDTH -
                                           UI_HIGHLIGHT_HEIGHT - UI_BOX_BORDER_PADDING_Y,
                                           _nameField.layer.position.y + UI_DEPTH_BORDER_HEIGHT);
        [self animateOffsetOfLayer:_nameField.layer to:nameFieldPos];
        
        [self performSelector:@selector(hideDepthLayer) withObject:self afterDelay:UI_ANIM_DURATION_RAISE];
    } else {
        _boxLayer.backgroundColor = [UI_EVENT_BG_COLOR CGColor];
        [self showDepthLayer];
        
        [self animateBoundsOfLayer:_categoryLayer to:CGRectMake(0, 0, UI_HIGHLIGHT_HEIGHT, UI_HIGHLIGHT_HEIGHT)];
        [self animateOffsetOfLayer:_categoryLayer to:CGPointMake(_categoryLayer.position.x - UI_DEPTH_BORDER_WIDTH, _categoryLayer.position.y - UI_DEPTH_BORDER_HEIGHT)];
        
        [LayerAnimationFactory animate:_boxLayer toFrame:[_boxLayer activeFrame]];
        [LayerAnimationFactory animate:_highlightLayer toFrame:[_highlightLayer activeFrame]];
        [LayerAnimationFactory animate:_railLayer toFrame:[_railLayer activeFrame]];
        [LayerAnimationFactory animate:_railLayer toAlpha:0];
        
        [self animateOffsetToActivePosition:_depthMask];
        
        CGPoint nameFieldPos = CGPointMake(_nameField.layer.position.x - UI_DEPTH_BORDER_WIDTH +
                                           UI_HIGHLIGHT_HEIGHT + UI_BOX_BORDER_PADDING_Y,
                                           _nameField.layer.position.y - UI_DEPTH_BORDER_HEIGHT);
        [self animateOffsetOfLayer:_nameField.layer to:nameFieldPos];
    }
}

- (void)setColor:(UIColor*)color {
    _baseColor = color;
    _depthLayer.baseColor = color;
    _boxLayer.baseColor = color;
    _highlightLayer.baseColor = color;
    _railLayer.baseColor = color;
    
    _categoryLayer.backgroundColor = [_baseColor CGColor];
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [UIColor colorForFadeBetweenFirstColor:_baseColor
                                                               secondColor:UI_EVENT_BG_COLOR
                                                                   atRatio:UI_BOX_BG_WHITENESS].CGColor;
    }
    
    [self setNeedsDisplay]; 
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
    _highlightLayer.highlightArea = area;
    _highlightLayer.hidden = NO;
    [self setNeedsDisplay];
}

- (void)unhighlight {
    [self performSelector:@selector(hideHighlightLayer) withObject:self afterDelay:0.1];
}

#pragma mark -
#pragma mark Framing Helpers

- (void)removeAllAnimations {
    [_boxLayer removeAllAnimations];
    [_depthLayer removeAllAnimations];
    [_highlightLayer removeAllAnimations];
}

- (CGRect)reframe {
    NSTimeInterval length = _endTime - _startTime;
    float natWidth = [[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING;
    float x = UI_EVENT_DX + _deletionProgress;
    float y = [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)] + UI_BOX_BORDER_MARGIN_Y;
    float width = (natWidth - _deletionProgress);
    width = MAX(width, UI_DELETION_WIDTH);
    float height = [[CalendarMath getInstance] pixelsPerHour] * length / SECONDS_PER_HOUR - UI_BOX_BORDER_MARGIN_Y * 2;
    return CGRectMake(x, y, MAX(width, 0), MAX(height, 0));
}

- (void)layoutSubviews {
    if (_deletionProgress) {
        [_boxLayer setFrame:[_boxLayer squashFrameWithProgress:_deletionProgress]];
        [_depthLayer setFrame:[_depthLayer squashFrameWithProgress:_deletionProgress]];
        [_highlightLayer setFrame:[_highlightLayer squashFrameWithProgress:_deletionProgress]];
    } else if (_isActive) {
        [_boxLayer setFrame:[_boxLayer activeFrame]];
        [_depthLayer setFrame:[_depthLayer activeFrame]];
        [_highlightLayer setFrame:[_highlightLayer activeFrame]];
    } else {
        [_boxLayer setFrame:[_boxLayer defaultFrame]];
        [_depthLayer setFrame:[_depthLayer defaultFrame]];
        [_highlightLayer setFrame:[_highlightLayer defaultFrame]];
        [_railLayer setFrame:[_railLayer defaultFrame]];
    }
    
    [_nameField setFrame:CGRectMake(_nameField.frame.origin.x, _nameField.frame.origin.y,
                                    [self frame].size.width - UI_BOX_BORDER_PADDING_Y * 2 - UI_RAIL_COLOR_WIDTH,
                                    self.frame.size.height - UI_BOX_BORDER_PADDING_Y * 2)];
        
    _depthMask.frame = CGRectMake(_depthMask.frame.origin.x, _depthMask.frame.origin.y,
                                  self.frame.size.width + UI_DEPTH_BORDER_WIDTH,
                                  self.frame.size.height + UI_DEPTH_BORDER_HEIGHT);
    _depthMask.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, _depthMask.frame.size.width,
                                                                  _depthMask.frame.size.height)].CGPath;
}

- (void)setDeletionProgress:(float)dX {
    if (dX < 0) dX = 0;
    float natWidth = [[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING;
    _deletionProgress = MIN(dX, natWidth - UI_DELETION_WIDTH);
    [self removeAllAnimations];
    [self layoutSubviews];
}

- (void)nullDeletionProgress {
    CGPoint catStartPos = CGPointMake(_deletionProgress + UI_HIGHLIGHT_PADDING - UI_DEPTH_BORDER_WIDTH, _categoryLayer.position.y);
    CABasicAnimation *catAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    catAnim.duration = UI_ANIM_DURATION_RAISE;
    catAnim.fromValue = [NSValue valueWithCGPoint:catStartPos];
    catAnim.toValue = [NSValue valueWithCGPoint:_categoryLayer.position];
    catAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_categoryLayer addAnimation:catAnim forKey:@"dummy"];
    
    _deletionProgress = 0;

    [LayerAnimationFactory animate:_boxLayer toFrame:[_boxLayer activeFrame]];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"depthWidth"];
    anim.duration = UI_ANIM_DURATION_RAISE;
    anim.fromValue = [NSNumber numberWithFloat:_depthLayer.depthWidth];
    anim.toValue = [NSNumber numberWithFloat:[self reframe].size.width + UI_DEPTH_BORDER_WIDTH];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_depthLayer addAnimation:anim forKey:@"dummy"];
    _depthLayer.depthWidth = [self reframe].size.width + UI_DEPTH_BORDER_WIDTH;
    
    [_depthLayer setFrame:[_depthLayer activeFrame]];
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

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [_depthLayer setNeedsDisplay];
    [_highlightLayer setNeedsDisplay];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
                                        replacementText:(NSString *)text {
    if (textView == _nameField && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
