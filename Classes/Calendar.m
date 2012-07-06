#import "Calendar.h"
#import "Category.h"
#import "CalendarMath.h"

@implementation Calendar

@synthesize eventStore;

- (id)init {
	self = [super init];
	
	if (self != nil) {
        _eventStore = [[EKEventStore alloc] init];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *serializedEvents = [defaults dataForKey:EVENTS_SAVE_KEY];
        _events = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:serializedEvents];
        
        if (_events != NULL) {
            NSEnumerator *e = [_events keyEnumerator];
            NSString *eventIdentifier;
            while (eventIdentifier = [e nextObject]) {
                Event *event = [_events objectForKey:eventIdentifier];
                EKEvent *ekEvent = [_eventStore eventWithIdentifier:eventIdentifier];
                
                if (ekEvent == NULL) {
                    // Event was deleted externally, remove from events dictionary
                    [_events removeObjectForKey:eventIdentifier];
                    continue;
                }
                
                [event setEkEvent:ekEvent];
            }
        } else {
            _events = [[NSMutableDictionary alloc] init];
        }
                
        if (!(_ekCalendar = [self fetchExistingCalendar])) {
            _ekCalendar = [self createNewCalendar];
        }
	}
	
    return self;
}

- (EKCalendar*)fetchExistingCalendar {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *calendarIdentifier = [defaults stringForKey:CALENDAR_IDENTIFIER_SAVE_KEY];
    
    if (calendarIdentifier != NULL) {
        return [_eventStore calendarWithIdentifier:calendarIdentifier];
    }
    return NULL;
}

- (EKCalendar*)createNewCalendar {
    EKSource* localSource;
    for (EKSource* source in _eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }
    
    if (!localSource) {
        return NULL;
    }
    
    EKCalendar *calendar = [EKCalendar calendarWithEventStore:_eventStore];
    calendar.source = localSource;
    calendar.title = CALENDAR_TITLE;
    
    NSError* error;
    [_eventStore saveCalendar:calendar commit:YES error:&error];
    
    NSString *calendarIdentifier = [calendar calendarIdentifier];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:calendarIdentifier forKey:CALENDAR_IDENTIFIER_SAVE_KEY];
    [defaults synchronize];
    
    if (error != nil) {
        NSLog(@"%@", error.description);
    }
    
    return calendar;
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
            Event *newEvent = [[Event alloc] initWithEKEvent:ekEvent andEventStore:_eventStore];
            [_events setObject:newEvent forKey:[ekEvent eventIdentifier]];
        }
    }
}

- (NSArray*)getEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime {
    [self loadEKEventsBetweenStartTime:startTime andEndTime:endTime];
    
    NSMutableArray *retEvents = [[NSMutableArray alloc] init];
    NSEnumerator *e = [_events objectEnumerator];
    Event *event;
    while (event = [e nextObject]) {
        if ([CalendarMath timesIntersectS1:[event startTime] e1:[event endTime] s2:startTime e2:endTime]) {
            [retEvents addObject:event];
        }
    }
    
    return retEvents;
}

- (Event*)eventWithId:(NSString*)identifier {
    return [_events objectForKey:identifier];
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
    [newEKEvent setCalendar:_ekCalendar];
    [newEKEvent setTitle:DEFAULT_EVENT_TITLE];
    
    Event *newEvent = [[Event alloc] initWithEKEvent:newEKEvent andEventStore:_eventStore];
    [newEvent save];                            // Need to save to get event identifier
    [_events setObject:newEvent forKey:[newEvent identifier]];
    return newEvent;
}

- (void)deleteEvent:(NSString*)eventId {
    Event *e = [_events objectForKey:eventId];
    
    NSError *deleteError;
    [_eventStore removeEvent:e.ekEvent span:EKSpanThisEvent error:&deleteError];
}

- (void)save {
    // Save to EventKit
    NSEnumerator *e = [_events objectEnumerator];
    Event* event;
    while (event = [e nextObject]) {
        [event save];
    }
    
    NSError *saveError;
    [_eventStore commit:&saveError];
    
    if (saveError != nil) {
        NSLog(@"%@", saveError.description);
    }
    
    //Save locally
    NSData *serializedEvents = [NSKeyedArchiver archivedDataWithRootObject:_events];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serializedEvents forKey:EVENTS_SAVE_KEY];
    [defaults synchronize];
}

@end
