//
//  KKImageElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKImageElement.h"
#import <KKHttp/KKHttp.h>

static CGSize KKImageElementLayout(KKViewElement * element);


@interface KKImageElement() {
    BOOL _displaying;
    KKHttpTask * _imageTask;
    KKHttpTask * _defaultTask;
    KKHttpTask * _failTask;
}

-(void) setNeedsDisplay;

@end

@implementation KKImageElement

@synthesize image = _image;
@synthesize defaultImage = _defaultImage;
@synthesize failImage = _failImage;

-(instancetype) init{
    if((self = [super init])) {
        [super setLayout:KKImageElementLayout];
        [self set:@"view" value:@"UIImageView"];
    }
    return self;
}
-(void) dealloc {
    
    [_imageTask cancel];
    [_defaultTask cancel];
    [_failTask cancel];
    
}
-(NSString *) src {
    return [self get:@"src"];
}

-(NSString *) defaultSrc {
    return [self get:@"default-src"];
}

-(NSString *) failSrc {
    return [self get:@"fail-src"];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    if([@"src" isEqualToString:key]) {
        NSString * v = [self get:key];
        if([v hasPrefix:@"http://"]){
            NSLog(@"%@",v);
        }
        self.image = nil;
        [self setNeedsDisplay];
    } else if([@"default-src" isEqualToString:key]) {
        self.defaultImage = nil;
        [self setNeedsDisplay];
    } else if([@"faile-src" isEqualToString:key]) {
        self.failImage = nil;
        [self setNeedsDisplay];
    }
}

-(UIImage *) image {
    
    if(_image == nil && _imageTask == nil && _error == nil) {
        NSString * v = [self src];
        if([v length]) {
            if([v hasPrefix:@"http://"] || [v hasPrefix:@"https://"]) {

                KKHttpOptions * options = [[KKHttpOptions alloc] initWithURL:v];
                options.type = KKHttpOptionsTypeImage;
                options.method = KKHttpOptionsGET;
                options.onfail = ^(NSError *error, id weakObject) {
                    if(weakObject) {
                        KKImageElement * e = (KKImageElement *) weakObject;
                        [e setError:error];
                    }
                };
                options.onload = ^(id data, NSError *error, id weakObject) {
                    if(weakObject) {
                        KKImageElement * e = (KKImageElement *) weakObject;
                        if(error) {
                            [e setError:error];
                        } else if(data){
                            [e setImage:(UIImage *) data];
                        } else {
                            [e setError:[NSError errorWithDomain:@"KKImageElement" code:0 userInfo:@{NSLocalizedDescriptionKey:@"图片格式错误"}]];
                        }
                    }
                };
                
                _imageTask = [[KKHttp main] send:options weakObject:self];
                
            } else {
                _image = [UIImage imageNamed:v];
            }
        }
    }
    
    if(_image == nil) {
        
        UIImage * v = _image;
        
        if(self.error) {
            v = self.failImage;
        }
        
        if(v == nil) {
            v = self.defaultImage;
        }
        
        return v;
    }
    
    return _image;
}

-(void) setImage:(UIImage *)image {
    _image = image;
    _error = nil;
    if(_imageTask) {
        [_imageTask cancel];
        _imageTask = nil;
    }
    [self setNeedsDisplay];
}

-(UIImage *) defaultImage {
    
    if(_defaultImage == nil && _defaultTask == nil) {
        NSString * v = [self defaultSrc];
        if([v length]) {
            if([v hasPrefix:@"http://"] || [v hasPrefix:@"https://"]) {
                KKHttpOptions * options = [[KKHttpOptions alloc] initWithURL:v];
                options.type = KKHttpOptionsTypeImage;
                options.method = KKHttpOptionsGET;
                options.onload = ^(id data, NSError *error, id weakObject) {
                    if(weakObject) {
                        KKImageElement * e = (KKImageElement *) weakObject;
                        if(error == nil) {
                            [e setDefaultImage:(UIImage *) data];
                        }
                    }
                };
                
                _defaultTask = [[KKHttp main] send:options weakObject:self];
                
            } else {
                _defaultImage = [UIImage imageNamed:v];
            }
        }
    }
    return _defaultImage;
}

-(void) setDefaultImage:(UIImage *)defaultImage {
    _defaultImage = defaultImage;
    if(_defaultTask) {
        [_defaultTask cancel];
        _defaultTask = nil;
    }
    [self setNeedsDisplay];
}

-(UIImage *) failImage {
    
    if(_failImage == nil && _failTask == nil) {
        NSString * v = [self failSrc];
        if([v length]) {
            if([v hasPrefix:@"http://"] || [v hasPrefix:@"https://"]) {
                KKHttpOptions * options = [[KKHttpOptions alloc] initWithURL:v];
                options.type = KKHttpOptionsTypeImage;
                options.method = KKHttpOptionsGET;
                options.onload = ^(id data, NSError *error, id weakObject) {
                    if(weakObject) {
                        KKImageElement * e = (KKImageElement *) weakObject;
                        if(error == nil) {
                            [e setFailImage:(UIImage *) data];
                        }
                    }
                };
                
                _defaultTask = [[KKHttp main] send:options weakObject:self];
            } else {
                _failImage = [UIImage imageNamed:v];
            }
        }
    }
    return _failImage;
}

-(void) setFailImage:(UIImage *)failImage {
    _failImage = failImage;
    if(_failTask) {
        [_failTask cancel];
        _failTask = nil;
    }
    [self setNeedsDisplay];
}

-(void) setNeedsDisplay {
    
    if(_displaying || self.view == nil) {
        return;
    }
    
    _displaying = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImageView * v = (UIImageView *) self.view;
        
        if([v isKindOfClass:[UIImageView class]]) {
            v.image = self.image;
        };
        
        _displaying = false;
    });
}

-(void) setLayout:(KKViewElementLayout)layout {
    [super setLayout:KKImageElementLayout];
}

@end


static CGSize KKImageElementLayout(KKViewElement * element) {
    
    CGSize size = element.frame.size;
    
    if(size.width == MAXFLOAT || size.height == MAXFLOAT) {
        KKImageElement * e = (KKImageElement *) element;
        CGSize s = e.image.size;
        if(size.width == MAXFLOAT && size.height) {
            size.width = s.width;
            size.height = s.height;
        } else if(size.width == MAXFLOAT) {
            if(s.height == 0) {
                size.width = 0;
            } else {
                size.width = size.height * s.width / s.height;
            }
        } else if(size.height == MAXFLOAT) {
            if(s.width == 0) {
                size.height = 0;
            } else {
                size.height = size.width * s.height / s.width;
            }
        }

    }
    
    return size;
}


@implementation UIImageView (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
    
    if([key isEqualToString:@"gravity"]) {
        self.layer.contentsGravity = value;
    }
}

@end

