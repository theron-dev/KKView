//
//  KKKeyboardElement.m
//  KKView
//
//  Created by 张海龙 on 2018/2/21.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKKeyboardElement.h"
#import <UIKit/UIKit.h>

@implementation KKKeyboardElement

-(instancetype) init {
    if((self  = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisible:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisible:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void) keyboardVisible:(NSNotification *) notification {
    CGRect bounds
}

-(void) keyboardHidden:(NSNotification *) notification {
    
}

@end
