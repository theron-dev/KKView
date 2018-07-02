//
//  KKSlideViewElement.m
//  KKView
//
//  Created by hailong11 on 2018/5/24.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKSlideViewElement.h"
#import "KKControlViewElement.h"

@interface KKSlideViewElement()

@property(nonatomic,strong) UITapGestureRecognizer * tapGestureRecognizer;

@end

@implementation KKSlideCurElement


@end

@implementation KKSlideViewElement

@synthesize curElementView = _curElementView;

+(void) initialize{
    
    [KKViewContext setDefaultElementClass:[KKSlideViewElement class] name:@"slide"];
    [KKViewContext setDefaultElementClass:[KKSlideCurElement class] name:@"slide:cur"];
}

-(void) tapAction:(UITapGestureRecognizer *) tapGestureRecognizer {
    
    CGPoint p = [tapGestureRecognizer locationInView:self.view];
    
    KKElement * e = self.lastChild;
    
    while(e) {
        
        if([e isKindOfClass:[KKControlViewElement class]]) {
            
            CGRect frame = [(KKViewElement *) e frame];
            
            if(CGRectContainsPoint(frame, p)) {
                
                KKElementEvent * event = [[KKElementEvent alloc] initWithElement:e];
                
                NSMutableDictionary * data = [e data];
                
                data[@"x"] = @(p.x - frame.origin.x);
                data[@"y"] = @(p.y - frame.origin.y);
                data[@"width"] = @(frame.size.width);
                data[@"height"] = @(frame.size.height);
                
                event.data = data;
                
                [e emit:@"tap" event:event];
                
                return;
            }
        }
        
        e = e.prevSibling;
    }
    
}

-(UITapGestureRecognizer *) tapGestureRecognizer {
    
    if(_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    }
    
    return _tapGestureRecognizer;
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
    if(_tapGestureRecognizer) {
        [self.view removeGestureRecognizer:_tapGestureRecognizer];
    }
    [_curElementView removeFromSuperview];
    [super setView:view];
    if(view != nil) {
        [view addGestureRecognizer:self.tapGestureRecognizer];
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
    
    if(anchor) {
        
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
            
            CGRect r = element.frame;
            CGSize size = CGSizeMake(r.size.width, self.frame.size.height);
            
            size.width = KKPixelValue(cur.element.width, size.width, 0);
            size.height = KKPixelValue(cur.element.height, size.height, 0);
            
            [cur.element layout:size];
        
            CGFloat centerX = r.origin.x + r.size.width * 0.5f;

            if(animated) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.3];
            }
            
            cur.frame = CGRectMake(centerX - size.width * 0.5f,
                                   0,
                                   size.width, size.height);
            
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

-(void) addSubview:(UIView *) view element:(KKViewElement *) element toView:(UIView *) toView {
    NSString * v = [element get:@"floor"];
    if([v isEqualToString:@"back"]) {
        [toView insertSubview:view atIndex:0];
    } else {
        [toView addSubview:view];
    }
}

@end
