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
#import <MobileCoreServices/MobileCoreServices.h>
#import <KKObserver/KKObserver.h>

@interface WKWebView(KKWebViewElement)

@end

@implementation WKWebView(KKWebViewElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    if([key hasPrefix:@"content-"]) {
        [self.scrollView KKViewElement:element setProperty:[key substringFromIndex:8] value:value];
    } else {
        [super KKViewElement:element setProperty:key value:value];
    }
}

@end

@interface KKWebViewElement()<WKUIDelegate,WKNavigationDelegate,UIAlertViewDelegate> {
    BOOL _displaying;
    
    void (^_confirmCompletionHandler)(BOOL result);
}

@property(nonatomic,readonly,strong) WKWebView * webView;

@end

@interface KKWebViewElementScriptMessageHandler : NSURLProtocol<WKScriptMessageHandler,WKURLSchemeHandler>

@property(nonatomic,strong) NSString * basePath;
@property(nonatomic,weak) KKWebViewElement * element;

@end

static NSString * KKWebViewElementURLProtocolKey = @"KKWebViewElementURLProtocolKey";

@implementation KKWebViewElementScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    KKWebViewElement * e = self.element;
    if(e) {
        KKElementEvent * event = [[KKElementEvent alloc] initWithElement:self.element];
        event.data = message.body;
        [e emit:@"data" event:event];
    }
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([NSURLProtocol propertyForKey:KKWebViewElementURLProtocolKey inRequest:request]) {
        return NO;
    }
    NSString * scheme = [request.URL scheme];
    return [scheme isEqualToString:@"app"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}


-(void) getContent:(NSURL *) URL response:(NSURLResponse **) resp data:(NSData **) data error:(NSError **) error {
    
    //    NSLog(@"[Ker] [KerURLProtocol] %@",[URL absoluteString]);
    
    NSString * filePath = [_basePath stringByAppendingPathComponent:URL.path];
    
    if(filePath == nil) {
        * error = [NSError errorWithDomain:@"KKWebViewElement" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Not Found File Path"}];
        return;
    }
    
    * data = [NSData dataWithContentsOfFile:filePath];
    
    if(* data == nil) {
        * error = [NSError errorWithDomain:@"KKWebViewElement" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Not Found File"}];
        return;
    }
    
    NSString * mimeType = [KKWebViewElementScriptMessageHandler mimeType:filePath data:* data defaultType:@"application/octet-stream"];
    
    * resp = [[NSURLResponse alloc] initWithURL:URL MIMEType:mimeType expectedContentLength:(* data).length textEncodingName:nil];
    
}

- (void)startLoading {
    
    NSMutableURLRequest * req = [self.request mutableCopy];
    
    [NSURLProtocol setProperty:@(YES) forKey:KKWebViewElementURLProtocolKey inRequest:req];
    
    NSError * err = nil;
    NSData * data = nil;
    NSURLResponse * resp = nil;
    
    [self getContent:req.URL response:&resp data:&data error:&err];
    
    if(err != nil) {
        [self.client URLProtocol:self didFailWithError:err];
        return;
    }
    
    [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
    
}

- (void)stopLoading {
    
}

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(11.0)){
    

    NSURL * URL = [urlSchemeTask request].URL;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError * err = nil;
        NSData * data = nil;
        NSURLResponse * resp = nil;
        
        [self getContent:URL response:&resp data:&data error:&err];
        
        if(err != nil) {
            [urlSchemeTask didFailWithError:err];
            return;
        }
        
        [urlSchemeTask didReceiveResponse:resp];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
        
    });
    
    
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)) {
    
}


+(NSString *) mimeType:(NSString *) filePath data:(NSData *) data defaultType:(NSString *) defaultType {
    
    NSString * mimeType = nil;
    
    if(mimeType == nil) {
        
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) filePath.pathExtension, nil);
        
        if(uti) {
            
            CFStringRef v = UTTypeCopyPreferredTagWithClass(uti,kUTTagClassMIMEType);
            
            if(v) {
                mimeType = (__bridge NSString *) v ;
                CFRelease(v);
            }
            
            CFRelease(uti);
            
        }
        
    }
    
    if(mimeType == nil && data) {
        
        uint8_t c;
        
        [data getBytes:&c length:1];
        
        switch (c) {
            case 0xFF:
                mimeType = @"image/jpeg";
                break;
            case 0x89:
                mimeType = @"image/png";
                break;
            case 0x47:
                mimeType = @"image/gif";
                break;
            case 0x49:
            case 0x4D:
                mimeType = @"image/tiff";
                break;
        }
    }
    
    if(mimeType == nil) {
        mimeType = defaultType;
    }
    
    return mimeType;
    
}



@end

@protocol KKWebViewElementWKBrowsingContextController  <NSObject>

-(void) registerSchemeForCustomProtocol:(NSString *) scheme;

@end

@implementation KKWebViewElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKWebViewElement class] name:@"webview"];
    
    if (@available(iOS 11.0, *)) {
    } else {
        [NSURLProtocol registerClass:[KKWebViewElementScriptMessageHandler class]];
        {
            Class cls = NSClassFromString(@"WKBrowsingContextController");
            SEL sel = @selector(registerSchemeForCustomProtocol:);
            if([cls respondsToSelector:sel]) {
                [(id<KKWebViewElementWKBrowsingContextController>)cls registerSchemeForCustomProtocol:@"app"];
            }
        }
    }
}

-(Class) viewClass {
    return [WKWebView class];
}

-(WKWebViewConfiguration *) loadWebViewConfiguration {
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController * userContentController = [[WKUserContentController alloc] init];
    
    KKWebViewElementScriptMessageHandler * object = [[KKWebViewElementScriptMessageHandler alloc] init];
    
    object.basePath = [self.viewContext basePath];
    object.element = self;
    
    [userContentController addScriptMessageHandler:object name:@"kk"];
    
    configuration.userContentController = userContentController;
    
    [configuration.preferences setJavaScriptCanOpenWindowsAutomatically:YES];
    [configuration.preferences setJavaScriptEnabled:YES];
    [configuration.preferences setMinimumFontSize:0];
    if (@available(iOS 9.0, *)) {
        [configuration setApplicationNameForUserAgent:[[KKHttp userAgent] stringByAppendingString:@" KK/1.0"]];
    } else {
    }
    
    @try {
        [configuration.preferences setValue:@TRUE forKey:@"allowFileAccessFromFileURLs"];
    }
    @catch (NSException *exception) {}
    
    @try {
        [configuration setValue:@TRUE forKey:@"allowUniversalAccessFromFileURLs"];
    }
    @catch (NSException *exception) {}
    
    if (@available(iOS 11.0, *)) {
        [configuration setURLSchemeHandler:object forURLScheme:@"app"];
    } else {
    }
    
    return configuration;
}

-(UIView *) createView {

    WKWebViewConfiguration * v = [self loadWebViewConfiguration];
    
    WKWebView * view = nil;
    
    if(v == nil) {
        view =  [[WKWebView alloc] initWithFrame:CGRectZero];
    } else {
        view = [[WKWebView alloc] initWithFrame:CGRectZero configuration:v];
    }
    
    return view;
    
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
    
    if([key isEqualToString:@"src"] || [key isEqualToString:@"#text"]) {
        [self setNeedsDisplay];
    }
}

-(void) display {
    
    NSString * uri = [[self get:@"src"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if(uri != nil ){
        
        NSURL * u = nil;
        
        if([uri containsString:@"://"]) {
           
            @try {
                u = [NSURL URLWithString:uri];
            }
            @catch(NSException *ex) {
                
            }
            
            if(u) {
                
                NSLog(@"[KK] [WEBVIEW] %@",u);
                
                NSMutableURLRequest * r = [NSMutableURLRequest requestWithURL:u];
                
                [r setValue:[KKHttp userAgent] forHTTPHeaderField:@"User-Agent"];
                
                NSArray<NSHTTPCookie *> * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:u];
                
                NSMutableString * s = [NSMutableString stringWithCapacity:4];
                
                for(NSHTTPCookie * cookie in cookies) {
                    [s appendFormat:@"%@=%@; ",cookie.name,cookie.value];
                }
                
                [r setValue:s forHTTPHeaderField:@"Cookie"];
                
                [self.webView loadRequest:[NSURLRequest requestWithURL:u]];
                
            }
            
        } else {
            NSString * path = [[self.viewContext basePath] stringByAppendingPathComponent:uri];
            NSString * code = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            if(code != nil ){
                [self.webView loadHTMLString:code baseURL:[NSURL URLWithString:@"app:///"]];
            }
        }
        
        
    } else {
        NSString * text = [self get:@"#text"];
        if([text length]) {
            [self.webView loadHTMLString:text baseURL:[NSURL URLWithString:@"app:///"]];
        }
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

-(void) emit:(NSString *) name event:(KKEvent *) event {
    
    if([name isEqualToString:@"evaluateJavaScript"]) {
        
        if([event isKindOfClass:[KKElementEvent class]]) {
            NSString * text = [[(KKElementEvent *) event data] kk_getString:@"text"];
            if([text length]) {
                [self.webView evaluateJavaScript:text completionHandler:nil];
            }
        }
        
        return;
    }
    
    [super emit:name event:event];
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
