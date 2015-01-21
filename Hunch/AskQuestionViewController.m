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

@interface AskQuestionViewController ()

@end

@implementation AskQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self displaySignUp];
    }
}

- (void)displaySignUp {
    SignUpViewController *viewController = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewController animated:YES completion:^{
        //
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
