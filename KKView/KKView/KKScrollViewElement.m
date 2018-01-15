//
//  KKScrollViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKScrollViewElement.h"
#import "KKViewContext.h"
#include <objc/runtime.h>

enum KKScrollViewElementScrollType {
    KKScrollViewElementScrollTypeNone,
    KKScrollViewElementScrollTypeTop,
    KKScrollViewElementScrollTypeBottom
} ;

@interface KKScrollViewElement() <UIScrollViewDelegate> {
    enum KKScrollViewElementScrollType _scrollType;
}

@end

@implementation KKScrollViewElement

+(void) initialize{
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKScrollViewElement class] name:@"scroll"];
}

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
    if (@available(iOS 11.0, *)) {
        ((UIScrollView *) self.view).contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
    }
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
                    
                    [self emit:@"taptoping" event:e];
                    
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
                    
                    [self emit:@"tapbottoming" event:e];
                    
                    _scrollType = KKScrollViewElementScrollTypeBottom;
                }
                
            }
        }
        
    }
}

-(void) scrollViewDidEndScrolling {
    if(_scrollType == KKScrollViewElementScrollTypeTop) {
        KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
        e.data = [self data];
        [self emit:@"taptop" event:e];
    } else if(_scrollType == KKScrollViewElementScrollTypeBottom) {
        KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
        e.data = [self data];
        [self emit:@"tapbottom" event:e];
    }
    _scrollType = KKScrollViewElementScrollTypeNone;
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrolling];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self scrollViewDidEndScrolling];
}

-(void) addSubview:(UIView *) view element:(KKViewElement *) element toView:(UIView *) toView {
    NSString * v = [element get:@"floor"];
    if([v isEqualToString:@"front"]) {
        [toView addSubview:view];
    } else {
        [toView insertSubview:view atIndex:0];
    }
}

-(void) addSubview:(UIView *) view toView:(UIView *) toView {
    [toView insertSubview:view atIndex:0];
}

-(BOOL) isChildrenVisible:(KKViewElement *) element {
    
    switch (element.position) {
        case KKPositionTop:
        {
            CGPoint p = self.contentOffset;
            struct KKEdge margin = element.margin;
            CGFloat mtop = KKPixelValue(margin.top, 0, 0);
            CGRect frame = element.frame;
            frame.origin.y = p.x + mtop;
            element.frame = frame;
        }
            break;
        case KKPositionBottom:
        {
            CGPoint p = self.contentOffset;
            CGRect frame = element.frame;
            struct KKEdge margin = element.margin;
            
            CGFloat mtop = KKPixelValue(margin.top, 0, 0);
            CGFloat mbottom = KKPixelValue(margin.bottom, 0, 0);
            
            struct KKEdge padding = self.padding;
            CGFloat pbottom = KKPixelValue(padding.bottom, 0, 0);
            
            if(frame.origin.y + frame.size.height + mtop + mbottom - p.y < self.frame.size.height - pbottom) {
                CGFloat y = p.y + self.frame.size.height - pbottom - frame.size.height - mbottom;
                element.translate = CGPointMake(0, y-frame.origin.y);
            } else {
                element.translate = CGPointZero;
            }
            
        }
            break;
        default:
            break;
    }
    
    return [super isChildrenVisible:element];
}

@end
