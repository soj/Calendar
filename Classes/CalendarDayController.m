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
    CGFloat top = [[CalendarMath getInstance] timeOffsetToPixel:(ent.startTime - _startTime)];
    [(UIScrollView*)self.view setContentOffset:CGPointMake(0, top) animated:YES];
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
    [self unsetActiveEventBlock];
    
    _activeEventBlock = event;
    [_activeEventBlock addGestureRecognizer:_eventBlockPan];
}

- (void)unsetActiveEventBlock {
    if (_activeEventBlock != NULL) {
        if (_activeEventBlock.hasFocus) {
            [_activeEventBlock resignFocus];
            [_delegate dismissCategoryChooser];
        }
        
        [_activeEventBlock removeGestureRecognizer:_eventBlockPan];
        _activeEventBlock = NULL;
    }
}

- (CalendarEvent*)createEventBlockWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    CalendarEvent *newBlock = [[CalendarEvent alloc] initWithBaseTime:_startTime startTime:startTime
                                                              endTime:endTime andDelegate:self];
	[_eventBlocks addObject:newBlock];
    
    UITapGestureRecognizer *eventBlockTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnEventBlock:)];
    [newBlock addGestureRecognizer:eventBlockTap];
	
	[_calendarDay addSubview:newBlock];
	return newBlock;
}

- (CalendarEvent*)createEventBlockWithExistingEvent:(Event*)event {
    CalendarEvent *newBlock = [self createEventBlockWithStartTime:[event startTime] endTime:[event endTime]];
    [newBlock setTitle:[event title]];
    [newBlock setEventId:[event identifier]];
    [newBlock setColor:[[event category] color]];
    return newBlock;
}

- (CalendarEvent*)createNewEventWithStartTime:(NSTimeInterval)time {
    NSTimeInterval endTime = time + MIN_TIME_INTERVAL;
    
    if (![self isTimeEmpty:time] || ![self isTimeEmpty:endTime]) {
        return nil;
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
        [_delegate dismissCategoryChooser];
    }
    
    [_delegate deleteEvent:event.eventId];
    [_eventBlocks removeObject:event];
    [event removeFromSuperview];
}

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

- (BOOL)isTimeEmpty:(NSTimeInterval)time {
    NSEnumerator *e = [_eventBlocks objectEnumerator];
	CalendarEvent *thatEvent;
    while (thatEvent = [e nextObject]) {
        if ([CalendarMath timesIntersectS1:time e1:time s2:thatEvent.startTime e2:thatEvent.endTime]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -
#pragma mark Event Block Movement

- (void)beginDragForYPosInActiveEventBlock:(CGFloat)y {
    if (y < EDGE_DRAG_PIXELS) {
        _dragEventTimeOffset = [[CalendarMath getInstance] pixelToTimeOffset:y];
        _dragType = kDragStartTime;
    } else if (y > _activeEventBlock.frame.size.height - EDGE_DRAG_PIXELS) {
        NSTimeInterval eventLength = _activeEventBlock.endTime - _activeEventBlock.startTime;
        _dragEventTimeOffset = eventLength - [[CalendarMath getInstance] pixelToTimeOffset:y];
        _dragType = kDragEndTime;
    } else {
        _dragEventTimeOffset = [[CalendarMath getInstance] pixelToTimeOffset:y];
        _dragType = kDragBoth;
    }
}

- (void)resizeEventBlock:(CalendarEvent*)eventBlock startTime:(NSTimeInterval)time forceLink:(BOOL)forceLink {
    CalendarEvent *thatBlock = [self boundaryBlockBeforeTime:eventBlock.endTime];
    if (thatBlock && (time < thatBlock.endTime || forceLink)) {
        [self resizeEventBlock:thatBlock endTime:time forceLink:NO];
        if (thatBlock.size <= 0) {
            [self commitEventBlockTimes:thatBlock];
        }
         _dragType = kDragLinkedStartTime;
    }
    eventBlock.startTime = time;
}

- (void)resizeEventBlock:(CalendarEvent*)eventBlock endTime:(NSTimeInterval)time forceLink:(BOOL)forceLink {
    CalendarEvent *thatBlock = [self boundaryBlockAfterTime:eventBlock.startTime];
    if (thatBlock && (time > thatBlock.startTime || forceLink)) {
        [self resizeEventBlock:thatBlock startTime:time forceLink:NO];
        if (thatBlock.size <= 0) {
            [self commitEventBlockTimes:thatBlock];
        }
        _dragType = kDragLinkedEndTime;
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

- (void)commitEventBlockTimes:(CalendarEvent*)event {
    if (!event) return;
    
    event.startTime = [CalendarMath roundTimeToGranularity:event.startTime];
    event.endTime = [CalendarMath roundTimeToGranularity:event.endTime];
    
    if (event.endTime - event.startTime < MIN_TIME_INTERVAL) {
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
    
    _eventBlockPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnEventBlock:)];
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    float xLoc = [recognizer locationInView:_calendarDay].x;
    float yLoc = [recognizer locationInView:_calendarDay].y;
    NSTimeInterval startTime = [CalendarMath roundTimeToGranularity:([[CalendarMath getInstance] pixelToTimeOffset:yLoc] + _startTime)];
    
    if (xLoc < EVENT_DX) {
        if (_activeEventBlock) {
            if (![_delegate eventIsValid:_activeEventBlock.eventId]) {
                [self deleteEventBlock:_activeEventBlock];
            } else {
                [self unsetActiveEventBlock];
            }
        }
    } else {
        if (_activeEventBlock && [_activeEventBlock hasFocus]) {
            if ([_delegate eventIsValid:_activeEventBlock.eventId]) {
                [_delegate dismissCategoryChooser];
                [_activeEventBlock resignFocus];
            } else {
                [self deleteEventBlock:_activeEventBlock];
            }
        } else {
            [self setActiveEventBlock:[self createNewEventWithStartTime:startTime]];
            [self scrollToEntity:_activeEventBlock];
            [_activeEventBlock setFocus];
        }
    }
}

- (void)handleTapOnEventBlock:(UITapGestureRecognizer*)recognizer {
    if ([recognizer view] == _activeEventBlock) {
        [self scrollToEntity:_activeEventBlock];
        [_activeEventBlock setFocus];
    } else {
        [self setActiveEventBlock:(CalendarEvent*)[recognizer view]];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {	
	float yLoc = [recognizer locationInView:_calendarDay].y;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSTimeInterval startTime = [CalendarMath roundTimeToGranularity:([[CalendarMath getInstance] pixelToTimeOffset:yLoc] + _startTime)];
            CalendarEvent *new;
            if ((new = [self createNewEventWithStartTime:startTime])) {
                [self setActiveEventBlock:new];
            } else {
                [recognizer cancel];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!_activeEventBlock) return;
            _activeEventBlock.endTime = _startTime + [[CalendarMath getInstance] pixelToTimeOffset:yLoc];
            _activeEventBlock.endTime = MAX(_activeEventBlock.endTime, _activeEventBlock.startTime + MIN_TIME_INTERVAL);
            _activeEventBlock.endTime = MIN(_activeEventBlock.endTime, [self boundaryAfterTime:_activeEventBlock.startTime]);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self commitEventBlockTimes:_activeEventBlock];
            [self commitEventBlockTimes:[self boundaryBlockAfterTime:_activeEventBlock.startTime]];
            [self scrollToEntity:_activeEventBlock];
            [_activeEventBlock setFocus];
            break;
        }
        default:
            break;
    }
}

- (void)handlePanOnEventBlock:(UIPanGestureRecognizer*)recognizer {
    NSAssert(_activeEventBlock == [recognizer view], @"Only the active event block may receive gestures");

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self beginDragForYPosInActiveEventBlock:[recognizer locationInView:_activeEventBlock].y];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            float loc = [recognizer locationInView:_calendarDay].y;
            if (_dragType == kDragBoth) {
                [self dragActiveEventBlockTo:([[CalendarMath getInstance] pixelToTimeOffset:loc] + _startTime)];
            } else if (_dragType == kDragStartTime || _dragType == kDragLinkedStartTime) {
                [self resizeEventBlock:_activeEventBlock startTime:([[CalendarMath getInstance] pixelToTimeOffset:loc] + _startTime)
                             forceLink:(_dragType == kDragLinkedStartTime)];
            } else {
                [self resizeEventBlock:_activeEventBlock endTime:([[CalendarMath getInstance] pixelToTimeOffset:loc] + _startTime)
                             forceLink:(_dragType == kDragLinkedEndTime)];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self commitEventBlockTimes:[self boundaryBlockBeforeTime:_activeEventBlock.endTime]];
            [self commitEventBlockTimes:_activeEventBlock];
            [self commitEventBlockTimes:[self boundaryBlockAfterTime:_activeEventBlock.startTime]];
            break;
        }
        default:
            break;
    }
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

- (void)calendarEvent:(CalendarEvent*)event didChangeTitle:(NSString*)title {
    NSAssert([event eventId] != NULL, @"CalendarEvent does not have an identifier");
    [_delegate updateEvent:[event eventId] title:title];
}

#pragma mark -
#pragma mark CategoryChooserDelegate Methods

- (void)categoryChooser:(CategoryChooserController*)chooser didSelectCategory:(Category*)cat {
    [_delegate updateEvent:[_activeEventBlock eventId] category:cat];
    [_activeEventBlock setColor:[cat color]];
    [_activeEventBlock resignFocus];
}

- (void)categoryChooser:(CategoryChooserController *)chooser didCreateNewCategory:(Category *)cat {
    [_delegate addNewCategory:cat];
    [_delegate updateEvent:[_activeEventBlock eventId] category:cat];
    [_activeEventBlock setColor:[cat color]];
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
