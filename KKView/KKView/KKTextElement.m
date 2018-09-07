//
//  KKTextElement.m
//  KKView
//
//  Created by zhanghailong on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKTextElement.h"
#import "JSContext+KKView.h"
#import "UIFont+KKElement.h"
#import "UIColor+KKElement.h"
#import "KKViewContext.h"

@interface KKTextElement() {
    BOOL _displaying;
    CGRect _bounds;
    CGSize _size;
}

-(void) setNeedsDisplay;

@end

@interface KKImgElement() {
    KKViewContext * _context;
}

@end

@implementation KKImgElement

+(void) initialize{
    [KKViewContext setDefaultElementClass:[KKImgElement class] name:@"img"];
}

-(instancetype) init {
    if((self = [super init])) {
        _context = [KKViewContext currentContext];
    }
    return self;
}

-(NSString *) text {
    return [self get:@"#text"];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    NSString * value = [self get:key];
    if([@"width" isEqualToString:key]) {
        self.width = KKPixelFromString(value);
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    } else if([@"height" isEqualToString:key]) {
        self.height = KKPixelFromString(value);
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    } else if([@"margin" isEqualToString:key]) {
        self.margin = KKEdgeFromString(value);
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
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
    return CGRectMake(- mleft + mright, - mtop + mbottom, width , height);
}

-(NSString *) src {
    return [self get:@"src"];
}

-(UIImage *) image {
    if(_image == nil) {
        NSString * v = self.src;
        if(_context == nil) {
            if([v hasPrefix:@"http://"] || [v hasPrefix:@"https://"]) {
                _image = [KKHttp imageWithURL:v];
            } else {
                _image = [UIImage kk_imageWithPath:v];
            }
        } else {
            _image = [_context imageWithURI:v];
        }
    }
    return _image;
}

@end


@implementation KKSpanElement

@synthesize lineSpacing = _lineSpacing;
@synthesize paragraphSpacing = _paragraphSpacing;
@synthesize letterSpacing = _letterSpacing;
@synthesize baseline = _baseline;
@synthesize color = _color;
@synthesize font = _font;
@synthesize strokeColor = _strokeColor;
@synthesize strokeSpacing = _strokeSpacing;
@synthesize textDecoration = _textDecoration;

+(void) initialize{
    [KKViewContext setDefaultElementClass:[KKSpanElement class] name:@"span"];
}

-(NSString *) text {
    return [self get:@"#text"];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    NSString * value = [self get:key];
    if([@"font" isEqualToString:key]) {
        self.font = [UIFont KKElementStringValue:value];
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    } else if([@"color" isEqualToString:key]) {
        self.color = [UIColor KKElementStringValue:value];
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    } else if([@"letter-spacing" isEqualToString:key]) {
        self.letterSpacing = KKPixelFromString(value);
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    } else if([@"#text" isEqualToString:key]) {
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    } else if ([@"text-stroke" isEqualToString:key]) {
        NSArray * arr = [value componentsSeparatedByString:@" "];
        for(NSString *v in arr) {
            if(KKPixelIsValue(v)) {
                self.strokeSpacing = KKPixelFromString(v);
            } else if([v hasPrefix:@"#"]) {
                self.strokeColor = [UIColor KKElementStringValue:v];
            }
        }
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    } else if([@"text-decoration" isEqualToString:key]) {
        self.textDecoration = KKTextDecorationFromString(value);
        if([self.parent isKindOfClass:[KKTextElement class]]) {
            [(KKTextElement *) self.parent setNeedsDisplay];
        }
    }
}

@end

CGSize KKTextElementLayout(KKViewElement * element);

@implementation KKTextElement

@synthesize attributedString = _attributedString;
@synthesize lineSpacing = _lineSpacing;
@synthesize paragraphSpacing = _paragraphSpacing;
@synthesize letterSpacing = _letterSpacing;
@synthesize baseline = _baseline;
@synthesize color = _color;
@synthesize font = _font;
@synthesize strokeColor = _strokeColor;
@synthesize strokeSpacing = _strokeSpacing;
@synthesize textDecoration = _textDecoration;
@synthesize textAlign = _textAlign;

+(void) initialize{
    [KKViewContext setDefaultElementClass:[KKTextElement class] name:@"text"];
}

-(instancetype) init{
    if((self = [super init])) {
        [super setLayout:KKTextElementLayout];
    }
    return self;
}

-(Class) viewClass {
    return [UILabel class];
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
            _attributedString = ([[NSAttributedString alloc] initWithString:v ? v : @"" attributes:KKTextElementStringAttribute(self,nil)]);
        } else {
            
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc] init];
            
            while(p != nil) {
                
                if([p isKindOfClass:[KKSpanElement class]]){
                    KKSpanElement * e = (KKSpanElement *) p;
                    NSString * v = e.text;
                    [string appendAttributedString:[[NSAttributedString alloc] initWithString:v?v:@"" attributes:KKTextElementStringAttribute(self, p,nil)]];
                    
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
    [view setUserInteractionEnabled:NO];
    [(UILabel *)view setNumberOfLines:0];
}

-(void) display {
    
    UILabel * v = (UILabel *) [self view];
    
    if([v isKindOfClass:[UILabel class]]) {
        [v setAttributedText:self.attributedString];
    }
    
    _displaying = false;
    
}

-(void) setNeedsDisplay {
    
    _attributedString = nil;
    _bounds= CGRectZero;
    _size = CGSizeZero;
    
    if(_displaying) {
        return;
    }
    
    _displaying = true;
    
    __weak KKTextElement * e = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [e display];
    });
    
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    NSString * value = [self get:key];
    if([@"font" isEqualToString:key]) {
        self.font = [UIFont KKElementStringValue:value];
        [self setNeedsDisplay];
    } else if([@"color" isEqualToString:key]) {
        self.color = [UIColor KKElementStringValue:value];
        [self setNeedsDisplay];
    } else if([@"line-spacing" isEqualToString:key]) {
        self.lineSpacing = KKPixelFromString(value);
        [self setNeedsDisplay];
    } else if([@"paragraph-spacing" isEqualToString:key]) {
        self.paragraphSpacing = KKPixelFromString(value);
        [self setNeedsDisplay];
    } else if([@"letter-spacing" isEqualToString:key]) {
        self.letterSpacing = KKPixelFromString(value);
        [self setNeedsDisplay];
    } else if([@"baseline" isEqualToString:key]) {
        self.baseline = KKPixelFromString(value);
        [self setNeedsDisplay];
    } else if([@"text-align" isEqualToString:key]) {
        self.textAlign = KKTextAlignmentFromString(value);
        [self setNeedsDisplay];
    } else if([@"#text" isEqualToString:key]) {
        [self setNeedsDisplay];
    } else if ([@"text-stroke" isEqualToString:key]) {
        NSArray * arr = [value componentsSeparatedByString:@" "];
        for(NSString *v in arr) {
            if(KKPixelIsValue(v)) {
                self.strokeSpacing = KKPixelFromString(v);
            } else if([v hasPrefix:@"#"]) {
                self.strokeColor = [UIColor KKElementStringValue:v];
            }
        }
        [self setNeedsDisplay];
    } else if([@"text-decoration" isEqualToString:key]) {
        self.textDecoration = KKTextDecorationFromString(value);
        [self setNeedsDisplay];
    }
}

-(void) obtainView:(UIView *)view {
    [super obtainView:view];
    [self setNeedsDisplay];
}

@end

CGSize KKTextElementLayout(KKViewElement * element) {
    
    CGSize size = element.frame.size;
    
    KKTextElement * v = (KKTextElement *) element;
    
    if(size.width == MAXFLOAT || size.height == MAXFLOAT) {
        CGRect r = [v bounds:size];
        
        if(size.width == MAXFLOAT) {
            CGFloat pleft = KKPixelValue(v.padding.left, 0, 0);
            CGFloat pright = KKPixelValue(v.padding.right, 0, 0);
            size.width = ceil(r.size.width + pleft + pright );
        }
        
        if(size.height == MAXFLOAT) {
            CGFloat ptop = KKPixelValue(v.padding.top, 0, 0);
            CGFloat pbottom = KKPixelValue(v.padding.bottom, 0, 0);
            size.height = ceil(r.size.height + ptop + pbottom );
        }
        
        return size;
    } else {
        return size;
    }
    
}

NSDictionary * KKTextElementStringAttribute(KKElement<KKTextElement> * e,...) {
    
    va_list ap;
    
    va_start(ap, e);
    
    NSMutableDictionary * attrs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    attrs[NSForegroundColorAttributeName] = e.color;
    attrs[NSFontAttributeName] = e.font ;
    attrs[NSKernAttributeName] = @(KKPixelValue(e.letterSpacing, 0, 0));
    attrs[NSBaselineOffsetAttributeName] = @(KKPixelValue(e.baseline, 0, 0));
    
    switch (e.textDecoration) {
        case KKTextDecorationUnderline:
            attrs[NSUnderlineColorAttributeName] = e.color;
            attrs[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
            break;
        case KKTextDecorationLineThrough:
            attrs[NSStrikethroughColorAttributeName] = e.color;
            attrs[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
            break;
        default:
            break;
    }
    
    NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
    
    if([e respondsToSelector:@selector(textAlign)]) {
        style.alignment = e.textAlign;
    }
    
    style.lineSpacing = KKPixelValue(e.lineSpacing, 0, 0);
    style.paragraphSpacing = KKPixelValue(e.paragraphSpacing, 0, 0);
    
    if (e.strokeColor) {
        attrs[NSStrokeColorAttributeName] = e.strokeColor;
        attrs[NSStrokeWidthAttributeName] = @(-KKPixelValue(e.strokeSpacing, 0, 0) -2);
    }
    
    while((e = va_arg(ap, KKElement<KKTextElement> *))) {
        
        {
            UIColor * v = e.color;
            if( v != NULL ) {
                attrs[NSForegroundColorAttributeName] = v;
                if(attrs[NSUnderlineColorAttributeName] != nil) {
                    attrs[NSUnderlineColorAttributeName] = v;
                }
                if(attrs[NSStrikethroughColorAttributeName] != nil) {
                    attrs[NSStrikethroughColorAttributeName] = v;
                }
            }
        }
        
        {
            UIFont * v = e.font;
            
            if( v != nil ) {
                attrs[NSFontAttributeName] = v;
            }
        }
        
        {
            
            if( e.letterSpacing.type != KKPixelTypeAuto ) {
                attrs[NSKernAttributeName] = @(KKPixelValue(e.letterSpacing, 0, 0));
            }
        }
        
        {
            UIColor * v = e.strokeColor;
            if (v != nil) {
                attrs[NSStrokeColorAttributeName] = e.strokeColor;
                attrs[NSStrokeWidthAttributeName] = @(-(KKPixelValue(e.strokeSpacing, 0, 0)) - 2);
            }
        }
        
        switch (e.textDecoration) {
            case KKTextDecorationUnderline:
                attrs[NSUnderlineColorAttributeName] = attrs[NSForegroundColorAttributeName];
                attrs[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
                break;
            case KKTextDecorationLineThrough:
                attrs[NSStrikethroughColorAttributeName] = attrs[NSForegroundColorAttributeName];
                attrs[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
                break;
            default:
                break;
        }
        
    }
    
    va_end(ap);
    
    attrs[NSParagraphStyleAttributeName] = style;
    
    return attrs;
}


@implementation UILabel (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
    
    if([key isEqualToString:@"color"]) {
        self.textColor = [UIColor KKElementStringValue:value];
    } else if([key isEqualToString:@"font"]) {
        self.font = [UIFont KKElementStringValue:value];
    } else if([key isEqualToString:@"text-align"]) {
        self.textAlignment = KKTextAlignmentFromString(value);
    } else if([key isEqualToString:@"#text"]) {
        [(KKTextElement *) element setNeedsDisplay];
    }
    
}

@end
