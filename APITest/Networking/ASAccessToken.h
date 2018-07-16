//
//  ASAccessToken.h
//  APITest
//
//  Created by SA on 7/12/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *serviceAccessToken = @"56f5c85156f5c85156f5c851cb5690e587556f556f5c8510db32cea7f12ee422c8c3ad2";
static NSString *APIVer = @"5.8";
static NSString *appID = @"6630870";

@interface ASAccessToken : NSObject

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSString *userID;

@end
