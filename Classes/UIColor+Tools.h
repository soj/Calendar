/* UIColor tools from http://www.cocoanetics.com/2009/10/manipulating-uicolors/ */

#import <Foundation/Foundation.h>

@interface UIColor (Tools)
- (UIColor*)colorByDarkeningColor:(CGFloat)colorMultiplier;
- (UIColor*)colorByChangingAlphaTo:(CGFloat)alpha;
@end
