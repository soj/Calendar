#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Event.h"

#define CALENDAR_TITLE                  @"Focus Calendar"
#define EVENTS_SAVE_KEY                 @"events"
#define CATEGORIES_SAVE_KEY            @"categories"
#define CALENDAR_IDENTIFIER_SAVE_KEY    @"calendarIdentifier"

@interface Calendar : NSObject {
	EKEventStore *_ekEventStore;
    EKCalendar *_ekCalendar;
    
	NSMutableDictionary *_events;
    NSMutableDictionary *_ekEvents;
    
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
}

@property (nonatomic, readonly, strong) EKEventStore* ekEventStore;
@property (nonatomic, readonly, strong) EKCalendar* ekCalendar;

- (void)loadSavedData;
- (BOOL)shouldSaveToEventKit;

- (void)loadEKEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (NSArray*)getEventsBetweenStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (Event*)createEventWithStartTime:(NSTimeInterval)startTime andEndTime:(NSTimeInterval)endTime;
- (void)deleteEvent:(NSString*)eventId;

- (Event*)eventWithId:(NSString*)identifier;
- (EKCalendar*)createNewCalendar;
- (EKCalendar*)fetchExistingCalendar;

- (void)save;
- (void)saveToEventKit;

@end
