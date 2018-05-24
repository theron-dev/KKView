//
//  KKSlideViewElement.m
//  KKView
//
//  Created by hailong11 on 2018/5/24.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKSlideViewElement.h"

@implementation KKSlideCurElement

@end

@implementation KKSlideViewElement

@synthesize curElementView = _curElementView;

+(void) initialize{
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKSlideViewElement class] name:@"slide"];
    [KKViewContext setDefaultElementClass:[KKSlideCurElement class] name:@"slide:cur"];
}

-(KKViewElement *) curElement {
    KKElement * e = self.firstChild;
    if([e isKindOfClass:[KKSlideCurElement class]]) {
        e = e.firstChild;
        if([e isKindOfClass:[KKViewElement class]]) {
            return (KKViewElement *) e;
        }
    }
    return nil;
}

-(void) setView:(UIView *)view {
    [_curElementView removeFromSuperview];
    [super setView:view];
    if(view != nil) {
        [(UIScrollView *) view setDelaysContentTouches:NO];
        [self updateAnchor:NO];
    }
}

-(void) changedKey:(NSString *)key{
    [super changedKey:key];
    if([@"anchor" isEqualToString:key]) {
        if(self.view) {
            [self updateAnchor:YES];
        }
    }
}

-(KKElementView *) curElementView {
    
    if(_curElementView == nil) {
        
        KKViewElement * e = self.curElement;
        
        if(e != nil) {
            _curElementView = [[KKElementView alloc] initWithFrame:CGRectZero];
            _curElementView.element = e;
        }
    }
    
    return _curElementView;
}

-(void) updateAnchor:(BOOL) animated {
    
    NSString * anchor = [self get:@"anchor"];
    
    KKViewElement * element = nil;
    
    KKElement * e = self.firstChild;
    
    while(e){
        
        if([e isKindOfClass:[KKViewElement class]]) {
            NSString * v = [e get:@"anchor"];
            if([v isEqualToString:anchor]) {
                element = (KKViewElement *) e;
                break;
            }
        }
        
        e = e.nextSibling;
    }
    
    KKElementView * cur = [self curElementView];
    
    if(cur != nil && self.view != nil) {
        
        if(element == nil) {
            [cur removeFromSuperview];
        } else {
            
            [self.view insertSubview:cur atIndex:0];
            
            if(CGRectEqualToRect(CGRectZero, cur.frame)) {
                animated = NO;
            }
            
            if(animated) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.3];
            }
            
            cur.frame = element.frame;
            [cur.element layout:element.frame.size];
            [cur.element obtainView:cur];
            
            if(animated) {
                [UIView commitAnimations];
            }
            
        }

    }
    
    if(element) {
        [(UIScrollView *)self.view scrollRectToVisible:element.frame animated:animated];
    }
    
}

@end
