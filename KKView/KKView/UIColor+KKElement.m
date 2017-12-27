//
//  UIColor+KKElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "UIColor+KKElement.h"

@implementation UIColor (KKElement)

+(UIColor *) KKElementStringValue:(NSString *) value  {
    
    if(value == nil) {
        return nil;
    }
    
    if([value length] == 9) {
        unsigned int r=0,g=0,b=0,a=0;
        sscanf([value UTF8String], "#%02x%02x%02x%02x",&a,&r,&g,&b);
        return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a / 255.0];
    } else if([value length] == 7) {
        unsigned int r=0,g=0,b=0;
        sscanf([value UTF8String], "#%02x%02x%02x",&r,&g,&b);
        return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
    } else if([value length] == 4) {
        unsigned int r=0,g=0,b=0;
        sscanf([value UTF8String], "#%1x%1x%1x",&r,&g,&b);
        r = r << 4 | r;
        g = g << 4 | g;
        b = b << 4 | b;
        return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
    }
    
    return nil;
}

@end
