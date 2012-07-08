#import "Calendar.h"
#import "Category.h"
#import "CalendarMath.h"

@implementation Calendar

@synthesize ekEventStore=_ekEventStore, ekCalendar=_ekCalendar;

static Calendar* instance = nil;

+ (Calendar*)getInstance {
    if (instance == nil) {
        instance = [[Calendar alloc] init];
        [instance loadEvents];
    }
    return instance;
}

- (id)init {
    NSAssert(instance == nil, @"Attempted to create multiple instances of Singleton");
    
	self = [super init];
	
	if (self != nil) {
        _ekEventStore = [[EKEventStore alloc] init];
        _ekEvents = [[NSMutableDictionary alloc] init];
        
        if (!(_ekCalendar = [self fetchExistingCalendar])) {
            _ekCalendar = [self createNewCalendar];
        }
    }
	
    return self;
}

- (void)loadEvents {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *serializedEvents = [defaults dataForKey:EVENTS_SAVE_KEY];
    _events = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:serializedEvents];
    
    if (_events) {
        [[_events allValues] enumerateObjectsUsingBlock:^(Event* x, NSUInteger index, BOOL *stop){
            if (x.ekEvent) {
                [_ekEvents setObject:x.ekEvent forKey:x.ekEvent.eventIdentifier];
            }
        }];
    } else {
        _events = [[NSMutableDictionary alloc] init];
    }

}

- (BOOL)shouldSaveToEventKit {
    // TODO: Make this a setting
    return NO;
}

- (EKCalendar*)fetchExistingCalendar {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *calendarIdentifier = [defaults stringForKey:CALENDAR_IDENTIFIER_SAVE_KEY];
    
    if (calendarIdentifier != NULL) {
        return [_ekEventStore calendarWithIdentifier:calendarIdentifier];
    }
    return NULL;
}

- (EKCalendar*)createNewCalendar {
    EKSource* localSource;
    for (EKSource* source in _ekEventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }
    
    if (!localSource) {
        return NULL;
    }
    
    EKCalendar *calendar = [EKCalendar calendarWithEventStore:_ekEventStore];
    calendar.source = localSource;
    calendar.title = CALENDAR_TITLE;
    
    NSError* error;
    [_ekEventStore saveCalendar:calendar commit:YES error:&error];
    
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
    
    NSPredicate *predicate = [_ekEventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *ekEvents = [_ekEventStore eventsMatchingPredicate:predicate];
    
    [ekEvents enumerateObjectsUsingBlock:^(EKEvent* ekEvent, NSUInteger index, BOOL *stop){
        // Ignore all-day events because they're impossible to represent
        if ([ekEvent isAllDay]) {
            return;
        }
        
        if (![_ekEvents objectForKey:[ekEvent eventIdentifier]]) {
            Event *newEvent = [[Event alloc] initWithEvent:ekEvent];
            [_events setObject:newEvent forKey:[newEvent identifier]];
            [_ekEvents setObject:ekEvent forKey:[ekEvent eventIdentifier]];
        }
    }];
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
    Event *newEvent = [[Event alloc] init];
    newEvent.startTime = startTime;
    newEvent.endTime = endTime;
    [_events setObject:newEvent forKey:[newEvent identifier]];
    return newEvent;
}

- (void)deleteEvent:(NSString*)eventId {
    Event *e = [_events objectForKey:eventId];
    [_events removeObjectForKey:eventId];
    
    NSError *deleteError;
    [_ekEventStore removeEvent:e.ekEvent span:EKSpanThisEvent error:&deleteError];
}

- (void)saveToEventKit {
    NSEnumerator *e = [_events objectEnumerator];
    Event* event;
    while (event = [e nextObject]) {
        [event saveToEventKit];
    }
    
    NSError *saveError;
    [_ekEventStore commit:&saveError];
    
    if (saveError != nil) {
        NSLog(@"%@", saveError.description);
    }
}

- (void)save {
    if ([self shouldSaveToEventKit]) {
        [self saveToEventKit];
    }
    
    NSData *serializedEvents = [NSKeyedArchiver archivedDataWithRootObject:_events];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serializedEvents forKey:EVENTS_SAVE_KEY];
    [defaults synchronize];
}

@end
