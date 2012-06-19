#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "Category.h"

@interface Event : NSObject {
	EKEvent *_ekEvent;
	Category *_category;
}

@end
