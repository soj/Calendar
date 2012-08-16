#import <Foundation/Foundation.h>

#import "CalendarEvent.h"

@interface LayerAnimationFactory : NSObject

+ (void)animate:(CALayer*)layer toFrame:(CGRect)frame;

@end
