//
//  KKScrollViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKScrollViewElement.h"

enum KKScrollViewElementScrollType {
    KKScrollViewElementScrollTypeNone,KKScrollViewElementScrollTypeTop,KKScrollViewElementScrollTypeBottom
} ;

@interface KKScrollViewElement() <UIScrollViewDelegate> {
    enum KKScrollViewElementScrollType _scrollType;
}

@end

@implementation KKScrollViewElement

-(instancetype) init {
    if((self = [super init])) {
        [self set:@"view" value:@"UIScrollView"];
    }
    return self;
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    
    if([@"taptop" isEqualToString:key]) {
        _taptop = KKPixelFromString([self get:key]);
    } else if([@"tapbottom" isEqualToString:key]) {
        _tapbottom = KKPixelFromString([self get:key]);
    }
    
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
        
        {
            CGFloat top = KKPixelValue(_taptop, self.frame.size.height, 0);
            CGFloat bottom = KKPixelValue(_tapbottom, self.frame.size.height, 0);
            
            if(top >0 && self.contentOffset.y <0 && - self.contentOffset.y >= top) {
                
                if(_scrollType == KKScrollViewElementScrollTypeNone) {
                    
                    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
                    
                    e.data = [self data];
                    
                    [self emit:@"taptop" event:e];
                    
                    _scrollType = KKScrollViewElementScrollTypeTop;
                }
                
            } else if(bottom > 0
                      && self.contentSize.height > self.frame.size.height
                      && self.contentOffset.y > self.contentSize.height - self.frame.size.height
                      && (self.contentOffset.y - self.contentSize.height + self.frame.size.height) >= (bottom - 1) )
            {
                
                if(_scrollType == KKScrollViewElementScrollTypeNone) {
                    
                    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
                    
                    e.data = [self data];
                    
                    [self emit:@"tapbottom" event:e];
                    
                    _scrollType = KKScrollViewElementScrollTypeBottom;
                }
                
            }
        }
        
    }
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _scrollType = KKScrollViewElementScrollTypeNone;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _scrollType = KKScrollViewElementScrollTypeNone;
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        _scrollType = KKScrollViewElementScrollTypeNone;
    }
}

-(void) addSubview:(UIView *) view toView:(UIView *) toView {
    [toView insertSubview:view atIndex:0];
}

@end
