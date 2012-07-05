/* UIColor tools from http://www.cocoanetics.com/2009/10/manipulating-uicolors/ */

#import <Foundation/Foundation.h>

@interface UIColor (Tools)
- (UIColor*)colorByDarkeningColor;
+ (UIColor*)colorForIndex:(NSInteger)idx;
@end
