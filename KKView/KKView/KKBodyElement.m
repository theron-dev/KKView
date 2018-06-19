//
//  KKBodyElement.m
//  KKView
//
//  Created by hailong11 on 2018/1/2.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKBodyElement.h"
#import "KKViewContext.h"

@implementation KKBodyElement

+(void) initialize{
    [KKViewContext setDefaultElementClass:[KKBodyElement class] name:@"body"];
}

-(void) dealloc {
    [self.view removeObserver:self forKeyPath:@"contentSize"];
    [self.view removeObserver:self forKeyPath:@"contentOffset"];
}

-(void) obtainView:(UIView *) view {
    
    if(self.view == view) {
        [self obtainChildrenView];
        return;
    }
    
    [self recycleView];
    
    [view addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [view addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [view KKElementObtainView:self];
    
    [self setView:view];
    
    [self changedKeys:[self keys]];
    
    [self obtainChildrenView];
}

-(void) recycleView {
    
    if(self.view != nil) {
        
        [self.view removeObserver:self forKeyPath:@"contentSize"];
        [self.view removeObserver:self forKeyPath:@"contentOffset"];
        [self.view KKElementRecycleView:self];
        
        self.view = nil;
        
        KKElement * p = self.firstChild;
        while(p) {
            if([p isKindOfClass:[KKViewElement class]]) {
                [(KKViewElement *) p recycleView];
            }
            p = p.nextSibling;
        }
    }
    
}

-(void) didLayouted {
    [self obtainChildrenView];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(object == self.view) {
        self.contentSize = [(UIScrollView *) self.view contentSize];
        self.contentOffset = [(UIScrollView *) self.view contentOffset];
    }
}

@end
