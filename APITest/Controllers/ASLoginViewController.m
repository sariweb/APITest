//
//  ASLoginViewController.m
//  APITest
//
//  Created by SA on 7/12/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASLoginViewController.h"
#import "WebKit/WebKit.h"
#import "ASAccessToken.h"

@interface ASLoginViewController () <WKNavigationDelegate>

@property (copy, nonatomic) ASLoginCompletionBlock completionBlock;
@property (weak, nonatomic) WKWebView *webView;
@property (assign, nonatomic) BOOL isRevoke;

@end

@implementation ASLoginViewController

- (id) initWithCompletionBlock:(ASLoginCompletionBlock) completionBlock
                    withRevoke:(BOOL)revoke {
    
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
        self.isRevoke = revoke;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    r.origin = CGPointZero;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:r];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    
    self.webView = webView;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    self.navigationItem.title = @"Login";
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://oauth.vk.com/authorize?"
                           "client_id=%@&"
                           "scope=143382&" // + 2 + 4 + 16 + 4096 + 8192 + 131072
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "display=mobile&"
                           "%@&"
                           "%@&"            // whether is needed to relogin again
                           "response_type=token", appID, APIVer, self.isRevoke ? @"revoke=1" : nil];

    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    webView.navigationDelegate = self;

    [webView loadRequest:request];
    
}

- (void)dealloc{
    self.webView.navigationDelegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem*) item {
    
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURLRequest *request = navigationAction.request;
    
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        
        ASAccessToken *token = [[ASAccessToken alloc] init];
        
        NSString *query = [[request URL] description];
        
        NSArray *array = [query componentsSeparatedByString:@"#"];
        
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs) {
            
            NSArray *values = [pair componentsSeparatedByString:@"="];
            
            if ([values count] == 2) {
                
                NSString *key = [values firstObject];
                
                if ([key isEqualToString:@"access_token"]) {
                    
                    token.token = [values lastObject];
                    
                } else if ([key isEqualToString:@"expires_in"]) {
                    
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                    
                } else if ([key isEqualToString:@"user_id"]) {
                    
                    token.userID = [values lastObject];
                }
            }
        }
        
        self.webView.navigationDelegate = nil;
        
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
