#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Event.h"

#define EVENTS_SAVE_KEY  @"events"

@interface Calendar : NSObject {
	EKEventStore *_eventStore;
	NSMutableDictionary *_events;
    
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
}

- (void)loadEKEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (NSArray*)getEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (Event*)createEventWithStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (NSArray*)categories;
- (void)save;

@end
