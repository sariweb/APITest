//
//  ASPostDetailsTableViewController.h
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPostDetailsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UIView *postInfoView;
@property (weak, nonatomic) IBOutlet UIImageView *authorPhoto;

@property (strong, nonatomic) NSString *postOwner;
@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSString *postDate;
@property (strong, nonatomic) NSString *postText;
@property (strong, nonatomic) NSString *likesCount;
@property (assign, nonatomic) BOOL isLikedByUser;
@property (strong, nonatomic) NSURL *authorPhotoURL;

@end
