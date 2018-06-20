//
//  KKPixel.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKPixel.h"

enum KKPosition KKPositionFromString(NSString * value) {
    
    if([value isEqualToString:@"top"]) {
        return KKPositionTop;
    }
    
    if([value isEqualToString:@"bottom"]) {
        return KKPositionBottom;
    }
    
    if([value isEqualToString:@"left"]) {
        return KKPositionTop;
    }
    
    if([value isEqualToString:@"right"]) {
        return KKPositionBottom;
    }
    
    return KKPositionNone;
}

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
    } else if([value hasSuffix:@"vw"]) {
        v.type = KKPixelTypeVW;
        v.value = [value floatValue];
    } else if([value hasSuffix:@"vh"]) {
        v.type = KKPixelTypeVH;
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

NSString * NSStringFromKKPixel(struct KKPixel v) {
    switch (v.type) {
        case KKPixelTypeAuto:
            return @"auto";
            break;
        case KKPixelTypePercent:
            return [NSString stringWithFormat:@"%g%%",v.value];
        case KKPixelTypeRPX:
            return [NSString stringWithFormat:@"%grpx",v.value];
        case KKPixelTypeVW:
            return [NSString stringWithFormat:@"%gvw",v.value];
        case KKPixelTypeVH:
            return [NSString stringWithFormat:@"%gvh",v.value];
        default:
            break;
    }
    return [NSString stringWithFormat:@"%gpx",v.value];
}

NSString * NSStringFromKKEdge(struct KKEdge v) {
    return [NSString stringWithFormat:@"%@ %@ %@ %@",
            NSStringFromKKPixel(v.top),
            NSStringFromKKPixel(v.right),
            NSStringFromKKPixel(v.bottom),
            NSStringFromKKPixel(v.left)];
}

CGFloat KKPixelUnitPX() {
    return 1;
}

CGFloat KKPixelUnitRPX() {

    CGSize size = [UIScreen mainScreen].bounds.size;
    
    if(size.width > size.height) {
        return size.height / 750.0f;
    } else {
        return size.width / 750.0f;
    }
}

CGFloat KKPixelUnitVW() {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.width / 100.0f;
}

CGFloat KKPixelUnitVH() {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.height / 100.0f;
}

CGFloat KKPixelValue(struct KKPixel  v ,CGFloat baseOf,CGFloat defaultValue) {
    switch (v.type) {
        case KKPixelTypePercent:
            return v.value * baseOf * 0.01;
        case KKPixelTypePX:
            return v.value * KKPixelUnitPX();
        case KKPixelTypeRPX:
            return v.value * KKPixelUnitRPX();
        case KKPixelTypeVW:
            return v.value * KKPixelUnitVW();
        case KKPixelTypeVH:
            return v.value * KKPixelUnitVH();
        default:
            break;
    }
    return defaultValue;
}

BOOL KKPixelIsValue(NSString * value) {
    return [value hasSuffix:@"%"]
        || [value hasSuffix:@"px"]
        || [value hasSuffix:@"rpx"]
        || [value hasSuffix:@"vw"]
        || [value hasSuffix:@"vh"]
        || [value isEqualToString:@"auto"];
}

NSString * KKStringValue(id value) {
    if([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return nil;
}

BOOL KKBooleanValue(id value) {
    
    if([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
   
    if([value isKindOfClass:[NSString class]]) {
        return [value isEqualToString:@"true"] || [value isEqualToString:@"yes"] || [value isEqualToString:@"1"];
    }
    
    return value ? true: false;
}

enum KKVerticalAlign KKVerticalAlignFromString(NSString * value) {
    if([value isEqualToString:@"middle"]) {
        return KKVerticalAlignMiddle;
    }
    if([value isEqualToString:@"bottom"]) {
        return KKVerticalAlignBottom;
    }
    return KKVerticalAlignTop;
}

NSTextAlignment KKTextAlignmentFromString(NSString * value) {
    if([value isEqualToString:@"right"]) {
        return NSTextAlignmentRight;
    } else if([value isEqualToString:@"center"]) {
        return NSTextAlignmentCenter;
    } else if([value isEqualToString:@"justify"]) {
        return NSTextAlignmentJustified;
    }
    return NSTextAlignmentLeft;
}

CATransform3D KKTransformFromString(NSString * value) {
    CATransform3D v = CATransform3DIdentity;

    for(NSString * i in [value componentsSeparatedByString:@" "]) {
        if([i hasPrefix:@"translate("]) {
            char x[255] = "",y[255] = "",z[255] = "";
            sscanf([i UTF8String], "translate(%[^, \\)],%[^, \\)],%[^, \\)])",x,y,z);
            CGFloat tx = KKPixelValue(KKPixelFromString([NSString stringWithUTF8String:x]), 0, 0);
            CGFloat ty = KKPixelValue(KKPixelFromString([NSString stringWithUTF8String:y]), 0, 0);
            CGFloat tz = KKPixelValue(KKPixelFromString([NSString stringWithUTF8String:z]), 0, 0);
            v = CATransform3DTranslate(v, tx, ty, tz);
        } else if([i hasPrefix:@"scale("]) {
            float x=0,y=0,z=0;
            sscanf([i UTF8String], "scale(%f,%f,%f)",&x,&y,&z);
            v = CATransform3DScale(v,x , y, z);
        } else if([i hasPrefix:@"rotateX("]) {
            float a=0;
            sscanf([i UTF8String], "rotateX(%f)",&a);
            v = CATransform3DRotate(v, a * M_PI / 180.0f, 1.0, 0, 0);
        } else if([i hasPrefix:@"rotateY("]) {
            float a=0;
            sscanf([i UTF8String], "rotateY(%f)",&a);
            v = CATransform3DRotate(v, a * M_PI / 180.0f, 0, 1, 0);
        } else if([i hasPrefix:@"rotateZ("]) {
            float a=0;
            sscanf([i UTF8String], "rotateZ(%f)",&a);
            v = CATransform3DRotate(v, a * M_PI / 180.0f, 0, 0, 1);
        } else if([i hasPrefix:@"rotate("]) {
            float a=0;
            sscanf([i UTF8String], "rotate(%f)",&a);
            v = CATransform3DRotate(v, a * M_PI / 180.0f, 0, 0, 1);
        }
    }
    return v;
}

enum KKTextDecoration KKTextDecorationFromString(NSString * value) {
    
    if([value isEqualToString:@"underline"]) {
        return KKTextDecorationUnderline;
    }
    
    if([value isEqualToString:@"line-through"]) {
        return KKTextDecorationLineThrough;
    }
    
    return KKTextDecorationNone;
}
