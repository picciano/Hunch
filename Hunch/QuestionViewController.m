//
//  QuestionViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/21/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "QuestionViewController.h"
#import "AskQuestionViewController.h"
#import "ProfileViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "CocoaLumberjack.h"

@interface QuestionViewController ()

@property (strong, nonatomic) PFObject *currentQuestion;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadEligibleQuestion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadEligibleQuestion) name:CURRENT_USER_CHANGE_NOTIFICATION object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)askAQuestion:(id)sender {
    UIViewController *viewController = [[AskQuestionViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)getQuestion:(id)sender {
    [self loadEligibleQuestion];
}

- (void)setCurrentQuestion:(PFObject *)currentQuestion {
    _currentQuestion = currentQuestion;
    [self updateDisplay:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDisplay:nil];
}

- (IBAction)updateDisplay:(id)sender {
    self.questionLabel.text = self.currentQuestion[OBJECT_KEY_TEXT];
}

- (IBAction)viewProfile:(id)sender {
    UIViewController *viewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)loadEligibleQuestion {
    self.currentQuestion = nil;
    PFQuery *myResponsesQuery = [PFQuery queryWithClassName:OBJECT_TYPE_RESPONSE];
    [myResponsesQuery whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:OBJECT_TYPE_QUESTION];
    [questionsQuery whereKey:OBJECT_KEY_USER notEqualTo:[PFUser currentUser]];
    [questionsQuery whereKey:OBJECT_KEY_ID doesNotMatchKey:OBJECT_KEY_QUESTION_ID inQuery:myResponsesQuery];
    
    [questionsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            DDLogError(@"Error loading eligible question: %@", error);
        } else {
            DDLogDebug(@"OBJECT_KEY_TEXT: %@", object[OBJECT_KEY_TEXT]);
            self.currentQuestion = object;
        }
    }];
}

- (void)saveResponse {
    PFObject *response = [PFObject objectWithClassName:OBJECT_TYPE_RESPONSE];
    response[OBJECT_KEY_QUESTION] = self.currentQuestion;
    response[OBJECT_KEY_USER] = [PFUser currentUser];
    
    PFRelation *answers = [self.currentQuestion relationForKey:OBJECT_KEY_ANSWERS];
    PFQuery *answersQuery = [answers query];
    PFObject *answer = [answersQuery getFirstObject];
    response[OBJECT_KEY_ANSWER] = answer;
    
    [response saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            DDLogError(@"Error during login: %@", error);
        } else {
            DDLogInfo(@"Response save completed.");
        }
    }];
}

@end
