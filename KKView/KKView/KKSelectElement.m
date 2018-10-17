//
//  KKSelectElement.m
//  KKView
//
//  Created by zhanghailong on 2018/9/6.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKSelectElement.h"
#import "JSContext+KKView.h"
#import "UIFont+KKElement.h"
#import "UIColor+KKElement.h"
#import "KKViewContext.h"

@interface KKSelectDefaultInputView : UIView<KKSelectInputView,UIPickerViewDelegate,UIPickerViewDataSource> {
    NSArray<KKSelectOption> * _options;
    KKSelectInputViewConfirmFunc _confirm;
    UIPickerView * _pickerView;
    UIToolbar * _toolbar;
    NSUInteger _selectedIndex;
}

@end

@implementation KKSelectDefaultInputView

@synthesize inputResponder = _inputResponder;

-(instancetype) initWithFrame:(CGRect)frame {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    if((self = [super initWithFrame:CGRectMake(0, 0, size.width , 260)])) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, size.width, 216)];
        [_pickerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
        [self addSubview:_pickerView];
        
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, size.width, 44)];
        [_pickerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_toolbar setItems:@[
                             [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancelAction)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(doConfirmAction)]
                             ]];
        [self addSubview:_toolbar];
    }
    return self;
}

-(void) doCancelAction {
    
    if(_confirm) {
        _confirm(nil);
    }
    
    _options = nil;
    _confirm = nil;
    [_pickerView reloadAllComponents];
}

-(void) doConfirmAction {
    

    if(_confirm) {
        
        if(_selectedIndex < [_options count]) {
            _confirm(_options[_selectedIndex]);
        } else {
            _confirm(nil);
        }
        
    }
    
    _options = nil;
    _confirm = nil;
    [_pickerView reloadAllComponents];
    
}

-(void) setOptions:(NSArray<KKSelectOption> *) options confirm:(KKSelectInputViewConfirmFunc) confirm inputResponder:(UIResponder *) inputResponder {
    _inputResponder = inputResponder;
    _options = options;
    _confirm = confirm;
    [_pickerView reloadAllComponents];
    _selectedIndex = 0;
    
    for(id<KKSelectOption> opt in options) {
        if([opt isSelected]) {
            break;
        }
        _selectedIndex ++;
    }
    
    if([_options count] >0) {
        [_pickerView selectRow:_selectedIndex inComponent:0 animated:NO];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedIndex = row;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_options count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(row < [_options count]) {
        return [[_options objectAtIndex:row] text];
    }
    return @"";
}

@end

@interface KKSelectElement() {
    NSMutableArray<KKSelectOption> * _options;
}

@property(nonatomic,strong,readonly) NSArray<KKSelectOption> * options;

@end

@implementation KKSelectOptionElement

-(NSString *) text {
    return [self get:@"#text"];
}

-(NSString *) value {
    return [self get:@"value"];
}

-(BOOL) isSelected {
    NSString * v = [self.parent get:@"value"];
    return [v isEqualToString:self.value];
}

@end

@interface KKSelectView : UIControl

@property(nonatomic,weak) KKSelectElement * element;
@property(nonatomic,readonly,strong) UILabel * textView;

@end

@implementation KKSelectView

@synthesize textView = _textView;

-(instancetype) initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        _textView = [[UILabel alloc] initWithFrame:self.bounds];
        [_textView setUserInteractionEnabled:NO];
        [_textView setNumberOfLines:0];
        [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:_textView];
        
        [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
        
        [self addTarget:self action:@selector(doTapAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void) doTapAction {
    [self becomeFirstResponder];
}

-(UIView *) inputView {
    return [KKSelectElement defaultInputView];
}

-(void) dealloc {
    
    [self removeObserver:self forKeyPath:@"enabled"];
    [self removeTarget:self action:@selector(doTapAction) forControlEvents:UIControlEventTouchUpInside];
    
}

-(BOOL) canBecomeFirstResponder {
    if([self isEnabled]) {
        
        __weak KKSelectView * view = self;
        __weak KKElement * element = _element;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(view) {
                [view updateInputView];
                [view updateStatus];
            }
            if(element) {
                KKElementEvent * e = [[KKElementEvent alloc] initWithElement:element];
                e.data = element.data;
                [element emit:@"focus" event:e];
            }
        });
    }
    return [self isEnabled];
}

-(BOOL) resignFirstResponder {
    
    __weak KKSelectView * view = self;
    __weak KKElement * element = _element;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(view) {
            [view clearInputView];
            [view updateStatus];
        }
        if(element) {
            KKElementEvent * e = [[KKElementEvent alloc] initWithElement:element];
            e.data = element.data;
            [element emit:@"blur" event:e];
        }
    });
    
    return [super resignFirstResponder];
}

-(void) KKElementObtainView:(KKViewElement *)element {
    _element = (KKSelectElement *) element;
    [super KKElementObtainView:element];
}

-(void) KKElementRecycleView:(KKViewElement *)element {
    _element = nil;
    [super KKElementRecycleView:element];
}

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value {
    [super KKViewElement:element setProperty:key value:value];
    
    if([key isEqualToString:@"value"]) {
        self.textView.text = value;
    } else if([key isEqualToString:@"color"]) {
        self.textView.textColor = [UIColor KKElementStringValue:value];
    } else if([key isEqualToString:@"autofocus"]) {
        if(KKBooleanValue(value)) {
            if([element isObtaining]) {
                __weak UIView * v = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [v becomeFirstResponder];
                });
            } else {
                [self becomeFirstResponder];
            }
        }
    } else if([key isEqualToString:@"text-align"]) {
        self.textView.textAlignment = KKTextAlignmentFromString(value);
    } else if([key isEqualToString:@"font"]) {
        self.textView.font = [UIFont KKElementStringValue:value];
    } else if([key isEqualToString:@"enabled"]) {
        self.enabled = KKBooleanValue(value);
    }
}

-(void) updateStatus {
    if(![self isEnabled]) {
        [_element setStatus:@"disabled"];
    } else if([self isFirstResponder]) {
        [_element setStatus:@"active"];
    } else {
        [_element setStatus:@""];
    }
}

-(void) clearInputView {
    
    UIView<KKSelectInputView> * inputView = (UIView<KKSelectInputView> *) self.inputView;
    
    if(inputView.inputResponder == self) {
        [inputView setOptions:nil confirm:nil inputResponder:nil];
    }
    
}

-(void) updateInputView {
    
    UIView<KKSelectInputView> * inputView = (UIView<KKSelectInputView> *) self.inputView;
    
    UIView * v = self;
    UIColor * tintColor = nil;
    
    while(v && tintColor == nil) {
        tintColor = v.tintColor;
        v = [v superview];
    }
    
    if(tintColor == nil) {
        tintColor = self.window.tintColor;
    }
    
    inputView.tintColor = tintColor;
    
    __weak UIView * view = self;
    __weak KKElement * element = _element;
    
    [inputView setOptions:[_element options] confirm:^(id<KKSelectOption> option) {
        
        if(element) {
            
            if(option) {
                [element set:@"value" value:option.value];
                KKElementEvent * e = [[KKElementEvent alloc] initWithElement:element];
                NSMutableDictionary * data = element.data;
                data[@"value"] = option.value;
                e.data = data;
                [element emit:@"change" event:e];
            }
            
            KKElementEvent * e = [[KKElementEvent alloc] initWithElement:element];
            NSMutableDictionary * data = element.data;
            e.data = data;
            [element emit:@"done" event:e];
            
        }
        
        [view resignFirstResponder];
        
    } inputResponder:self];
    
    [self reloadInputViews];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if([keyPath isEqualToString:@"enabled"]) {
        if(![self isEnabled]) {
            [self resignFirstResponder];
        }
        [self updateStatus];
    }
    
}


@end


@implementation KKSelectElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKSelectElement class] name:@"select"];
    [KKViewContext setDefaultElementClass:[KKSelectOptionElement class] name:@"option"];
    
}

-(instancetype) init{
    if((self = [super init])) {
        _options = [[NSMutableArray<KKSelectOption> alloc] initWithCapacity:4];
    }
    return self;
}

-(void) didAddChildren:(KKElement *)element {
    [super didAddChildren:element];
    if([element isKindOfClass:[KKSelectOptionElement class]]) {
        [_options addObject:(KKSelectOptionElement *) element];
    }
}

-(void) willRemoveChildren:(KKElement *)element {
    [super willRemoveChildren:element];
    if([element isKindOfClass:[KKSelectOptionElement class]]) {
        [_options removeObject:(KKSelectOptionElement *) element];
    }
}

-(UILabel *) textView {
    UIView * v = self.view;
    
    if([v isKindOfClass:[KKSelectView class]]) {
        return [(KKSelectView *) v textView];
    }
    
    return nil;
}

-(Class) viewClass {
    return [KKSelectView class];
}

static UIView<KKSelectInputView> * _KKSelectElementDefaultInputView = nil;

+(UIView<KKSelectInputView> *) defaultInputView {
    if(_KKSelectElementDefaultInputView == nil){
        _KKSelectElementDefaultInputView = [[KKSelectDefaultInputView alloc] initWithFrame:CGRectZero];
    }
    return _KKSelectElementDefaultInputView;
}

+(void) setDefaultInputView:(UIView<KKSelectInputView> *) inputView {
    _KKSelectElementDefaultInputView = inputView;
}

@end
