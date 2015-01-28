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
#import "AnswerButton.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "CocoaLumberjack.h"

#define VIEW_TAG_ANSWER_BUTTON_BASE 100

@interface QuestionViewController ()

@property (strong, nonatomic) PFObject *currentQuestion;
@property (strong, nonatomic) NSArray *currentAnswers;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportAbuseButton;
@property (nonatomic) BOOL suppressNoMoreQuestionsWarning;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self loadEligibleQuestion];
    }
    
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
    
    PFRelation *answers = [self.currentQuestion relationForKey:OBJECT_KEY_ANSWERS];
    PFQuery *answersQuery = [answers query];
    [answersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DDLogError(@"Error finding answers: %@", error);
        } else {
            DDLogDebug(@"Answers are loaded.");
            self.currentAnswers = objects;
            [self updateDisplay:nil];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDisplay:nil];
}

- (IBAction)updateDisplay:(id)sender {
    self.questionLabel.text = self.currentQuestion[OBJECT_KEY_TEXT];
    self.reportAbuseButton.hidden = (self.currentQuestion == nil);
    for (int i = 0; i < 3; i++) {
        NSInteger tag = i + VIEW_TAG_ANSWER_BUTTON_BASE;
        AnswerButton *answerButton = (AnswerButton *)[self.view viewWithTag:tag];
        if (i < self.currentAnswers.count) {
            answerButton.answer = self.currentAnswers[i][OBJECT_KEY_TEXT];
        } else {
            answerButton.answer = nil;
        }
    }
}

- (IBAction)viewProfile:(id)sender {
    UIViewController *viewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)touchAnswer:(id)sender {
    DDLogDebug(@"touchAnswer: called");
    
    PFObject *answer = self.currentAnswers[((UIView *)sender).tag - VIEW_TAG_ANSWER_BUTTON_BASE];
    [self saveResponse:answer];
}

- (IBAction)reportQuestion:(id)sender {
    DDLogDebug(@"reportQuestion: called");
    
    PFObject *abuse = [PFObject objectWithClassName:OBJECT_TYPE_ABUSE];
    abuse[OBJECT_KEY_QUESTION] = self.currentQuestion;
    abuse[OBJECT_KEY_USER] = [PFUser currentUser];
    [abuse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            DDLogError(@"Error during reporting abuse: %@", error);
        }
        [self loadEligibleQuestion];
    }];
}

- (void)loadEligibleQuestion {
    self.currentQuestion = nil;
    self.currentAnswers = nil;
    [self updateDisplay:nil];
    
    PFQuery *myResponsesQuery = [PFQuery queryWithClassName:OBJECT_TYPE_RESPONSE];
    [myResponsesQuery whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:OBJECT_TYPE_QUESTION];
    [questionsQuery whereKey:OBJECT_KEY_USER notEqualTo:[PFUser currentUser]];
    [questionsQuery whereKey:OBJECT_KEY_ID doesNotMatchKey:OBJECT_KEY_QUESTION_ID inQuery:myResponsesQuery];
    
    [questionsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            DDLogError(@"Error loading eligible question: %@", error);
            if (self.suppressNoMoreQuestionsWarning) {
                [self performSelector:@selector(loadEligibleQuestion) withObject:nil afterDelay:5];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No more questions"
                                                                               message:@"You have answered all the questions. We will keep checking and to see if any more questions get added."
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          self.suppressNoMoreQuestionsWarning = YES;
                                                                          [self performSelector:@selector(loadEligibleQuestion) withObject:nil afterDelay:5];
                                                                      }];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        } else {
            DDLogDebug(@"Question is loaded: %@", object[OBJECT_KEY_TEXT]);
            self.suppressNoMoreQuestionsWarning = NO;
            self.currentQuestion = object;
        }
    }];
}

- (void)saveResponse:(PFObject *)answer {
    PFObject *response = [PFObject objectWithClassName:OBJECT_TYPE_RESPONSE];
    response[OBJECT_KEY_QUESTION] = self.currentQuestion;
    response[OBJECT_KEY_USER] = [PFUser currentUser];
    if (answer) response[OBJECT_KEY_ANSWER] = answer;
    
    [response saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            DDLogError(@"Error during login: %@", error);
        } else {
            DDLogInfo(@"Response save completed.");
            [self loadEligibleQuestion];
        }
    }];
}

@end
