//
//  AchievementTableViewCell.m
//  Hunch
//
//  Created by Anthony Picciano on 1/28/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "AchievementTableViewCell.h"
#import "Constants.h"
#import "PFObject+DateFormat.h"

@interface AchievementTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *achievementTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *achievementDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *achievementCreatedAtLabel;

@end

@implementation AchievementTableViewCell

- (void)setAchievement:(PFObject *)achievement {
    _achievement = achievement;
    [self updateDisplay];
}

- (void)updateDisplay {
    self.achievementTextLabel.text = [NSString stringWithFormat:@"%@", self.achievement[OBJECT_KEY_TEXT]];
    self.achievementDescriptionLabel.text = [NSString stringWithFormat:@"%@", self.achievement[OBJECT_KEY_DESCRIPTION]];
    self.achievementCreatedAtLabel.text = [NSString stringWithFormat:@"Asked on %@", [self.achievement createdAtWithDateFormat:NSDateFormatterMediumStyle timeFormat:NSDateFormatterShortStyle]];
}

@end
