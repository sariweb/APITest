//
//  ASUser.h
//  APITest
//
//  Created by SA on 7/10/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASServerObject.h"

static NSUInteger userIDForRequest = 33727028;

@interface ASUser : ASServerObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSURL *photo;

@property (assign, nonatomic) NSUInteger userID;
@property (strong, nonatomic) NSString *nameForGroup;
@property (strong, nonatomic) NSURL *image50URL;
@property (assign, nonatomic) NSInteger online;

@end
