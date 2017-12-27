//
//  KKScrollViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKScrollViewElement.h"

@interface KKScrollViewElement() <UIScrollViewDelegate>

@end

@implementation KKScrollViewElement

-(instancetype) init {
    if((self = [super init])) {
        [self set:@"view" value:@"UIScrollView"];
    }
    return self;
}

-(void) setView:(UIView *)view {
    [self.view removeObserver:self forKeyPath:@"contentOffset"];
    [(UIScrollView *) self.view setDelegate:nil];
    [super setView:view];
    [self.view addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [(UIScrollView *) self.view setDelegate:self];
}

-(void) dealloc {
    [self.view removeObserver:self forKeyPath:@"contentOffset"];
    [(UIScrollView *) self.view setDelegate:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(object == self.view && [keyPath isEqualToString:@"contentOffset"]) {
        self.contentOffset = [(UIScrollView *) self.view contentOffset];
    }
}

@end
