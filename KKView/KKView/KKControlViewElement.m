//
//  KKControlViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKControlViewElement.h"
#import "JSContext+KKView.h"

@implementation KKControlViewElement

+(void) initialize{
    [super initialize];
    [JSContext setDefaultElementClass:self name:@"button"];
}

-(instancetype) init {
    if((self = [super init])) {
        [self set:@"view" value:@"UIControl"];
    }
    return self;
}

-(void) setView:(UIView *)view {
    UIControl * v = (UIControl *) self.view;
    [v removeTarget:self action:@selector(doTapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view removeObserver:self forKeyPath:@"enabled"];
    [self.view removeObserver:self forKeyPath:@"selected"];
    [self.view removeObserver:self forKeyPath:@"highlighted"];
    [super setView:view];
    [self.view addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    v = (UIControl *) self.view;
    [v addTarget:self action:@selector(doTapAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void) doTapAction {
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];

    e.data = [self data];
    
    [self emit:@"tap" event:e];
    
}

-(void) dealloc {
    
    [self.view removeObserver:self forKeyPath:@"enabled"];
    [self.view removeObserver:self forKeyPath:@"selected"];
    [self.view removeObserver:self forKeyPath:@"highlighted"];
    UIControl * v = (UIControl *) self.view;
    [v removeTarget:self action:@selector(doTapAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(object == self.view &&
       ([keyPath isEqualToString:@"enabled"] ||[keyPath isEqualToString:@"selected"] ||[keyPath isEqualToString:@"highlighted"]) ) {
        UIControl * v = (UIControl *) self.view;
        if([v isEnabled]) {
            if([v isSelected]) {
                [self setStatus:@"selected"];
            } else if([v isHighlighted]) {
                [self setStatus:@"hover"];
            } else {
                [self setStatus:@""];
            }
        } else {
            [self setStatus:@"disabled"];
        }
    }
}

@end


@implementation UIControl (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
    
    if([@"selected" isEqualToString:key]) {
        self.selected = KKBooleanValue(value);
    } else if([@"enabled" isEqualToString:key]) {
        self.enabled = KKBooleanValue(value);
    }
}

@end

