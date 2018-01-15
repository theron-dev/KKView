//
//  UIView+BackgroundImage.m
//  KKView
//
//  Created by hailong11 on 2018/1/15.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "UIView+BackgroundImage.h"
#include <objc/runtime.h>

@implementation UIView (BackgroundImage)

-(UIImage *) kk_backgroundImage {
    UIImageView * imageView = objc_getAssociatedObject(self, "_kk_backgroundImageView");
    return [imageView image];
}

-(void) setKk_backgroundImage:(UIImage *)kk_backgroundImage {
    UIImageView * imageView = objc_getAssociatedObject(self, "_kk_backgroundImageView");
    if(imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [imageView setUserInteractionEnabled:NO];
        [self insertSubview:imageView atIndex:0];
        objc_setAssociatedObject(self, "_kk_backgroundImageView", imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    imageView.image = kk_backgroundImage;
    imageView.hidden = kk_backgroundImage == nil;
}

@end
