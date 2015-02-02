//
//  MessageOverlayViewController.h
//  Hunch
//
//  Created by Anthony Picciano on 2/2/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageOverlayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *contentBackgroundColor;
@property (strong, nonatomic) UIColor *messageLabelTextColor;
@property (nonatomic) CGFloat contentCornerRadius;

- (void)show;
- (void)showAfterDelay:(NSTimeInterval)delay;
- (void)cancelPendingShow;
- (void)hide;

@end
