//
//  KKQRCaptureElement.m
//  KKView
//
//  Created by hailong11 on 2018/1/1.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKQRCaptureElement.h"
#import "KKViewContext.h"

#import <AVFoundation/AVFoundation.h>

typedef void (^KKQRCaptureViewOnVisible)(BOOL visible);

@interface KKQRCaptureView: UIView <AVCaptureMetadataOutputObjectsDelegate> {
    
}

@property(nonatomic,weak) id<AVCaptureMetadataOutputObjectsDelegate> delegate;
@property(nonatomic,assign,getter=isCapture) BOOL capture;
@property(nonatomic,strong) AVCaptureVideoPreviewLayer * previewLayer;
@property(nonatomic,strong) AVCaptureSession * session;

-(void) startCapture;

-(void) stopCapture;

@end

@implementation KKQRCaptureView

@synthesize delegate = _delegate;
@synthesize capture = _capture;
@synthesize previewLayer = _previewLayer;
@synthesize session = _session;

-(void) didMoveToWindow {
    [super didMoveToWindow];
    if(self.window) {
        if(_capture) {
            [self startCapture];
        }
    } else {
        [self stopCapture];
    }
}


-(void) dealloc {
    [_session stopRunning];
    [_previewLayer removeFromSuperlayer];
}

-(void) KKViewElement:(KKViewElement *)element setProperty:(NSString *)key value:(NSString *)value{
    [super KKViewElement:element setProperty:key value:value];
    
    if([key isEqualToString:@"capture"]) {
        self.capture = KKBooleanValue(value);
    }
}

-(void) setCapture:(BOOL)capture {
    _capture = capture;
    if(_capture && self.window) {
        [self startCapture];
    } else {
        [self stopCapture];
    }
}

-(void) startCapture {
    
    AVCaptureVideoPreviewLayer * layer = [self previewLayer];
    
    if(layer) {
        layer.frame = self.bounds;
        [self.layer insertSublayer:layer atIndex:0];
    }
    
    [self.session startRunning];
}

-(void) stopCapture {
    [_session stopRunning];
}

-(AVCaptureSession *) session {
    
    if(_session == nil){
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if(device == nil) {
            NSLog(@"AVCaptureDevice AVMediaTypeVideo Not Found");
            return nil;
        }
        
        NSError *error = nil;
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        if (error) {
            NSLog(@"AVCaptureDeviceInput %@",error);
            return nil;
        }
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _session = [[AVCaptureSession alloc] init];
        
        [_session addInput:input];
        [_session addOutput:output];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode , AVMetadataObjectTypeEAN8Code ,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeCode128Code];
    }
    
    return _session;
}

-(AVCaptureVideoPreviewLayer *) previewLayer {
    if(_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    [_delegate captureOutput:output didOutputMetadataObjects:metadataObjects fromConnection:connection];
    
}


-(void) recycle {
    [_session stopRunning];
    [_previewLayer removeFromSuperlayer];
    _session = nil;
    _previewLayer = nil;
}

@end

@interface KKQRCaptureElement () <AVCaptureMetadataOutputObjectsDelegate> {
    
}

@end

@implementation KKQRCaptureElement

+(void) initialize {
    
    [KKViewContext setDefaultElementClass:[KKQRCaptureElement class] name:@"qr:capture"];
}

-(void) dealloc {
    NSLog(@"KKQRCaptureElement dealloc");
}

-(instancetype) init {
    if((self = [super init])) {
    }
    return self;
}

-(Class) viewClass {
    return [KKQRCaptureView class];
}

-(void) setView:(UIView *)view {
    [(KKQRCaptureView *) self.view setDelegate:nil];
    [(KKQRCaptureView *) self.view recycle];
    [super setView:view];
    [(KKQRCaptureView *) self.view setDelegate:self];
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects.count > 0) {
        
        [self set:@"capture" value:@"false"];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects.firstObject;
        
        KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
        
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:self.data];
        
        data[@"text"] = obj.stringValue;
        
        e.data = data;
        
        [self emit:@"capture" event:e];
        
    }
    
}

@end
