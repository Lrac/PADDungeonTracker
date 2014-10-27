//
//  PADDungeonDetailsViewController.h
//  PADTracker
//
//  Created by Carl Lam on 2014-08-11.
//
//

#import <UIKit/UIKit.h>
#import "PADDungeonEvent.h"

@interface PADDungeonDetailsViewController : UIViewController

@property PADDungeonEvent *dungeonEvent;
@property (strong, nonatomic) IBOutlet UILabel *dungeonTime;
@property (strong, nonatomic) IBOutlet UILabel *timeTillStart;

@end
