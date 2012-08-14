#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface AnimatableLayer : CALayer
@property (nonatomic) float customprop;
@end

@interface LayerDelegate : NSObject {
    __weak UIView* _view;
}

- (id)initWithView:(UIView*)view;
- (CALayer*)makeLayerWithName:(NSString*)name;
- (AnimatableLayer*)makeAnimatableLayerWithName:(NSString*)name;

@end