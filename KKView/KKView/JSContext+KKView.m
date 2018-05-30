//
//  JSContext+KKView.m
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "JSContext+KKView.h"
#include "KKViewContext.h"

@implementation JSContext (KKView)


-(void) KKViewOpenlib {
    [self KKViewOpenlib:[KKViewContext defaultElementClass]];
}

-(void) KKViewOpenlib:(NSDictionary *) elementClass {
    
    self[@"View"] = ^(NSString * name,NSDictionary * attrs,KKElement * parent,KKJSObserver * data,JSValue * fn) {
        
        Class isa = NSClassFromString([elementClass valueForKey:name]);
        
        if(isa == nil) {
            isa = [KKElement class];
        }
        
        KKView(isa, attrs, parent, data, ^(KKElement *p, KKJSObserver *data) {
            if([fn isObject]) {
                @try{
                    [fn callWithArguments:@[p,data]];
                }
                @catch(NSException * ex) {
                    NSLog(@"[KK] %@",ex);
                }
            }
        });
    };
    
}

@end
