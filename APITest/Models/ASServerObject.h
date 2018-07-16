//
//  ASServerObject.h
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASServerObject : NSObject

- (instancetype)initWithServerResponse:(NSDictionary *)responseObject;

@end
