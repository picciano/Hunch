//
//  QuestionTableViewCell.m
//  Hunch
//
//  Created by Anthony Picciano on 1/28/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "QuestionTableViewCell.h"
#import "Constants.h"
#import "PFObject+DateFormat.h"

@interface QuestionTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *questionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionCreatedAtLabel;

@end

@implementation QuestionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setQuestion:(PFObject *)question {
    _question = question;
    [self updateDisplay];
}

- (void)updateDisplay {
    self.questionTextLabel.text = self.question[OBJECT_KEY_TEXT];
    self.questionCreatedAtLabel.text = [NSString stringWithFormat:@"Asked on %@", [self.question createdAtWithDateFormat:NSDateFormatterMediumStyle timeFormat:NSDateFormatterShortStyle]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
