//
//  ASCommentTableViewCell.h
//  APITest
//
//  Created by SA on 7/15/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fromName;
@property (weak, nonatomic) IBOutlet UILabel *commentDate;
@property (weak, nonatomic) IBOutlet UIImageView *fromPhoto;
@property (weak, nonatomic) IBOutlet UILabel *commentText;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (strong, nonatomic) NSString *commentID;
@property (strong, nonatomic) NSString *ownerID;

@end
