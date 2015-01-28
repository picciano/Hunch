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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.questions.count;
            break;
            
        case 1:
            return 5;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Questions Asked";
            break;
            
        case 1:
            return @"Achievements";
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
    
    // Configure the cell...
    cell.textLabel.text = @"Achievement entry...";
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

@end
