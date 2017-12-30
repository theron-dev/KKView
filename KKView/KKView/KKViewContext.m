//
//  KKViewContext.m
//  KKView
//
//  Created by hailong11 on 2017/12/28.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKViewContext.h"

#include <pthread.h>

static pthread_key_t gKKViewContextKey = 0;
static dispatch_once_t gKKViewContextOnce;

static void KKViewContextQueueDealloc(void * v) {
    if(v) {
        CFRelease((CFTypeRef) v);
    }
}

static NSMutableArray * KKViewContextQueue() {
    
    dispatch_once(&gKKViewContextOnce, ^{
        pthread_key_create(&gKKViewContextKey, KKViewContextQueueDealloc);
    });
    
    CFMutableArrayRef v = (CFMutableArrayRef) pthread_getspecific(gKKViewContextKey);
    
    if(v == nil) {
        v = CFArrayCreateMutable(NULL, 4, NULL);
        pthread_setspecific(gKKViewContextKey,v);
    }
    
    return (__bridge NSMutableArray *) v;
}

@implementation KKViewContext

-(UIImage *) imageWithURI:(NSString * ) uri {
    
    if([(id)_delegate respondsToSelector:@selector(KKViewContext:imageWithURI:)]) {
        UIImage * v  = [_delegate KKViewContext:self imageWithURI:uri];
        if(v != nil) {
            return v;
        }
    }
    
    if(uri == nil || [uri isEqualToString:@""]) {
        return nil;
    }
    
    if([uri hasPrefix:@"http://"] || [uri hasPrefix:@"https://"]) {
        return [KKHttp imageWithURL:uri];
    } else if([uri hasPrefix:@"/"]) {
        return [UIImage imageNamed:uri];
    } else if([uri hasPrefix:@"@"]) {
        return [UIImage imageNamed:[uri substringFromIndex:1]];
    } else {
        return [UIImage imageNamed:[_basePath stringByAppendingPathComponent:uri]];
    }
}

-(id<KKHttpTask>) send:(KKHttpOptions *) options weakObject:(id) weakObject  {
    
    if([(id) _delegate respondsToSelector:@selector(KKViewContext:willSend:)]) {
        [_delegate KKViewContext:self willSend:options];
    }
    
    if([(id)_delegate respondsToSelector:@selector(KKViewContext:send:weakObject:)]) {
        id<KKHttpTask> v = [_delegate KKViewContext:self send:options weakObject:weakObject];
        if(v) {
            return v;
        }
    }
    
    return [[KKHttp main] send:options weakObject:weakObject];
}

-(void) cancel:(id) weakObject {
    
    if([(id)_delegate respondsToSelector:@selector(KKViewContext:cancel:)]) {
        if( [_delegate KKViewContext:self cancel:weakObject]) {
            return ;
        }
    }
    
    [[KKHttp main] cancel:weakObject];
}

+(void) pushContext:(KKViewContext *) context {
    [KKViewContextQueue() addObject:context];
}

+(KKViewContext *) currentContext {
    return [KKViewContextQueue() lastObject];
}

+(void) popContext {
    [KKViewContextQueue() removeLastObject];
}

@end
