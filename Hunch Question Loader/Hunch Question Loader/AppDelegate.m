//
//  AppDelegate.m
//  Hunch Question Loader
//
//  Created by Anthony Picciano on 2/3/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initializeParseWithOptions:launchOptions];
    return YES;
}

- (void)initializeParseWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CLIENT_KEY];
    [PFUser enableAutomaticUser];
    
    PFUser *user = [PFUser currentUser];
    NSLog(@"user: %@", user.username);
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(@"User is anonymous. Save it.");
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            user.username = PARSE_USERNAME;
            user.password = PARSE_PASSWORD;
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [PFUser logInWithUsernameInBackground:PARSE_USERNAME password:PARSE_PASSWORD block:^(PFUser *user, NSError *error) {
                        if (error) {
                            NSLog(@"Could not sign up or login.");
                        } else {
                            [self sendLoginNotification];
                        }
                    }];
                } else {
                    [self sendLoginNotification];
                }
            }];
        }];
    } else {
        [self performSelector:@selector(sendLoginNotification) withObject:nil afterDelay:0.5];
    }
}

- (void)sendLoginNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:CURRENT_USER_CHANGE_NOTIFICATION object:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
