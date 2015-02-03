//
//  AchievementTableViewCell.h
//  Hunch
//
//  Created by Anthony Picciano on 1/28/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AchievementTableViewCell : UITableViewCell

@property (strong, nonatomic) PFObject *achievement;

@end
