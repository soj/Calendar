#import <QuartzCore/QuartzCore.h>

#import "CalendarEvent.h"
#import "Category.h"
#import "CalendarMath.h"
#import "LayerAnimationFactory.h"

#import "UIConstants.h"

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
        
        _depthMask = [[DepthMaskLayer alloc] initWithParent:self.layer];
        [_depthMask setFrame:[_depthMask defaultFrame]];
        _depthLayer.mask = _depthMask;
        
        _highlightLayer = [[HighlightBoxLayer alloc] initWithParent:self.layer];
        [_highlightLayer setFrame:[_highlightLayer defaultFrame]];
        _highlightLayer.hidden = YES;

        _railLayer = [[RailLayer alloc] initWithParent:self.layer];
        [_railLayer setFrame:[_railLayer defaultFrame]];
        
        _categoryLayer = [[CategoryLayer alloc] initWithParent:self.layer];
        [_categoryLayer setFrame:[_categoryLayer defaultFrame]];
        
        _nameView = [[CalendarEventName alloc] init];
        _nameView.delegate = self;
        _nameLayer = (NameLayer*)_nameView.layer;
        _nameLayer.parent = self.layer;
        [_nameLayer setFrame:[_nameLayer defaultFrame]];
        
        [self.layer addSublayer:_depthLayer];
        [self.layer addSublayer:_boxLayer];
        [self.layer addSublayer:_highlightLayer];
        [self.layer addSublayer:_railLayer];
        [self.layer addSublayer:_categoryLayer];
        
        [self addSubview:_nameView];
                
        [self setIsActive:NO];
    }
		
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

- (void)setIsActive:(BOOL)isActive {
    if (isActive == _isActive) return;
    
    _isActive = isActive;
    
    if (!isActive) {
        [self.layer.sublayers enumerateObjectsUsingBlock:^(CalendarEventLayer* layer, 
                                                           NSUInteger idx, BOOL *stop) {
            if ([layer isKindOfClass:CalendarEventLayer.class]) {
                [LayerAnimationFactory animate:layer toFrame:[layer defaultFrame]];
            }
        }];
        [LayerAnimationFactory animate:_depthMask toFrame:[_depthMask defaultFrame]];
        [LayerAnimationFactory animate:_railLayer toAlpha:1.0];
        
        _boxLayer.backgroundColor = [self highlightColor].CGColor;
        [self performSelector:@selector(hideDepthLayer) withObject:self afterDelay:UI_ANIM_DURATION_RAISE];
    } else {
        [self.layer.sublayers enumerateObjectsUsingBlock:^(CalendarEventLayer* layer, 
                                                           NSUInteger idx, BOOL *stop) {
            if ([layer isKindOfClass:CalendarEventLayer.class]) {
                [LayerAnimationFactory animate:layer toFrame:[layer activeFrame]];
            }
        }];
        [LayerAnimationFactory animate:_depthMask toFrame:[_depthMask activeFrame]];
        [LayerAnimationFactory animate:_railLayer toAlpha:0];
        
        _boxLayer.backgroundColor = UI_EVENT_BG_COLOR.CGColor;
        [self showDepthLayer];
    }
}

- (void)setColor:(UIColor*)color {
    _baseColor = color;
    _depthLayer.baseColor = color;
    _boxLayer.baseColor = color;
    _highlightLayer.baseColor = color;
    _railLayer.baseColor = color;
    _categoryLayer.baseColor = color;
    
    if (!_isActive) {
        _boxLayer.backgroundColor = [self highlightColor].CGColor;
    }
    
    [self setNeedsDisplay]; 
}

- (void)setTitle:(NSString*)title {
    [_nameView setText:title];
}

#pragma mark -
#pragma mark Highlighting and Depth Visibility

- (void)highlightArea:(HighlightArea)area {
    _highlightLayer.highlightArea = area;
    _highlightLayer.hidden = NO;
    [self setNeedsDisplay];
}

- (void)unhighlight {
    [self performSelector:@selector(hideHighlightLayer) withObject:self afterDelay:0.1];
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

- (UIColor*)highlightColor {
    return [UIColor colorForFadeBetweenFirstColor:_baseColor
                                      secondColor:UI_EVENT_BG_COLOR
                                          atRatio:UI_BOX_BG_WHITENESS];
}


#pragma mark -
#pragma mark Framing and Display Helpers

- (CGRect)reframe {
    NSTimeInterval length = _endTime - _startTime;
    
    float natWidth = [[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING;
    float x = UI_EVENT_DX + _deletionProgress;
    float y = [[CalendarMath getInstance] timeOffsetToPixel:(_startTime - _baseTime)] + UI_BOX_BORDER_MARGIN_Y + UI_DAY_TOP_OFFSET;
    float width = MAX(natWidth - _deletionProgress, UI_DELETION_WIDTH);
    float height = [[CalendarMath getInstance] pixelsPerHour] * length / SECONDS_PER_HOUR - UI_BOX_BORDER_MARGIN_Y * 2;
    
    return CGRectMake(x, y, MAX(width, 0), MAX(height, 0));
}

- (void)layoutSubviews {
    [self.layer.sublayers enumerateObjectsUsingBlock:^(CalendarEventLayer* layer, 
                                                       NSUInteger idx, BOOL *stop) {
        if ([layer isKindOfClass:CalendarEventLayer.class]) {
            if (_deletionProgress && !_isActive) {
                return;
            } else if (_deletionProgress) {
                [layer setFrame:[layer squashFrameWithProgress:_deletionProgress active:YES]];
            } else if (_isActive) {
                [layer setFrame:[layer activeFrame]];
            } else {
                [layer setFrame:[layer defaultFrame]];
            }
        }
    }];
    if (_isActive) {
        [_depthMask setFrame:[_depthMask activeFrame]];
    } else {
        [_depthMask setFrame:[_depthMask defaultFrame]];
    }
}

- (void)setDeletionProgress:(float)dX {
    if (dX < 0) dX = 0;
    float natWidth = [[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING;
    _deletionProgress = MIN(dX, natWidth - UI_DELETION_WIDTH);
    [self layoutSubviews];
}

- (void)nullDeletionProgress {    
    [LayerAnimationFactory animate:_boxLayer toFrame:[_boxLayer activeFrame]];
    [LayerAnimationFactory animate:_categoryLayer toFrame:[_categoryLayer activeFrame]];
    [LayerAnimationFactory animate:_nameLayer toFrame:[_nameLayer activeFrame]];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"depthWidth"];
    anim.duration = UI_ANIM_DURATION_RAISE;
    anim.fromValue = [NSNumber numberWithFloat:_depthLayer.depthWidth];
    anim.toValue = [NSNumber numberWithFloat:[_depthLayer activeFrame].size.width];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_depthLayer addAnimation:anim forKey:@"depthWidth"];
    
    _deletionProgress = 0;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [_depthMask setNeedsDisplay];
    [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer* layer, NSUInteger idx, BOOL *stop) {
        if ([layer isKindOfClass:CalendarEventLayer.class]) {
            [layer setNeedsDisplay];
        }
    }];
}

- (BOOL)shouldDeleteFromActive {
    float natWidth = [[CalendarMath getInstance] dayWidth] - UI_EVENT_DX - UI_RIGHT_PADDING;
    return _deletionProgress >= natWidth - UI_DELETION_WIDTH;
}

- (void)deleteFromActive {
    [self.layer.sublayers enumerateObjectsUsingBlock:^(CalendarEventLayer* layer,
                                                       NSUInteger idx, BOOL *stop) {
        if ([layer isKindOfClass:CalendarEventLayer.class]) {
            [LayerAnimationFactory animate:layer
                                   toFrame:[layer squashFrameWithProgress:_deletionProgress
                                                                   active:NO]];
            [LayerAnimationFactory animate:layer toAlpha:0];
        }
    }];
}

#pragma mark -
#pragma mark Focus Handling

- (BOOL)isPointInsideTextView:(CGPoint)pt {
    CGRect rect = CGRectMake(_nameView.frame.origin.x, _nameView.frame.origin.y,
                             _nameView.contentSize.width, _nameView.contentSize.height);
    return CGRectContainsPoint(rect, pt);
}

- (BOOL)isPointInsideCatView:(CGPoint)pt {
    return CGRectContainsPoint(_categoryLayer.frame, pt);
}

- (void)setNameFocus {
    _hasFocus = YES;
    [_nameView setUserInteractionEnabled:YES];
    [_nameView setEditable:YES];
    
    [_nameView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:UI_ANIM_DURATION_RAISE];
}

- (void)setCategoryFocus {
    _hasFocus = YES;
    [_delegate showCategoryChooser];
}

- (void)resignFocus {
    _hasFocus = NO;
    [_nameView resignFirstResponder];
    [_nameView setUserInteractionEnabled:NO];
    [_nameView setEditable:NO];
    [_delegate dismissCategoryChooser];
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
    if (textView == _nameView) {
        NSString *trimmed = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        textView.text = trimmed;
        [_delegate calendarEvent:self didChangeTitle:trimmed];
        
        [_nameView resignFirstResponder];
        [_nameView setEditable:NO];
        
        if (!_hasCategory) {
            [_delegate showCategoryChooser];
        }
    }
    
    [self endHackToStopAutoScrollOnTextField:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
                                        replacementText:(NSString *)text {
    if (textView == _nameView && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
