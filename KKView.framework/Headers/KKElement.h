//
//  KKElement.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKElement : NSObject

@property(nonatomic,strong,readonly) KKElement * firstChild;
@property(nonatomic,strong,readonly) KKElement * lastChild;
@property(nonatomic,strong,readonly) KKElement * nextSibling;
@property(nonatomic,weak,readonly) KKElement * prevSibling;
@property(nonatomic,weak,readonly) KKElement * parent;

-(void) append:(KKElement * ) element;
-(void) before:(KKElement * ) element;
-(void) after:(KKElement * ) element;
-(void) remove;

-(void) appendTo:(KKElement * ) element;
-(void) beforeTo:(KKElement * ) element;
-(void) afterTo:(KKElement * ) element;

-(void) changedKeys:(NSSet *) keys;

-(NSString *) get:(NSString *) key;

-(void) set:(NSString *) key value:(NSString *) value;

-(void) setAttrs:(NSDictionary *) attrs;

-(void) setStyle:(NSDictionary *) style forStatus:(NSString *) status;

-(NSString *) status;

-(void) setStatus:(NSString *) status;

@end
