#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface LayerDelegate : NSObject {
    __weak UIView* _view;
}

- (id)initWithView:(UIView*)view;
- (CALayer*)makeLayerWithName:(NSString*)name;

@end