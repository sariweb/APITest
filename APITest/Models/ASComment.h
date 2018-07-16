//
//  ASComment.h
//  APITest
//
//  Created by SA on 7/15/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASServerObject.h"

@interface ASComment : ASServerObject

@property (strong, nonatomic) NSString *commentID;
@property (strong, nonatomic) NSString *fromName;
@property (strong, nonatomic) NSURL *fromImage;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSString *commentDate;
@property (strong, nonatomic) NSString *likesCount;
@property (assign, nonatomic) BOOL isLikedByUser;

@end
