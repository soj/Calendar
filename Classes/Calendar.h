#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Event.h"

#define CALENDAR_TITLE                  @"Focus Calendar"
#define EVENTS_SAVE_KEY                 @"events"
#define CALENDAR_IDENTIFIER_SAVE_KEY    @"calendarIdentifier"

@interface Calendar : NSObject {
	EKEventStore *_eventStore;
    EKCalendar *_ekCalendar;
	NSMutableDictionary *_events;
    
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
}

- (void)loadEKEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (NSArray*)getEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (Event*)createEventWithStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (NSArray*)categories;
- (EKCalendar*)createNewCalendar;
- (EKCalendar*)fetchExistingCalendar;
- (void)save;

@end
