//
//  ProfileViewController.m
//  Hunch
//
//  Created by Anthony Picciano on 1/26/15.
//  Copyright (c) 2015 Anthony Picciano. All rights reserved.
//

#import "ProfileViewController.h"
#import "SignUpViewController.h"
#import "QuestionTableViewCell.h"
#import "AchievementTableViewCell.h"
#import "QuestionResultViewController.h"
#import "HeaderView.h"
#import "CocoaLumberjack.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "PFObject+DateFormat.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfResponsesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfQuestionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int numberOfResponses;
@property (nonatomic) NSArray *questions;
@property (nonatomic) NSArray *achievements;

@end

static const DDLogLevel ddLogLevel = DDLogLevelDebug;
static NSString *kAchievementTableViewCell = @"kAchievementTableViewCell";
static NSString *kQuestionReuseIdentifier = @"kQuestionReuseIdentifier";

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"QuestionTableViewCell"bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kQuestionReuseIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AchievementTableViewCell"bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kAchievementTableViewCell];
    
    [self loadProfile];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfile) name:CURRENT_USER_CHANGE_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDisplay];
}

- (void)updateDisplay {
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.usernameLabel.text = @"Anonymous";
        self.signupButton.hidden = NO;
    } else {
        self.usernameLabel.text = [PFUser currentUser].username;
        self.signupButton.hidden = YES;
    }
    
    self.numberOfResponsesLabel.text = [NSString stringWithFormat:@"%i", self.numberOfResponses];
    self.numberOfQuestionsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.questions.count];
    self.accountCreatedLabel.text = [[PFUser currentUser] createdAtWithDateFormat:NSDateFormatterMediumStyle];
}

- (IBAction)signUp:(id)sender {
    UIViewController *viewController = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)setNumberOfResponses:(int)numberOfResponses {
    _numberOfResponses = numberOfResponses;
    [self updateDisplay];
}

- (void)loadProfile {
    self.questions = [NSArray array];
    self.achievements = [NSArray array];
    self.numberOfResponses = 0;
    
    PFQuery *answers = [PFQuery queryWithClassName:OBJECT_TYPE_RESPONSE];
    [answers whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [answers countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            DDLogError(@"Error counting responses: %@", error);
        } else {
            self.numberOfResponses = number;
        }
    }];
    
    PFQuery *questions = [PFQuery queryWithClassName:OBJECT_TYPE_QUESTION];
    [questions whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [questions orderByDescending:OBJECT_KEY_CREATED_AT];
    [questions findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DDLogError(@"Could not load questions: %@", error);
        } else {
            self.questions = objects;
            [self updateDisplay];
            [self.tableView reloadData];
        }
    }];
    
    PFQuery *achievements = [PFQuery queryWithClassName:OBJECT_TYPE_ACHIEVEMENT];
    [achievements whereKey:OBJECT_KEY_USER equalTo:[PFUser currentUser]];
    [achievements orderByDescending:OBJECT_KEY_CREATED_AT];
    [achievements findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DDLogError(@"Could not load achievements: %@", error);
        } else {
            self.achievements = objects;
            [self.tableView reloadData];
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 44.0f;
            break;
            
        case 1:
            return 66.0f;
            break;
            
        default:
            return 44.0f;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.questions.count;
            break;
            
        case 1:
            return self.achievements.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.questions.count>0?30:0;
            break;
            
        case 1:
            return self.achievements.count>0?30:0;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    HeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil] firstObject];
    
    switch (section) {
        case 0:
            view.titleLabel.text = @"Questions Asked";
            return view;
            break;
            
        case 1:
            view.titleLabel.text = @"Achievements";
            return view;
            break;
            
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [self tableView:tableView questionTableViewCellAtIndexPath:indexPath];
            break;
            
        case 1:
            return [self tableView:tableView achievementTableViewCellAtIndexPath:indexPath];
            break;
            
        default:
            return nil;
            break;
    }
}

- (QuestionTableViewCell *)tableView:(UITableView *)tableView questionTableViewCellAtIndexPath:(NSIndexPath *)indexPath {
    QuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQuestionReuseIdentifier forIndexPath:indexPath];
    cell.question = self.questions[indexPath.row];
    
    return cell;
}

- (AchievementTableViewCell *)tableView:(UITableView *)tableView achievementTableViewCellAtIndexPath:(NSIndexPath *)indexPath {
    AchievementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAchievementTableViewCell forIndexPath:indexPath];
    cell.achievement = self.achievements[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            [self navigateToQuestionResultsViewWithIndex:indexPath.row];
            break;
            
        case 1:
            break;
            
        default:
            break;
    }
}

- (void)navigateToQuestionResultsViewWithIndex:(NSInteger)index {
    QuestionResultViewController *viewController = [[QuestionResultViewController alloc] initWithNibName:nil bundle:nil];
    viewController.question = self.questions[index];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
