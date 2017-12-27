//
//  KKPixel.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKPixel.h"

struct KKPixel KKPixelFromString(NSString * value) {
    struct KKPixel v = {0,KKPixelTypeAuto};
    if([value isEqualToString:@"auto"]) {
        v.type = KKPixelTypeAuto;
    } else if([value hasSuffix:@"%"]) {
        v.type = KKPixelTypePercent;
        v.value = [value floatValue];
    } else if([value hasSuffix:@"rpx"]) {
        v.type = KKPixelTypeRPX;
        v.value = [value floatValue];
    } else  {
        v.type = KKPixelTypePX;
        v.value = [value floatValue];
    }
    return v;
}

struct KKEdge KKEdgeFromString(NSString * value) {
    struct KKEdge v = {{0,KKPixelTypeAuto},{0,KKPixelTypeAuto},{0,KKPixelTypeAuto},{0,KKPixelTypeAuto}};
    NSArray * vs = [value componentsSeparatedByString:@" "];
    if([vs count] > 0) {
        v.top = KKPixelFromString(vs[0]);
        if([vs count] > 1) {
            
            v.right = KKPixelFromString(vs[1]);
            
            if([vs count] > 2) {
                
                v.bottom = KKPixelFromString(vs[2]);
                
                if([vs count] > 3) {
                    v.left = KKPixelFromString(vs[3]);
                } else {
                    v.left = v.right;
                }
                
            } else {
                v.bottom = v.top;
                v.left = v.right;
            }
            
        } else {
            v.left = v.right = v.bottom = v.top;
        }
    }
    return v;
}

CGFloat KKPixelUnitPX() {
    return 1;
}

CGFloat KKPixelUnitRPX() {
    static CGFloat v = 0;
    if(v == 0) {
        v = [UIScreen mainScreen].bounds.size.width / 750.0;
    }
    return v;
}

CGFloat KKPixelValue(struct KKPixel  v ,CGFloat baseOf,CGFloat defaultValue) {
    switch (v.type) {
        case KKPixelTypePercent:
            return v.value * baseOf * 0.01;
        case KKPixelTypePX:
            return v.value * KKPixelUnitPX();
        case KKPixelTypeRPX:
            return v.value * KKPixelUnitRPX();
        default:
            break;
    }
    return defaultValue;
}

extern NSString * KKStringValue(id value) {
    if([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return nil;
}

extern BOOL KKBooleanValue(id value) {
    
    if([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
   
    if([value isKindOfClass:[NSString class]]) {
        return [value isEqualToString:@"true"] || [value isEqualToString:@"yes"];
    }
    
    return value ? true: false;
}
