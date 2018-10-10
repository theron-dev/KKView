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

@interface KKWebViewElement()<WKUIDelegate,WKNavigationDelegate,UIAlertViewDelegate> {
    BOOL _displaying;
    
    void (^_confirmCompletionHandler)(BOOL result);
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
        [v removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
        [v setUIDelegate:nil];
        [v setNavigationDelegate:nil];
    }
    [super setView:view];
    v = self.webView;
    if(v) {
        [v addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
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
        u = [NSURL URLWithString:[[self get:@"src"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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

-(UIView *) contentView {
    return [(WKWebView *) self.view scrollView];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if(object == self.view) {
        if([keyPath isEqualToString:@"estimatedProgress"]) {
            KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
            NSMutableDictionary * data = self.data;
            data[@"value"] = @([(WKWebView *) object estimatedProgress]);
            e.data = data;
            [self emit:@"progress" event:e];
        }
    }
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    e.data = self.data;
    [self emit:@"loading" event:e];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    e.data = self.data;
    [self emit:@"load" event:e];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    NSMutableDictionary * data = self.data;
    data[@"errmsg"] = [error localizedDescription];
    e.data = data;
    [self emit:@"error" event:e];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString * u = navigationAction.request.URL.absoluteString;
    
    KKElement * p = self.firstChild;
    
    while(p) {
        
        if([[p get:@"#name"] isEqualToString:@"action"]) {
            {
                NSString * v = [p get:@"prefix"];
                
                if(v != nil && [u hasPrefix:v]) {
                    break;
                }
            }
            {
                NSString * v = [p get:@"suffix"];
                
                if(v != nil && [u hasSuffix:v]) {
                    break;
                }
            }
            {
                NSString * v = [p get:@"pattern"];
                
                if(v != nil) {
                    
                    NSRegularExpression * pattern = [NSRegularExpression regularExpressionWithPattern:v options:NSRegularExpressionAnchorsMatchLines error:nil];
                    
                    NSTextCheckingResult * r = [pattern firstMatchInString:u options:NSMatchingReportProgress range:NSMakeRange(0, [u length])];
                    
                    if(r != nil) {
                        break;
                    }
                }
            }
        }
        
        p = p.nextSibling;
    }
    
    if(p) {
        
        NSString * name = [p get:@"name"];
        
        if([name length] == 0) {
            name = @"action";
        }
        
        KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
        NSMutableDictionary * data = self.data;
        {
            NSMutableDictionary * v = p.data;
            NSEnumerator *keyEnum = [v keyEnumerator];
            NSString * key;
            while((key = [keyEnum nextObject])) {
                data[key] = [v valueForKey:key];
            }
        }
        data[@"url"] = u;
        e.data = data;
        [self emit:name event:e];
        
        if([[p get:@"policy"] isEqualToString:@"allow"]) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

- (void)webViewDidClose:(WKWebView *)webView {
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    e.data = self.data;
    [self emit:@"close" event:e];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    
    [alertView show];
    
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    _confirmCompletionHandler = completionHandler;
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    
    alertView.tag = 200;
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 200) {
        if(_confirmCompletionHandler) {
            _confirmCompletionHandler(buttonIndex == 0);
            _confirmCompletionHandler = nil;
        }
    }
}

@end
