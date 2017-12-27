//
//  UIFont+KKElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "UIFont+KKElement.h"
#import "KKPixel.h"

@implementation UIFont (KKElement)

+(UIFont *) KKElementStringValue:(NSString *) value {
    
    if(value == nil) {
        return nil;
    }
    
    NSArray * vs = [value componentsSeparatedByString:@" "];
    CGFloat fontSize =0 ;
    for(NSString * v in vs) {
        if([v hasSuffix:@"px"]) {
            fontSize = KKPixelValue(KKPixelFromString(v),0,0);
        } else if([v isEqualToString:@"bold"]) {
            return [UIFont boldSystemFontOfSize:fontSize];
        } else if([v isEqualToString:@"italic"]) {
            return [UIFont italicSystemFontOfSize:fontSize];
        } else {
            UIFont * vv = [UIFont fontWithName:v size:fontSize];
            if(vv) {
                return vv;
            }
        }
    }
    return [UIFont systemFontOfSize:fontSize];
    
}

@end
