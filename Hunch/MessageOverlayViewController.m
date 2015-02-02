//
//  MessageOverlayViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 2/2/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "MessageOverlayViewController.h"

@interface MessageOverlayViewController ()

@end

#define DEFAULT_CONTENT_CORNER_RADIUS 10.0f

@implementation MessageOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentCornerRadius = DEFAULT_CONTENT_CORNER_RADIUS;
}

- (void)show {
    if (self.view.hidden == NO && self.view.alpha == 1.0f) {
        return;
    }
    
    self.view.frame = self.view.superview.bounds;
    self.view.alpha = 0.0f;
    self.view.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.view.alpha = 1.0f;
    }];
}

- (void)showAfterDelay:(NSTimeInterval)delay {
    [self cancelPendingShow];
    [self performSelector:@selector(show) withObject:nil afterDelay:delay];
}

- (void)cancelPendingShow {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)hide {
    [self cancelPendingShow];
    [UIView animateWithDuration:0.25f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
}

#pragma mark - setters and getters

- (void)setMessage:(NSString *)message {
    self.messageLabel.text = message;
}

- (NSString *)message {
    return self.messageLabel.text;
}

- (void)setMessageLabelTextColor:(UIColor *)messageLabelTextColor {
    self.messageLabel.textColor = messageLabelTextColor;
}

- (UIColor *)messageLabelTextColor {
    return self.messageLabel.textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.view.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor {
    return self.view.backgroundColor;
}

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor {
    
    self.contentView.backgroundColor = contentBackgroundColor;
}

- (UIColor *)contentBackgroundColor {
    return self.contentView.backgroundColor;
}

- (void)setContentView:(UIView *)contentView {
    while ([self.view subviews].count > 0) {
        [[self.view subviews][0] removeFromSuperview];
    }
    [self.view addSubview:self.contentView];
}

- (UIView *)contentView {
    while ([self.view subviews].count > 0) {
        return [self.view subviews][0];
    }
    return nil;
}

- (void)setContentCornerRadius:(CGFloat)contentCornerRadius {
    self.contentView.layer.cornerRadius = contentCornerRadius;
}

- (CGFloat)contentCornerRadius {
    return self.contentView.layer.cornerRadius;
}

- (void)setBlocksActivity:(BOOL)blocksActivity {
    self.view.userInteractionEnabled = blocksActivity;
}

- (BOOL)blocksActivity {
    return self.view.userInteractionEnabled;
}

@end
