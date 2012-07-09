#import "Event.h"

@implementation Event

@synthesize ekEvent=_ekEvent, title=_title, startTime=_startTime, endTime=_endTime, identifier=_identifier, categoryIdentifier=_categoryIdentifier;

- (id)init {
    if (self = [super init]) {
        _identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    
    return self;
}

- (id)initWithEvent:(EKEvent*)event {
    if (self = [self init]) {
        _ekEvent = event;
        _title = [_ekEvent title];
        _startTime = [[_ekEvent startDate] timeIntervalSinceReferenceDate];
        _endTime = [[_ekEvent endDate] timeIntervalSinceReferenceDate];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _identifier = [aDecoder decodeObjectForKey:@"eventIdentifier"];
        _categoryIdentifier = [aDecoder decodeObjectForKey:@"categoryIdentifier"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _startTime = [aDecoder decodeFloatForKey:@"startTime"];
        _endTime = [aDecoder decodeFloatForKey:@"endTime"];
        
        NSString *ekEventIdentifier = [aDecoder decodeObjectForKey:@"ekEventIdentifier"];
        if (ekEventIdentifier) {
            [self loadFromEventKitWithIdentifier:ekEventIdentifier];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self identifier] forKey:@"eventIdentifier"];
    [aCoder encodeObject:[self title] forKey:@"title"];
    [aCoder encodeFloat:[self startTime] forKey:@"startTime"];
    [aCoder encodeFloat:[self endTime] forKey:@"endTime"];

    if (_categoryIdentifier != nil) {
        [aCoder encodeObject:_categoryIdentifier forKey:@"categoryIdentifier"];
    }
        
    if (_ekEvent != nil) {
        [aCoder encodeObject:[_ekEvent eventIdentifier] forKey:@"ekEventIdentifier"];
    }
}

- (void)setEKEventStore:(EKEventStore*)eventStore andEKCalendar:(EKCalendar*)calendar {
    _ekEventStore = eventStore;
    _ekCalendar = calendar;
}

- (Category*)category {
    if (_categoryIdentifier == nil) {
        return [Category uncategorized];
    }
    return [Category categoryByIdentifier:_categoryIdentifier];
}

- (Category*)categoryOrNull {
    return [Category categoryByIdentifier:_categoryIdentifier];
}

- (BOOL)loadFromEventKitWithIdentifier:(NSString*)identifier {
    if (_ekEvent) return YES;
    
    NSAssert(_ekEventStore != nil, @"Must set EKEventStore and EKCalendar on Event");
    _ekEvent = [_ekEventStore eventWithIdentifier:identifier];
    return (_ekEvent != nil);
}

- (void)prepEKEvent {
    if (!_ekEvent) {
        NSAssert(_ekEventStore != nil && _ekCalendar != nil, @"Must set EKEventStore and EKCalendar on Event");

        _ekEvent = [EKEvent eventWithEventStore:_ekEventStore];
        [_ekEvent setStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_startTime]];
        [_ekEvent setEndDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_endTime]];
        [_ekEvent setCalendar:_ekCalendar];
        [_ekEvent setTitle:[self title]];
    }
}

- (void)saveToEventKit {
    [self prepEKEvent];
    
    NSAssert(_ekEventStore != nil, @"Must set EKEventStore and EKCalendar on Event");
    
    NSError *saveError;
    if (![_ekEventStore saveEvent:_ekEvent span:EKSpanThisEvent error:&saveError]) {
        NSLog(@"Warning: No new event data to save");
    }
    
    if (saveError != nil) {
        NSLog(@"%@", saveError.description);
    }
}

@end
