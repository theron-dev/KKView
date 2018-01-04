//
//  KKLoadingViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKLoadingViewElement.h"
#import "KKViewContext.h"

@implementation KKLoadingViewElement

+(void) initialize{
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKLoadingViewElement class] name:@"loading"];
}

-(instancetype) init {
    if((self = [super init])) {
        [self setAttrs:@{@"view":NSStringFromClass([UIActivityIndicatorView class])}];
    }
    return self;
}

-(void) changedKey:(NSString *)key{
    [super changedKey:key];
    
    if([key isEqualToString:@"type"]) {
        
        NSString * v = [self get:key];
        
        UIActivityIndicatorView * loadingView = (UIActivityIndicatorView *) self.view;
        
        if([v isEqualToString:@"large"]) {
            loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        } else if([v isEqualToString:@"gray"]) {
            loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        } else {
            loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        }
    } else if([key isEqualToString:@"hidden"]) {
        NSString * v = [self get:key];
        UIActivityIndicatorView * loadingView = (UIActivityIndicatorView *) self.view;
        if(KKBooleanValue(v)) {
            [loadingView stopAnimating];
            [loadingView setHidden:YES];
        } else {
            [loadingView setHidden:NO];
            [loadingView startAnimating];
        }
    }
    
}

@end
