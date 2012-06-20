#import "Event.h"


@implementation Event

- (id)initWithEKEvent:(EKEvent*)ekEvent {
    if (self = [super init]) {
        _ekEvent = ekEvent;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        // TODO: Get the EKEvent with this identifier
        NSString *eventIdentifier = [aDecoder decodeObjectForKey:@"eventIdentifier"];
        _category = [aDecoder decodeObjectForKey:@"category"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ekEvent.eventIdentifier forKey:@"eventIdentifier"];
    [aCoder encodeObject:_category forKey:@"category"];
}

- (NSTimeInterval)startTime {
    return [[_ekEvent startDate] timeIntervalSinceReferenceDate];
}

- (NSTimeInterval)endTime {
    return [[_ekEvent endDate] timeIntervalSinceReferenceDate];
}

@end
