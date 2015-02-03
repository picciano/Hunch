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
#import "MessageOverlayViewController.h"
#import "Achievements.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "CocoaLumberjack.h"

#define VIEW_TAG_ANSWER_BUTTON_BASE 100
#define RETRY_DELAY                 8
#define OVERLAY_MESSAGE_DELAY       0.5

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportAbuseButton;
@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;

@property (strong, nonatomic) PFObject *currentQuestion;
@property (strong, nonatomic) NSArray *currentAnswers;
@property (nonatomic) BOOL suppressNoMoreQuestionsWarning;

@property (strong, nonatomic) MessageOverlayViewController *messageOverlay;

@end

static const DDLogLevel ddLogLevel = DDLogLevelError;

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageOverlay = [[MessageOverlayViewController alloc] initWithNibName:nil bundle:nil];
    self.messageOverlay.blocksActivity = NO;
    self.messageOverlay.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.messageOverlay.view belowSubview:self.adBanner];
    
    [self setAnswerBackgroundImages];
    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self loadEligibleQuestion];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidChange) name:CURRENT_USER_CHANGE_NOTIFICATION object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setAnswerBackgroundImages {
    ((AnswerButton *)[self.view viewWithTag:VIEW_TAG_ANSWER_BUTTON_BASE + 0]).background = [UIImage imageNamed:@"Answer1"];
    ((AnswerButton *)[self.view viewWithTag:VIEW_TAG_ANSWER_BUTTON_BASE + 1]).background = [UIImage imageNamed:@"Answer2"];
    ((AnswerButton *)[self.view viewWithTag:VIEW_TAG_ANSWER_BUTTON_BASE + 2]).background = [UIImage imageNamed:@"Answer3"];
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
            [self.messageOverlay hide];
            [self updateDisplay:nil];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewWillAppear:(BOOL)animated {
    if (animated) { // YES if coming back from another screen, NO if initial launch
        [self loadEligibleQuestion];
    }
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
    
    self.currentQuestion = nil;
    self.currentAnswers = nil;
    [self updateDisplay:nil];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Abuse Has Been Reported"
                                                                       message:@"Thank you for your report. We will look at the question and take appropriate action."
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        [self loadEligibleQuestion];
    }];
}

- (void)currentUserDidChange {
    self.currentQuestion = nil;
    self.currentAnswers = nil;
    [self updateDisplay:nil];
    
    if ([self.navigationController visibleViewController] == self) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self loadEligibleQuestion];
    }
}

- (void)loadEligibleQuestion {
    self.messageOverlay.message = @"Loading...";
    [self.messageOverlay showAfterDelay:OVERLAY_MESSAGE_DELAY];
    
    PFQuery *myResponsesQuery = [PFQuery queryWithClassName:OBJECT_TYPE_RESPONSE];
    [myResponsesQuery whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:OBJECT_TYPE_QUESTION];
    [questionsQuery whereKey:OBJECT_KEY_USER notEqualTo:[PFUser currentUser]];
    [questionsQuery orderByDescending:OBJECT_KEY_CREATED_AT];
    [questionsQuery whereKey:OBJECT_KEY_ID doesNotMatchKey:OBJECT_KEY_QUESTION_ID inQuery:myResponsesQuery];
    
    [questionsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            self.messageOverlay.message = @"Waiting for a question.";
            if (self.suppressNoMoreQuestionsWarning) {
                [self performSelector:@selector(loadEligibleQuestion) withObject:nil afterDelay:RETRY_DELAY];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No more questions"
                                                                               message:@"You have answered all the questions. We will keep checking and to see if any more questions get added."
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          self.suppressNoMoreQuestionsWarning = YES;
                                                                          [self performSelector:@selector(loadEligibleQuestion) withObject:nil afterDelay:RETRY_DELAY];
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
    self.messageOverlay.message = @"Saving Response...";
    [self.messageOverlay showAfterDelay:OVERLAY_MESSAGE_DELAY];
    
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
            [self requestInterstitialAdPresentation];
            [Achievements currentUserDidAnswerQuestion];
        }
    }];
}

#pragma - ADBannerViewDelegate methods

- (void)bannerViewWillLoadAd:(ADBannerView *)banner {
    DDLogInfo(@"Ad Banner will load ad.");
    
    // Show the ad banner.
    self.adBanner.alpha = 0.0;
    self.adBanner.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 1.0;
    } completion:nil];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    DDLogInfo(@"Ad Banner did load ad.");
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Ad Banner action is about to begin.");
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    NSLog(@"Ad Banner action did finish");
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Unable to show ads. Error: %@", [error localizedDescription]);
    
    // Hide the ad banner.
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.adBanner.hidden = YES;
    }];
}

@end
