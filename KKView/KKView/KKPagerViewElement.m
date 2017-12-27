//
//  KKPagerViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKPagerViewElement.h"

@implementation KKPagerViewElement

-(void) setView:(UIView *)view{
    [super setView:view];
    UIScrollView * v = (UIScrollView *) view;
    [v setPagingEnabled:YES];
    [v setShowsVerticalScrollIndicator:NO];
    [v setShowsHorizontalScrollIndicator:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.contentSize.width > self.frame.size.width) {
        if(scrollView.contentOffset.x == 0) {
            [scrollView setContentOffset:CGPointMake(self.contentSize.width - self.frame.size.width * 2 , 0) animated:NO];
        }
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
