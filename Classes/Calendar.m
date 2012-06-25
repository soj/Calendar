#import "Calendar.h"
#import "Category.h"

@implementation Calendar


- (id)init {
	self = [super init];
	
	if (self != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *serializedEvents = [defaults dataForKey:EVENTS_SAVE_KEY];
        _events = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:serializedEvents];
        
        if (_events == NULL) {
            _events = [[NSMutableDictionary alloc] init];
        }
        
        _eventStore = [[EKEventStore alloc] init];
        
        //[self createNewCalendar];
	}
	
	return self;
}

- (void)createNewCalendar {
    // Get the calendar source
    EKSource* localSource;
    for (EKSource* source in _eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }
    
    if (!localSource) {
        return;
    }
    
    EKCalendar *calendar = [EKCalendar calendarWithEventStore:_eventStore];
    calendar.source = localSource;
    calendar.title = @"Focus Calendar";
    
    NSError* error;
    bool success= [_eventStore saveCalendar:calendar commit:YES error:&error];
    
    // TODO: Save this to make sure duplicate calendars aren't created
    NSString *calendarIdentifier = [calendar calendarIdentifier];
    
    if (error != nil) {
        NSLog(error.description);
        // TODO: error handling here
    }
}

- (void)loadEKEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime {
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:endTime];
    
    NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *ekEvents = [_eventStore eventsMatchingPredicate:predicate];
    
    NSEnumerator *e = [ekEvents objectEnumerator];
    EKEvent *ekEvent;
    while (ekEvent = [e nextObject]) {
        // Ignore all-day events because they're impossible to represent
        if ([ekEvent isAllDay]) {
            continue;
        }
        
        if (![_events objectForKey:[ekEvent eventIdentifier]]) {
            Event *newEvent = [[Event alloc] initWithEKEvent:ekEvent];
            [_events setObject:newEvent forKey:[ekEvent eventIdentifier]];
            NSLog(@"%@", [ekEvent title]);
        }
    }
}

- (NSArray*)getEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime {
    [self loadEKEventsBetweenStartTime:startTime andEndTime:endTime];
    
    NSMutableArray *retEvents = [[NSMutableArray alloc] init];
    NSEnumerator *e = [_events objectEnumerator];
    Event *event;
    while (event = [e nextObject]) {
        if (timesIntersect([event startTime], [event endTime], startTime, endTime)) {
            [retEvents addObject:event];
        }
    }
    
    return retEvents;
}

- (NSArray*)categories {
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    [categories addObject:[[Category alloc] initWithName:@"Social" andColor:[UIColor orangeColor]]];
    [categories addObject:[[Category alloc] initWithName:@"Health" andColor:[UIColor purpleColor]]];
    [categories addObject:[[Category alloc] initWithName:@"Waste of Time" andColor:[UIColor greenColor]]];
    return categories;
}

- (Event*)createEventWithStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime {
    EKEvent *newEKEvent = [EKEvent eventWithEventStore:_eventStore];
    [newEKEvent setStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:startTime]];
    [newEKEvent setEndDate:[NSDate dateWithTimeIntervalSinceReferenceDate:endTime]];
    [newEKEvent setCalendar:_eventStore.defaultCalendarForNewEvents];
    [newEKEvent setTitle:@"Test Event"];
    Event *newEvent = [[Event alloc] initWithEKEvent:newEKEvent];
    [_events setObject:newEvent forKey:@"TODO_IDENTIFIER"];
    NSError *saveError;
    [_eventStore saveEvent:newEKEvent span:EKSpanThisEvent error:&saveError];
    
    if (saveError != nil) {
        NSLog(saveError.description);
        // TODO: error handling here
    }
    
    return newEvent;
}

- (void)save {
    NSData *serializedEvents = [NSKeyedArchiver archivedDataWithRootObject:_events];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serializedEvents forKey:EVENTS_SAVE_KEY];
    [defaults synchronize];
}

@end
