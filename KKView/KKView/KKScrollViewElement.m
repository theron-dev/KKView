//
//  KKScrollViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKScrollViewElement.h"
#import "KKViewContext.h"
#import <KKObserver/KKObserver.h>
#include <objc/runtime.h>

enum KKScrollViewElementScrollType {
    KKScrollViewElementScrollTypeNone,
    KKScrollViewElementScrollTypeTop,
    KKScrollViewElementScrollTypeBottom
} ;

@interface KKScrollViewElement() <UIScrollViewDelegate> {
    enum KKScrollViewElementScrollType _scrollType;
    BOOL _tracking;
    NSString * _anchor;
    BOOL _anchorScrolling;
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
    [(UIScrollView *) self.view setShowsHorizontalScrollIndicator:NO];
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
        
        if([self hasEvent:@"scroll"]){
            
            NSMutableDictionary * data = self.data;
            
            data[@"tracking"] = @(_tracking);
            data[@"x"] = @(self.contentOffset.x);
            data[@"y"] = @(self.contentOffset.y);
            data[@"w"] = @(self.contentSize.width);
            data[@"h"] = @(self.contentSize.height);
            data[@"width"] = @(self.frame.size.width);
            data[@"height"] = @(self.frame.size.height);
            
            KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
            
            e.data = data;
            
            [self emit:@"scroll" event:e];
            
        }
        
        if(!_anchorScrolling && [self hasEvent:@"anchor"]) {
  
            KKElement * p = self.lastChild;
            
            NSString * anchor = nil;
            KKViewElement * element = nil;
            
            while(p) {
                if([p isKindOfClass:[KKViewElement class]]) {
                    anchor = [p get:@"anchor"];
                    if(anchor != nil) {
                        struct KKEdge margin = KKEdgeFromString([p get:@"anchor-margin"]);
                        CGRect t = [(KKViewElement *)p frame];
                        t.origin.y += element.translate.y - KKPixelValue(margin.top,0,0);
                        if(self.contentOffset.y >= t.origin.y) {
                            element = (KKViewElement *) p;
                            break;
                        }
                    }
                }
                p = p.prevSibling;
            }
            
            if(element != nil) {

                if(![anchor isEqualToString:_anchor]) {
                    
                    _anchor = anchor;
                    
                    NSMutableDictionary * data = self.data;
                    
                    data[@"tracking"] = @(_tracking);
                    data[@"x"] = @(self.contentOffset.x);
                    data[@"y"] = @(self.contentOffset.y);
                    data[@"w"] = @(self.contentSize.width);
                    data[@"h"] = @(self.contentSize.height);
                    data[@"width"] = @(self.frame.size.width);
                    data[@"height"] = @(self.frame.size.height);
                    data[@"view"] = @{@"width":@(element.frame.size.width)
                                      ,@"height":@(element.frame.size.height)
                                      ,@"x":@(element.frame.origin.x)
                                      ,@"y":@(element.frame.origin.y)
                                      ,@"anchor":anchor
                                      };
                    
                    KKElement * p = self.firstChild;
                    
                    while(p) {
                        
                        p = p.nextSibling;
                    }
                    
                    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
                    
                    e.data = data;
                    
                    [self emit:@"anchor" event:e];
                    
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
    _anchorScrolling = NO;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    _scrollType = KKScrollViewElementScrollTypeNone;
    _tracking = NO;
    _anchor = nil;
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self scrollViewDidEndScrolling];
    _tracking = NO;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _tracking = YES;
}


-(void) addSubview:(UIView *) view element:(KKViewElement *) element toView:(UIView *) toView {
    NSString * v = [element get:@"floor"];
    if([v isEqualToString:@"front"]) {
        [toView addSubview:view];
    } else {
        [toView insertSubview:view atIndex:0];
    }
}


-(BOOL) isChildrenVisible:(KKViewElement *) element {
    
    switch (element.position) {
        case KKPositionTop:
        {
            CGPoint p = self.contentOffset;
            struct KKEdge margin = element.margin;
            CGFloat mtop = KKPixelValue(margin.top, 0, 0);
            CGRect frame = element.frame;
            if(frame.origin.y - p.y - mtop < 0) {
                element.translate = CGPointMake(0, p.y - frame.origin.y + mtop);
            } else {
                element.translate = CGPointZero;
            }
            [element didLayouted];
        }
            break;
        case KKPositionBottom:
        {
            CGRect frame = element.frame;
            struct KKEdge margin = element.margin;
            
            CGFloat mbottom = KKPixelValue(margin.bottom, 0, 0);
            
            CGFloat dy = self.contentOffset.y + self.frame.size.height - frame.size.height - mbottom - frame.origin.y;
            
            if(dy > 0 ) {
                element.translate = CGPointMake(0, dy);
            } else {
                element.translate = CGPointZero;
            }
            
            [element didLayouted];
        }
            break;
        default:
            break;
    }
    
    return [super isChildrenVisible:element];
}

-(void) emit:(NSString *)name event:(KKEvent *)event {
    
    if([event isKindOfClass:[KKElementEvent class]]) {
        
        if([name isEqualToString:@"scrolltop"]) {
            
            [(KKElementEvent *) event setCancelBubble:YES];
            
            [(UIScrollView *) self.view setContentOffset:CGPointZero animated:NO];
            
        } else if([name isEqualToString:@"anchor"]) {
            
            [(KKElementEvent *) event setCancelBubble:YES];
            
            NSDictionary * data = [(KKElementEvent *) event data];
            
            struct KKEdge margin = KKEdgeFromString([data kk_getString:@"margin"]);
            
            NSString * anchor = [data kk_getString:@"anchor"];
            
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
            
            if(element != nil) {
                CGRect r = element.frame;
                r.origin.y -= KKPixelValue(margin.top, 0, 0);
                r.origin.x -= KKPixelValue(margin.left, 0, 0);
                _anchorScrolling = YES;
                [(UIScrollView *) self.view setContentOffset:r.origin animated:YES];
            }
            
        }
        
    }
    
    [super emit:name event:event];
}
@end
