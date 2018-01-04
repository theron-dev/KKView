//
//  KKQRElement.m
//  KKView
//
//  Created by hailong11 on 2018/1/1.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKQRElement.h"
#import "KKViewContext.h"

@interface KKQRElement() {
    BOOL _displaying;
}

@end

@implementation KKQRElement

@synthesize image = _image;

+(void) initialize {
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKQRElement class] name:@"qr"];
}

-(instancetype) init {
    if((self = [super init])) {
        [self set:@"view" value:@"UIImageView"];
    }
    return self;
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    if([key isEqualToString:@"#text"]) {
        [self setNeedsDisplay];
    } else if([key isEqualToString:@"color"]) {
        [self setNeedsDisplay];
    }
}

-(UIImage *) image {
    
    if(_image == nil) {
        
        NSString * text = [self get:@"#text"];
        
        if(text == nil) {
            text = @"";
        }
        
        NSData *data_qr = [text dataUsingEncoding:NSUTF8StringEncoding];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        
        [filter setValue:data_qr forKey:@"inputMessage"];
        
        _image = [UIImage imageWithCIImage:[filter outputImage]];
        
    }
    
    return _image;
}

-(void) setNeedsDisplay {
    
    if(_displaying) {
        return;
    }
    
    _image = nil;
    _displaying = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImageView * v = (UIImageView *) self.view;
        
        v.image = self.image;
        
        _displaying = NO;
    });
}

@end
