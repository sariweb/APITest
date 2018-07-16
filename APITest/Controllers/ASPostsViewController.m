//
//  ASPostsViewController.m
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASPostsViewController.h"
#import "ASPostDetailsTableViewController.h"
#import "ASServerManager.h"
#import "ASAccessToken.h"
#import "UIKit+AFNetworking.h"
#import "ASUser.h"
#import "ASGroup.h"
#import "ASPost.h"
#import "ASPostViewCell.h"

static NSInteger postsInRequest = 10;

static NSString * const kLogin = @"Login";
static NSString * const kLogout = @"Logout";

@interface ASPostsViewController ()

@property (strong, nonatomic) NSMutableArray *postsArray;
@property (strong, nonatomic) UIBarButtonItem *loginButton;
@property (strong, nonatomic) UIBarButtonItem *loginNameItem;
@property (assign, nonatomic) BOOL isFirstPostsLoad;
@property (assign, nonatomic) BOOL isFirstAppRun;
@property (assign, nonatomic) BOOL isAllPostsLoaded;
@property (strong, nonatomic) NSIndexPath *cellToReloadIndexPath;

@property (assign, nonatomic) BOOL firstTimeAppear;

@end

@implementation ASPostsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstPostsLoad = YES;
    self.isFirstAppRun = YES;
    self.isAllPostsLoaded = NO;
    
    self.postsArray = [NSMutableArray array];
    
    self.firstTimeAppear = YES;
    
    [self getPostsFromServer];
    
    // Table refresh slide down
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    // Check accessToken for expiration date
    
    self.loginButton = [self.navigationItem.rightBarButtonItems firstObject];
    self.loginNameItem = [self.navigationItem.rightBarButtonItems lastObject];
    
    __weak UIBarButtonItem *weakLoginButton = self.loginButton;
    __weak UIBarButtonItem *weakLoginNameItem = self.loginNameItem;
    
    if ([[ASServerManager sharedManager] isAccessTokenValid]) {      // if accessToken is still valid
        
        ASAccessToken *accessToken = [self loadAccessTokenFromUserDefaultsWithKey:@"token"];
        
        [[ASServerManager sharedManager] getUser:accessToken.userID
                                       onSuccess:^(ASUser *user) {
                                           weakLoginButton.title = kLogout;
                                           weakLoginNameItem.title = user.firstName;
                                       }
                                       onFailure:^(NSError *error, NSInteger statusCode) {
                                           NSLog(@"Error: %@, status code: %li", [error localizedDescription], statusCode);
                                       }];
        
    } else {
        self.loginButton.title = kLogin;
        self.loginNameItem.title = nil;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API
- (void)authorizeUser {
    
    [[ASServerManager sharedManager] authorizeUser:^(ASUser *user) {
        
        if (user) {
            self.loginNameItem.title = user.firstName;
            self.loginButton.title = kLogout;
            [self refreshWall];
        }
        
    } withRevoke:YES];
}

- (void) getPostsFromServer {
    
    [[ASServerManager sharedManager]
     getPostsWithOffset:[self.postsArray count]
     count:postsInRequest
     onSuccess:^(NSArray *posts) {
         
         if ([posts count] < postsInRequest) {
             self.isAllPostsLoaded = YES;
         }
         
         [self.postsArray addObjectsFromArray:posts];
         
         NSMutableArray* newPaths = [NSMutableArray array];
         for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         
         if (self.isFirstPostsLoad) {

             self.isFirstPostsLoad = NO;

             [self.tableView performBatchUpdates:^{
                 [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
             } completion:nil];
         
         } else {
             
             [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
             
             // more or less smooth visible load of additional posts
             NSInteger cellRowToMoveTo = [self.tableView.visibleCells count] / 2;
             ASPostViewCell *middleVisibleCell = [self.tableView.visibleCells objectAtIndex:cellRowToMoveTo];
             
             [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:middleVisibleCell]
                                   atScrollPosition:UITableViewScrollPositionTop
                                           animated:YES];
         }
     
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %li", [error localizedDescription], statusCode);
     }];
}

- (void)refreshWall {
    NSInteger cellRowToMoveTo;
    ASPostViewCell *middleVisibleCell;
    NSIndexPath *middleVisibleCellPath;
    
    if (! ([self.tableView.visibleCells count] > 0) ) {
        NSMutableArray* newPaths = [NSMutableArray array];
        [newPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    cellRowToMoveTo = [self.tableView.visibleCells count] / 2;
    middleVisibleCell = [self.tableView.visibleCells objectAtIndex:cellRowToMoveTo];
    middleVisibleCellPath = [self.tableView indexPathForCell:middleVisibleCell];
    
    [[ASServerManager sharedManager]
     getPostsWithOffset:0
     count:MAX(postsInRequest, [self.postsArray count])
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray removeAllObjects];
         [self.postsArray addObjectsFromArray:posts];
         
         [self.tableView reloadData];
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.tableView scrollToRowAtIndexPath:middleVisibleCellPath
                                   atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
         });
         
         [self.refreshControl endRefreshing];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         [self.refreshControl endRefreshing];
     }];
}

#pragma mark - User defaults

- (void)saveAccessTokenToUserDefaults:(ASAccessToken *)accessToken forKey:(NSString *)key {
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

- (ASAccessToken *)loadAccessTokenFromUserDefaultsWithKey:(NSString *)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    
    ASAccessToken *accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return accessToken;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.postsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"PostCell";
    
    ASPostViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    ASPost *post = [self.postsArray objectAtIndex:indexPath.row];
    
    // Setting "from" name, post date, likes and comments count
    
    cell.fromID = post.fromID;
    cell.fromName.text = post.fromName;
    cell.postDate.text = post.postDate;
    cell.likesCount.text = post.likesCount;
    cell.commentsCount.text = post.commentsCount;
    
    // Setting postID for managing likes
    
    cell.postID = post.postID;
    
    // Setting post text frame
    
    CGFloat textHeight = [ASPostViewCell heightForText:post.postText withFontSize:18.0];
    
    cell.postText.frame = CGRectMake(CGRectGetMinX(cell.postText.frame),
                                     CGRectGetMinY(cell.postText.frame),
                                     CGRectGetWidth(cell.postText.frame),
                                     textHeight);
    cell.postText.text = post.postText;
    
    
    // Downloading from-Photo
    
    cell.fromPhoto.image = nil;
    
    __weak ASPostViewCell *weakCell = cell;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:post.fromImage];
    
    [cell.fromPhoto
     setImageWithURLRequest:request
     placeholderImage:[UIImage imageNamed:@"dummyPhoto"]
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
         weakCell.fromPhoto.image = image;
         [weakCell layoutSubviews];
     }
     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         NSLog(@"Loading image error: %@, status code: %li", [error localizedDescription], response.statusCode);
     }];
    
    // Downloading post images
    
    for (UIImageView *postImageView in cell.additionalImages) {
        postImageView.image = nil;
    }
    
    CGFloat imageZeroYOffset = 10.0;                                                    // space between images
    __block CGFloat imageZeroY = CGRectGetMaxY(cell.postText.frame) + imageZeroYOffset; // image start point
    
    for (int i = 0; i < [post.postImages count]; i++) {
        
        if (i > 2) {
            break;
        }
        
        NSURL *postImageURL = [post.postImages objectAtIndex:i];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:postImageURL];
        
        [[cell.additionalImages objectAtIndex:i]
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
             
             CGFloat imageRatio = image.size.width / image.size.height;
             CGFloat imageHeight = CGRectGetWidth(weakCell.postText.frame) / imageRatio;
             
             CGRect calculatedImageFrame = CGRectMake(CGRectGetMinX(weakCell.postText.frame),
                                                      imageZeroY,
                                                      CGRectGetWidth(weakCell.postText.frame),
                                                      imageHeight);
             
             UIImageView *currentPostImage = [weakCell.additionalImages objectAtIndex:i];
             currentPostImage.frame = calculatedImageFrame;
             currentPostImage.image = image;
             
             imageZeroY += imageHeight + imageZeroYOffset;
             
             [weakCell layoutSubviews];
         }
         failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
             NSLog(@"Loading image error: %@, status code: %li", [error localizedDescription], response.statusCode);
         }];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isAllPostsLoaded) {
        
        if (indexPath.row == [self.postsArray count] - postsInRequest / 2) {
            [self getPostsFromServer];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ASPost *post = [self.postsArray objectAtIndex:indexPath.row];
    
    CGFloat postHeight = 0.0;
    
    if ([post.postImages count] < 1) {
        postHeight = [ASPostViewCell heightForCellWithText:post.postText withFontSize:18.0 andImagesRatios:nil];
    } else {
        postHeight = [ASPostViewCell heightForCellWithText:post.postText withFontSize:18.0 andImagesRatios:post.postImagesRatios];
    }
    
    return postHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.cellToReloadIndexPath = indexPath;
    
    ASPost *post = [self.postsArray objectAtIndex:indexPath.row];
    
    ASPostDetailsTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ASPostDetailsTableViewController"];
    
    vc.postOwner = post.postOwnerID;
    vc.postID = post.postID;
    vc.authorName = post.fromName;
    vc.postDate = post.postDate;
    vc.postText = post.postText;
    vc.authorPhotoURL = post.fromImage;
    
    ASPostViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.isLikedByUser = cell.likeButton.isSelected;
    vc.likesCount = cell.likesCount.text;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Actions

- (IBAction)loginButton:(UIBarButtonItem *)sender {
    
    if ([self.loginButton.title isEqualToString:kLogin]) {
        [self authorizeUser];
    } else {
        
        self.loginButton.title = kLogin;
        self.loginNameItem.title = nil;
        
        [[ASServerManager sharedManager] deleteCurrentAccessToken];
        
//        [self refreshWall];
    }
}

@end
