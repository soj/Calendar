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

+ (Category*)uncategorized {
    return [[Category alloc] initWithName:@"Uncategorized" andColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
}

+ (UIColor*)nextColor {
    int idx = [categoriesByIdentifier count];
    switch (idx % 4) {
        case 0: {
            return [UIColor colorWithRed:140/255.0 green:0 blue:0 alpha:1.0];
        }
        case 1: {
            return [UIColor colorWithRed:0 green:69/255.0 blue:140/255.0 alpha:1.0];
        }
        case 2: {
            return [UIColor colorWithRed:51/255.0 green:144/255.0 blue:53/255.0 alpha:1.0];
        }
        case 3: {
            return [UIColor colorWithRed:127/255.0 green:51/255.0 blue:126/255.0 alpha:1.0];
        }
    }
    return [[Category uncategorized] color];
}

- (id)initWithName:(NSString *)name andColor:(UIColor *)color {
	if (self = [super init]) {
        _identifier = [[NSProcessInfo processInfo] globallyUniqueString];
		_name = name;
		_color = color;
	}
    return self;
}

- (id)initAndRegisterWithName:(NSString*)name andColor:(UIColor*)color {
	self = [self initWithName:name andColor:color];
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
