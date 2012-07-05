#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Category.h"

@interface Event : NSObject <NSCoding> {
	EKEvent *_ekEvent;
    EKEventStore *_ekEventStore;
	Category *_category;
}

@property (nonatomic, strong) EKEvent *ekEvent;
@property (nonatomic, strong) Category *category;
@property (nonatomic) NSString *title;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (readonly) NSString* identifier;

- (id)initWithEKEvent:(EKEvent*)ekEvent andEventStore:(EKEventStore*)store;
- (void)save;

@end
