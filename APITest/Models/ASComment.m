//
//  ASComment.m
//  APITest
//
//  Created by SA on 7/15/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASComment.h"

@implementation ASComment


- (instancetype)initWithServerResponse:(NSDictionary *)responseObject {
    
    self = [super init];
    if (self) {
        
        // Getting who-posted's info
        
        NSString *fromName = nil;
        NSString *fromPhotoURL = nil;
        
        
        NSArray *fromProfiles = [responseObject objectForKey:@"profiles"];              // all persons ID
        NSArray *fromGroups = [responseObject objectForKey:@"groups"];                  // all groups ID
        NSString *fromID = [NSString stringWithFormat:@"%lld",
                            [[responseObject objectForKey:@"from_id"] longLongValue]];  // who posted ID
        
        if ([fromID hasPrefix:@"-"]) {     // whether it is a group
            
            for (NSDictionary *dict in fromGroups) {
                
                NSString *itemID = [NSString stringWithFormat:@"-%lld", [[dict objectForKey:@"id"] longLongValue]];
                
                if ([itemID isEqualToString:fromID]) {
                    fromName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
                    fromPhotoURL = [dict objectForKey:@"photo_200"];
                    break;
                }
            }
            
        } else {                            // whether it is a person
            
            for (NSDictionary *dict in fromProfiles) {
                
                NSString *itemID = [NSString stringWithFormat:@"%lld", [[dict objectForKey:@"id"] longLongValue]];
                
                if ([itemID isEqualToString:fromID]) {
                    fromName = [NSString stringWithFormat:@"%@ %@",
                                [dict objectForKey:@"first_name"],
                                [dict objectForKey:@"last_name"]];
                    fromPhotoURL = [dict objectForKey:@"photo_100"];
                    break;
                }
            }
        }
        
        self.fromName = fromName;
        self.fromImage = [NSURL URLWithString:fromPhotoURL];
        
        // Getting post date
        
        NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] longLongValue]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        
        NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
        hourFormatter.dateFormat = @"HH:mm";
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        if ([calendar isDateInToday:postDate]) { // post has been made during 24 hours
            self.commentDate = [NSString stringWithFormat:@"сегодня в %@", [hourFormatter stringFromDate:postDate]];
        } else if ([calendar isDateInYesterday:postDate]) {
            self.commentDate = [NSString stringWithFormat:@"вчера в %@", [hourFormatter stringFromDate:postDate]];
        } else {
            self.commentDate = [NSString stringWithFormat:@"%@ в %@",
                                [dateFormatter stringFromDate:postDate],
                                [hourFormatter stringFromDate:postDate]];
        }
        
        // Getting post text and additional info
        
        self.commentText = [responseObject objectForKey:@"text"];
        
        NSDictionary *likesInfo = [responseObject objectForKey:@"likes"];
        
        self.likesCount = [NSString stringWithFormat:@"%ld", [[likesInfo objectForKey:@"count"] integerValue]];
        
        self.isLikedByUser = [[likesInfo objectForKey:@"user_likes"] integerValue] == 1 ? YES : NO;;
        
        self.commentID = [NSString stringWithFormat:@"%li", [[responseObject objectForKey:@"id"] longValue]];
    }
    
    return self;
}

@end
