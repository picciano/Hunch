//
//  AskQuestionViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/21/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "AskQuestionViewController.h"
#import "SignUpViewController.h"
#import "UIControl+NextControl.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "CocoaLumberjack.h"

#define VIEW_TAG_QUESTION           201
#define SCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height
#define VIEW_OFFSET_FOR_KEYBOARD    -100.0f
#define IPHONE_4_SCREEN_HEIGHT      480.f

@interface AskQuestionViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UITextField *answer1Field;
@property (weak, nonatomic) IBOutlet UITextField *answer2Field;
@property (weak, nonatomic) IBOutlet UITextField *answer3Field;
@property (weak, nonatomic) IBOutlet UILabel *answer3Label;
@property (weak, nonatomic) IBOutlet UILabel *questionCharacterCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *askQuestionButton;

typedef enum {
    QuestionTypeUnknown,
    QuestionTypeYesNo,
    QuestionTypeCustom
} QuestionType;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation AskQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:17];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.typeSegmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.questionTextView becomeFirstResponder];
    [self updateDisplay:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        DDLogDebug(@"User is anonymous. Show sign up view.");
        [self displaySignUp];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.answer1Field becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.tag == VIEW_TAG_QUESTION && textView.text.length > MAXIMUM_QUESTION_LENGTH) {
        textView.text = [textView.text substringToIndex:MAXIMUM_QUESTION_LENGTH];
    }
    [self updateDisplay:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self repositionViewForKeyboard:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.nextControl) {
        [textField transferFirstResponderToNextControl];
    } else {
        [self repositionViewForKeyboard:NO];
        [self.questionTextView becomeFirstResponder];
    }
    return NO;
}

- (void)repositionViewForKeyboard:(BOOL)isRaised {
    if (SCREEN_HEIGHT > IPHONE_4_SCREEN_HEIGHT) return;
    if (isRaised) {
        [UIView animateWithDuration:0.25f animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0.0f, VIEW_OFFSET_FOR_KEYBOARD);
        } completion:^(BOOL finished) {}];
    } else {
        [UIView animateWithDuration:0.25f animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0.0f, 0.0f);
        } completion:^(BOOL finished) {}];
    }
}

- (IBAction)toggleType:(id)sender {
    if ([self questionType] == QuestionTypeCustom) {
        self.answer1Field.text = EMPTY_STRING;
        self.answer2Field.text = EMPTY_STRING;
        self.answer3Field.text = EMPTY_STRING;
    } else {
        [self repositionViewForKeyboard:NO];
        [self.questionTextView becomeFirstResponder];
    }
    [self updateDisplay:sender];
}

- (IBAction)answerChanged:(id)sender {
    UITextField *textField = (UITextField *)sender;
    if (textField.text.length > MAXIMUM_ANSWER_LENGTH) {
        textField.text = [textField.text substringToIndex:MAXIMUM_ANSWER_LENGTH];
    }
    [self updateDisplay:nil];
}

- (IBAction)updateDisplay:(id)sender {
    if ([self questionType] == QuestionTypeYesNo) {
        self.answer1Field.text = ANSWER_YES;
        self.answer2Field.text = ANSWER_NO;
        self.answer3Field.text = EMPTY_STRING;
    }
    
    self.questionCharacterCountLabel.text = [NSString stringWithFormat:@"%lu / %i", (unsigned long)self.questionTextView.text.length, MAXIMUM_QUESTION_LENGTH];
    self.answer3Field.hidden = self.answer3Label.hidden = ([self questionType] == QuestionTypeYesNo);
    self.answer1Field.enabled = self.answer2Field.enabled = self.answer3Field.enabled = ([self questionType] == QuestionTypeCustom);
    self.askQuestionButton.enabled = (self.answer1Field.text.length > 0 && self.answer2Field.text.length > 0 && self.questionTextView.text.length >= MINIMUM_QUESTION_LENGTH);
}

- (void)cleanQuestion {
    self.questionTextView.text = [self.questionTextView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if ([self.questionTextView.text characterAtIndex:self.questionTextView.text.length-1] != '?') {
        self.questionTextView.text = [NSString stringWithFormat:@"%@?", self.questionTextView.text];
    }
}

- (IBAction)askQuestion:(id)sender {
    [self cleanQuestion];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        PFObject *question = [PFObject objectWithClassName:OBJECT_TYPE_QUESTION];
        question[OBJECT_KEY_USER] = [PFUser currentUser];
        question[OBJECT_KEY_TEXT] = self.questionTextView.text;
        
        PFObject *answer1 = [PFObject objectWithClassName:OBJECT_TYPE_ANSWER];
        answer1[OBJECT_KEY_TEXT] = self.answer1Field.text;
        answer1[OBJECT_KEY_QUESTION] = question;
        [answer1 save];
        
        PFObject *answer2 = [PFObject objectWithClassName:OBJECT_TYPE_ANSWER];
        answer2[OBJECT_KEY_TEXT] = self.answer2Field.text;
        answer2[OBJECT_KEY_QUESTION] = question;
        [answer2 save];
        
        PFObject *answer3;
        if (self.answer3Field.text.length > 0) {
            answer3 = [PFObject objectWithClassName:OBJECT_TYPE_ANSWER];
            answer3[OBJECT_KEY_TEXT] = self.answer3Field.text;
            answer3[OBJECT_KEY_QUESTION] = question;
            [answer3 save];
        }
        
        PFRelation *answers = [question relationForKey:@"answers"];
        [answers addObject:answer1];
        [answers addObject:answer2];
        if (answer3) {
            [answers addObject:answer3];
        }
        
        [question saveEventually:^(BOOL succeeded, NSError *error) {
            if (error) {
                DDLogError(@"Error during save question: %@", error);
            } else {
                DDLogInfo(@"Question saved.");
                [self performSelectorOnMainThread:@selector(dismiss:) withObject:nil waitUntilDone:NO];
            }
        }];
    });
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displaySignUp {
    UIViewController *viewController = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (QuestionType)questionType {
    switch (self.typeSegmentedControl.selectedSegmentIndex) {
        case 0:
            return QuestionTypeYesNo;
            break;
            
        case 1:
            return QuestionTypeCustom;
            break;
            
        default:
            return QuestionTypeUnknown;
            break;
    }
}

@end
