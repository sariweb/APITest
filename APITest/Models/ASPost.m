//
//  ASPost.m
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASPost.h"

@implementation ASPost

- (instancetype)initWithServerResponse:(NSDictionary *)responseObject {
    
    self = [super init];
    if (self) {
        
        // Getting who-posted's info
        
        NSString *fromName = nil;
        NSString *fromPhotoURL = nil;
        
        
        NSArray *fromProfiles = [responseObject objectForKey:@"profiles"];              // all persons ID
        NSArray *fromGroups = [responseObject objectForKey:@"groups"];                  // all groups ID
        NSString *source_id = [NSString stringWithFormat:@"%lld", [[responseObject objectForKey:@"source_id"] longLongValue]];  // who posted ID
        
        if ([source_id hasPrefix:@"-"]) {     // whether it is a group
            
            for (NSDictionary *dict in fromGroups) {
                
                NSString *itemID = [NSString stringWithFormat:@"-%lld", [[dict objectForKey:@"id"] longLongValue]];
                
                if ([itemID isEqualToString:source_id]) {
                    fromName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
                    fromPhotoURL = [dict objectForKey:@"photo_200"];
                    
                    break;
                }
            }
            
        } else {                            // whether it is a person
            
            for (NSDictionary *dict in fromProfiles) {
                
                NSString *itemID = [NSString stringWithFormat:@"%lld", [[dict objectForKey:@"id"] longLongValue]];
                
                if ([itemID isEqualToString:source_id]) {
                    fromName = [NSString stringWithFormat:@"%@ %@",
                                [dict objectForKey:@"first_name"],
                                [dict objectForKey:@"last_name"]];
                    fromPhotoURL = [dict objectForKey:@"photo_100"];
                    break;
                }
            }
        }
        
        self.fromID = source_id;
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
            self.postDate = [NSString stringWithFormat:@"сегодня в %@", [hourFormatter stringFromDate:postDate]];
        } else if ([calendar isDateInYesterday:postDate]) {
            self.postDate = [NSString stringWithFormat:@"вчера в %@", [hourFormatter stringFromDate:postDate]];
        } else {
            self.postDate = [NSString stringWithFormat:@"%@ в %@",
                             [dateFormatter stringFromDate:postDate],
                             [hourFormatter stringFromDate:postDate]];
        }
        
        // Getting post text and additional info
        
        self.postText = [responseObject objectForKey:@"text"];
        
        NSDictionary *likesInfo = [responseObject objectForKey:@"likes"];
        
        self.likesCount = [NSString stringWithFormat:@"%ld", [[likesInfo objectForKey:@"count"] longValue]];
        
        self.isLikedByUser = [[likesInfo objectForKey:@"user_likes"] longValue] == 1 ? YES : NO;
        
        NSDictionary *commentsInfo = [responseObject objectForKey:@"comments"];
        
        self.commentsCount = [NSString stringWithFormat:@"%ld", [[commentsInfo objectForKey:@"count"] longValue]];
        
        self.postID = [NSString stringWithFormat:@"%li", [[responseObject objectForKey:@"post_id"] longValue]];
        
        self.postOwnerID = source_id;
        
        // Getting post images array
        
        NSMutableArray *imagesArray = [NSMutableArray array];
        NSMutableArray *imagesRatioArray = [NSMutableArray array];
        
        NSArray *attachements = [responseObject objectForKey:@"attachments"];
        
        for (NSDictionary *attDict in attachements) {
            
            if ([[attDict objectForKey:@"type"] isEqualToString:@"photo"]) {
                
                NSDictionary *photoDict = [attDict objectForKey:@"photo"];
                
                [imagesArray addObject:[NSURL URLWithString:[photoDict objectForKey:@"photo_604"]]];
                
                // Getting image size ratio
                NSInteger imageWidth = [[photoDict objectForKey:@"width"] integerValue];
                NSInteger imageHeight = [[photoDict objectForKey:@"height"] integerValue];
                CGFloat imageRatio = (CGFloat)imageWidth / (CGFloat)imageHeight;
                
                [imagesRatioArray addObject:@(imageRatio)];
            }
        }
        
        self.postImages = [NSArray arrayWithArray:imagesArray];
        self.postImagesRatios = [NSArray arrayWithArray:imagesRatioArray];
    }
    
    return self;
}

@end
