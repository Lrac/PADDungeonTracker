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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
