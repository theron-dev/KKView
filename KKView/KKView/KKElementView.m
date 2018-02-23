//
//  KKElementView.m
//  KKView
//
//  Created by hailong11 on 2018/2/23.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKElementView.h"

@implementation KKElementView

-(void) setElement:(KKViewElement *)element {
    if(_element != element) {
        [_element recycleView];
        _element = element;
        [_element obtainView:self];
        [self setNeedsLayout];
    }
}

-(void) layoutSubviews{
    [super layoutSubviews];
    [_element layout:self.bounds.size];
}

@end
