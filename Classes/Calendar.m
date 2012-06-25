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
	}
	
	return self;
}

- (void)loadEKEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime {
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:endTime];
    
    NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *ekEvents = [_eventStore eventsMatchingPredicate:predicate];
    
    NSEnumerator *e = [ekEvents objectEnumerator];
    EKEvent *ekEvent;
    while (ekEvent = [e nextObject]) {
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

- (void)createEvent {
	EKEvent *newEvent = [EKEvent eventWithEventStore:_eventStore];
}

- (void)save {
    NSData *serializedEvents = [NSKeyedArchiver archivedDataWithRootObject:_events];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serializedEvents forKey:EVENTS_SAVE_KEY];
    [defaults synchronize];
}

@end
