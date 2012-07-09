#import "Calendar.h"
#import "Category.h"
#import "CalendarMath.h"

@implementation Calendar

@synthesize ekEventStore=_ekEventStore, ekCalendar=_ekCalendar;

- (id)init {
	self = [super init];
	
	if (self != nil) {
        _ekEventStore = [[EKEventStore alloc] init];
        _ekEvents = [[NSMutableDictionary alloc] init];
        
        if (!(_ekCalendar = [self fetchExistingCalendar])) {
            _ekCalendar = [self createNewCalendar];
        }
    }
    
    [self loadSavedData];
	
    return self;
}

- (NSArray*)defaultCategories {
    return [[NSArray alloc] initWithObjects:
            [[Category alloc] initAndRegisterWithName:@"Social" andColor:[UIColor orangeColor]],
            [[Category alloc] initAndRegisterWithName:@"Health" andColor:[UIColor purpleColor]],
            [[Category alloc] initAndRegisterWithName:@"Waste of Time" andColor:[UIColor greenColor]],
            nil];
}

- (void)loadSavedCategories {
    NSData *serializedCategories = [[NSUserDefaults standardUserDefaults] dataForKey:CATEGORIES_SAVE_KEY];
    NSArray *categories = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:serializedCategories];
    
    if (!categories) {
        categories = [self defaultCategories];
    }
    
    [Category loadCategoriesFrom:categories];
}

- (void)loadSavedEvents {
    NSData *serializedEvents = [[NSUserDefaults standardUserDefaults] dataForKey:EVENTS_SAVE_KEY];
    _events = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:serializedEvents];
    
    if (_events) {
        [[_events allValues] enumerateObjectsUsingBlock:^(Event* e, NSUInteger index, BOOL *stop){
            [e setEKEventStore:_ekEventStore andEKCalendar:_ekCalendar];
            if (e.ekEvent) {
                [_ekEvents setObject:e.ekEvent forKey:e.ekEvent.eventIdentifier];
            }
        }];
    } else {
        _events = [[NSMutableDictionary alloc] init];
    }
}

- (void)loadSavedData {
    [self loadSavedCategories];
    [self loadSavedEvents];
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
            [newEvent setEKEventStore:_ekEventStore andEKCalendar:_ekCalendar];
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

- (Event*)createEventWithStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime {
    Event *newEvent = [[Event alloc] init];
    [newEvent setEKEventStore:_ekEventStore andEKCalendar:_ekCalendar];
    
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
    NSData *serializedCategories = [NSKeyedArchiver archivedDataWithRootObject:[Category allCategories]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serializedEvents forKey:EVENTS_SAVE_KEY];
    [defaults setObject:serializedCategories forKey:CATEGORIES_SAVE_KEY];
    [defaults synchronize];
}

@end
