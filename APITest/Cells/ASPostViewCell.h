//
//  ASPostViewCell.h
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPostViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fromName;
@property (weak, nonatomic) IBOutlet UILabel *postDate;
@property (weak, nonatomic) IBOutlet UIImageView *fromPhoto;
@property (weak, nonatomic) IBOutlet UILabel *postText;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *additionalImages;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet UILabel *pinnedPost;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *fromPhotoButton;

@property (strong, nonatomic) NSString *fromID;
@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) NSString *groupID;

//- (IBAction)actionLikeButton:(UIButton *)sender;
//- (IBAction)actionFromPhoto:(UIButton *)sender;

+ (CGFloat)heightForText:(NSString *)text withFontSize:(CGFloat)fontSize;
+ (CGFloat)heightForCellWithText:(NSString *)text withFontSize:(CGFloat)fontSize andImagesRatios:(NSArray *)imagesRatios;

@end
