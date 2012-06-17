#import "EventManager.h"


@implementation EventManager

- (NSArray*)getEventsForRefDate:(int)refDate {
	NSDate *startDate;
	NSDate *endDate;
	NSPredicate *datePred = [_eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
	return [_eventStore eventsMatchingPredicate:datePred];
}

- (void)createEvent {
	EKEvent *newEvent = [EKEvent eventWithEventStore:_eventStore];
}

@end
