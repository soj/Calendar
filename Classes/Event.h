#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Category.h"

@interface Event : NSObject <NSCoding> {
	EKEvent *_ekEvent;
	Category *_category;
}

- (id)initWithEKEvent:(EKEvent*)ekEvent;
- (NSTimeInterval)startTime;
- (NSTimeInterval)endTime;

@end
