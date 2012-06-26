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

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _color = [aDecoder decodeObjectForKey:@"color"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_color forKey:@"color"];
}

@end
