//
//  KKSelectElement.m
//  KKView
//
//  Created by hailong11 on 2018/9/6.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKSelectElement.h"

@implementation KKSelectElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKSelectElement class] name:@"select"];
    [KKViewContext setDefaultElementClass:[KKElement class] name:@"option"];
    
}

@end
