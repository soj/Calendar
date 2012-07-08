#import "Event.h"
#import "Calendar.h"

@implementation Event

@synthesize ekEvent=_ekEvent, title=_title, startTime=_startTime, endTime=_endTime, category=_category, identifier=_identifier;

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
        _category = [aDecoder decodeObjectForKey:@"category"];
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
    [aCoder encodeObject:[self categoryOrNull] forKey:@"category"];
    [aCoder encodeObject:[self title] forKey:@"title"];
    [aCoder encodeFloat:[self startTime] forKey:@"startTime"];
    [aCoder encodeFloat:[self endTime] forKey:@"endTime"];

    if (_ekEvent != nil) {
        [aCoder encodeObject:[_ekEvent eventIdentifier] forKey:@"ekEventIdentifier"];
    }
}

- (Category*)category {
    if (_category == NULL) {
        return [[Category alloc] initWithName:@"Uncategorized" andColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
    }
    return _category;
}

- (Category*)categoryOrNull {
    return _category;
}

- (BOOL)loadFromEventKitWithIdentifier:(NSString*)identifier {
    if (_ekEvent) return YES;
    _ekEvent = [[[Calendar getInstance] ekEventStore] eventWithIdentifier:identifier];
    return (_ekEvent != nil);
}

- (void)prepEKEvent {
    if (!_ekEvent) {
        _ekEvent = [EKEvent eventWithEventStore:[[Calendar getInstance] ekEventStore]];
        [_ekEvent setStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_startTime]];
        [_ekEvent setEndDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_endTime]];
        [_ekEvent setCalendar:[[Calendar getInstance] ekCalendar]];
        [_ekEvent setTitle:[self title]];
    }
}

- (void)saveToEventKit {
    [self prepEKEvent];
    
    NSError *saveError;
    if (![[[Calendar getInstance] ekEventStore] saveEvent:_ekEvent span:EKSpanThisEvent error:&saveError]) {
        NSLog(@"Warning: No new event data to save");
    }
    
    if (saveError != nil) {
        NSLog(@"%@", saveError.description);
    }
}

@end
