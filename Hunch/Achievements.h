//
//  Achievements.h
//  Hunch
//
//  Created by Anthony Picciano on 2/2/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Achievements : NSObject

+ (void)currentUserDidAskQuestion;
+ (void)currentUserDidAnswerQuestion;

@end
