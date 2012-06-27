#import <Foundation/Foundation.h>
#import "CalendarEntity.h"
#import "ShadowedTextField.h"
#import "Category.h"
#import "CategoryChooserController.h"

#define EVENT_DX			65.0
#define RIGHT_RAIL_WIDTH	45.0

#define BORDER_COLOR		0, 0, 0, 0.4
#define BORDER_PADDING_X	10.0
#define BORDER_PADDING_Y	5.0

@interface CalendarEvent : CalendarEntity <UITextFieldDelegate, CategoryChooserDelegate> {
	NSString *_eventId;
	ShadowedTextField *_nameField;
	ShadowedTextField *_catField;
    
    int _multitaskIndex;
    int _numMultitasks;
}

@property (nonatomic, strong) NSString *eventId;

- (void)setFocus;
- (void)drawInContext:(CGContextRef)context;
- (void)setCategory:(Category*)cat;
- (void)setMultitaskIndex:(int)index outOf:(int)numMultitasks;
- (void)resizeTextFields;
- (void)setTitle:(NSString*)title;

@end
