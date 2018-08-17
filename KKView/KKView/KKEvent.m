//
//  KKEvent.m
//  KKView
//
//  Created by zhanghailong on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKEvent.h"

@interface KKEventCallback :NSObject {
    
}

@property(nonatomic,strong) KKEventEmitterFunction fn;
@property(nonatomic,assign) void * context;

@end

@implementation KKEventCallback

@end

@interface KKEventEmitter() {
    NSMutableDictionary * _callbacks;
}

@end

@implementation KKEvent

@end

@implementation KKEventEmitter

-(void) on:(NSString *) name fn:(KKEventEmitterFunction) fn context:(void *) context {
    
    if(_callbacks == nil){
        _callbacks = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    NSMutableArray * cbs = [_callbacks valueForKey:name];
    
    if(cbs == nil) {
        cbs = [[NSMutableArray alloc] initWithCapacity:4];
        [_callbacks setValue:cbs forKey:name];
    }
    
    KKEventCallback * cb = [[KKEventCallback alloc] init];
    cb.fn = fn;
    cb.context = context;
    
    [cbs addObject:cb];
}

-(void) off:(NSString *) name fn:(KKEventEmitterFunction) fn context:(void *) context {
    if(name == nil && fn == nil && context == nil) {
        _callbacks = nil;
    } else if(name == nil) {
        NSEnumerator * keyEnum = [_callbacks keyEnumerator];
        NSString * key;
        while((key = [keyEnum nextObject])) {
            NSMutableArray * cbs = [_callbacks valueForKey:key];
            NSInteger i = 0;
            while(i < [cbs count]) {
                KKEventCallback * cb = [cbs objectAtIndex:0];
                if((fn == nil || fn == cb.fn) && (context == NULL || context == cb.context)) {
                    [cbs removeObjectAtIndex:i];
                    continue;
                }
                i ++;
            }
        }
    } else {
        NSMutableArray * cbs = [_callbacks valueForKey:name];
        NSInteger i = 0;
        while(i < [cbs count]) {
            KKEventCallback * cb = [cbs objectAtIndex:0];
            if((fn == nil || fn == cb.fn) && (context == NULL || context == cb.context)) {
                [cbs removeObjectAtIndex:i];
                continue;
            }
            i ++;
        }
    }
}

-(void) emit:(NSString *) name event:(KKEvent *) event {
    
    NSMutableArray * cbs = [_callbacks valueForKey:name];
    
    if(cbs != nil) {
        for(KKEventCallback * cb in [NSArray arrayWithArray:cbs]) {
            if(cb.fn) {
                cb.fn(event, cb.context);
            }
        }
    }
    
}

-(BOOL) hasEvent:(NSString *) name {
    return [[_callbacks valueForKey:name] count] > 0;
}

@end

