//
//  PADDungeonEvent.h
//  PADTracker
//
//  Created by Carl Lam on 2014-08-09.
//
//

#import <Foundation/Foundation.h>

@interface PADDungeonEvent : NSObject

@property NSString *dungeonName;
@property NSString *dungeonTime;
@property NSDate *dungeonDate;
@property NSString *dungeonLink;
@property NSString *dungeonImageURL;
@property UIImage *dungeonImage;
@property BOOL clockClicked;
@property UIImage *clockImage;
@property NSDate *alarmDate;
@property UILocalNotification *alarmNotification;
@property (readonly) NSDate *creationDate;

@end
