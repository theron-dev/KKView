//
//  JSContext+KKView.m
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "JSContext+KKView.h"
#import "KKPagerViewElement.h"
#import "KKTextElement.h"
#import "KKImageElement.h"
#import "KKControlViewElement.h"
#import "KKLoadingViewElement.h"
#import "KKSwitchViewElement.h"

@implementation JSContext (KKView)

+(NSDictionary *) defaultElementClass {
    static NSDictionary * v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = @{
              @"view":NSStringFromClass([KKViewElement class]),
              @"text":NSStringFromClass([KKTextElement class]),
              @"span":NSStringFromClass([KKSpanElement class]),
              @"img":NSStringFromClass([KKImgElement class]),
              @"image":NSStringFromClass([KKImageElement class]),
              @"scroll":NSStringFromClass([KKScrollViewElement class]),
              @"pager":NSStringFromClass([KKPagerViewElement class]),
              @"button":NSStringFromClass([KKControlViewElement class]),
              @"loading":NSStringFromClass([KKLoadingViewElement class]),
              @"switch":NSStringFromClass([KKSwitchViewElement class]),
              };
    });
    return v;
}

-(void) KKViewOpenlib {
    [self KKViewOpenlib:[[self class] defaultElementClass]];
}

-(void) KKViewOpenlib:(NSDictionary *) elementClass {
    
    self[@"View"] = ^(NSString * name,NSDictionary * attrs,KKElement * parent,KKObserver * data,JSValue * fn) {
        
        Class isa = NSClassFromString([elementClass valueForKey:name]);
        
        if(isa == nil) {
            isa = [KKElement class];
        }
        
        KKView(isa, attrs, parent, data, ^(KKElement *p, KKObserver *data) {
            if(fn) {
                [fn callWithArguments:@[p,data]];
            }
        });
    };
    
}

@end
