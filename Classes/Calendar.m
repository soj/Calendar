#import "Calendar.h"
#import "Category.h"

@implementation Calendar

@synthesize categories=_categories;

- (id)init {
	self = [super init];
	
	if (self != nil) {
		_categories = [[NSMutableArray alloc] init];
		[_categories addObject:[[Category alloc] initWithName:@"Social" andColor:[UIColor orangeColor]]];
		[_categories addObject:[[Category alloc] initWithName:@"Health" andColor:[UIColor purpleColor]]];
		[_categories addObject:[[Category alloc] initWithName:@"Waste of Time" andColor:[UIColor greenColor]]];
	}
	
	return self;
}

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
