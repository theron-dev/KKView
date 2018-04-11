//
//  KKElementView.m
//  KKView
//
//  Created by hailong11 on 2018/2/23.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKElementView.h"

@interface KKElementView() {
    KKEventEmitterFunction _onLayout;
}

@end

@implementation KKElementView

-(instancetype) init {
    if((self = [super init])) {
        
        __weak KKElementView * v = self;
        
        _onLayout = ^(KKEvent *event, void *context) {
            
            if(v && [event isKindOfClass:[KKElementEvent class]]) {
                
                NSDictionary * data = [(KKElementEvent *) event data];
                
                BOOL animated = [[data valueForKey:@"animated"] boolValue];
                
                if(animated) {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.3];
                }
                
                [v.element layout:v.bounds.size];
                [v.element obtainView:v];
                
                if(animated) {
                    [UIView commitAnimations];
                }
            }
        };
        
    }
    return self;
}

-(void) dealloc {
    [_element recycleView];
    [_element off:@"layout" fn:_onLayout context:nil];
}

-(void) setElement:(KKViewElement *)element {
    if(_element != element) {
        [_element recycleView];
        [_element off:@"layout" fn:_onLayout context:nil];
        _element = element;
        [_element on:@"layout" fn:_onLayout context:nil];
        [self setNeedsLayout];
    }
}

-(void) layoutSubviews{
    [super layoutSubviews];
    [_element layout:self.bounds.size];
    [_element obtainView:self];
}

@end
