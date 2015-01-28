//
//  QuestionResultViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/28/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "QuestionResultViewController.h"
#import "StyleKit.h"

@interface QuestionResultViewController ()

@end

@implementation QuestionResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self configurePieChart];
}

- (void)configurePieChart {
    PCPieChart *pieChart = self.pieChart;
    pieChart.titleFont = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13];
    pieChart.percentageFont = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20];
    
    NSMutableArray *components = [NSMutableArray array];
    
    for (int i=0; i<3; i++) {
        PCPieComponent *component = [PCPieComponent pieComponentWithTitle:@"Title" value:33.3];
        
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
    
    [pieChart setComponents:components];
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
