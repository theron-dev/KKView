//
//  KKTextElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKTextElement.h"

#import "UIFont+KKElement.h"
#import "UIColor+KKElement.h"

@interface KKTextElement() {
    BOOL _displaying;
    CGRect _bounds;
    CGSize _size;
}

-(void) setNeedsDisplay;

@end


@implementation KKImgElement

-(NSString *) text {
    return [self get:@"#text"];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    NSString * value = [self get:key];
    if([@"width" isEqualToString:key]) {
        self.width = KKPixelFromString(value);
    } else if([@"height" isEqualToString:key]) {
        self.height = KKPixelFromString(value);
    } else if([@"margin" isEqualToString:key]) {
        self.margin = KKEdgeFromString(value);
    } else if([@"src" isEqualToString:key]) {
        self.image = nil;
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    }
}

-(CGRect) bounds {
    
    CGFloat width = KKPixelValue(self.width, 0, MAXFLOAT);
    CGFloat height = KKPixelValue(self.height, 0, MAXFLOAT);
    
    CGSize size = self.image.size;
    
    if(width == MAXFLOAT && height == MAXFLOAT) {
        width = size.width;
        height = size.height;
    } else if(width == MAXFLOAT ) {
        if(size.height != 0) {
            width = height * size.width / size.height;
        } else {
            width = 0;
        }
    } else if(height == MAXFLOAT ) {
        if(size.width != 0) {
            height = width * size.height / size.width;
        } else {
            height = 0;
        }
    }
    
    CGFloat mleft = KKPixelValue(self.margin.left, 0, 0);
    CGFloat mtop = KKPixelValue(self.margin.top, 0, 0);
    CGFloat mright = KKPixelValue(self.margin.right, 0, 0);
    CGFloat mbottom = KKPixelValue(self.margin.bottom, 0, 0);
    return CGRectMake(mleft - mright, mtop - mbottom, width + mleft + mright, height + mtop + mbottom);
}

-(NSString *) src {
    return [self get:@"src"];
}

-(UIImage *) image {
    if(_image == nil) {
        NSString * v = self.src;
        if([v hasPrefix:@"http://"] || [v hasPrefix:@"https://"]) {
            
        } else {
            _image = [UIImage imageNamed:v];
        }
    }
    return _image;
}

@end


@implementation KKSpanElement

-(NSString *) text {
    return [self get:@"#text"];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    NSString * value = [self get:key];
    if([@"font" isEqualToString:key]) {
        self.font = [UIFont KKElementStringValue:value];
    } else if([@"color" isEqualToString:key]) {
        self.color = [UIColor KKElementStringValue:value];
    } else if([@"letter-spacing" isEqualToString:key]) {
        self.letterSpacing = KKPixelFromString(value);
    } else if([@"#text" isEqualToString:key]) {
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    }
}

@end

static CGSize KKTextElementLayout(KKViewElement * element);
static NSDictionary * KKTextElementAttribute(KKTextElement * e,KKElement * element);


@implementation KKTextElement

@synthesize attributedString = _attributedString;

-(instancetype) init{
    if((self = [super init])) {
        [super setLayout:KKTextElementLayout];
        [self setAttrs:@{@"view":@"UILabel"}];
    }
    return self;
}

-(void) setLayout:(KKViewElementLayout)layout {
    [super setLayout:KKTextElementLayout];
}

-(NSString *) text {
    return [self get:@"#text"];
}

-(NSAttributedString *) attributedString {
    if(_attributedString == nil) {
        KKElement * p = self.firstChild;
        if(p == NULL) {
            NSString * v = self.text;
            _attributedString = ([[NSAttributedString alloc] initWithString:v ? v : @"" attributes:KKTextElementAttribute(self, self)]);
        } else {
            
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc] init];
            
            while(p != nil) {
                
                if([p isKindOfClass:[KKSpanElement class]]){
                    KKSpanElement * e = (KKSpanElement *) p;
                    NSString * v = e.text;
                    [string appendAttributedString:[[NSAttributedString alloc] initWithString:v?v:@"" attributes:KKTextElementAttribute(self, p)]];
                    
                    p = p.nextSibling;
                    
                    continue;
                }
                
                if([p isKindOfClass:[KKImgElement class]]) {
                    
                    KKImgElement * e = (KKImgElement *) p;
                    
                    NSTextAttachment * image = [[NSTextAttachment alloc] init];
                    
                    image.image = e.image;
                    image.bounds = e.bounds;
                    
                    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:image]];
                    
                    p = p.nextSibling;
                    
                    continue;
                }
                
                p = p.nextSibling;
            }
            
            _attributedString = (string);
        }
        
    }
    return _attributedString;
}

-(CGRect) bounds:(CGSize) size {
    if(!CGSizeEqualToSize(_size, size)) {
        _size = size;
        _bounds = [[self attributedString] boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    }
    return _bounds;
}

-(void) setView:(UIView *)view {
    [super setView:view];
    [self setNeedsDisplay];
}

-(void) setNeedsDisplay {
    
    if(_displaying) {
        return;
    }
    
    _attributedString = nil;
    _displaying = true;
    _bounds= CGRectZero;
    _size = CGSizeZero;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UILabel * v = (UILabel *) [self view];
        
        if([v isKindOfClass:[UILabel class]]) {
            [v setAttributedText:self.attributedString];
        }
        
        _displaying = false;
    });
    
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    NSString * value = [self get:key];
    if([@"font" isEqualToString:key]) {
        self.font = [UIFont KKElementStringValue:value];
    } else if([@"color" isEqualToString:key]) {
        self.color = [UIColor KKElementStringValue:value];
    } else if([@"line-spacing" isEqualToString:key]) {
        self.lineSpacing = KKPixelFromString(value);
    } else if([@"paragraph-spacing" isEqualToString:key]) {
        self.paragraphSpacing = KKPixelFromString(value);
    } else if([@"letter-spacing" isEqualToString:key]) {
        self.letterSpacing = KKPixelFromString(value);
    } else if([@"text-align" isEqualToString:key]) {
        if([value isEqualToString:@"right"]) {
            self.textAlign = NSTextAlignmentRight;
        } else if([value isEqualToString:@"center"]) {
            self.textAlign = NSTextAlignmentCenter;
        } if([value isEqualToString:@"justify"]) {
            self.textAlign = NSTextAlignmentJustified;
        } else {
            self.textAlign = NSTextAlignmentLeft;
        }
    } else if([@"#text" isEqualToString:key]) {
        [self setNeedsDisplay];
    }
}

@end

CGSize KKTextElementLayout(KKViewElement * element) {
    
    CGSize size = element.frame.size;
    
    KKTextElement * v = (KKTextElement *) element;
    
    if(size.width == MAXFLOAT || size.height == MAXFLOAT) {
        CGRect r = [v bounds:size];
        CGFloat pleft = KKPixelValue(v.padding.left, 0, 0);
        CGFloat pright = KKPixelValue(v.padding.right, 0, 0);
        CGFloat ptop = KKPixelValue(v.padding.top, 0, 0);
        CGFloat pbottom = KKPixelValue(v.padding.bottom, 0, 0);
        r.size.width = ceil(r.size.width + pleft + pright );
        r.size.height = ceil(r.size.height + ptop + pbottom );
        return r.size;
    } else {
        return size;
    }
    
}


static NSDictionary * KKTextElementAttribute(KKTextElement * e,KKElement * element) {
    
    NSMutableDictionary * attrs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    attrs[NSForegroundColorAttributeName] = e.color;
    attrs[NSFontAttributeName] = e.font;
    attrs[NSKernAttributeName] = @(KKPixelValue(e.letterSpacing, 0, 0));
    
    NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
    
    {
        style.alignment = e.textAlign;
    }
    
    style.lineSpacing = KKPixelValue(e.lineSpacing, 0, 0);
    style.paragraphSpacing = KKPixelValue(e.paragraphSpacing, 0, 0);
    
    if(e != element && [element isKindOfClass:[KKSpanElement class]]) {
        
        KKSpanElement * ee = (KKSpanElement *) element;
        
        {
            UIColor * v = ee.color;
            if( v != NULL ) {
                attrs[NSForegroundColorAttributeName] = v;
            }
        }
        
        {
            UIFont * v = ee.font;
            
            if( v != nil ) {
                attrs[NSFontAttributeName] = v;
            }
        }
        
        {

            if( ee.letterSpacing.type != KKPixelTypeAuto ) {
                attrs[NSKernAttributeName] = @(KKPixelValue(ee.letterSpacing, 0, 0));
            }
        }
        
    }
    
    attrs[NSParagraphStyleAttributeName] = style;
    
    return attrs;
    
}
