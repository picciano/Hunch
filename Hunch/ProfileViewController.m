//
//  ProfileViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/26/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "ProfileViewController.h"
#import "SignUpViewController.h"
#import "CocoaLumberjack.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfResponsesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfQuestionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (nonatomic) int numberOfResponses;
@property (nonatomic) int numberOfQuestions;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadProfile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfile) name:CURRENT_USER_CHANGE_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDisplay];
}

- (void)updateDisplay {
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.usernameLabel.text = @"Anonymous";
        self.signupButton.hidden = NO;
    } else {
        self.usernameLabel.text = [PFUser currentUser].username;
        self.signupButton.hidden = YES;
    }
    
    self.numberOfResponsesLabel.text = [NSString stringWithFormat:@"%i", self.numberOfResponses];
    self.numberOfQuestionsLabel.text = [NSString stringWithFormat:@"%i", self.numberOfQuestions];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.accountCreatedLabel.text = [dateFormatter stringFromDate:[PFUser currentUser].createdAt];
}

- (IBAction)signUp:(id)sender {
    UIViewController *viewController = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)setNumberOfQuestions:(int)numberOfQuestions {
    _numberOfQuestions = numberOfQuestions;
    [self updateDisplay];
}

- (void)setNumberOfResponses:(int)numberOfResponses {
    _numberOfResponses = numberOfResponses;
    [self updateDisplay];
}

- (void)loadProfile {
    self.numberOfQuestions = 0;
    self.numberOfResponses = 0;
    
    PFQuery *answers = [PFQuery queryWithClassName:OBJECT_TYPE_RESPONSE];
    [answers whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [answers countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            DDLogError(@"Error counting responses: %@", error);
        } else {
            self.numberOfResponses = number;
        }
    }];
    PFQuery *questions = [PFQuery queryWithClassName:OBJECT_TYPE_QUESTION];
    [questions whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [questions countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            DDLogError(@"Error counting questions: %@", error);
        } else {
            self.numberOfQuestions = number;
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
