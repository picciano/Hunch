//
//  SignUpViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/21/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "SignUpViewController.h"
#import "CocoaLumberjack.h"
#import "UIControl+NextControl.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.usernameField becomeFirstResponder];
    [self updateDisplay:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField transferFirstResponderToNextControl];
    return NO;
}

- (IBAction)updateDisplay:(id)sender {
    self.signupButton.enabled = self.loginButton.enabled = (self.usernameField.text.length > 0 && self.passwordField.text.length > 0);
}

- (IBAction)signUp:(id)sender {
    PFUser *user = [PFUser currentUser];
    user.username = self.usernameField.text;
    user.password = self.passwordField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            DDLogError(@"Error during signup: %@", error);
            long code = [[error.userInfo valueForKey:@"code"] longValue];
            NSString *message = @"Sorry, could not complete sign up. Try again later.";
            if (code == 202) {
                message = @"Sorry, that username has been taken. Pick another username or login instead.";
            }
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error signing up"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            DDLogInfo(@"Signup completed.");
            [self dismissViewControllerAnimated:YES completion:^{
                // notify
            }];
        }
    }];
}

- (IBAction)login:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (error) {
            DDLogError(@"Error during login: %@", error);
        } else {
            DDLogInfo(@"Login completed.");
            [self dismissViewControllerAnimated:YES completion:^{
                // notify
            }];
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end