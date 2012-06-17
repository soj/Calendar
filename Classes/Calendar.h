#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface Calendar : NSObject {
	EKEventStore *_eventStore;
}

- (NSArray*)getEventsForRefDate:(int)refDate;
- (void)createEvent;

@end
