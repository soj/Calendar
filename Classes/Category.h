#import <Foundation/Foundation.h>

@interface Category : NSObject <NSCoding> {
	NSString *_name;
	UIColor *_color;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIColor *color;

- (id)initWithName:(NSString*)name andColor:(UIColor*)color;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
