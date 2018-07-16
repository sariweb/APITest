//
//  ASAccessToken.m
//  APITest
//
//  Created by SA on 7/12/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASAccessToken.h"

static NSString *const kASAccessTokenCoderKeyToken = @"kASAccessTokenCoderKeyToken";
static NSString *const kASAccessTokenCoderKeyExpirationDate = @"kASAccessTokenCoderKeyExpirationDate";
static NSString *const kASAccessTokenCoderKeyUserID = @"kASAccessTokenCoderKeyUserID";

@implementation ASAccessToken

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    [aCoder encodeObject:self.token forKey:kASAccessTokenCoderKeyToken];
    [aCoder encodeObject:self.expirationDate forKey:kASAccessTokenCoderKeyExpirationDate];
    [aCoder encodeObject:self.userID forKey:kASAccessTokenCoderKeyUserID];
    
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        _token = [aDecoder decodeObjectForKey:kASAccessTokenCoderKeyToken];
        _expirationDate = [aDecoder decodeObjectForKey:kASAccessTokenCoderKeyExpirationDate];
        _userID = [aDecoder decodeObjectForKey:kASAccessTokenCoderKeyUserID];
    }
    
    return self;
}

@end
