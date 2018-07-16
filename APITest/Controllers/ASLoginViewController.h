//
//  ASLoginViewController.h
//  APITest
//
//  Created by SA on 7/12/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASAccessToken;

typedef void(^ASLoginCompletionBlock)(ASAccessToken* token);

@interface ASLoginViewController : UIViewController

- (id) initWithCompletionBlock:(ASLoginCompletionBlock) completionBlock withRevoke:(BOOL)revoke;

@end
