#import "Event.h"


@implementation Event

@synthesize ekEvent=_ekEvent;

- (id)initWithEKEvent:(EKEvent*)ekEvent andEventStore:(EKEventStore*)store {
    if (self = [super init]) {
        _ekEvent = ekEvent;
        _ekEventStore = store;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _category = [aDecoder decodeObjectForKey:@"category"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ekEvent.eventIdentifier forKey:@"eventIdentifier"];
    [aCoder encodeObject:_category forKey:@"category"];
}

- (NSString*)identifier {
    NSAssert([_ekEvent eventIdentifier] != NULL, @"Need to save EKEvent before retrieving event identifier");
    return [_ekEvent eventIdentifier];
}

- (void)setCategory:(Category *)category {
    _category = category;
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

- (void)setTitle:(NSString*)title {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    [_ekEvent setTitle:title];
    [self save];
}

- (NSString*)title {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    return [_ekEvent title];
}

- (void)setStartTime:(NSTimeInterval)startTime {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    [_ekEvent setStartDate:[NSDate dateWithTimeIntervalSinceReferenceDate:startTime]];
    [self save];
}

- (NSTimeInterval)startTime {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    return [[_ekEvent startDate] timeIntervalSinceReferenceDate];
}

- (void)setEndTime:(NSTimeInterval)endTime {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    [_ekEvent setEndDate:[NSDate dateWithTimeIntervalSinceReferenceDate:endTime]];
    [self save];
}

- (NSTimeInterval)endTime {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    return [[_ekEvent endDate] timeIntervalSinceReferenceDate];
}

- (void)save {
    NSError *saveError;
    if (![_ekEventStore saveEvent:_ekEvent span:EKSpanThisEvent error:&saveError]) {
        NSLog(@"Warning: No new event data to save");
    }
    
    if (saveError != nil) {
        NSLog(@"%@", saveError.description);
    }
}

@end
