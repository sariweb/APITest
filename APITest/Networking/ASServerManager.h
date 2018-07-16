//
//  ASServerManager.h
//  APITest
//
//  Created by Sergey Agishev on 07.07.18.
//  Copyright (c) 2018 Sergei Agishev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@protocol ASServerManagerDelegate;

@class ASUser, ASGroup, ASAccessToken;

@interface ASServerManager : NSObject

@property (strong, nonatomic) ASAccessToken *accessToken;
@property (weak, nonatomic) id <ASServerManagerDelegate> delegate;

+ (ASServerManager*) sharedManager;

- (BOOL)isAccessTokenValid;

- (void)deleteCurrentAccessToken;

- (void)authorizeUser:(void(^)(ASUser *user))completion withRevoke:(BOOL)revoke;

- (void)getUser:(NSString*)userID
       onSuccess:(void(^)(ASUser *user)) success
       onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

//- (void)getGroupInfo:(NSString *)groupID
//           onSuccess:(void(^)(ASGroup *group))success
//           onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)getPostsWithOffset:(NSInteger)offset
                    count:(NSInteger)count
                onSuccess:(void(^)(NSArray *posts))success
                onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)getPostInfo:(NSString *)userAndPostID
          onSuccess:(void(^)(NSDictionary *response))success
          onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)getComments:(NSString *)ownerID
            forPost:(NSString *)postID
         withOffset:(NSInteger)offset
              count:(NSInteger)count
          onSuccess:(void(^)(NSArray *comments))success
          onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

@end

@protocol ASServerManagerDelegate // to send progress to UIView

@required

@property (weak, nonatomic) UIProgressView *uploadProgressView;

@end
