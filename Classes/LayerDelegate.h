#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/* A layer that provides a special property for animation in drawInContext */
@interface ComplexAnimLayer : CALayer

@property (nonatomic) float animValue;

+ (NSString*)animPropName;

@end


@interface LayerDelegate : NSObject {
    __weak UIView* _view;
}

- (id)initWithView:(UIView*)view;
- (CALayer*)makeLayerWithName:(NSString*)name;
- (ComplexAnimLayer*)makeComplexAnimLayerWithName:(NSString*)name;

@end