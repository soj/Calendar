#import "Category.h"


@implementation Category

@synthesize color=_color, name=_name;

- (id)initWithName:(NSString*)name andColor:(UIColor*)color {
	self = [super init];
	
	if (self != nil) {
		_name = name;
		_color = color;
	}
	
	return self;
}

@end
