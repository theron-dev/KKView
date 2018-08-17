//
//  NSTimer+KKView.h
//  KKView
//
//  Created by zhanghailong on 2018/1/13.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (KKView)

+ (NSTimer *) kk_timerWithTimeInterval:(NSTimeInterval)ti func:(void (^)(id weakObject))block weakObject:(id) weakObject repeats:(BOOL)yesOrNo;

@end
