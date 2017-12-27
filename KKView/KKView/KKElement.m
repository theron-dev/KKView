//
//  KKElement.m
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import "KKElement.h"

@interface KKElement() {
    NSMutableDictionary * _attributes;
    NSMutableDictionary * _styles;
}
@end

@implementation KKElement

-(void) append:(KKElement * ) element {
    
    if(element == nil) {
        return ;
    }
    
    __strong KKElement * e = element;
    
    [e remove];
    
    if(_lastChild) {
        _lastChild->_nextSibling = e;
        e->_prevSibling = _lastChild;
        _lastChild = e;
        e->_parent = self;
    } else {
        _firstChild = _lastChild = e;
        e->_parent = self;
    }
    
    [self didAddChildren:element];
}

-(void) before:(KKElement * ) element {
    
    if(element == nil) {
        return ;
    }
    
    __strong KKElement * e = element;
    
    [e remove];
    
    if(_prevSibling) {
        _prevSibling->_nextSibling = e;
        e->_prevSibling = _prevSibling;
        e->_nextSibling = self;
        e->_parent = _parent;
        _prevSibling = e;
    } else if(_parent) {
        e->_nextSibling = self;
        e->_parent = _parent;
        _prevSibling = e;
        _parent->_firstChild = e;
    }
    
    [_parent didAddChildren:element];
}

-(void) after:(KKElement * ) element {
    
    if(element == nil) {
        return ;
    }
    
    __strong KKElement * e = element;
    
    [e remove];
    
    if(_nextSibling) {
        _nextSibling->_prevSibling = e;
        e->_nextSibling = _nextSibling;
        e->_prevSibling = self;
        e->_parent = _parent;
        _nextSibling = e;
    } else if(_parent) {
        e->_prevSibling = self;
        e->_parent = _parent;
        _nextSibling = e;
        _parent->_lastChild = e;
    }
    
    [_parent didAddChildren:element];
}

-(void) remove {
    
    if(_prevSibling) {
        
        [_parent willRemoveChildren:self];
        
        _prevSibling->_nextSibling = _nextSibling;
        if(_nextSibling) {
            _nextSibling->_prevSibling = _prevSibling;
        } else {
            _parent->_lastChild = _prevSibling;
        }
    } else if(_parent) {
        
        [_parent willRemoveChildren:self];
        
        _parent->_firstChild = _nextSibling;
        if(_nextSibling) {
            _nextSibling->_prevSibling = NULL;
        } else {
            _parent->_lastChild = NULL;
        }
    }
}


-(void) appendTo:(KKElement * ) element {
    [element append:self];
}

-(void) beforeTo:(KKElement * ) element {
    [element before:element];
}

-(void) afterTo:(KKElement * ) element {
    [element after:element];
}


-(void) willRemoveChildren:(KKElement *) element {
    
}

-(void) didAddChildren:(KKElement *) element {
    
}

-(NSString *) get:(NSString *) key {
    NSString * v = [_attributes valueForKey:key];
    if(v == nil) {
        NSString * status = self.status;
        if(status == nil) {
            status = @"";
        }
        NSMutableDictionary * attrs = [_styles valueForKey:status];
        v = [attrs valueForKey:key];
    }
    return v;
}

-(void) set:(NSString *) key value:(NSString *) value {
    if(_attributes== nil) {
        _attributes = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    [_attributes setValue:value forKey:key];
    if([@"status" isEqualToString:key] || [@"in-status" isEqualToString:key]) {
        NSMutableSet * keys = [NSMutableSet setWithCapacity:4];
        NSMutableDictionary * attrs = [_styles valueForKey:@""];
        if(attrs) {
            [keys addObjectsFromArray:[attrs allKeys]];
        }
        NSString * status = self.status;
        if(status != nil && ![status isEqualToString:@""]) {
            attrs = [_styles valueForKey:status];
            if(attrs) {
                [keys addObjectsFromArray:[attrs allKeys]];
            }
        }
        [self changedKeys:keys];
    } else {
        [self changedKeys:[NSSet setWithObject:key]];
    }
}

-(void) setAttrs:(NSDictionary *) attrs {
    if(_attributes== nil) {
        _attributes = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    [_attributes addEntriesFromDictionary:attrs];
    [self changedKeys:[NSSet setWithArray:[attrs allKeys]]];
}

-(void) setStyle:(NSDictionary *) style forStatus:(NSString *) status {
    if(_styles == nil) {
        _styles = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    if(status == nil) {
        status = @"";
    }
    NSMutableDictionary * attrs = [_styles valueForKey:status];
    if(attrs == nil) {
        attrs = [[NSMutableDictionary alloc] initWithCapacity:4];
        [_styles setValue:attrs forKey:status];
    }
    [attrs setDictionary:style];
}

-(void) setCSSStyle:(NSString *) cssStyle forStatus:(NSString *) status {
    
    NSArray * vs = [cssStyle componentsSeparatedByString:@";"];
    
    NSMutableDictionary * attrs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    for(NSString * v in vs) {
        NSArray * kv = [v componentsSeparatedByString:@":"];
        NSString * key = [kv[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * value = nil;
        if([kv count] > 1) {
            value = [kv[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if(key && value) {
            [attrs setValue:value forKey:key];
        }
    }
    
    [self setStyle:attrs forStatus:status];
}

-(NSString *) status {
    NSString * v = [_attributes valueForKey:@"status"];
    if(v == nil) {
        v = [_attributes valueForKey:@"in-status"];
    }
    return v;
}

-(void) setStatus:(NSString *) status {
    [self set:@"status" value:status];
    KKElement * e = self.firstChild;
    while(e) {
        [e set:@"in-status" value:status];
        e = e.nextSibling;
    }
}

-(NSSet *) keys {
    
    NSMutableSet * keys = [NSMutableSet set];
    
    if(_attributes) {
        [keys addObjectsFromArray:[_attributes allKeys]];
    }
    
    NSString * v = self.status;
    
    if(v == nil) {
        v = @"";
    }
    
    NSDictionary * attr = [_styles valueForKey:v];
    
    if(attr) {
        [keys addObjectsFromArray:[attr allKeys]];
    }
    
    if(! [@"" isEqualToString:v]) {
        
        attr = [_styles valueForKey:@""];
        
        if(attr) {
            [keys addObjectsFromArray:[attr allKeys]];
        }
    }
    
    return keys;
}

-(void) changedKeys:(NSSet *) keys {
    for(NSString * key in keys) {
        [self changedKey:key];
    }
}

-(void) changedKey:(NSString *) key {
    
}

@end
