//
//  UIView+BackgroundImage.h
//  KKView
//
//  Created by zhanghailong on 2018/1/15.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BackgroundImage)

@property(nonatomic,strong) UIImage * kk_backgroundImage;
@property(nonatomic,strong,readonly) CAGradientLayer * kk_backgroundGradientLayer;

-(void) kk_backgroundGradientLayerLayout;

-(void) kk_backgroundGradientLayerClear;

@end
