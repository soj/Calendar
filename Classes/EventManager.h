#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventManager : NSObject {
	EKEventStore *_eventStore;
}

- (NSArray*)getEventsForRefDate:(int)refDate;
- (void)createEvent;

@end
