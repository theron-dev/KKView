//
//  KKViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKViewElement.h"
#import "KKAnimationElement.h"
#import "UIColor+KKElement.h"
#import "UIFont+KKElement.h"
#import "KKPixel.h"
#import "KKViewContext.h"
#import "UIView+BackgroundImage.h"

#include <objc/runtime.h>

@interface KKViewElement() {

}

@end

@implementation KKViewElement

@synthesize viewContext = _viewContext;
@synthesize obtaining = _obtaining;

+(void) initialize{
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKViewElement class] name:@"view"];
}

-(instancetype) init{
    if((self = [super init])) {
        _layout = KKViewElementLayoutRelative;
        _viewContext = [KKViewContext currentContext];
    }
    return self;
}

-(void) changedKey:(NSString *) key {
    [super changedKey:key];
    
    NSString * value = [self get:key];
    
    if([key isEqualToString:@"padding"]) {
        _padding = KKEdgeFromString(value);
    } else if([key isEqualToString:@"margin"]) {
        _margin = KKEdgeFromString(value);
    } else if([key isEqualToString:@"width"]) {
        _width = KKPixelFromString(value);
    } else if([key isEqualToString:@"min-width"]) {
        _minWidth = KKPixelFromString(value);
    } else if([key isEqualToString:@"max-width"]) {
        _maxWidth = KKPixelFromString(value);
    } else if([key isEqualToString:@"height"]) {
        _height = KKPixelFromString(value);
    } else if([key isEqualToString:@"min-height"]) {
        _minHeight = KKPixelFromString(value);
    } else if([key isEqualToString:@"max-height"]) {
        _maxHeight = KKPixelFromString(value);
    } else if([key isEqualToString:@"left"]) {
        _left = KKPixelFromString(value);
    } else if([key isEqualToString:@"right"]) {
        _right = KKPixelFromString(value);
    } else if([key isEqualToString:@"top"]) {
        _top = KKPixelFromString(value);
    } else if([key isEqualToString:@"bottom"]) {
        _bottom = KKPixelFromString(value);
    } else if([key isEqualToString:@"layout"]) {
        if([value isEqualToString:@"relative"]) {
            [self setLayout: KKViewElementLayoutRelative];
        } else if([value isEqualToString:@"flex"]) {
            [self setLayout: KKViewElementLayoutFlex];
        } else if([value isEqualToString:@"horizontal"]) {
            [self setLayout: KKViewElementLayoutHorizontal];
        } else {
            [self setLayout: NULL];
        }
    } else if([key isEqualToString:@"vertical-align"]) {
        _verticalAlign = KKVerticalAlignFromString(value);
    } else if([key isEqualToString:@"position"]) {
        _position = KKPositionFromString(value);
    }
    [_view KKViewElement:self setProperty:key value:value];
}

#define KKViewDequeueViewsKey  "KKViewDequeueViewsKey"

-(NSString *) reuse {
    NSString * v = [self get:@"reuse"];
    if(v == nil) {
        v = [NSString stringWithFormat:@"#%d",(int) self.levelId];
    }
    return v;
}

-(Class) viewClass {
    return NSClassFromString([self get:@"view"]);
}

-(void) obtainView:(UIView *) view {
    
    if(_view && _view.superview == view) {
        [self obtainChildrenView];
        return;
    }
    
    [self recycleView];
    
    _obtaining = YES;
    
    __strong UIView * vv = nil;
    
    UIView * v = view;
    
    NSString * reuse = self.reuse;
    
    if([reuse length] > 0) {
        
        NSMutableDictionary * dequeueViews = objc_getAssociatedObject(v, KKViewDequeueViewsKey);
        
        if(dequeueViews != nil) {
            
            NSMutableArray * views = [dequeueViews objectForKey:reuse];
            
            if([views count] > 0) {
                
                vv = [views lastObject];
                
                [views removeLastObject];
                
            }
            
        }
    }
    
    if(vv == nil) {
        vv = [[[self viewClass] alloc] initWithFrame:CGRectZero];
    }
    
    if(vv == nil) {
        vv = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if([self.parent isKindOfClass:[KKViewElement class]]) {
        [(KKViewElement *) self.parent addSubview:vv element:self toView:v];
    } else {
        [v addSubview:vv];
    }
    
    [self setView:vv];
    
    [vv KKElementObtainView:self];
    
    [vv KKViewElementDidLayouted:self];
    
    for(NSString * key in self.keys) {
        NSString * v = [self get:key];
        [vv KKViewElement:self setProperty:key value:v];
    }

    [self obtainChildrenView];
    
    _obtaining = NO;
}

-(void) recycleView {
    
    UIView * vv = _view;
    UIView * v = [vv superview];
    
    if(v) {
        
        NSString * reuse = self.reuse;

        if([reuse length] > 0) {

            NSMutableDictionary * dequeueViews = objc_getAssociatedObject(v, KKViewDequeueViewsKey);
            
            if(dequeueViews == nil) {
                dequeueViews = [NSMutableDictionary dictionaryWithCapacity:4];
                objc_setAssociatedObject(v, KKViewDequeueViewsKey, dequeueViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            
            NSMutableArray * views = [dequeueViews objectForKey:reuse];
            
            if(views == nil) {
                views = [NSMutableArray arrayWithCapacity:4];
                [dequeueViews setObject:views forKey:reuse];
            }
            
            [views addObject:vv];
            
        }
        
        [vv KKElementRecycleView:self];
        
        [self setView:nil];
        
        KKElement * p = self.firstChild;
        
        while(p) {
            if([p isKindOfClass:[KKViewElement class]]) {
                [(KKViewElement *) p recycleView];
            }
            p = p.nextSibling;
        }
    }
}

-(void) obtainChildrenView {
    
    if(_view) {
        
        KKElement * p = self.firstChild;
        
        while(p) {
            
            if([p isKindOfClass:[KKViewElement class]]) {
                KKViewElement * e = (KKViewElement *) p;
                if([self isChildrenVisible:e]) {
                    [e obtainView:_view];
                } else {
                    UIView * v = [e view];
                    [e recycleView];
                    [v removeFromSuperview];
                }
            }
            p = p.nextSibling;
        }
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

-(void) didAddChildren:(KKElement *)element {
    [super didAddChildren:element];
}

-(void) willRemoveChildren:(KKElement *)element {
    [super willRemoveChildren:element];
    
    if([element isKindOfClass:[KKViewElement class]]) {
        UIView * v = [(KKViewElement *) element view];
        [(KKViewElement *) element recycleView];
        [v removeFromSuperview];
    }
    
}

-(void) remove {
    UIView * v = self.view;
    [self recycleView];
    [v removeFromSuperview];
    [super remove];
}

-(BOOL) isChildrenVisible:(KKViewElement *) element {
    CGRect r = _frame;
    r.origin = _contentOffset;
    return CGRectIntersectsRect(r, element.frame);
}

-(BOOL) isHidden {
    NSString * v = [self get:@"hidden"];
    return v == nil ? false: KKBooleanValue(v);
}


-(void) layoutChildren {
    if(_layout) {
        _contentSize = (* _layout)(self);
    }
}

-(void) layout:(CGSize) size {
    _frame.size = size;
    if(_layout) {
        _contentSize = (* _layout)(self);
    }
    [self didLayouted];
}

-(void) didLayouted {
    [_view KKViewElementDidLayouted:self];
    [self obtainChildrenView];
}

-(void) setContentOffset:(CGPoint)contentOffset {
    _contentOffset = contentOffset;
    [self obtainChildrenView];
}

@end

/**
 * 相对布局 "relative"
 */
CGSize KKViewElementLayoutRelative(KKViewElement * element) {
    
    CGSize size = element.frame.size;
    struct KKEdge padding = element.padding;
    CGFloat paddingLeft = KKPixelValue(padding.left, size.width, 0);
    CGFloat paddingRight = KKPixelValue(padding.right, size.width, 0);
    CGFloat paddingTop = KKPixelValue(padding.top, size.height, 0);
    CGFloat paddingBottom = KKPixelValue(padding.bottom, size.height, 0);
    CGSize inSize = CGSizeMake(size.width - paddingLeft - paddingRight,size.height - paddingTop - paddingBottom);
    
    CGSize contentSize = CGSizeZero;
    
    KKElement * p = element.firstChild;
    
    while(p) {
        
        if([p isKindOfClass:[KKViewElement class]]) {
            
            KKViewElement * e = (KKViewElement *) p;
            
            CGFloat mleft = KKPixelValue(e.margin.left, size.width, 0);
            CGFloat mright = KKPixelValue(e.margin.right, size.width, 0);
            CGFloat mtop = KKPixelValue(e.margin.top, size.height, 0);
            CGFloat mbottom = KKPixelValue(e.margin.bottom, size.height, 0);
            
            CGFloat width = KKPixelValue(e.width, inSize.width - mleft - mright, MAXFLOAT);
            CGFloat height = KKPixelValue(e.height, inSize.height - mtop - mbottom, MAXFLOAT);
            
            CGRect v = e.frame;
            
            v.size.width = width;
            v.size.height = height;
            
            e.frame = v;
            
            [e layoutChildren];
            
            if(width == MAXFLOAT) {
                width = v.size.width = e.contentSize.width;
                CGFloat min = KKPixelValue(e.minWidth, inSize.width, 0);
                CGFloat max = KKPixelValue(e.maxWidth, inSize.width, MAXFLOAT);
                if(v.size.width < min) {
                    width = v.size.width = min;
                }
                if(v.size.width > max) {
                    width = v.size.width = max;
                }
            }
            
            if(height == MAXFLOAT) {
                height = v.size.height = e.contentSize.height;
                CGFloat min = KKPixelValue(e.minHeight, inSize.height, 0);
                CGFloat max = KKPixelValue(e.maxHeight, inSize.height, MAXFLOAT);
                if(v.size.height < min) {
                    height = v.size.height = min;
                }
                if(v.size.height > max) {
                    height = v.size.height = max;
                }
            }
            
            e.frame = v;
            
            CGFloat left = KKPixelValue(e.left, inSize.width, MAXFLOAT);
            CGFloat right = KKPixelValue(e.right, inSize.width, MAXFLOAT);
            CGFloat top = KKPixelValue(e.top, inSize.height, MAXFLOAT);
            CGFloat bottom = KKPixelValue(e.bottom, inSize.height, MAXFLOAT);
            
            if(left == MAXFLOAT) {
                
                if(size.width == MAXFLOAT) {
                    left = paddingLeft + mleft;
                } else if(right == MAXFLOAT) {
                    left = paddingLeft + mleft + (inSize.width - width - mleft - mright) * 0.5f;
                } else {
                    left = paddingLeft + (inSize.width - right - mright - width);
                }
                
            } else {
                left = paddingLeft + left + mleft;
            }
            
            if(top == MAXFLOAT) {
                
                if(size.height == MAXFLOAT) {
                    top = paddingTop + mtop;
                } else if(bottom == MAXFLOAT) {
                    top = paddingTop + mtop + (inSize.height - height - mtop - mbottom) * 0.5f;
                } else {
                    top = paddingTop + (inSize.height - height - mbottom - bottom);
                }
                
            } else {
                top = paddingTop + top + mtop;
            }
            
            v = e.frame;
            
            v.origin.x = left ;
            v.origin.y = top ;
            
            if(left + paddingRight + mright + v.size.width > contentSize.width) {
                contentSize.width = left + paddingRight + mright + v.size.width;
            }
            
            if(top + paddingBottom + mbottom  + v.size.height > contentSize.height) {
                contentSize.height = top + paddingBottom + mbottom + v.size.height ;
            }
            
            e.frame = v;
            [e didLayouted];
        }
        
        p = p.nextSibling;
    }
    
    return contentSize;
}

static void KKViewElementLayoutLine(NSArray * elements,CGSize inSize,CGFloat lineHeight) {
    
    for(KKViewElement * element in elements) {
        
        enum KKVerticalAlign v = element.verticalAlign;
        
        if(v == KKVerticalAlignBottom) {
            CGRect r = element.frame;
            CGFloat mbottom = KKPixelValue(element.margin.bottom, inSize.height, 0);
            CGFloat mtop = KKPixelValue(element.margin.top, inSize.height, 0);
            r.origin.y = r.origin.y + (lineHeight - mtop - mbottom - r.size.height);
            element.frame =r;
        } else if(v == KKVerticalAlignMiddle) {
            CGRect r = element.frame;
            CGFloat mbottom = KKPixelValue(element.margin.bottom, inSize.height, 0);
            CGFloat mtop = KKPixelValue(element.margin.top, inSize.height, 0);
            r.origin.y = r.origin.y + (lineHeight - mtop - mbottom - r.size.height) * 0.5;
            element.frame =r;
        }
        
        [element didLayouted];
    }
    
}

/**
 * 流式布局 "flex" 左到右 上到下
 */
CGSize KKViewElementLayoutFlex(KKViewElement * element) {
    
    CGSize size = element.frame.size;
    struct KKEdge padding = element.padding;
    CGFloat paddingLeft = KKPixelValue(padding.left, size.width, 0);
    CGFloat paddingRight = KKPixelValue(padding.right, size.width, 0);
    CGFloat paddingTop = KKPixelValue(padding.top, size.height, 0);
    CGFloat paddingBottom = KKPixelValue(padding.bottom, size.height, 0);
    CGSize inSize = CGSizeMake(size.width - paddingLeft - paddingRight,size.height - paddingTop - paddingBottom);
    
    CGFloat y = paddingTop;
    CGFloat x = paddingLeft;
    CGFloat maxWidth = paddingLeft + paddingRight;
    CGFloat lineHeight = 0;
    
    NSMutableArray * lineElements = [NSMutableArray arrayWithCapacity:4];
    KKElement * p = element.firstChild;
    
    while(p) {
        
        if([p isKindOfClass:[KKViewElement class]]) {
            
            KKViewElement * e = (KKViewElement *) p;
            
            if([e isHidden]) {
                p = p.nextSibling;
                continue;
            }
            
            CGFloat mleft = KKPixelValue(e.margin.left, inSize.width, 0);
            CGFloat mright = KKPixelValue(e.margin.right, inSize.width, 0);
            CGFloat mtop = KKPixelValue(e.margin.top, inSize.height, 0);
            CGFloat mbottom = KKPixelValue(e.margin.bottom, inSize.height, 0);
            
            CGFloat width = KKPixelValue(e.width, inSize.width - mleft - mright, MAXFLOAT);
            CGFloat height = KKPixelValue(e.height, inSize.height - mtop - mbottom, MAXFLOAT);
            
            CGRect v = e.frame;
            
            v.size.width = width;
            v.size.height = height;
            
            e.frame = v;
            
            [e layoutChildren];
            
            if(width == MAXFLOAT) {
                width = v.size.width = e.contentSize.width;
                CGFloat min = KKPixelValue(e.minWidth, inSize.width, 0);
                CGFloat max = KKPixelValue(e.maxWidth, inSize.width, MAXFLOAT);
                if(v.size.width < min) {
                    width = v.size.width = min;
                }
                if(v.size.width > max) {
                    width = v.size.width = max;
                }
            }
            
            if(height == MAXFLOAT) {
                height = v.size.height = e.contentSize.height;
                CGFloat min = KKPixelValue(e.minHeight, inSize.height, 0);
                CGFloat max = KKPixelValue(e.maxHeight, inSize.height, MAXFLOAT);
                if(v.size.height < min) {
                    height = v.size.height = min;
                }
                if(v.size.height > max) {
                    height = v.size.height = max;
                }
            }
            
            e.frame = v;
            
            if(x + mleft + mright + paddingRight + v.size.width > size.width) {
                if([lineElements count] > 0) {
                    KKViewElementLayoutLine(lineElements,inSize,lineHeight);
                    [lineElements removeAllObjects];
                }
                y += lineHeight;
                lineHeight = 0;
                x = paddingLeft;
            }
            
            CGFloat left = x + mleft;
            CGFloat top = y + mtop;
            
            x += width + mleft + mright;
            
            if(lineHeight < height + mtop + mbottom) {
                lineHeight = height + mtop + mbottom;
            }
            
            v = e.frame;
            
            v.origin.x = left;
            v.origin.y = top;
            
            if(left + paddingRight + mright > maxWidth) {
                maxWidth = left + paddingRight + mright;
            }
            
            e.frame = v;
            
            [lineElements addObject:e];
        }
        
        p = p.nextSibling;
    }
    
    if([lineElements count] > 0) {
        KKViewElementLayoutLine(lineElements,inSize,lineHeight);
    }
    
    return CGSizeMake(maxWidth,y + lineHeight + paddingBottom);
}

/**
 * 水平布局 "horizontal" 左到右
 */
CGSize KKViewElementLayoutHorizontal(KKViewElement * element) {
    CGSize size = element.frame.size;
    struct KKEdge padding = element.padding;
    CGFloat paddingLeft = KKPixelValue(padding.left, size.width, 0);
    CGFloat paddingRight = KKPixelValue(padding.right, size.width, 0);
    CGFloat paddingTop = KKPixelValue(padding.top, size.height, 0);
    CGFloat paddingBottom = KKPixelValue(padding.bottom, size.height, 0);
    CGSize inSize = CGSizeMake(size.width - paddingLeft - paddingRight,size.height - paddingTop - paddingBottom);
    
    CGFloat y = paddingTop;
    CGFloat x = paddingLeft;
    CGFloat maxWidth = paddingLeft + paddingRight;
    CGFloat lineHeight = 0;
    
    NSMutableArray * lineElements = [NSMutableArray arrayWithCapacity:4];
    
    KKElement * p = element.firstChild;
    
    while(p) {

        if([p isKindOfClass:[KKViewElement class]]) {
            
            KKViewElement * e = (KKViewElement *) p;
            
            if([e isHidden]) {
                p = p.nextSibling;
                continue;
            }
            
            CGFloat mleft = KKPixelValue(e.margin.left, inSize.width, 0);
            CGFloat mright = KKPixelValue(e.margin.right, inSize.width, 0);
            CGFloat mtop = KKPixelValue(e.margin.top, inSize.height, 0);
            CGFloat mbottom = KKPixelValue(e.margin.bottom, inSize.height, 0);
            
            CGFloat width = KKPixelValue(e.width, inSize.width - mleft - mright, MAXFLOAT);
            CGFloat height = KKPixelValue(e.height, inSize.height - mtop - mbottom, MAXFLOAT);
            
            CGRect v = e.frame;
            
            v.size.width = width;
            v.size.height = height;
            
            e.frame = v;
            
            [e layoutChildren];
            
            if(width == MAXFLOAT) {
                width = v.size.width = e.contentSize.width;
                CGFloat min = KKPixelValue(e.minWidth, inSize.width, 0);
                CGFloat max = KKPixelValue(e.maxWidth, inSize.width, MAXFLOAT);
                if(v.size.width < min) {
                    width = v.size.width = min;
                }
                if(v.size.width > max) {
                    width = v.size.width = max;
                }
            }
            
            if(height == MAXFLOAT) {
                height = v.size.height = e.contentSize.height;
                CGFloat min = KKPixelValue(e.minHeight, inSize.height, 0);
                CGFloat max = KKPixelValue(e.maxHeight, inSize.height, MAXFLOAT);
                if(v.size.height < min) {
                    height = v.size.height = min;
                }
                if(v.size.height > max) {
                    height = v.size.height = max;
                }
            }
            
            e.frame = v;
            
        
            CGFloat left = x + mleft;
            CGFloat top = y + mtop;
            
            x += width + mleft + mright;
            
            if(lineHeight < height + mtop + mbottom) {
                lineHeight = height + mtop + mbottom;
            }
            
            v = e.frame;
            
            v.origin.x = left ;
            v.origin.y = top ;
            
           
            if(left + paddingRight + mright + v.size.width > maxWidth) {
                maxWidth = left + paddingRight + mright + v.size.width;
            }
            
            e.frame = v;
            
            [lineElements addObject:e];
        }
        
        p = p.nextSibling;
    }
    
    if([lineElements count]) {
        KKViewElementLayoutLine(lineElements, inSize, lineHeight);
    }
    
    return CGSizeMake(maxWidth,y + lineHeight + paddingBottom);
}

@implementation UIView (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    if([key isEqualToString:@"background-color"]) {
        self.backgroundColor = [UIColor KKElementStringValue:value];
    } else if([key isEqualToString:@"border-color"]) {
        self.layer.borderColor = [UIColor KKElementStringValue:value].CGColor;
    } else if([key isEqualToString:@"border-width"]) {
        self.layer.borderWidth = KKPixelValue(KKPixelFromString(value), element.frame.size.width, 0);
    } else if([key isEqualToString:@"border-radius"]) {
        self.layer.cornerRadius = KKPixelValue(KKPixelFromString(value), element.frame.size.width, 0);
    } else if([key isEqualToString:@"opacity"]) {
        self.alpha = value == nil || [value isEqualToString:@""] ? 1.0 : [value doubleValue];
    } else if([key isEqualToString:@"hidden"]) {
        self.hidden = value == nil ? false: KKBooleanValue(value);
    } else if([key isEqualToString:@"overflow"]) {
        if([@"hidden" isEqualToString:value]) {
            self.layer.masksToBounds = YES;
        } else {
            self.layer.masksToBounds = NO;
        }
    } else if([key isEqualToString:@"tint-color"]) {
        self.tintColor = [UIColor KKElementStringValue:value];
    } else if([key isEqualToString:@"enabled"]) {
        self.userInteractionEnabled = KKBooleanValue(value);
    } else if([key isEqualToString:@"background-image"]) {
        if(value) {
            
            NSArray * vs = [value componentsSeparatedByString:@" "];
            
            UIImage * image = nil;
            
            if(element.viewContext == nil) {
                image = [UIImage imageNamed:vs[0]];
            } else {
                image = [element.viewContext imageWithURI:vs[0]];
            }
            
            if([vs count] == 3 && image) {
                
                CGSize size = image.size;
                CGFloat left = [vs[1] doubleValue];
                CGFloat top = [vs[2] doubleValue];
         
                image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, size.height - top -1, size.width - left - 1)];
                
            }
            
            self.kk_backgroundImage = image;
            
        } else {
            self.kk_backgroundImage = nil;
        }
    } else if([key isEqualToString:@"box-shadow"]) {
        NSArray * vs = [value componentsSeparatedByString:@" "];
        if([vs count] == 4) {
            self.layer.shadowOffset = CGSizeMake(KKPixelValue(KKPixelFromString(vs[0]),0,0), KKPixelValue(KKPixelFromString(vs[1]),0,0));
            self.layer.shadowRadius = KKPixelValue(KKPixelFromString(vs[2]),0,0);
            self.layer.shadowColor = [UIColor KKElementStringValue:vs[3]].CGColor;
            self.layer.shadowOpacity = 1.0;
        } else{
            self.layer.shadowColor = nil;
        }
    } else if([key isEqualToString:@"animation"]) {
        [self.layer removeAllAnimations];
        KKElement * e = element.firstChild;
        while(e != nil) {
            if([e isKindOfClass:[KKAnimationElement class]]) {
                NSString * name = [e get:@"name"];
                if([name isEqualToString:value]) {
                    [self.layer addAnimation:[(KKAnimationElement *) e animation] forKey:name];
                    break;
                }
            }
            e = e.nextSibling;
        }
    } else if([key isEqualToString:@"transform"]) {
        self.layer.transform = KKTransformFromString(value);
    }
}

-(void) KKViewElementDidLayouted:(KKViewElement *) element {
    CGRect r = element.frame;
    r.origin.x += element.translate.x;
    r.origin.y += element.translate.y;
    self.frame = r;
}

-(void) KKElementRecycleView:(KKViewElement *) element {
    
}

-(void) KKElementObtainView:(KKViewElement *) element {
    
}

@end

@implementation UIScrollView (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
}

-(void) KKViewElementDidLayouted:(KKViewElement *) element {
    [super KKViewElementDidLayouted:element];
    
    CGSize size = element.contentSize;
    
    if([[element get:@"overflow-y"] isEqualToString:@"scroll"]) {
        size.height = MAX(element.frame.size.height + 1,size.height);
    }
    
    if([[element get:@"overflow-x"] isEqualToString:@"scroll"]) {
        size.width = MAX(element.frame.size.width + 1,size.width);
    }
    
    self.contentSize = size;
}

@end


