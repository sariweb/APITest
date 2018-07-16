//
//  ASPostDetailsTableViewController.m
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASPostDetailsTableViewController.h"
#import "ASCommentTableViewCell.h"
#import "ASPostViewCell.h"
#import "UIKit+AFNetworking.h"
#import "ASServerManager.h"
#import "ASComment.h"

static NSInteger const commentsInRequest = 10;

@interface ASPostDetailsTableViewController ()

@property (strong, nonatomic) NSMutableArray *commentsArray;
@property (assign, nonatomic) BOOL isFirstPostsLoad;
@property (assign, nonatomic) BOOL isAllCommentsLoaded;

@end

@implementation ASPostDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get comments
    
    self.isAllCommentsLoaded = NO;
    
    [self getCommentsFromServer];
    
    // Setting post info view frame
    
    CGFloat infoViewHeight = [ASPostViewCell heightForCellWithText:self.postText withFontSize:18.0 andImagesRatios:nil];
    
    CGRect newInfoViewFrame = CGRectMake(CGRectGetMinX(self.postInfoView.frame),
                                         CGRectGetMinY(self.postInfoView.frame),
                                         CGRectGetWidth(self.postInfoView.frame),
                                         infoViewHeight);
    
    self.postInfoView.frame = newInfoViewFrame;
    
    // Setting post text frame
    
    CGFloat textHeight = [ASPostViewCell heightForText:self.postText withFontSize:18.0];
    
    self.postTextLabel.frame = CGRectMake(CGRectGetMinX(self.postTextLabel.frame),
                                          CGRectGetMinY(self.postTextLabel.frame),
                                          CGRectGetWidth(self.postTextLabel.frame),
                                          textHeight);
    
    // Setting post details
    
    self.authorNameLabel.text = self.authorName;
    self.postDateLabel.text = self.postDate;
    self.postTextLabel.text = self.postText;
    
    [self getAuthorPhoto];

    // Table refresh slide down
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    // Other stuff
    
    self.authorPhoto.layer.cornerRadius = CGRectGetWidth(self.authorPhoto.frame) / 2.0;
    self.authorPhoto.clipsToBounds = YES;
    
    self.commentsArray = [NSMutableArray array];
    
    self.isFirstPostsLoad = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void)getAuthorPhoto {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authorPhotoURL];
    
    [self.authorPhoto
     setImageWithURLRequest:request
     placeholderImage:[UIImage imageNamed:@"dummyPhoto"]
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
         self.authorPhoto.image = image;
     }
     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         NSLog(@"Loading image error: %@, status code: %li", [error localizedDescription], response.statusCode);
     }];
}

- (void)getCommentsFromServer {
    
    [[ASServerManager sharedManager]
     getComments:self.postOwner
     forPost:self.postID
     withOffset:[self.commentsArray count]
     count:commentsInRequest
     onSuccess:^(NSArray *comments) {
         
         if ([comments count] < commentsInRequest) {
             self.isAllCommentsLoaded = YES;
         }
         
         [self.commentsArray addObjectsFromArray:comments];
         
         NSMutableArray *newPaths = [NSMutableArray array];
         
         for (int i = (int)[self.commentsArray count] - (int)[comments count]; i < [self.commentsArray count]; i++) {
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         
         if (self.isFirstPostsLoad) {
             
             self.isFirstPostsLoad = NO;
             
             [self.tableView performBatchUpdates:^{
                 [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
             } completion:nil];
             
         } else {
             
             [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
             
             // more or less smooth visible load of additional comments
             NSInteger cellRowToMoveTo = [self.tableView.visibleCells count] - 1;
             ASCommentTableViewCell *lastVisibleCell = [self.tableView.visibleCells objectAtIndex:cellRowToMoveTo];
             
             [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:lastVisibleCell]
                                   atScrollPosition:UITableViewScrollPositionNone
                                           animated:YES];
         }
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

- (void)refreshWall {
    
    [[ASServerManager sharedManager]
     getComments:self.postOwner
     forPost:self.postID
     withOffset:0
     count:MAX(commentsInRequest, [self.commentsArray count])
     onSuccess:^(NSArray *comments) {
         
         [self.commentsArray removeAllObjects];
         [self.commentsArray addObjectsFromArray:comments];
         
         [self.tableView reloadData];
         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         
         [self.refreshControl endRefreshing];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         [self.refreshControl endRefreshing];
     }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Comments";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.commentsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"CommentCell";
    
    ASCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    ASComment *comment = [self.commentsArray objectAtIndex:indexPath.row];
    
    // Setting "from" name, post date, likes and comments count
    
    cell.fromName.text = comment.fromName;
    cell.commentDate.text = comment.commentDate;
    cell.likesCount.text = comment.likesCount;
    cell.likeButton.selected = comment.isLikedByUser;
    
    // Setting postID and groupID for managing likes
    
    cell.commentID = comment.commentID;
    cell.ownerID = self.postOwner;
    
    // Setting post text frame
    
    CGFloat textHeight = [ASPostViewCell heightForText:comment.commentText withFontSize:16.0];
    
    cell.commentText.frame = CGRectMake(CGRectGetMinX(cell.commentText.frame),
                                        CGRectGetMinY(cell.commentText.frame),
                                        CGRectGetWidth(cell.commentText.frame),
                                        textHeight);
    cell.commentText.text = comment.commentText;
    
    // Downloading from-Photo
    
    cell.fromPhoto.image = nil;
    
    __weak ASCommentTableViewCell *weakCell = cell;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:comment.fromImage];
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.commentsArray count] - 1) {
        
        if (!self.isAllCommentsLoaded) {
            
            [self getCommentsFromServer];
            
        }
    }
}

#pragma mark - UITableVIewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ASComment *comment = [self.commentsArray objectAtIndex:indexPath.row];
    
    CGFloat postHeight = 0.0;
    
    postHeight = [ASPostViewCell heightForCellWithText:comment.commentText withFontSize:16.0 andImagesRatios:nil];
    
    return postHeight - 30.0; // correction for smaller fromPhoto (30x30)
}

@end
