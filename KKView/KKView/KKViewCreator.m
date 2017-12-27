//
//  KKViewCreator.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKViewCreator.h"
#import "KKPixel.h"

//var attributeOn = function(page,document,e,attrs){

typedef void (^KKViewItemLoad) (id item);

static void KKViewOnAttribute(KKObserver * data, KKElement * e, NSDictionary * attrs) {
    
    NSEnumerator * keyEnum = [attrs keyEnumerator];
    
    NSString * key;
    
    __weak KKElement * element = e;
    
    while((key = [keyEnum nextObject])) {
        
        NSString * v = [attrs valueForKey:key];
        
        if([key hasPrefix:@":"]) {
            
            if([key isEqualToString:@":text"]) {
                
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    [element set:@"#text" value:KKStringValue(value)];
                    
                } evaluateScript:v context:nil];
                
            } else if([key isEqualToString:@":show"]) {
                
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    [element set:@"hidden" value:KKBooleanValue(value)?@"false":@"true"];
                    
                } evaluateScript:v context:nil];
                
            } else if([key isEqualToString:@":hide"]) {
                
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    [element set:@"hidden" value:KKBooleanValue(value)?@"true":@"false"];
                    
                } evaluateScript:v context:nil];
                
            } else {
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    [element set:[key substringFromIndex:1] value:KKStringValue(value)];
                    
                } evaluateScript:v context:nil];
            }
        } else if([key hasPrefix:@"style:"]) {
            [element setCSSStyle:v forStatus:[key substringFromIndex:6]];
        } else if([key isEqualToString:@"style"]) {
            [element setCSSStyle:v forStatus:@""];
        } else {
            [element set:key value:v];
        }
        
    }
}

void KKView(Class elementClass, NSDictionary * attrs, KKElement * p, KKObserver * data,KKViewChildren children) {
    
    NSString * v = [attrs valueForKey:@":for"];
    
    if([v length] == 0) {
        KKElement * e = [[elementClass alloc] init];
        KKViewOnAttribute(data,e,attrs);
        [p append:e];
        if(children){
            children(e,data);
        }
    } else {
        
        NSString * key = @"item";
        NSString * evaluateScript = v;
        
        NSRange r = [v rangeOfString:@" in "];
        
        if(r.location != NSNotFound) {
            key = [[v substringWithRange:NSMakeRange(0, r.location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            evaluateScript = [v substringWithRange:NSMakeRange(r.location + r.length, [v length] - r.location - r.length)];
        }
        
        __weak KKElement * parent = p;
        __block NSMutableArray * elements = [NSMutableArray arrayWithCapacity:4];
        __strong NSMutableDictionary * mattrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
        
        [mattrs removeObjectForKey:@":for"];
        
        KKObserverFunction reloadData = ^(id value, NSArray *changedKeys, void *context) {
            
            __block NSInteger i = 0;
            
            KKViewItemLoad itemLoad = ^(id item){
                
                KKElement * e;
                if(i < [elements count]) {
                    e = [elements objectAtIndex:i];
                } else {
                    e = [[elementClass alloc] init];
                    [e.kk_Observer setParent:data];
                    KKViewOnAttribute(e.kk_Observer,e,mattrs);
                    if(children){
                        children(e,e.kk_Observer);
                    }
                    [parent append:e];
                    [elements addObject:e];
                }
                
                [e.kk_Observer set:@[key] value:item];
                
                i ++;
                
            };
            
            if([value isKindOfClass:[NSArray class]]) {
                
                for(id item in value) {
                    itemLoad(item);
                }
                
            } else if([value isKindOfClass:[NSDictionary class]]) {
                NSEnumerator * keyEnum = [value keyEnumerator];
                NSString * key;
                while((key = [keyEnum nextObject])) {
                    id item = [value valueForKey:key];
                    itemLoad(item);
                }
            }
            
            while(i < [elements count]) {
                KKElement * e = [elements lastObject];
                [e.kk_Observer off:nil keys:@[] context:nil];
                [e remove];
                [elements removeLastObject];
            }
            
        };
        
        [data on:reloadData evaluateScript:evaluateScript context:nil];
        
    }
}
