//
//  NSTimer+KKView.m
//  KKView
//
//  Created by zhanghailong on 2018/1/13.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "NSTimer+KKView.h"

@interface KKTimer : NSObject

@property(nonatomic,weak) id weakObject;
@property(nonatomic,strong) void (^block)(id weakObject);

-(void) doAction:(NSTimer *) timer;

@end

@implementation KKTimer

-(void) doAction:(NSTimer *) timer {
    if(_weakObject) {
        if(_block) {
            _block(_weakObject);
        }
    } else {
        [timer invalidate];
    }
}
       
@end

@implementation NSTimer (KKView)

+ (NSTimer *) kk_timerWithTimeInterval:(NSTimeInterval)ti func:(void (^)(id weakObject))block weakObject:(id) weakObject repeats:(BOOL)yesOrNo {
    KKTimer * timer = [[KKTimer alloc] init];
    timer.weakObject = weakObject;
    timer.block = block;
    
    return [NSTimer scheduledTimerWithTimeInterval:ti target:timer selector:@selector(doAction:) userInfo:nil repeats:yesOrNo];
}

@end
