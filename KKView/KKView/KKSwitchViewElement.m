//
//  KKSwitchViewElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKSwitchViewElement.h"

@implementation KKSwitchViewElement

-(instancetype) init {
    if((self = [super init])) {
        [self setAttrs:@{@"view":NSStringFromClass([UISwitch class])}];
    }
    return self;
}

-(void) setView:(UIView *)view {
    [(UISwitch *) self.view removeTarget:self action:@selector(doChangeAction:) forControlEvents:UIControlEventValueChanged];
    [super setView:view];
    [(UISwitch *) self.view addTarget:self action:@selector(doChangeAction:) forControlEvents:UIControlEventValueChanged];
}

-(void) doChangeAction:(UISwitch *) view {
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    
    e.data = [self data];
    
    [self emit:@"change" event:e];
    
}

@end


@implementation UISwitch (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
    
    if([@"checked" isEqualToString:key]) {
        [self setOn:KKBooleanValue(value)];
    }
}

@end
