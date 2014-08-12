//
//  PADGroupSettingsViewController.h
//  PADTracker
//
//  Created by Carl Lam on 2014-08-09.
//
//

#import <UIKit/UIKit.h>

@interface PADGroupSettingsViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>

@property NSUInteger starterType;
@property NSUInteger group;
@property NSString *timeZone;
@property (strong, nonatomic) IBOutlet UILabel *myTimeZone;
@property (strong, nonatomic) IBOutlet UIPickerView *timeZonePicker;
@property (strong, nonatomic) NSArray *timeZoneArray;

@end
