//
//  ASGroup.m
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASGroup.h"

@implementation ASGroup

- (instancetype)initWithServerResponse:(NSDictionary *)responseObject {
    
    self = [super init];
    
    if (self) {
        
        NSDictionary *counters = [responseObject objectForKey:@"counters"];
        
        self.name             = [responseObject objectForKey:@"name"];
        self.groupDescription = [responseObject objectForKey:@"description"];
        self.groupPhoto       = [NSURL URLWithString: [responseObject objectForKey:@"photo_200"]];
        self.membersCount     = [NSString stringWithFormat:@"%li",
                                 [[responseObject objectForKey:@"members_count"] integerValue]];
        self.photoCount       = [NSString stringWithFormat:@"%li",
                                 [[counters objectForKey:@"photos"] integerValue]];
        self.videoCount       = [NSString stringWithFormat:@"%li",
                                 [[counters objectForKey:@"videos"] integerValue]];
    }
    
    return self;
}

@end
