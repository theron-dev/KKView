//
//  KKPagerViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKPagerViewElement.h"
#import "KKViewContext.h"
#import "NSTimer+KKView.h"

@interface KKPagerViewElement() <UIScrollViewDelegate> {
    NSTimer * _timer;
    BOOL _animating;
    BOOL _loop;
}

@end

@implementation KKPagerViewElement

+(void) initialize{
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKPagerViewElement class] name:@"pager"];
}

-(instancetype) init{
    if((self = [super init])) {
        _loop = YES;
    }
    return self;
}

-(void) dealloc {
    [_timer invalidate];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    if([@"loop" isEqualToString:key]) {
        _loop = KKBooleanValue([self get:key]);
    }
}

-(void) setView:(UIView *)view{
    [_timer invalidate];
    _timer = nil;
    [super setView:view];
    
    if(view) {
        
        UIScrollView * v = (UIScrollView *) view;
        [v setPagingEnabled:YES];
        [v setShowsVerticalScrollIndicator:NO];
        [v setShowsHorizontalScrollIndicator:NO];
        [self pageIndexChanged:YES];
        
        {
            NSTimeInterval v = [[self get:@"interval"] doubleValue];
            
            if(v > 0) {
                _timer = [NSTimer kk_timerWithTimeInterval: (v / 1000.0) func:^(id weakObject) {
                    [weakObject doLoopAction];
                } weakObject:self repeats:YES];
            }
            
        }
    }
}

-(void) didLayouted{
    [super didLayouted];
    if(self.view) {
        [self pageIndexChanged:YES];
    }
}

-(void) doLoopAction {
    
    if(_animating) {
        return;
    }
    
    UIScrollView * v = (UIScrollView *) self.view;
    CGSize size = self.frame.size;
    
    if(size.width <= 0){
        return;
    }
    
    NSInteger pageIndex = (NSInteger) self.contentOffset.x / (NSInteger) size.width;
    NSInteger pageCount = (NSInteger) self.contentSize.width / (NSInteger) size.width;
    
    if(pageCount > 2 && pageIndex > 0 && pageIndex < pageCount -1) {
 
        pageIndex = (pageIndex) % (pageCount - 1) + 1;
        
        [v setContentOffset:CGPointMake(pageIndex * size.width, 0) animated:YES];
    }
}

-(void) pageIndexChanged:(BOOL) inited {
    UIScrollView * v = (UIScrollView *) self.view;
    CGSize size = self.frame.size;
    if(size.width <=0.0f) {
        return;
    }
    NSInteger pageIndex = (NSInteger) self.contentOffset.x / (NSInteger) size.width;
    NSInteger pageCount = (NSInteger) self.contentSize.width / (NSInteger) size.width;
    
    if(pageCount > 1 && _loop) {
        if(pageIndex == 0) {
            if(!inited) {
                [v setContentOffset:CGPointMake((pageCount - 2) * size.width, 0) animated:NO];
            } else {
                [v setContentOffset:CGPointMake(size.width, 0) animated:NO];
            }
        } else if(pageIndex == pageCount - 1) {
            [v setContentOffset:CGPointMake(size.width, 0) animated:NO];
        }
        pageIndex = v.contentOffset.x / size.width - 1;
        pageCount = pageCount - 1;
    }
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    
    NSMutableDictionary * data = [self data];
    
    data[@"pageIndex"] = @(pageIndex);
    data[@"pageCount"] = @(pageCount);
    
    e.data = data;
    
    [self emit:@"pagechange" event:e];
    
    _animating = NO;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _animating = YES;
}

-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    _animating = YES;
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [super scrollViewDidEndScrollingAnimation:scrollView];
    [self pageIndexChanged:NO];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [super scrollViewDidEndDecelerating:scrollView];
    [self pageIndexChanged:NO];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if(! decelerate) {
        [self pageIndexChanged:NO];
    }
}


-(BOOL) isChildrenVisible:(KKViewElement *) element {
    CGRect r = self.frame;
    r.origin = self.contentOffset;
    r.origin.x -= r.size.width;
    r.size.width += r.size.width * 2;
    return CGRectIntersectsRect(r, element.frame);
}

@end
