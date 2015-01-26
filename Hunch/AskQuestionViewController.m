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
#import <Parse/Parse.h>
#import "CocoaLumberjack.h"

@interface AskQuestionViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UITextField *answer1Field;
@property (weak, nonatomic) IBOutlet UITextField *answer2Field;
@property (weak, nonatomic) IBOutlet UITextField *answer3Field;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation AskQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField transferFirstResponderToNextControl];
    return NO;
}

- (IBAction)updateDisplay:(id)sender {
    // TODO: implement this
}

- (void)displaySignUp {
    UIViewController *viewController = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
