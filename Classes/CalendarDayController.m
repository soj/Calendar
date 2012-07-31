#import "CalendarDayController.h"
#import "CalendarMath.h"
#import "UIGestureRecognizer+Tools.h"

@implementation CalendarDayController

@synthesize startTime=_startTime;

- (id)initWithStartTime:(NSTimeInterval)startTime andDelegate:(id<CalendarDayDelegate>)delegate {
	self = [super initWithNibName:@"CalendarDayController" bundle:nil];

	if (self) {
		_delegate = delegate;
		_startTime = startTime;		// TODO: Assert that this is midnight of some day
		_eventBlocks = [[NSMutableSet alloc] init];
		
		NSAssert((int)_startTime == (int)[CalendarMath floorTimeToStartOfDay:_startTime],
				 @"The start time provided must be the first second of a given day");
		
		[self createGestureRecognizers];
		[self createCalendarDay];
	}
	
	return self;
}

- (void)createCalendarDay {
	NSTimeInterval endTime = _startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
	_calendarDay = [[CalendarDay alloc] initWithBaseTime:_startTime startTime:_startTime endTime:endTime];
	
	[_calendarDay setCurrentTime:[NSDate timeIntervalSinceReferenceDate]];
	NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(updateCurrentTime)];
	NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
	[invoc setSelector:@selector(updateCurrentTime)];
	[invoc setTarget:self];
	[NSTimer scheduledTimerWithTimeInterval:SECONDS_PER_MINUTE invocation:invoc repeats:YES];
	
	[(UIScrollView*)self.view setContentSize:_calendarDay.frame.size];
	[self.view addSubview:_calendarDay];
}

- (void)updateCurrentTime {
	[_calendarDay setCurrentTime:[NSDate timeIntervalSinceReferenceDate]];
	[_calendarDay setNeedsDisplay];
}

- (void)scrollToEntity:(CalendarEntity*)ent {
    [self scrollToTime:ent.startTime];
}

- (void)scrollToTime:(NSTimeInterval)time {
    CGFloat top = [[CalendarMath getInstance] timeOffsetToPixel:(time - _startTime)];
    top = MAX(0, top);
    top = MIN(_calendarDay.frame.size.height - [UIScreen mainScreen].bounds.size.height, top);
    [(UIScrollView*)self.view setContentOffset:CGPointMake(0, top) animated:YES];
}

- (BOOL)isTimeVisible:(NSTimeInterval)time {
    if (time < _startTime || time > _startTime + SECONDS_PER_DAY) {
        return NO;
    }
    
    float pixelOffset = [(UIScrollView*)self.view contentOffset].y - UI_DAY_TOP_OFFSET;
    NSTimeInterval topVisible = [[CalendarMath getInstance] pixelToTimeOffset:pixelOffset] + _startTime;
    NSTimeInterval bottomVisible = topVisible + [[CalendarMath getInstance] pixelToTimeOffset:self.view.frame.size.height];
    return time >= topVisible && time <= bottomVisible;
}

#pragma mark -
#pragma mark Event Block Management Helpers

- (CalendarEvent*)boundaryBlockBeforeTime:(NSTimeInterval)time {
    __block CalendarEvent *boundaryBlock = nil;
    [[_eventBlocks allObjects] enumerateObjectsUsingBlock:^(CalendarEvent* block, NSUInteger index, BOOL *stop){
        if (block.endTime > (boundaryBlock ? boundaryBlock.endTime : _startTime) && block.endTime < time) {
            boundaryBlock = block;
        }
    }];
    return boundaryBlock;
}

- (CalendarEvent*)boundaryBlockAfterTime:(NSTimeInterval)time {
    __block CalendarEvent *boundaryBlock = nil;
    [[_eventBlocks allObjects] enumerateObjectsUsingBlock:^(CalendarEvent* block, NSUInteger index, BOOL *stop){
        if (block.startTime < (boundaryBlock ? boundaryBlock.startTime : _startTime + SECONDS_PER_DAY) && block.startTime > time) {
            boundaryBlock = block;
        }
    }];
    return boundaryBlock;
}

- (NSTimeInterval)boundaryBeforeTime:(NSTimeInterval)time {
    CalendarEvent *thatBlock = [self boundaryBlockBeforeTime:time];
    if (thatBlock) return thatBlock.endTime;
    else return _startTime;
}

- (NSTimeInterval)boundaryAfterTime:(NSTimeInterval)time {
    CalendarEvent *thatBlock = [self boundaryBlockAfterTime:time];
    if (thatBlock) return thatBlock.startTime;
    else return _startTime + SECONDS_PER_DAY;
}

- (CalendarEvent*)eventBlockBetween:(NSTimeInterval)time and:(NSTimeInterval)endTime {
    NSEnumerator *e = [_eventBlocks objectEnumerator];
	CalendarEvent *thatEvent;
    while (thatEvent = [e nextObject]) {
        if ([CalendarMath timesIntersectS1:time e1:endTime s2:thatEvent.startTime e2:thatEvent.endTime]) {
            return thatEvent;
        }
    }
    return nil;
}

- (BOOL)isTimeEmptyBetween:(NSTimeInterval)time and:(NSTimeInterval)endTime {
    return [self eventBlockBetween:time and:endTime] == nil;
}

#pragma mark -
#pragma mark Event Block Management

- (void)setEvents:(NSArray*)events {
    NSEnumerator *e = [events objectEnumerator];
    Event *event;
    while (event = [e nextObject]) {
        [self createEventBlockWithExistingEvent:event];
    }
}

- (void)setActiveEventBlock:(CalendarEvent*)event {
    if (event == _activeEventBlock) return;
    
    [self unsetActiveEventBlock];
    
    _activeEventBlock = event;
    [_activeEventBlock setIsActive:YES];
    [_calendarDay bringSubviewToFront:_activeEventBlock];
    [_activeEventBlock addGestureRecognizer:_eventBlockPan];
    [_activeEventBlock addGestureRecognizer:_eventBlockHorizontalPan];
    [_activeEventBlock addGestureRecognizer:_eventBlockLongPress];
}

- (void)unsetActiveEventBlock {
    if (_activeEventBlock != NULL) {
        CalendarEvent *block = _activeEventBlock;
        _activeEventBlock = NULL;

        if (block.hasFocus) {
            [block resignFocus];
        }
        
        [block removeGestureRecognizer:_eventBlockPan];
        [block removeGestureRecognizer:_eventBlockHorizontalPan];
        [block removeGestureRecognizer:_eventBlockLongPress];
        [block setIsActive:NO];
        
        if (![_delegate eventIsValid:block.eventId]) {
            [self deleteEventBlock:block];
        }
    }
}

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    CalendarEvent *newBlock = [[CalendarEvent alloc] initWithBaseTime:_startTime startTime:startTime
                                                              endTime:endTime andDelegate:self];
	[_eventBlocks addObject:newBlock];
    
    UITapGestureRecognizer *eventBlockTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnEventBlock:)];
    [newBlock addGestureRecognizer:eventBlockTap];
    
    UILongPressGestureRecognizer *eventBlockLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressOnEventBlock:)];
    [newBlock addGestureRecognizer:eventBlockLongPress];
	
	[_calendarDay addSubview:newBlock];
	return newBlock;
}

- (CalendarEvent*)createEventBlockWithExistingEvent:(Event*)event {
    NSTimeInterval startTime = [CalendarMath roundTimeToGranularity:event.startTime];
    NSTimeInterval endTime = [CalendarMath roundTimeToGranularity:event.endTime];
    CalendarEvent *newBlock = [self createEventBlockWithStartTime:startTime endTime:endTime];
    [newBlock setTitle:[event title]];
    [newBlock setEventId:[event identifier]];
    [newBlock setColor:[[event category] color]];
    if ([event category] != [Category uncategorized]) {
        [newBlock setHasCategory:YES];
    }
    return newBlock;
}

- (CalendarEvent*)createNewEventWithStartTime:(NSTimeInterval)time {
    NSTimeInterval endTime = time + MIN_EVENT_TIME_INTERVAL;
    
    if (![self isTimeEmptyBetween:time and:endTime]) {
        NSTimeInterval newStartTime = [self boundaryBeforeTime:endTime];
        NSTimeInterval newEndTime = [self boundaryAfterTime:(time - 1)]; // -1 to account for completely overlapping blocks
        if (fabs(newStartTime - time) < fabs(newEndTime - endTime)) {
            time = newStartTime;
            endTime = newStartTime + MIN_EVENT_TIME_INTERVAL;
        } else {
            endTime = newEndTime;
            time = endTime - MIN_EVENT_TIME_INTERVAL;
        }
        if (![self isTimeEmptyBetween:time and:endTime]) {
            return nil;
        }
    }
    
    CalendarEvent* newBlock = [self createEventBlockWithStartTime:time endTime:endTime];
    
    Event* e = [_delegate createEventWithStartTime:time endTime:endTime];
    [newBlock setEventId:[e identifier]];
    [newBlock setColor:[[e category] color]];
    
	return newBlock;
}

- (void)deleteEventBlock:(CalendarEvent*)event {
    if (event == _activeEventBlock) {
        [self unsetActiveEventBlock];
    }
    
    [_delegate deleteEvent:event.eventId];
    [_eventBlocks removeObject:event];
    [event removeFromSuperview];
}

#pragma mark -
#pragma mark Event Block Movement

- (void)beginDraggingEventBlockStartTime:(CalendarEvent*)eventBlock {
    _dragType = kDragStartTime;
    [_activeEventBlock highlightArea:kHighlightTop];
}

- (void)beginDraggingEventBlockEndTime:(CalendarEvent*)eventBlock {
    _dragType = kDragEndTime;
    [_activeEventBlock highlightArea:kHighlightBottom];
}

- (void)beginDraggingEventBlock:(CalendarEvent*)eventBlock {
    _dragType = kDragBoth;
    [_activeEventBlock highlightArea:kHighlightAll];
}

- (BOOL)beginDragForYPosInActiveEventBlock:(CGFloat)y {
    int forceDragEnd = false;
    if (y < UI_EDGE_DRAG_PIXELS && y > _activeEventBlock.frame.size.height - UI_EDGE_DRAG_PIXELS) {
        forceDragEnd = roundf(y / _activeEventBlock.frame.size.height);
    }
    
    if (y < UI_EDGE_DRAG_PIXELS && !forceDragEnd) {
        _dragEventTimeOffset = [[CalendarMath getInstance] pixelToTimeOffset:y];
        [self beginDraggingEventBlockStartTime:_activeEventBlock];
    } else if (y > _activeEventBlock.frame.size.height - UI_EDGE_DRAG_PIXELS) {
        NSTimeInterval eventLength = _activeEventBlock.endTime - _activeEventBlock.startTime;
        // magical 2 minute "don't overshoot" factor may be due to depth layer
        _dragEventTimeOffset = eventLength - [[CalendarMath getInstance] pixelToTimeOffset:y] - SECONDS_PER_MINUTE * 2;
        [self beginDraggingEventBlockEndTime:_activeEventBlock];
    } else {
        if (![self isTimeVisible:_activeEventBlock.endTime] || ![self isTimeVisible:_activeEventBlock.startTime]) {
            return NO;
        }
        _dragEventTimeOffset = [[CalendarMath getInstance] pixelToTimeOffset:y];
        [self beginDraggingEventBlock:_activeEventBlock];
    }
    return YES;
}

- (void)resizeEventBlock:(CalendarEvent*)eventBlock startTime:(NSTimeInterval)time forceLink:(BOOL)forceLink {
    if (eventBlock == _activeEventBlock) {
        if ((time + _dragEventTimeOffset) > eventBlock.endTime) {
            _dragEventTimeOffset = (time + _dragEventTimeOffset) - eventBlock.endTime;
            [self beginDraggingEventBlockEndTime:eventBlock];
            [self resizeEventBlock:eventBlock endTime:time forceLink:forceLink];
            return;
        }
        time = MIN(time, eventBlock.endTime - MIN_EVENT_TIME_INTERVAL);
    }
    
    CalendarEvent *thatBlock = [self boundaryBlockBeforeTime:eventBlock.endTime];
    if (thatBlock && thatBlock != _activeEventBlock && (time < thatBlock.endTime || forceLink)) {
        [self resizeEventBlock:thatBlock endTime:time forceLink:NO];
        _dragType = kDragLinkedStartTime;
        if (thatBlock.size <= 0) {
            [self commitEventBlockTimes:thatBlock];
            _dragType = kDragStartTime;
        }
    }
    eventBlock.startTime = time;
}

- (void)resizeEventBlock:(CalendarEvent*)eventBlock endTime:(NSTimeInterval)time forceLink:(BOOL)forceLink {
    if (eventBlock == _activeEventBlock) {
        if ((time - _dragEventTimeOffset) < eventBlock.startTime) {
            _dragEventTimeOffset = eventBlock.startTime - (time - _dragEventTimeOffset);
            [self beginDraggingEventBlockStartTime:eventBlock];
            [self resizeEventBlock:eventBlock startTime:time forceLink:forceLink];
            return;
        }
        time = MAX(time, eventBlock.startTime + MIN_EVENT_TIME_INTERVAL);
    }
    
    CalendarEvent *thatBlock = [self boundaryBlockAfterTime:eventBlock.startTime];
    if (thatBlock && thatBlock != _activeEventBlock && (time > thatBlock.startTime || forceLink)) {
        [self resizeEventBlock:thatBlock startTime:time forceLink:NO];
        _dragType = kDragLinkedEndTime;
        if (thatBlock.size <= 0) {
            [self commitEventBlockTimes:thatBlock];
            _dragType = kDragEndTime;
        }
    }
    eventBlock.endTime = time;
}

- (void)dragActiveEventBlockTo:(NSTimeInterval)time {
    NSTimeInterval blockSize = _activeEventBlock.endTime - _activeEventBlock.startTime;
    NSTimeInterval newStartTime = _activeEventBlock.startTime, newEndTime = _activeEventBlock.endTime;
    
    newStartTime = time - _dragEventTimeOffset;
    newEndTime = newStartTime + blockSize;
    
    if (newStartTime < [self boundaryBeforeTime:_activeEventBlock.endTime]) {
        newStartTime = [self boundaryBeforeTime:_activeEventBlock.endTime];
        newEndTime = newStartTime + blockSize;
    } else if (newEndTime > [self boundaryAfterTime:_activeEventBlock.startTime]) {
        newEndTime = [self boundaryAfterTime:_activeEventBlock.startTime];
        newStartTime = newEndTime - blockSize;
    }
    
    _activeEventBlock.startTime = newStartTime;
    _activeEventBlock.endTime = newEndTime;
}

- (void)continueActiveEventBlockDragWithTimeOffset:(NSTimeInterval)timeOffset {
    if (_dragType == kDragBoth) {
        [self dragActiveEventBlockTo:(timeOffset + _startTime)];
    } else if (_dragType == kDragStartTime || _dragType == kDragLinkedStartTime) {
        [self resizeEventBlock:_activeEventBlock startTime:(timeOffset + _startTime - _dragEventTimeOffset) forceLink:(_dragType == kDragLinkedStartTime)];
    } else {
        [self resizeEventBlock:_activeEventBlock endTime:(timeOffset + _startTime + _dragEventTimeOffset) forceLink:(_dragType == kDragLinkedEndTime)];
    }
}

- (void)commitEventBlockTimes:(CalendarEvent*)event {
    if (!event) return;
    
    event.startTime = [CalendarMath roundTimeToGranularity:event.startTime];
    event.endTime = [CalendarMath roundTimeToGranularity:event.endTime];
    
    if (event.endTime - event.startTime < MIN_EVENT_TIME_INTERVAL) {
        [self deleteEventBlock:event];
    } else {
        [_delegate updateEvent:event.eventId startTime:event.startTime];
        [_delegate updateEvent:event.eventId endTime:event.endTime];
    }
}

#pragma mark -
#pragma mark Gesture Recognizers

- (void)createGestureRecognizers {
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
	UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    _eventBlockPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOrLongPressOnEventBlock:)];
    _eventBlockPan.cancelsTouchesInView = NO;
    _eventBlockPan.delegate = self;

    _eventBlockHorizontalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleHorizontalPanOnEventBlock:)];
    _eventBlockHorizontalPan.cancelsTouchesInView = NO;
    _eventBlockHorizontalPan.delegate = self;
    
    _eventBlockLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(handlePanOrLongPressOnEventBlock:)];
    _eventBlockLongPress.delegate = self;
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    float xLoc = [recognizer locationInView:_calendarDay].x;
    float yLoc = [recognizer locationInView:_calendarDay].y;
    NSTimeInterval startTime = [CalendarMath roundTimeToGranularity:([[CalendarMath getInstance] pixelToTimeOffset:yLoc] + _startTime - FINGER_TAP_TIME_OFFSET)];
      
    if (xLoc < UI_EVENT_DX) {
        if (_activeEventBlock) {
            [self unsetActiveEventBlock];
        }
    } else {
        if (_activeEventBlock && [_activeEventBlock hasFocus]) {
            if ([_delegate eventIsValid:_activeEventBlock.eventId]) {
                [_activeEventBlock resignFocus];
            } else {
                [self deleteEventBlock:_activeEventBlock];
            }
        } else {
            CalendarEvent *new;
            if ((new = [self createNewEventWithStartTime:startTime])) {
                [self setActiveEventBlock:new];
                [self scrollToEntity:_activeEventBlock];
                [_activeEventBlock setNameFocus];
            } else {
                [recognizer cancel];
            }
        }
    }
}

- (void)handleTapOnEventBlock:(UITapGestureRecognizer*)recognizer {
    CGPoint pt = [recognizer locationInView:_activeEventBlock];
    if ([recognizer view] == _activeEventBlock) {
        if ([_activeEventBlock pointInsideTextView:pt]) {
            [_activeEventBlock setNameFocus];
        } else if ([_activeEventBlock pointInsideCatView:pt]) {
            [_activeEventBlock setCategoryFocus];
        } else if ([_activeEventBlock hasFocus]) {
            [_activeEventBlock resignFocus];
        }
    } else {
        [self setActiveEventBlock:(CalendarEvent*)[recognizer view]];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {
	float yLoc = [recognizer locationInView:_calendarDay].y;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSTimeInterval startTime = [CalendarMath roundTimeToGranularity:([[CalendarMath getInstance] pixelToTimeOffset:yLoc] + _startTime - FINGER_TAP_TIME_OFFSET)];
            CalendarEvent *new;
            if ([self isTimeEmptyBetween:startTime and:startTime] && (new = [self createNewEventWithStartTime:startTime])) {
                [self setActiveEventBlock:new];
                [self scrollToEntity:_activeEventBlock];
                [_calendarDay fadeInTimeLines];
                [self beginDragForYPosInActiveEventBlock:_activeEventBlock.frame.size.height];
            } else {
                [recognizer cancel];
                break;
            }
            // Fall through
        }
        case UIGestureRecognizerStateChanged: {
            NSTimeInterval timeOffset = [[CalendarMath getInstance] pixelToTimeOffset:yLoc];
            [self continueActiveEventBlockDragWithTimeOffset:timeOffset];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self commitEventBlockTimes:_activeEventBlock];
            [self commitEventBlockTimes:[self boundaryBlockAfterTime:_activeEventBlock.startTime]];
            [self scrollToEntity:_activeEventBlock];
            [_activeEventBlock setNameFocus];
            [_calendarDay fadeOutTimeLines];
            [_activeEventBlock unhighlight];
            break;
        }
        default:
            break;
    }
}

- (void)handleLongPressOnEventBlock:(UILongPressGestureRecognizer*)recognizer {    
    if ([recognizer view] != _activeEventBlock) {
        [self setActiveEventBlock:(CalendarEvent*)recognizer.view];
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        float yLoc = [recognizer locationInView:recognizer.view].y;
        if (![self beginDragForYPosInActiveEventBlock:yLoc]) {
            [recognizer cancel];
        }
    }
    [self handlePanOrLongPressOnEventBlock:recognizer];
}

- (void)handlePanOrLongPressOnEventBlock:(UIGestureRecognizer*)recognizer {
    NSAssert(_activeEventBlock == [recognizer view], @"Only the active event block may receive this gesture");
    float yLoc = [recognizer locationInView:_calendarDay].y;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [_calendarDay fadeInTimeLines];
            // Fall through
        }
        case UIGestureRecognizerStateChanged: {
            NSTimeInterval timeOffset = [[CalendarMath getInstance] pixelToTimeOffset:yLoc];
            [self continueActiveEventBlockDragWithTimeOffset:timeOffset];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self commitEventBlockTimes:[self boundaryBlockBeforeTime:_activeEventBlock.endTime]];
            [self commitEventBlockTimes:_activeEventBlock];
            [self commitEventBlockTimes:[self boundaryBlockAfterTime:_activeEventBlock.startTime]];
            [_calendarDay fadeOutTimeLines];
            [_activeEventBlock unhighlight];
            break;
        }
        default:
            break;
    }
}

- (void)handleHorizontalPanOnEventBlock:(UIGestureRecognizer*)recognizer {
    NSAssert(_activeEventBlock == [recognizer view], @"Only the active event block may receive this gesture");
    float xLoc = [recognizer locationInView:_calendarDay].x;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
        }
        case UIGestureRecognizerStateChanged: {
        }
        case UIGestureRecognizerStateEnded: {
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer {
    CGPoint translation = [_eventBlockHorizontalPan translationInView:_activeEventBlock];
    if ((recognizer == _eventBlockHorizontalPan && fabs(translation.y) >= fabs(translation.x)) ||
        (recognizer == _eventBlockPan && fabs(translation.x) > fabs(translation.y))) {
        return NO;
    }
    
    if (recognizer == _eventBlockPan || recognizer == _eventBlockLongPress) {
        if (![self beginDragForYPosInActiveEventBlock:[recognizer locationInView:_activeEventBlock].y]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -
#pragma mark UIViewController Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark CalendarEventDelegate Methods

- (void)showCategoryChooser {
    [_delegate showCategoryChooserWithDelegate:self];
}

- (void)dismissCategoryChooser {
    [_delegate dismissCategoryChooser];
}

- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title {
    NSAssert([event eventId] != NULL, @"CalendarEvent does not have an identifier");
    [_delegate updateEvent:[event eventId] title:title];
}

#pragma mark -
#pragma mark CategoryChooserDelegate Methods

- (void)categoryChooser:(CategoryChooserController*)chooser didSelectCategory:(Category*)cat {
    [_delegate updateEvent:[_activeEventBlock eventId] category:cat];
    [_activeEventBlock setColor:[cat color]];
    [_activeEventBlock setHasCategory:YES];
    [_activeEventBlock resignFocus];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_topTime = (NSTimeInterval)[scrollView contentOffset].y / [[CalendarMath getInstance] pixelsPerHour] * SECONDS_PER_HOUR + _startTime;
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it ]doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

@end
