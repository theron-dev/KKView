//
//  KKTextareaElement.m
//  KKView
//
//  Created by zhanghailong on 2018/9/7.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKTextareaElement.h"
#import "KKViewContext.h"
#import "UIColor+KKElement.h"
#import "UIFont+KKElement.h"
#import <KKObserver/KKObserver.h>

@interface KKTextareaElement()<UITextViewDelegate>

-(CGRect) bounds:(CGSize) size;

@end

CGSize KKTextareaElementLayout(KKViewElement * element) {
    
    CGSize size = element.frame.size;
    
    KKTextareaElement * v = (KKTextareaElement *) element;
    
    if(size.width == MAXFLOAT || size.height == MAXFLOAT) {
        
        CGRect r = [v bounds:size];
        
        if(size.width == MAXFLOAT) {
            CGFloat pleft = KKPixelValue(v.padding.left, 0, 0);
            CGFloat pright = KKPixelValue(v.padding.right, 0, 0);
            size.width = ceil(r.size.width + pleft + pright );
            
            CGFloat min = KKPixelValue(v.minWidth, 0, 0);
            CGFloat max = KKPixelValue(v.maxWidth, 0, INT32_MAX);
            
            if(size.width < min) {
                size.width = min;
            }
            
            if(size.width > max) {
                size.width = max;
            }
            
        }
        
        if(size.height == MAXFLOAT) {
            
            CGFloat ptop = KKPixelValue(v.padding.top, 0, 0);
            CGFloat pbottom = KKPixelValue(v.padding.bottom, 0, 0);
            size.height = ceil(r.size.height + ptop + pbottom );
            
            CGFloat min = KKPixelValue(v.minHeight, 0, 0);
            CGFloat max = KKPixelValue(v.maxHeight, 0, INT32_MAX);
            
            if(size.height < min) {
                size.height = min;
            }
            
            if(size.height > max) {
                size.height = max;
            }
            
        }
        
        return size;
    } else {
        return size;
    }
    
}


@implementation KKTextareaElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKTextareaElement class] name:@"textarea"];
    [KKViewContext setDefaultElementClass:[KKTextareaElement class] name:@"editor"];
}

-(instancetype) init{
    if((self = [super init])) {
        [self setLayout:KKTextareaElementLayout];
    }
    return self;
}

-(Class) viewClass {
    return [UITextView class];
}

-(void) setLayout:(KKViewElementLayout)layout {
    [super setLayout:KKTextareaElementLayout];
}

-(void) setView:(UIView *)view {
    
    {
        KKElement * e = self.firstChild;
        
        if(e && [[e get:@"#name"] isEqualToString:@"bar"]) {
            KKElement * p = e.firstChild;
            while(p != nil) {
                if([p isKindOfClass:[KKViewElement class]]) {
                    [(KKViewElement *) p recycleView];
                }
                p = p.nextSibling;
            }
        }
    }
    
    [(UITextView*) self.view setInputView:nil];
    [(UITextView*) self.view setDelegate:nil];
    [super setView:view];
    [(UITextView*) self.view setDelegate:self];
    UITextView * textView = (UITextView *) view;
    if(textView) {
        
        [textView setContentInset:UIEdgeInsetsMake(-10, -5, -15, -5)];
        
        {
            KKElement * e = self.firstChild;
            
            if(e && [[e get:@"#name"] isEqualToString:@"bar"]) {
                
                UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
                
                [textView setInputAccessoryView:view];
                
                CGSize size = CGSizeZero;
                
                KKElement * p = e.firstChild;
                
                while(p != nil) {
                    if([p isKindOfClass:[KKViewElement class]]) {
                        size.width = MAX(size.width,[(KKViewElement *) p frame].size.width);
                        size.height = MAX(size.height,[(KKViewElement *) p frame].size.height);
                        [(KKViewElement *) p obtainView:view];
                    }
                    p = p.nextSibling;
                }
                
                view.frame = CGRectMake(0, 0, size.width, size.height);
                
            }
        }
        
    }
}

-(void) emit:(NSString *)name event:(KKEvent *)event {
    [super emit:name event:event];
    
    if([name isEqualToString:@"insert"]) {
        if([event isKindOfClass: [KKElementEvent class]]) {
            NSString * text = [[(KKElementEvent *) event data] kk_getString:@"text"];
            if(text) {
                UITextView * textView = (UITextView *) self.view;
                [textView insertText:text];
                [self textViewDidChange:textView];
            }
        }
        
    }
}

-(void) didLayouted {
    [super didLayouted];
    
    KKElement * e = self.firstChild;
    
    if(e && [[e get:@"#name"] isEqualToString:@"bar"]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        KKElement * p = e.firstChild;
        while(p != nil) {
            if([p isKindOfClass:[KKViewElement class]]) {
                KKViewElement * v =(KKViewElement *) p;
                [(KKViewElement *) p layout:CGSizeMake(KKPixelValue(v.width, size.width, 0), KKPixelValue(v.height, size.height, 0))];
            }
            p = p.nextSibling;
        }
    }
}

-(CGRect) bounds:(CGSize) size {
    CGRect r = CGRectZero;
    if(self.view) {
        r.size = [(UITextView *) self.view contentSize];
    }
    return r;
}

-(void) textViewDidBeginEditing:(UITextView *)textView {
    [self setStatus:@"active"];
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    
    e.data = self.data;
    
    [self emit:@"focus" event:e];
}

-(void) textViewDidEndEditing:(UITextView *)textView {
    
    [self setStatus:@""];
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    
    e.data = self.data;
    
    [self emit:@"blur" event:e];
    
}

-(void) textViewDidChange:(UITextView *)textView {
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    
    NSMutableDictionary * data = self.data;
    
    data[@"value"] = textView.text;
    
    e.data = data;
    
    [self emit:@"change" event:e];
    
    if(self.width.type == KKPixelTypeAuto || self.height.type == KKPixelTypeAuto) {
        e.cancelBubble = NO;
        [self emit:@"layout" event:e];
    }
    
}

@end


@implementation UITextView (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
  
    if([key isEqualToString:@"#text"] || [key isEqualToString:@"value"]) {
        self.text = value;
    } else if([key isEqualToString:@"color"]) {
        self.textColor = [UIColor KKElementStringValue:value];
    } else if([key isEqualToString:@"autofocus"]) {
        if(KKBooleanValue(value)) {
            if([element isObtaining]) {
                __weak UITextView * v = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [v becomeFirstResponder];
                });
            } else {
                [self becomeFirstResponder];
            }
        }
    } else if([key isEqualToString:@"text-align"]) {
        self.textAlignment = KKTextAlignmentFromString(value);
    } else if([key isEqualToString:@"font"]) {
        self.font = [UIFont KKElementStringValue:value];
    } else if([key isEqualToString:@"padding"]) {
        UIEdgeInsets edge = UIEdgeInsetsMake(-10, -5, -15, -5);
        edge.top += KKPixelValue(element.padding.top,0,0);
        edge.right += KKPixelValue(element.padding.right,0,0);
        edge.bottom += KKPixelValue(element.padding.bottom,0,0);
        edge.left += KKPixelValue(element.padding.left,0,0);
        [self setContentInset:edge];
    }
    
}

-(void) KKViewElementDidLayouted:(KKViewElement *)element {

    CGRect r = element.frame;
    r.origin.x += element.translate.x;
    r.origin.y += element.translate.y;
    
    self.frame = r;
    
}

@end

