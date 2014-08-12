//
//  PADGroupSettingsViewController.m
//  PADTracker
//
//  Created by Carl Lam on 2014-08-09.
//
//

#import "PADGroupSettingsViewController.h"

@interface PADGroupSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *starterSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *groupSegment;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property NSInteger timeZoneRow;

@end

@implementation PADGroupSettingsViewController
@synthesize starterSegment;
@synthesize groupSegment;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.saveButton) return;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.starterSegment.selectedSegmentIndex forKey:@"key1"];
    [userDefaults setInteger:self.groupSegment.selectedSegmentIndex forKey:@"key2"];
    [userDefaults setObject:self.timeZone forKey:@"key3"];
    [userDefaults setInteger:self.timeZoneRow forKey:@"key4"];
    [userDefaults synchronize];
    self.starterType = self.starterSegment.selectedSegmentIndex;
    self.group = self.groupSegment.selectedSegmentIndex;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.starterSegment.selectedSegmentIndex = [userDefaults integerForKey:@"key1"];
    self.groupSegment.selectedSegmentIndex = [userDefaults integerForKey:@"key2"];
    self.timeZone = [userDefaults objectForKey:@"key3"];
    self.timeZoneRow = [userDefaults integerForKey:@"key4"];
    [self.timeZonePicker selectRow:self.timeZoneRow inComponent:0 animated:YES];
    self.timeZoneArray = [[NSArray alloc] initWithObjects:@"PDT", @"MDT", @"CDT", @"EDT", @"Atlantic Time",
                          @"London, Dublin, Lisbon Time", nil];
    self.myTimeZone.text = [self.timeZoneArray objectAtIndex:self.timeZoneRow];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 6;
}

// returns the number of 'columns' to display.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [self.timeZoneArray objectAtIndex:row];
}

// returns the # of rows in each component..
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    switch (row){
        case 0:
            self.timeZone = @"-8";
            self.timeZoneRow = row;
            
            self.myTimeZone.text = [self.timeZoneArray objectAtIndex:row];
            break;
        case 1:
            self.timeZone = @"-7";
            self.timeZoneRow = row;
            self.myTimeZone.text = [self.timeZoneArray objectAtIndex:row];
            break;
        case 2:
            self.timeZone = @"-6";
            self.timeZoneRow = row;
            self.myTimeZone.text = [self.timeZoneArray objectAtIndex:row];
            break;
        case 3:
            self.timeZone = @"-5";
            self.timeZoneRow = row;
            self.myTimeZone.text = [self.timeZoneArray objectAtIndex:row];
            break;
        case 4:
            self.timeZone = @"-4";
            self.timeZoneRow = row;
            self.myTimeZone.text = [self.timeZoneArray objectAtIndex:row];
            break;
        case 5:
            self.timeZone = @"0";
            self.timeZoneRow = row;
            self.myTimeZone.text = [self.timeZoneArray objectAtIndex:row];
            break;
            
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
