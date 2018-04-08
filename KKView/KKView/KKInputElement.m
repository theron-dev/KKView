//
//  KKInputElement.m
//  KKView
//
//  Created by 张海龙 on 2018/4/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKInputElement.h"
#import "KKViewContext.h"
#import "UIColor+KKElement.h"
#import "UIFont+KKElement.h"

@interface KKInputElement()<UITextFieldDelegate>
@end

@implementation KKInputElement

+(void) initialize {
    [super initialize];
    [KKViewContext setDefaultElementClass:[KKInputElement class] name:@"input"];
}

-(Class) viewClass {
    return [UITextField class];
}

-(void) setView:(UIView *)view {
    [(UITextField*) self.view setDelegate:nil];
    [super setView:view];
    [(UITextField*) self.view setDelegate:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self setStatus:@"active"];
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    
    e.data = self.data;
    
    [self emit:@"focus" event:e];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self setStatus:@""];
    
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    
    e.data = self.data;
    
    [self emit:@"blur" event:e];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    __weak KKInputElement * element = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(element) {
            
            UITextField * textField = (UITextField *) element.view;
            
            if(textField) {
                
                KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
                
                NSMutableDictionary * data = element.data;
                
                data[@"value"] = textField.text;
                
                e.data = data;
                
                [self emit:@"change" event:e];
                
            }
        }
    });
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end


@implementation UITextField (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
    
    if([key isEqualToString:@"value"]) {
        self.text = value;
    } else if([key isEqualToString:@"placeholder"] || [key isEqualToString:@"placeholder-color"]) {
        UIColor * v = [UIColor KKElementStringValue:[element get:@"placeholder-color"]];
        if(v == nil) {
            self.attributedPlaceholder = nil;
            self.placeholder = [element get:@"placeholder"];
        } else {
            self.placeholder = nil;
            self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[element get:@"placeholder"] attributes:@{NSForegroundColorAttributeName:v}];
        }
    } else if([key isEqualToString:@"color"]) {
        self.textColor = [UIColor KKElementStringValue:value];
    } else if([key isEqualToString:@"autofocus"]) {
        if(KKBooleanValue(value)) {
            [self becomeFirstResponder];
        }
    } else if([key isEqualToString:@"text-align"]) {
        self.textAlignment = KKTextAlignmentFromString(value);
    } else if([key isEqualToString:@"font"]) {
        self.font = [UIFont KKElementStringValue:value];
    }
}


@end
