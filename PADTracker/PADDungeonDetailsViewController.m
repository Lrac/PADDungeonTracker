//
//  PADDungeonDetailsViewController.m
//  PADTracker
//
//  Created by Carl Lam on 2014-08-11.
//
//

#import "PADDungeonDetailsViewController.h"
#import "PADDungeonEvent.h"

@interface PADDungeonDetailsViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) IBOutlet UIImageView *dungeonImage;
@property (strong, nonatomic) IBOutlet UILabel *dungeonDate;

@end

@implementation PADDungeonDetailsViewController

@synthesize dungeonEvent;

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
    [self.navigationBar setTitle:self.dungeonEvent.dungeonName];
    // Do any additional setup after loading the view.

    //queue updates in separate thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL rand = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dungeonImage.image = self.dungeonEvent.dungeonImage;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, MMM d"];
            [timeFormatter setDateFormat:@"h:mm a"];
            self.dungeonDate.text = [dateFormatter stringFromDate:self.dungeonEvent.dungeonDate];
            self.dungeonTime.text = [timeFormatter stringFromDate:self.dungeonEvent.dungeonDate];
            self.timeTillStart.text = @"";
        });


        while (rand) {
             int timeDifference = [self.dungeonEvent.dungeonDate timeIntervalSinceNow];
            if  (self.dungeonEvent.dungeonDate == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.dungeonDate.text = @"Time not available yet";
                });
            } else if (timeDifference >= 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    int hours = timeDifference / 3600;
                    int minutes = timeDifference % 3600 / 60;
                    int seconds = timeDifference % 3600 % 60;
                    self.timeTillStart.text = [NSString stringWithFormat:@"Starts in %dh %dm %ds", hours, minutes, seconds];
                });
            } else if (timeDifference < -3600){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.timeTillStart.text = @"Dungeon has ended";
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    int endTime = timeDifference + 3600;
                    int minutes = endTime / 60;
                    int seconds = endTime % 60;
                    self.timeTillStart.text = [NSString stringWithFormat:@"Ends in %dm %ds", minutes, seconds];
                    self.timeTillStart.textColor = [UIColor redColor];
                });
            }
            [NSThread sleepForTimeInterval:1];
            
        }

        
    });
    
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
