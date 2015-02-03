//
//  Achievements.m
//  Hunch
//
//  Created by Anthony Picciano on 2/2/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "Achievements.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "CocoaLumberjack.h"
#import <Parse/Parse.h>

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation Achievements

+ (void)currentUserDidAskQuestion {
    PFQuery *query = [PFQuery queryWithClassName:OBJECT_TYPE_QUESTION];
    [query whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            DDLogError(@"Error counting questions: %@", error);
        } else {
            switch (number) {
                case 1:
                    [self createAchievementWithName:@"Curious" description:@"Awarded for asking your first question."];
                    break;
                    
                case 5:
                    [self createAchievementWithName:@"Asker" description:@"Awarded for asking your fifth question."];
                    break;
                    
                case 10:
                    [self createAchievementWithName:@"Researcher" description:@"Awarded for asking your tenth question."];
                    break;
                    
                case 20:
                    [self createAchievementWithName:@"Investigator" description:@"Awarded for asking your 20th question."];
                    break;
                    
                case 50:
                    [self createAchievementWithName:@"Interrogator" description:@"Awarded for asking your 50th question."];
                    break;
                    
                case 100:
                    [self createAchievementWithName:@"Sherlock Holmes" description:@"Awarded for asking your 100th question."];
                    break;
                    
                default:
                    break;
            }
        }
    }];
}

+ (void)currentUserDidAnswerQuestion {
    PFQuery *query = [PFQuery queryWithClassName:OBJECT_TYPE_RESPONSE];
    [query whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            DDLogError(@"Error counting questions: %@", error);
        } else {
            switch (number) {
                case 1:
                    [self createAchievementWithName:@"Hunch" description:@"Awarded for answering your first question."];
                    break;
                    
                case 10:
                    [self createAchievementWithName:@"Instinct" description:@"Awarded for answering your tenth question."];
                    break;
                    
                case 50:
                    [self createAchievementWithName:@"Intuition" description:@"Awarded for answering your 50th question."];
                    break;
                    
                case 100:
                    [self createAchievementWithName:@"Portent" description:@"Awarded for answering your 100th question."];
                    break;
                    
                case 200:
                    [self createAchievementWithName:@"Premonition" description:@"Awarded for answering your 200th question."];
                    break;
                    
                case 500:
                    [self createAchievementWithName:@"Guru" description:@"Awarded for answering your 500th question."];
                    break;
                
                default:
                    break;
            }
        }
    }];
}

+ (void)createAchievementWithName:(NSString *)text description:(NSString *)description {
    PFObject *object = [PFObject objectWithClassName:OBJECT_TYPE_ACHIEVEMENT];
    [object setObject:[PFUser currentUser] forKey:OBJECT_KEY_USER];
    [object setObject:text forKey:OBJECT_KEY_TEXT];
    [object setObject:description forKey:OBJECT_KEY_DESCRIPTION];
    
    [object saveEventually];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Achievement Unlocked: %@", text]
                                                                   message:[NSString stringWithFormat:@"You have earned the achievement \"%@\".\n%@", text, description]
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alert addAction:defaultAction];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
