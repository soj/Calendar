//
//  CategoryChooserCell.h
//  calendar
//
//  Created by Fravic Fernando on 12-06-17.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CategoryChooserCell : UITableViewCell {
	UILabel *_categoryName;
	UIView *_colorView;
	UIColor *_color;
}

@property (nonatomic, strong) IBOutlet UILabel *categoryName;
@property (nonatomic, strong) IBOutlet UIView *colorView;

- (void)setColor:(UIColor*)color;
- (void)setName:(NSString*)name;

@end
