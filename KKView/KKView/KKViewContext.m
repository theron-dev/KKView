//
//  KKViewContext.m
//  KKView
//
//  Created by zhanghailong on 2017/12/28.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKViewContext.h"
#import "KKPagerViewElement.h"
#import "KKTextElement.h"
#import "KKImageElement.h"
#import "KKControlViewElement.h"
#import "KKLoadingViewElement.h"
#import "KKSwitchViewElement.h"
#import "KKQRElement.h"
#import "KKQRCaptureElement.h"
#import "KKBodyElement.h"
#import "KKKeyboardElement.h"
#import "KKTopbarElement.h"
#import "KKAnimationElement.h"
#import "KKInputElement.h"
#import "KKSlideViewElement.h"
#import "KKAudioElement.h"
#import "KKWebViewElement.h"

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

+(void) initialize {
    
    [KKPagerViewElement class];
    [KKTextElement class];
    [KKSpanElement class];
    [KKImgElement class];
    [KKImageElement class];
    [KKControlViewElement class];
    [KKLoadingViewElement class];
    [KKSwitchViewElement class];
    [KKQRElement class];
    [KKQRCaptureElement class];
    [KKBodyElement class];
    [KKKeyboardElement class];
    [KKTopbarElement class];
    [KKAnimationElement class];
    [KKInputElement class];
    [KKSlideViewElement class];
    [KKAudioElement class];
    [KKWebViewElement class];
}

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
        return [UIImage kk_imageWithPath:uri];
    } else if([uri hasPrefix:@"@"]) {
        return [UIImage kk_imageWithPath:[uri substringFromIndex:1]];
    } else {
        return [UIImage kk_imageWithPath:[_basePath stringByAppendingPathComponent:uri]];
    }
}
    
-(BOOL) imageWithURI:(NSString * ) uri callback:(KKHttpImageCallback) callback {
    
    if([(id)_delegate respondsToSelector:@selector(KKViewContext:imageWithURI:callback:)]) {
        if([_delegate KKViewContext:self imageWithURI:uri callback:callback]) {
            return YES;
        }
    }
    
    if(uri == nil || [uri isEqualToString:@""]) {
        return NO;
    }
    
    NSString * path = nil;
    
    if([uri hasPrefix:@"http://"] || [uri hasPrefix:@"https://"]) {
        return [KKHttp imageWithURL:uri callback:callback];
    } else if([uri hasPrefix:@"/"]) {
        path = uri;
    } else if([uri hasPrefix:@"@"]) {
        if(callback) {
            dispatch_async(KKHttpIODispatchQueue(), ^{
                UIImage * image = [UIImage kk_imageWithPath:[uri substringFromIndex:1]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(image);
                });
            });
        }
        return YES;
    } else {
        path = [_basePath stringByAppendingPathComponent:uri];
    }
    
    if(path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if(callback) {
            dispatch_async(KKHttpIODispatchQueue(), ^{
                UIImage * image = [UIImage kk_imageWithPath:path];
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(image);
                });
            });
        }
        return YES;
    }
    
    return NO;
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

+(void) setDefaultElementClass:(Class) elementClass name:(NSString *) name {
    [[self defaultElementClass] setObject:NSStringFromClass(elementClass) forKey:name];
}

+(NSMutableDictionary *) defaultElementClass {
    static NSMutableDictionary * v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [[NSMutableDictionary alloc] init];
    });
    return v;
}


@end
