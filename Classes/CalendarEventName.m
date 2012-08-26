#import "CalendarEventName.h"

#import "UIConstants.h"

@implementation CalendarEventName

+ (Class)layerClass {
    return NameLayer.class;
}

- (id)init {
    if (self = [super init]) {
        self.font = UI_MEDIUM_FONT;
        self.textColor = UI_NAME_COLOR;
        self.returnKeyType = UIReturnKeyDone;
        self.editable = NO;
        self.scrollEnabled = NO;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
