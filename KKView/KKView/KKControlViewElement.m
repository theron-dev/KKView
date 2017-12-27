//
//  KKControlViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKControlViewElement.h"

@implementation KKControlViewElement

-(instancetype) init {
    if((self = [super init])) {
        [self set:@"view" value:@"UIControl"];
    }
    return self;
}

-(void) setView:(UIView *)view {
    UIControl * v = (UIControl *) self.view;
    [v removeTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view removeObserver:self forKeyPath:@"enabled"];
    [self.view removeObserver:self forKeyPath:@"selected"];
    [self.view removeObserver:self forKeyPath:@"highlighted"];
    [super setView:view];
    [self.view addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    v = (UIControl *) self.view;
    [v addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void) doAction {
    if(_onAction) {
        _onAction();
    }
}

-(void) dealloc {
    
    [self.view removeObserver:self forKeyPath:@"enabled"];
    [self.view removeObserver:self forKeyPath:@"selected"];
    [self.view removeObserver:self forKeyPath:@"highlighted"];
    UIControl * v = (UIControl *) self.view;
    [v removeTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
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
