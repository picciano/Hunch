//
//  CreditsViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 2/3/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "CreditsViewController.h"

@interface CreditsViewController ()

@end

@implementation CreditsViewController

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
