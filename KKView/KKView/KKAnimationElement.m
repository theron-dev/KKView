//
//  KKAnimationElement.m
//  KKView
//
//  Created by 张海龙 on 2018/4/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKAnimationElement.h"
#import "KKPixel.h"
#import "KKViewContext.h"

@implementation KKAnimationElement

@synthesize animation = _animation;

+(void) initialize {
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKAnimationElement class] name:@"animation"];
    [KKViewContext setDefaultElementClass:[KKElement class] name:@"anim:transform"];
    [KKViewContext setDefaultElementClass:[KKElement class] name:@"anim:opacity"];
}

-(CAAnimation *) animation {
    if(_animation == nil) {
        
        CAAnimationGroup * group = [CAAnimationGroup animation];
        
        group.duration = [[self get:@"duration"] floatValue] * 0.001;
        group.repeatCount = [[self get:@"repeat-count"] intValue];
        group.autoreverses = KKBooleanValue( [self get:@"autoreverses"] );
        group.timeOffset = [[self get:@"delay"] floatValue] * 0.001;
        
        NSMutableArray* animations = [NSMutableArray arrayWithCapacity:4];
        
        KKElement * e = self.firstChild;
        
        while(e) {
            
            NSString * name = [e get:@"#name"];
            
            if([name isEqualToString:@"anim:transform"]) {
                
                CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"transform"];
                
                {
                    NSString * v = [e get:@"from"];
                    
                    if(v != nil) {
                        anim.fromValue = [NSValue valueWithCATransform3D:KKTransformFromString(v)];
                    }
                }
                
                {
                    NSString * v = [e get:@"to"];
                    
                    if(v != nil) {
                        anim.toValue = [NSValue valueWithCATransform3D:KKTransformFromString(v)];
                    }
                }
                
                {
                    NSString * v = [e get:@"delay"];
                    
                    if(v != nil) {
                        anim.timeOffset = [v floatValue] * 0.001f;
                    }
                }
                
                {
                    NSString * v = [e get:@"duration"];
                    
                    if(v != nil) {
                        anim.duration = [v floatValue] * 0.001f;
                    }
                }
                
                [animations addObject:anim];
                
            } else if([name isEqualToString:@"anim:opacity"]) {
                
                CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];

                {
                    NSString * v = [e get:@"from"];
                    
                    if(v != nil) {
                        anim.fromValue = @([v floatValue]);
                    }
                }
                
                {
                    NSString * v = [e get:@"to"];
                    
                    if(v != nil) {
                        anim.toValue = @([v floatValue]);
                    }
                }
                
                {
                    NSString * v = [e get:@"delay"];
                    
                    if(v != nil) {
                        anim.timeOffset = [v floatValue] * 0.001f;
                    }
                }
                
                {
                    NSString * v = [e get:@"duration"];
                    
                    if(v != nil) {
                        anim.duration = [v floatValue] * 0.001f;
                    }
                }
                
                [animations addObject:anim];
            }
            
            e = e.nextSibling;
        }
        
        group.animations = animations;
        
        _animation = group;
    }
    return _animation;
}

@end
