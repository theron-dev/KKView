//
//  KKTopbarElement.m
//  KKView
//
//  Created by hailong11 on 2018/2/23.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKTopbarElement.h"
#import "KKViewContext.h"

@implementation KKTopbarElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKTopbarElement class] name:@"topbar"];
}

@end
