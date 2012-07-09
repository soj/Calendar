#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Category.h"

#define DEFAULT_EVENT_TITLE             @"Untitled Event"

@interface Event : NSObject <NSCoding> {
	EKEvent *_ekEvent;
    EKEventStore *_ekEventStore;
    EKCalendar *_ekCalendar;
    
    NSString *_identifier;
    NSString *_title;
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
	NSString *_categoryIdentifier;
}

@property (nonatomic, strong) EKEvent *ekEvent;

@property (nonatomic) NSString *title;
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic) NSString* categoryIdentifier;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;

- (id)initWithEvent:(EKEvent*)event;
- (void)setEKEventStore:(EKEventStore*)eventStore andEKCalendar:(EKCalendar*)calendar;

- (BOOL)loadFromEventKitWithIdentifier:(NSString*)identifier;
- (void)prepEKEvent;
- (void)saveToEventKit;

- (Category*)category;
- (Category*)categoryOrNull;

@end
