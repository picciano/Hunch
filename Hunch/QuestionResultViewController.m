//
//  QuestionResultViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/28/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "QuestionResultViewController.h"
#import "StyleKit.h"
#import "PCPieChart.h"
#import "Constants.h"
#import "CocoaLumberjack.h"

@interface QuestionResultViewController ()

@property (weak, nonatomic) IBOutlet PCPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) NSArray *answers;
@property (strong, nonatomic) NSMutableArray *responseCounts;

@end

static const DDLogLevel ddLogLevel = DDLogLevelError;

@implementation QuestionResultViewController

NSUInteger countsRemaining;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDisplay];
    [self loadAnswers];
}

- (void)updateDisplay {
    self.questionLabel.text = self.question[OBJECT_KEY_TEXT];
}

- (void)loadAnswers {
    PFRelation *answers = [self.question relationForKey:OBJECT_KEY_ANSWERS];
    PFQuery *answersQuery = [answers query];
    [answersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DDLogError(@"Error finding answers: %@", error);
        } else {
            DDLogDebug(@"Answers are loaded.");
            self.answers = objects;
            self.responseCounts = [NSMutableArray arrayWithObjects:@0, @0, @0, nil];
            countsRemaining = objects.count;
            [self loadResponseCounts];
        }
    }];
}

- (void)loadResponseCounts {
    for (int i = 0; i < self.answers.count; i++) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            PFQuery *query = [PFQuery queryWithClassName:OBJECT_TYPE_RESPONSE];
            [query whereKey:OBJECT_KEY_ANSWER equalTo:self.answers[i]];
            self.responseCounts[i] = [NSNumber numberWithLong:[query countObjects]];
            countsRemaining--;
            if (countsRemaining == 0) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self configurePieChart];
                });
            }
        });
    }
}

- (void)configurePieChart {
    PCPieChart *pieChart = self.pieChart;
    pieChart.titleFont = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13];
    pieChart.percentageFont = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:16];
    
    NSMutableArray *components = [NSMutableArray array];
    
    for (int i = 0; i < self.answers.count; i++) {
        PCPieComponent *component = [PCPieComponent pieComponentWithTitle:self.answers[i][OBJECT_KEY_TEXT]
                                                                    value:[self.responseCounts[i] floatValue]];
        
        switch (i) {
            case 0:
                component.colour = [StyleKit hunchLightGreen];
                break;
                
            case 1:
                component.colour = [StyleKit hunchBlue];
                break;
                
            case 2:
                component.colour = [StyleKit hunchRed];
                break;
                
            default:
                break;
        }
        
        [components addObject:component];
    }
    
    pieChart.alpha = 0.0;
    [pieChart setComponents:components];
    [UIView animateWithDuration:0.5 animations:^{
        pieChart.alpha = 1.0;
    }];
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
