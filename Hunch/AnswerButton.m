//
//  AnswerButton.m
//  Hunch
//
//  Created by Anthony Picciano on 1/27/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "AnswerButton.h"
#import "StyleKit.h"

@implementation AnswerButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidden = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [StyleKit drawAnswerLabelWithFrame:self.bounds background:self.background answer:self.answer];
}

- (void)setBackground:(UIImage *)background {
    _background = background;
    self.hidden = NO;
    [self setNeedsDisplay];
}

- (void)setAnswer:(NSString *)answer {
    _answer = answer;
    self.hidden = !answer;
    [self setNeedsDisplay];
}

@end
