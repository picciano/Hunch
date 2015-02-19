//
//  ViewController.m
//  Hunch Question Loader
//
//  Created by Anthony Picciano on 2/3/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionsLoadedLabel;
@property (weak, nonatomic) IBOutlet UILabel *answersLoadedLabel;
@property (weak, nonatomic) IBOutlet UILabel *completedLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggedInLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic) NSUInteger questionsLoaded;
@property (nonatomic) NSUInteger answersLoaded;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserDidChange) name:CURRENT_USER_CHANGE_NOTIFICATION object:nil];
}

- (void)currentUserDidChange {
    NSLog(@"user: %@", [PFUser currentUser].username);
    self.loggedInLabel.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDisplay];
}

- (void)incrementAnswerCount {
    self.answersLoaded++;
    [self updateDisplay];
}

- (void)incrementQuestionCount {
    self.questionsLoaded++;
    [self updateDisplay];
}

- (void)showCompletedLabel {
    self.completedLabel.hidden = NO;
}

- (void)updateDisplay {
    self.questionsLoadedLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.questionsLoaded];
    self.answersLoadedLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.answersLoaded];
}

- (IBAction)loadQuestions:(id)sender {
    self.startButton.enabled = NO;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Questions" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        NSArray *questions = dict[@"questions"];
        
        for (NSDictionary *question in questions) {
            NSString *text = question[@"text"];
            NSArray *answerTexts = question[@"answers"];
            
            if (![self validateText:text answers:answerTexts]) {
                continue;
            }
            
            PFObject *question = [PFObject objectWithClassName:OBJECT_TYPE_QUESTION];
            question[OBJECT_KEY_USER] = [PFUser currentUser];
            question[OBJECT_KEY_TEXT] = text;
            
            PFRelation *answers = [question relationForKey:@"answers"];
            
            for (NSString *answerText in answerTexts) {
                PFObject *answer = [PFObject objectWithClassName:OBJECT_TYPE_ANSWER];
                answer[OBJECT_KEY_TEXT] = answerText;
                answer[OBJECT_KEY_QUESTION] = question;
                
                [answer save];
                [self performSelectorOnMainThread:@selector(incrementAnswerCount) withObject:nil waitUntilDone:NO];
                
                [answers addObject:answer];
            }
            
            [question save];
            [self performSelectorOnMainThread:@selector(incrementQuestionCount) withObject:nil waitUntilDone:NO];
        }
        
        [self performSelectorOnMainThread:@selector(showCompletedLabel) withObject:nil waitUntilDone:NO];
        
    });
}

- (BOOL)validateText:(NSString *)text answers:(NSArray *)answerTexts {
    if (text.length < MINIMUM_QUESTION_LENGTH) {
        NSLog(@"QUESTION IS TOO SHORT: %@", text);
        return NO;
    }
    
    if (text.length > MAXIMUM_QUESTION_LENGTH) {
        NSLog(@"QUESTION IS TOO LONG: %@", text);
        return NO;
    }
    
    for (NSString *answerText in answerTexts) {
        if (answerText.length > MAXIMUM_ANSWER_LENGTH) {
            NSLog(@"ANSWER IS TOO LONG: %@", answerText);
            return NO;
        }
    }
    
    return YES;
}

@end
