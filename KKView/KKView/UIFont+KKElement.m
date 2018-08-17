//
//  UIFont+KKElement.m
//  KKView
//
//  Created by zhanghailong on 2017/12/25.
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
    BOOL bold = NO;
    BOOL italic = NO;
    NSString * name = nil;
    
    for(NSString * v in vs) {
        
        if(KKPixelIsValue(v)) {
            fontSize = KKPixelValue(KKPixelFromString(v),0,0);
        } else if([v isEqualToString:@"bold"]) {
            bold = YES;
        } else if([v isEqualToString:@"italic"]) {
            italic = YES;
        } else if([v length]){
            name = v;
        }
    }
    
    if(name) {
        UIFont * v = [UIFont fontWithName:name size:fontSize];
        if(v) {
            return v;
        }
    }
    
    if(bold) {
        return [UIFont boldSystemFontOfSize:fontSize];
    }
    if(italic) {
        return [UIFont italicSystemFontOfSize:fontSize];
    }
    return [UIFont systemFontOfSize:fontSize];
    
}

@end
