//
//  KKViewCreator.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKViewCreator.h"
#import "KKPixel.h"
#import "KKViewContext.h"

typedef void (^KKViewItemLoad) (id idx,id item);

static void KKViewOnEvent(KKObserver * data, KKElement * e, NSString * name, NSArray * keys) {
    
    __weak KKObserver * v = data;
    
    [e on:name fn:^(KKEvent *event, void *context) {
        
        if([event isKindOfClass:[KKElementEvent class]]) {
            KKElementEvent * e = (KKElementEvent *) event;
            KKObserver * p = v;
            while(p && p.parent) {
                p = p.parent;
            }
            [p set:keys value:e.data];
        }
        
    } context:nil];
    
}

static void KKViewOnAttribute(KKObserver * data, KKElement * e, NSDictionary * attrs) {
    
    NSEnumerator * keyEnum = [attrs keyEnumerator];
    
    NSString * key;
    
    __weak KKElement * element = e;
    
    while((key = [keyEnum nextObject])) {
        
        NSString * v = [attrs valueForKey:key];
        
        if([key hasPrefix:@"kk:"]) {
            
            if([key isEqualToString:@"kk:text"]) {
                
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    if(value != nil) {
                        [element set:@"#text" value:KKStringValue(value)];
                    }
                    
                } evaluateScript:v context:nil];
                
            } else if([key isEqualToString:@"kk:show"]) {
                
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    if(value != nil) {
                        [element set:@"hidden" value:KKBooleanValue(value)?@"false":@"true"];
                    }
                    
                } evaluateScript:v context:nil];
                
            } else if([key isEqualToString:@"kk:hide"]) {
                
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    if(value != nil) {
                        [element set:@"hidden" value:KKBooleanValue(value)?@"true":@"false"];
                    }
                    
                } evaluateScript:v context:nil];
            } else if([key hasPrefix:@"kk:on"]) {
                
                KKViewOnEvent(data,e,[key substringFromIndex:5],[v componentsSeparatedByString:@"."]);
                
            } else {
                [data on:^(id value, NSArray *changedKeys, void *context) {
                    
                    if(value != nil) {
                        [element set:[key substringFromIndex:3] value:KKStringValue(value)];
                    }
                    
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

void KKViewOnFor(NSString * evaluate, Class elementClass, NSDictionary * attrs, KKElement * p, KKObserver * data,KKViewChildren children) {
    
    KKViewContext * viewContext = [KKViewContext currentContext];
    
    NSString * index = @"index";
    NSString * key = @"item";
    NSString * evaluateScript = evaluate;
    
    NSRange r = [evaluate rangeOfString:@" in "];
    
    if(r.location != NSNotFound) {
        key = [[evaluate substringWithRange:NSMakeRange(0, r.location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        evaluateScript = [evaluate substringWithRange:NSMakeRange(r.location + r.length, [evaluate length] - r.location - r.length)];
        r = [key rangeOfString:@","];
        if(r.location != NSNotFound) {
            index = [[key substringToIndex:r.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            key = [[key substringFromIndex:r.location + r.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    __weak KKElement * parent = p;
    __block NSMutableArray * elements = [NSMutableArray arrayWithCapacity:4];
    __block NSMutableArray * observers = [NSMutableArray arrayWithCapacity:4];
    
    KKObserverFunction reloadData = ^(id value, NSArray *changedKeys, void *context) {
        
        if(viewContext) {
            [KKViewContext pushContext:viewContext];
        }
        
        __block NSInteger i = 0;
        
        KKViewItemLoad itemLoad = ^(id idx, id item){
            
            KKElement * e;
            KKObserver * obs;
            if(i < [elements count]) {
                e = [elements objectAtIndex:i];
                obs = [observers objectAtIndex:i];
            } else {
                e = [[elementClass alloc] init];
                obs = [data newObserver];
                KKViewOnAttribute(obs,e,attrs);
                if(children){
                    children(e,obs);
                }
                [parent append:e];
                [elements addObject:e];
                [observers addObject:obs];
                [obs setParent:data];
            }
            
            [obs set:@[index] value:idx];
            [obs set:@[key] value:item];
            
            i ++;
            
        };
        
        if([value isKindOfClass:[NSArray class]]) {
            
            NSInteger idx = 0;
            
            for(id item in value) {
                itemLoad(@(idx),item);
                idx ++;
            }
            
        } else if([value isKindOfClass:[NSDictionary class]]) {
            NSEnumerator * keyEnum = [value keyEnumerator];
            NSString * key;
            while((key = [keyEnum nextObject])) {
                id item = [value valueForKey:key];
                itemLoad(key,item);
            }
        }
        
        while(i < [elements count]) {
            KKElement * e = [elements lastObject];
            KKObserver * obs = [observers lastObject];
            [obs off:nil keys:@[] context:nil];
            [e remove];
            [elements removeLastObject];
            [observers removeLastObject];
        }
        
        if(viewContext) {
            [KKViewContext popContext];
        }
    };
    
    [data on:reloadData evaluateScript:evaluateScript context:nil];
    
}

void KKView(Class elementClass, NSDictionary * attrs, KKElement * p, KKObserver * data,KKViewChildren children) {
    
    NSString * v = [attrs valueForKey:@"kk:for"];
    
    if([v length] > 0) {
        
        NSMutableDictionary * mattrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
        
        [mattrs removeObjectForKey:@"kk:for"];
        
        KKViewOnFor(v,elementClass, mattrs, p, data, children);
        
    } else {
        KKElement * e = [[elementClass alloc] init];
        KKViewOnAttribute(data,e,attrs);
        [p append:e];
        if(children){
            children(e,data);
        }
    }
}
