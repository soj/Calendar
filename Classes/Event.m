#import "Event.h"


@implementation Event

@synthesize ekEvent=_ekEvent;

- (id)initWithEKEvent:(EKEvent*)ekEvent {
    if (self = [super init]) {
        _ekEvent = [ekEvent retain];
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

- (NSTimeInterval)startTime {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    return [[_ekEvent startDate] timeIntervalSinceReferenceDate];
}

- (NSTimeInterval)endTime {
    NSAssert(_ekEvent != NULL, @"Could not find EKEvent for Event");
    return [[_ekEvent endDate] timeIntervalSinceReferenceDate];
}

@end
