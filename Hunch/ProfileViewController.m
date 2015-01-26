//
//  ProfileViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/26/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "ProfileViewController.h"
#import "CocoaLumberjack.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnswersLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfQuestionsLabel;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDisplay];
}

- (void)updateDisplay {
    self.usernameLabel.text = [PFUser currentUser].username;
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.usernameLabel.text = @"Anonymous";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.accountCreatedLabel.text = [dateFormatter stringFromDate:[PFUser currentUser].createdAt];
}

- (void)loadProfile {
    PFQuery *answers = [PFQuery queryWithClassName:OBJECT_TYPE_ANSWER];
    [answers whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [answers countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            DDLogError(@"Error counting answers: %@", error);
        } else {
            self.numberOfAnswersLabel.text = [NSString stringWithFormat:@"%i", number];
        }
    }];
    PFQuery *questions = [PFQuery queryWithClassName:OBJECT_TYPE_QUESTION];
    [questions whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [questions countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            DDLogError(@"Error counting questions: %@", error);
        } else {
            self.numberOfQuestionsLabel.text = [NSString stringWithFormat:@"%i", number];
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
