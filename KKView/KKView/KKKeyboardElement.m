//
//  KKKeyboardElement.m
//  KKView
//
//  Created by 张海龙 on 2018/2/21.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKKeyboardElement.h"
#import <UIKit/UIKit.h>
#import "KKViewElement.h"
#import "KKViewContext.h"

@implementation KKKeyboardElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKKeyboardElement class] name:@"keyboard"];
}

-(instancetype) init {
    if((self  = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisible:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisible:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void) keyboardVisible:(NSNotification *) notification {
    
    KKElement * p = self.parent;
    
    if([p isKindOfClass:[KKViewElement class]]) {
        
        CGRect bounds = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        KKViewElement * e = (KKViewElement *) p;
        
        struct KKEdge padding = KKEdgeFromString([e get:@"padding"]);
        
        CGFloat bottom = KKPixelValue(padding.bottom, 0, 0);
        
        padding.bottom.type = KKPixelTypePX;
        padding.bottom.value = bottom + bounds.size.height;
        
        e.padding = padding;
        
        KKElementEvent * event = [[KKElementEvent alloc] initWithElement:e];
        
        event.data = e.data;
        
        [e emit:@"layout" event:event];
    }
    
}

-(void) keyboardHidden:(NSNotification *) notification {
    
    KKElement * p = self.parent;
    
    if([p isKindOfClass:[KKViewElement class]]) {

        KKViewElement * e = (KKViewElement *) p;
        
        struct KKEdge padding = KKEdgeFromString([e get:@"padding"]);
   
        e.padding = padding;
        
        KKElementEvent * event = [[KKElementEvent alloc] initWithElement:e];
        
        NSMutableDictionary * data = e.data;
        
        data[@"animated"] = @(true);
        
        event.data = data;
        
        [e emit:@"layout" event:event];
    }
}

@end
