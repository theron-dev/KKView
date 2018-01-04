//
//  KKPagerViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKPagerViewElement.h"
#import "KKViewContext.h"

@interface KKPagerViewElement() <UIScrollViewDelegate>

@end

@implementation KKPagerViewElement

+(void) initialize{
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKPagerViewElement class] name:@"pager"];
}

-(void) setView:(UIView *)view{
    [super setView:view];
    UIScrollView * v = (UIScrollView *) view;
    [v setPagingEnabled:YES];
    [v setShowsVerticalScrollIndicator:NO];
    [v setShowsHorizontalScrollIndicator:NO];
    [self pageIndexChanged:YES];
}

-(void) pageIndexChanged:(BOOL) inited {
    UIScrollView * v = (UIScrollView *) self.view;
    CGSize size = self.frame.size;
    NSInteger pageIndex = v.contentOffset.x / size.width;
    NSInteger pageCount = v.contentSize.width / size.width;
    if(pageCount > 1) {
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
