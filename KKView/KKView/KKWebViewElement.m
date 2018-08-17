//
//  KKWebViewElement.m
//  KKView
//
//  Created by zhanghailong on 2018/7/2.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKWebViewElement.h"
#import "KKViewContext.h"
#import <WebKit/WebKit.h>

@interface KKWebViewElement()<WKUIDelegate,WKNavigationDelegate> {
    BOOL _displaying;
}

@property(nonatomic,readonly,strong) WKWebView * webView;

@end

@implementation KKWebViewElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKWebViewElement class] name:@"webview"];
    
}

-(Class) viewClass {
    return [WKWebView class];
}

-(WKWebViewConfiguration *) loadWebViewConfiguration {
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    return configuration;
}

-(UIView *) createView {
    
    WKWebViewConfiguration * v = [self loadWebViewConfiguration];
    
    if(v == nil) {
        return [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    
    return [[WKWebView alloc] initWithFrame:CGRectZero configuration:v];
    
}

-(WKWebView *) webView {
    return (WKWebView *) self.view;
}

-(void) setView:(UIView *)view {
    WKWebView * v = self.webView;
    if(v) {
        [v setUIDelegate:nil];
        [v setNavigationDelegate:nil];
    }
    [super setView:view];
    v = self.webView;
    if(v) {
        [v setOpaque:NO];
        [v setUIDelegate:self];
        [v setNavigationDelegate:self];
        [self setNeedsDisplay];
    }
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    
    if([key isEqualToString:@"src"]) {
        [self setNeedsDisplay];
    }
}

-(void) display {
    
    NSURL * u = nil;
    
    @try {
        u = [NSURL URLWithString:[self get:@"src"]];
    }
    @catch(NSException *ex) {
        
    }
    
    if(u) {
        NSLog(@"[KK] [WEBVIEW] %@",u);
        [self.webView loadRequest:[NSURLRequest requestWithURL:u]];
    }
    
    _displaying = false;
    
}

-(void) setNeedsDisplay {
    
    if(_displaying || self.view == nil) {
        return;
    }
    
    _displaying = true;
    
    __weak KKWebViewElement * e = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [e display];
    });
}


@end
