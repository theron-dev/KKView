//
//  KKTextareaElement.m
//  KKView
//
//  Created by hailong11 on 2018/9/7.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKTextareaElement.h"
#import "KKViewContext.h"
#import "UIColor+KKElement.h"
#import "UIFont+KKElement.h"

@interface KKTextareaElement()<UITextViewDelegate>
@end


@implementation KKTextareaElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKTextareaElement class] name:@"textarea"];
}

-(Class) viewClass {
    return [UITextView class];
}

-(void) setView:(UIView *)view {
    [(UITextView*) self.view setDelegate:nil];
    [super setView:view];
    [(UITextView*) self.view setDelegate:self];
    UITextView * textView = (UITextView *) view;
    if(textView) {
        [textView setContentInset:UIEdgeInsetsMake(-10, -5, -15, -5)];
    }
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
    
}

@end


@implementation UITextView (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
  
    if([key isEqualToString:@"#text"]) {
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


@end

