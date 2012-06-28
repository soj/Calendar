#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Category.h"

@interface Event : NSObject <NSCoding> {
	EKEvent *_ekEvent;
	Category *_category;
}

@property (nonatomic, strong) EKEvent *ekEvent;
@property (nonatomic) NSString *title;
@property (readonly) NSString* identifier;

- (id)initWithEKEvent:(EKEvent*)ekEvent;
- (NSTimeInterval)startTime;
- (NSTimeInterval)endTime;

@end
