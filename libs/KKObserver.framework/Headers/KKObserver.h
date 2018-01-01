//
//  KKObserver.h
//  KKObserver
//
//  Created by 张海龙 on 2017/12/4.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef void (^KKObserverFunction)(id value,NSArray * changedKeys,void * context);

@protocol KKObserver<JSExport>

JSExportAs(changeKeys,
-(void) changeKeys:(NSArray *) keys
);

JSExportAs(get,
-(id) get:(NSArray *) keys defaultValue:(id) defaultValue
);

JSExportAs(set,
-(void) set:(NSArray *) keys value:(id) value
);

JSExportAs(on,
-(void) onJSFunctionKeys:(NSArray *) keys fn:(JSValue *) func context:(JSValue *) context
);

JSExportAs(evaluate,
-(void) onJSFunctionEvaluateScript:(NSString *) evaluateScript fn:(JSValue *) func context:(JSValue *) context
);

JSExportAs(off,
-(void) offJSFunctionKeys:(NSArray *) keys fn:(JSValue *) func context:(JSValue *) context
);

@end

@interface KKObserver : NSDictionary<KKObserver> {
    
}

@property(nonatomic,strong) id object;
@property(nonatomic,weak) KKObserver * parent;
@property(nonatomic,strong,readonly) JSContext *jsContext;

-(instancetype) initWithJSContext:(JSContext *) jsContext;
-(instancetype) initWithJSContext:(JSContext *) jsContext object:(id) object;
-(instancetype) init;
-(instancetype) initWithObject:(id) object;

-(void) on:(KKObserverFunction) func evaluateScript:(NSString *) evaluateScript context:(void *) context;

-(void) on:(KKObserverFunction) func keys:(NSArray *) keys children:(BOOL) children context:(void *) context;

-(void) on:(KKObserverFunction) func keys:(NSArray *) keys children:(BOOL) children identity:(NSUInteger) identity context:(void *) context;

-(void) on:(KKObserverFunction) func keys:(NSArray *) keys context:(void *) context;

-(void) off:(KKObserverFunction) func keys:(NSArray *) keys context:(void *) context;

-(id) evaluateScript:(NSString*) evaluateScript;

-(instancetype) newObserver;

+(JSContext *) mainJSContext;

+(void) setMainJSContext:(JSContext *) mainJSContext;

@end

@interface NSObject(KKObserver)

-(id) kk_getValue:(NSString *) key;

-(void) kk_setValue:(NSString *) key value:(id) value;

-(id) kk_get:(NSArray *) keys defaultValue:(id) defaultValue;

-(void) kk_set:(NSArray *) keys value:(id) value;

-(NSSet *) kk_keySet;

-(NSString *) kk_stringValue;

-(NSString *) kk_getString:(NSString *) key;

@end

