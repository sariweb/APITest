//
//  ASServerManager.m
//  APITest
//
//  Created by Sergey Agishev on 07.07.18.
//  Copyright (c) 2018 Sergei Agishev. All rights reserved.
//

#import "ASServerManager.h"
#import "AFNetworking.h"
#import "ASLoginViewController.h"
#import "ASAccessToken.h"
#import "ASUser.h"
#import "ASGroup.h"
#import "ASPost.h"
#import "ASComment.h"

@interface ASServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation ASServerManager

+ (ASServerManager*) sharedManager {
    
    static ASServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ASServerManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL *url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        
        self.accessToken = [self loadAccessTokenFromUserDefaultsWithKey:@"token"];
    }
    
    return self;
}

- (void) authorizeUser:(void(^)(ASUser* user)) completion withRevoke:(BOOL)revoke{
    
    ASLoginViewController *vc = [[ASLoginViewController alloc] initWithCompletionBlock:^(ASAccessToken *token) {
        
        self.accessToken = token;
        
        [self saveAccessTokenToUserDefaults:token forKey:@"token"];
        
        if (token) {
            
            [self getUser:self.accessToken.userID
                onSuccess:^(ASUser *user) {
                    if (completion) {
                        completion(user);
                    }
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    if (completion) {
                        completion(nil);
                    }
                }];
            
        } else if (completion) {
            completion(nil);
        }
        
        
    }
    withRevoke:revoke];
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController *mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nav
                         animated:YES
                       completion:nil];
     
}

- (BOOL)isAccessTokenValid {
    
    if (self.accessToken.expirationDate.timeIntervalSinceNow > 0) {
        return YES;
    }
    
    return NO;
}

- (ASAccessToken *)loadAccessTokenFromUserDefaultsWithKey:(NSString *)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    
    ASAccessToken *accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return accessToken;
}

- (void)saveAccessTokenToUserDefaults:(ASAccessToken *)accessToken forKey:(NSString *)key {
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

- (void)deleteCurrentAccessToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"token"];
    self.accessToken = nil;
}

#pragma mark - GET Requests

- (void)getUser:(NSString*)userID
      onSuccess:(void(^)(ASUser *user)) success
      onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID,                         @"user_ids",
                            @"photo_200",                   @"fields",
                            @"nom",                         @"name_case",
                            serviceAccessToken,             @"access_token",
                            APIVer,                         @"v", nil];
    
    
    [self.sessionManager GET:@"users.get"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                         
                         NSArray *arrayResponse = [responseObject objectForKey:@"response"];
                         
                         if ([arrayResponse count] > 0) {
                             
                             ASUser *user = [[ASUser alloc] initWithServerResponse:[arrayResponse firstObject]];
                             
                             if (success) {
                                 success(user);
                             }
                             
                         } else {
                             
                             NSHTTPURLResponse *response = nil;
                             
                             if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                                 response = (NSHTTPURLResponse *)task.response;
                             }
                             
                             if (failure) {
                                 failure(nil, response.statusCode);
                             }
                         }
                         
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         [self failureHandler:task error:error forFailureBlock:failure];
                         
                     }];
    
    
}

- (void)getPostsWithOffset:(NSInteger)offset
                    count:(NSInteger)count
                onSuccess:(void(^)(NSArray *posts))success
                onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(count),                   @"count",
                            @(offset),                  @"offset",
                            @"post",                    @"filters",
                            self.accessToken.token,     @"access_token",
                            APIVer,                     @"v", nil];
    
    [self.sessionManager GET:@"newsfeed.get"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
                         
                         NSDictionary *responseDict = [responseObject objectForKey:@"response"];
                         
                         NSArray *postsArray = [responseDict objectForKey:@"items"];
                         
                         NSMutableArray *objectsArray = [NSMutableArray array];
                         
                         for (NSDictionary *dict in postsArray) {
                             
                             NSMutableDictionary *newDictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
                             [newDictionary setObject:[responseDict objectForKey:@"profiles"] forKey:@"profiles"];
                             [newDictionary setObject:[responseDict objectForKey:@"groups"] forKey:@"groups"];
                             
                             ASPost *post = [[ASPost alloc] initWithServerResponse:[NSDictionary dictionaryWithDictionary:newDictionary]];
                             [objectsArray addObject:post];
                         }
                         
                         if (success) {
                             success(objectsArray);
                         }
                         
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [self failureHandler:task error:error forFailureBlock:failure];
                     }];
}

- (void)getPostInfo:(NSString *)ownerAndPostID
          onSuccess:(void(^)(NSDictionary *response))success
          onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    ownerAndPostID = [self checkAndAddMinusFor:ownerAndPostID];
    
    NSDictionary *params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     ownerAndPostID,            @"posts",
     self.accessToken.token,    @"access_token",
     APIVer,                    @"v", nil];
    
    [self.sessionManager GET:@"wall.getById"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
                         
                         NSArray *responseArray = [responseObject objectForKey:@"response"];
                         NSDictionary *responseDict = [responseArray firstObject];
                         
                         if (success) {
                             success(responseDict);
                         }
                         
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [self failureHandler:task error:error forFailureBlock:failure];
                     }];
}

- (void)getComments:(NSString *)ownerID
            forPost:(NSString *)postID
         withOffset:(NSInteger)offset
              count:(NSInteger)count
          onSuccess:(void(^)(NSArray *comments))success
          onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ownerID,                    @"owner_id",
                            postID,                     @"post_id",
                            @"1",                       @"need_likes",
                            @(count),                   @"count",
                            @(offset),                  @"offset",
                            @"1",                       @"extended",
                            [self isAccessTokenValid] ?
                            self.accessToken.token :
                            serviceAccessToken,         @"access_token",
                            APIVer,                     @"v", nil];
    
    [self.sessionManager GET:@"wall.getComments"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
                         
                         NSDictionary *responseDict = [responseObject objectForKey:@"response"];
                         
                         NSArray *commentsArray = [responseDict objectForKey:@"items"];
                         
                         NSMutableArray *objectsArray = [NSMutableArray array];
                         
                         for (NSDictionary *dict in commentsArray) {
                             
                             NSMutableDictionary *newDictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
                             [newDictionary setObject:[responseDict objectForKey:@"profiles"] forKey:@"profiles"];
                             [newDictionary setObject:[responseDict objectForKey:@"groups"] forKey:@"groups"];
                             
                             ASComment *comment = [[ASComment alloc] initWithServerResponse:[NSDictionary dictionaryWithDictionary:newDictionary]];
                             [objectsArray addObject:comment];
                         }
                         
                         if (success) {
                             success(objectsArray);
                         }
                         
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [self failureHandler:task error:error forFailureBlock:failure];
                     }];
}

#pragma mark - Helpers

- (void)failureHandler:(NSURLSessionDataTask *)task
                 error:(NSError *)error
       forFailureBlock:(void(^)(NSError *error, NSInteger statusCode))failureBlock {
    
    NSLog(@"Error: %@", error);
    
    NSHTTPURLResponse *response = nil;
    
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        response = (NSHTTPURLResponse *)task.response;
    }
    
    if (failureBlock) {
        failureBlock(error, response.statusCode);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSString *)checkAndAddMinusFor:(NSString *)string {
    
    if (![string hasPrefix:@"-"]) {
        string = [@"-" stringByAppendingString:string];
    }
    
    return string;
}

@end
