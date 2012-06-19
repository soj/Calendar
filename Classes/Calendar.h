#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface Calendar : NSObject {
	EKEventStore *_eventStore;
	
	NSMutableArray *_events;
	NSMutableArray *_categories;
}

@property (retain) NSMutableArray *categories;

- (NSArray*)getEventsForRefDate:(int)refDate;
- (void)createEvent;

@end
