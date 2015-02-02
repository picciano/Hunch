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
#import "Constants.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

static const DDLogLevel ddLogLevel = DDLogLevelError;

@implementation SignUpViewController

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
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error signing up"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            DDLogInfo(@"Signup completed.");
            [self dismissViewControllerAnimated:YES completion:^{
                [self initializePushNotifications];
                [[NSNotificationCenter defaultCenter] postNotificationName:CURRENT_USER_CHANGE_NOTIFICATION object:self];
            }];
        }
    }];
}

- (IBAction)login:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (error) {
            DDLogError(@"Error during login: %@", error);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error logging in"
                                                                           message:@"Check your username and password, or maybe try signing up instead."
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            DDLogInfo(@"Login completed.");
            [self dismissViewControllerAnimated:YES completion:^{
                [self initializePushNotifications];
                [[NSNotificationCenter defaultCenter] postNotificationName:CURRENT_USER_CHANGE_NOTIFICATION object:self];
            }];
        }
    }];
}



- (void)initializePushNotifications {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    UIApplication *application = [UIApplication sharedApplication];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
