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
    
    [KKViewContext setDefaultElementClass:[KKLoadingViewElement class] name:@"loading"];
}

-(instancetype) init {
    if((self = [super init])) {
        [self setAttrs:@{@"view":NSStringFromClass([UIActivityIndicatorView class]),@"hidden":@"false"}];
    }
    return self;
}

@end

@implementation UIActivityIndicatorView(KKElement)

-(void) KKViewElement:(KKViewElement *)element setProperty:(NSString *)key value:(NSString *)v {
    [super KKViewElement:element setProperty:key value:v];
    
    if([key isEqualToString:@"type"]) {
        
        if([v isEqualToString:@"large"]) {
            self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        } else if([v isEqualToString:@"gray"]) {
            self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        } else {
            self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        }
    } else if([key isEqualToString:@"hidden"]) {
        if(KKBooleanValue(v)) {
            [self stopAnimating];
            [self setHidden:YES];
        } else {
            [self setHidden:NO];
            [self startAnimating];
        }
    }
    
}
@end
