//
//  ASUser.m
//  APITest
//
//  Created by SA on 7/10/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASUser.h"

@implementation ASUser

- (instancetype) initWithServerResponse:(NSDictionary *)responseObject {
    
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        self.photo = [NSURL URLWithString:[responseObject objectForKey:@"photo_200"]];
        /*
        self.userID = [[responseObject objectForKey:@"id"] unsignedIntValue];
        
        if ([[responseObject objectForKey:@"type"] isEqualToString:@"page"]) {
            
            self.nameForGroup = [responseObject objectForKey:@"name"];
            
        } else {
            
            self.firstName = [responseObject objectForKey:@"first_name"];
            self.lastName = [responseObject objectForKey:@"last_name"];
        }
        
        self.online = (NSInteger)[[responseObject objectForKey:@"online"] intValue];
        
        NSString *urlStringPhoto50 = [responseObject objectForKey:@"photo_50"];
        
        if (urlStringPhoto50) {
            self.image50URL = [NSURL URLWithString:urlStringPhoto50];
        }
         */
        
    }
    
    return self;
    
}

@end
