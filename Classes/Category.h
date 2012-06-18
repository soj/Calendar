#import <Foundation/Foundation.h>

@interface Category : NSObject {
	NSString *_name;
	UIColor *_color;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIColor *color;

- (id)initWithName:(NSString*)name andColor:(UIColor*)color;

@end
