#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Event.h"

#define CALENDAR_TITLE                  @"Focus Calendar"
#define EVENTS_SAVE_KEY                 @"events"
#define CALENDAR_IDENTIFIER_SAVE_KEY    @"calendarIdentifier"
#define DEFAULT_EVENT_TITLE             @"Untitled Event"

@interface Calendar : NSObject {
	EKEventStore *_eventStore;
    EKCalendar *_ekCalendar;
	NSMutableDictionary *_events;
    
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
}

@property (nonatomic, readonly, strong) EKEventStore* eventStore;

- (void)loadEKEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (NSArray*)getEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (Event*)createEventWithStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;

- (NSArray*)categories;
- (Event*)eventWithId:(NSString*)identifier;
- (EKCalendar*)createNewCalendar;
- (EKCalendar*)fetchExistingCalendar;

- (void)save;

@end
