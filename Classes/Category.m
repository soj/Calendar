#import "Category.h"

@implementation Category

@synthesize identifier=_identifier, color=_color, name=_name;

static NSMutableDictionary* categoriesByIdentifier = nil;

+ (void)loadCategoriesFrom:(NSArray *)categories {
    [categories enumerateObjectsUsingBlock:^(Category* cat, NSUInteger index, BOOL *stop){
        [categoriesByIdentifier setObject:cat forKey:cat.identifier];
    }];
}

+ (Category*)categoryByIdentifier:(NSString*)identifier {
    return [categoriesByIdentifier objectForKey:identifier];
}

+ (NSArray*)allCategories {
    return [categoriesByIdentifier allValues];
}

+ (void)registerCategory:(Category*)cat {
    if (categoriesByIdentifier == nil) {
        categoriesByIdentifier = [[NSMutableDictionary alloc] init];
    }
    [categoriesByIdentifier setObject:cat forKey:cat.identifier];
}

- (id)initWithName:(NSString*)name andColor:(UIColor*)color {
	self = [super init];
	
	if (self != nil) {
        _identifier = [[NSProcessInfo processInfo] globallyUniqueString];
		_name = name;
		_color = color;
	}
    
    [Category registerCategory:self];
	
	return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _color = [aDecoder decodeObjectForKey:@"color"];
    }
    
    [Category registerCategory:self];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_color forKey:@"color"];
}

@end
