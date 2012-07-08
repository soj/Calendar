#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Category.h"

#define DEFAULT_EVENT_TITLE             @"Untitled Event"

@interface Event : NSObject <NSCoding> {
	EKEvent *_ekEvent;
    
    NSString *_identifier;
    NSString *_title;
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
	Category *_category;
}

@property (nonatomic, strong) EKEvent *ekEvent;

@property (nonatomic) NSString *title;
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic, strong) Category *category;

- (id)initWithEvent:(EKEvent*)event;

- (BOOL)loadFromEventKitWithIdentifier:(NSString*)identifier;
- (void)prepEKEvent;
- (void)saveToEventKit;

- (Category*)categoryOrNull;

@end
