//
//  PADDungeonTrackerTableViewController.h
//  PADTracker
//
//  Created by Carl Lam on 2014-08-09.
//
//

#import <UIKit/UIKit.h>

@interface PADDungeonTrackerTableViewController : UITableViewController<NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableData *_responseData;
}

@property NSUInteger starter;
@property NSUInteger group;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
