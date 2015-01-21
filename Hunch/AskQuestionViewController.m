//
//  AskQuestionViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/21/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "AskQuestionViewController.h"
#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "CocoaLumberjack.h"

@interface AskQuestionViewController ()

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation AskQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        DDLogDebug(@"User is anonymous. Show sign up view.");
        [self displaySignUp];
    }
}

- (void)displaySignUp {
    SignUpViewController *viewController = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
