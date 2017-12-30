//
//  KKEvent.m
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKEvent.h"

@interface KKEventCallback :NSObject {
    
}

@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) KKEventEmitterFunction fn;
@property(nonatomic,assign) void * context;

@end

@implementation KKEventCallback

@end

@interface KKEventEmitter() {
    NSMutableArray * _callbacks;
}

@end

@implementation KKEvent

@end

@implementation KKEventEmitter

-(void) on:(NSString *) name fn:(KKEventEmitterFunction) fn context:(void *) context {
    KKEventCallback * cb = [[KKEventCallback alloc] init];
    cb.name = name;
    cb.fn = fn;
    cb.context = context;
    if(_callbacks == nil) {
        _callbacks = [NSMutableArray arrayWithCapacity:4];
    }
    [_callbacks addObject:cb];
}

-(void) off:(NSString *) name fn:(KKEventEmitterFunction) fn context:(void *) context {
    NSInteger i = 0;
    while(i < [_callbacks count]) {
        KKEventCallback * cb = [_callbacks objectAtIndex:0];
        if((name == nil || [name isEqualToString:cb.name])
           && (fn == nil || fn == cb.fn) && (context == NULL || context == cb.context)) {
            [_callbacks removeObjectAtIndex:i];
            continue;
        }
        i ++;
    }
}

-(void) emit:(NSString *) name event:(KKEvent *) event {
    NSMutableArray * cbs = [NSMutableArray arrayWithCapacity:4];
    for(KKEventCallback * cb in _callbacks) {
        if([name isEqualToString:cb.name]) {
            [cbs addObject:cb];
        }
    }
    for(KKEventCallback * cb in cbs) {
        if(cb.fn) {
            cb.fn(event, cb.context);
        }
    }
}

@end

