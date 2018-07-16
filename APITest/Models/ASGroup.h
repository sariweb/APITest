//
//  ASGroup.h
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASServerObject.h"

@interface ASGroup : ASServerObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *groupDescription;
@property (strong, nonatomic) NSURL *groupPhoto;
@property (strong, nonatomic) NSString *membersCount;
@property (strong, nonatomic) NSString *photoCount;
@property (strong, nonatomic) NSString *videoCount;

@end
