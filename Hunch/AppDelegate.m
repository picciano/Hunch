//
//  AppDelegate.m
//  Hunch
//
//  Created by Anthony Picciano on 1/21/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "AppDelegate.h"
#import "QuestionViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "CocoaLumberjack.h"

@interface AppDelegate ()

@end

static const DDLogLevel ddLogLevel = DDLogLevelError;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initializeLumberjackWithOptions:launchOptions];
    [self initializeParseWithOptions:launchOptions];
    [self initializeUserInterfaceWithOptions:launchOptions];
    
    return YES;
}

- (void)initializeLumberjackWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)initializeParseWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CLIENT_KEY];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFUser enableAutomaticUser];
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        DDLogDebug(@"User is anonymous. Save it.");
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CURRENT_USER_CHANGE_NOTIFICATION object:self];
        }];
    }
}

- (void)initializeUserInterfaceWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    QuestionViewController *viewController = [[QuestionViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

@end
