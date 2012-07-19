/* UIColor tools from http://www.cocoanetics.com/2009/10/manipulating-uicolors/ */

#import <Foundation/Foundation.h>

@interface UIColor (Tools)
- (UIColor*)colorByDarkeningColor:(CGFloat)colorMultiplier;
- (UIColor*)colorByChangingAlphaTo:(CGFloat)alpha;
+ (UIColor*)colorForFadeBetweenFirstColor:(UIColor *)firstColor secondColor:(UIColor *)secondColor atRatio:(CGFloat)ratio;
@end
