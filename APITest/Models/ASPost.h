//
//  ASPost.h
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASServerObject.h"

@interface ASPost : ASServerObject

@property (strong, nonatomic) NSString *fromID;
@property (strong, nonatomic) NSString *postOwnerID;
@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) NSString *fromName;
@property (strong, nonatomic) NSURL *fromImage;
@property (strong, nonatomic) NSString *postText;
@property (strong, nonatomic) NSString *postDate;
@property (strong, nonatomic) NSString *likesCount;
@property (assign, nonatomic) BOOL isLikedByUser;
@property (strong, nonatomic) NSString *commentsCount;
@property (strong, nonatomic) NSArray *postImages;
@property (strong, nonatomic) NSArray *postImagesRatios;
@property (strong, nonatomic) NSString *pinnedPost;

@end
