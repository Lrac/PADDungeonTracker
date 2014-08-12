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
@property NSString *dungeonLink;
@property BOOL clockClicked;
@property UIImage *clockImage;
@property (readonly) NSDate *creationDate;

@end
