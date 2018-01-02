//
//  KKQRCaptureElement.m
//  KKView
//
//  Created by hailong11 on 2018/1/1.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKQRCaptureElement.h"
#import "JSContext+KKView.h"

#import <AVFoundation/AVFoundation.h>

typedef void (^KKQRCaptureViewOnVisible)(BOOL visible);

@interface KKQRCaptureView: UIView {
    
}

@property(nonatomic,strong) KKQRCaptureViewOnVisible onVisible;

@end

@implementation KKQRCaptureView

@synthesize onVisible = _onVisible;

-(void) didMoveToWindow {
    [super didMoveToWindow];
    if(_onVisible) {
        _onVisible(self.window != nil);
    }
}

@end

@interface KKQRCaptureElement () <AVCaptureMetadataOutputObjectsDelegate>  {
    
}

@property(nonatomic,strong) AVCaptureVideoPreviewLayer * previewLayer;
@property(nonatomic,strong) AVCaptureSession * session;

-(void) startCapture;

-(void) stopCapture;

@end

@implementation KKQRCaptureElement

@synthesize previewLayer = _previewLayer;
@synthesize session = _session;

+(void) initialize {
    [super initialize];
    [JSContext setDefaultElementClass:[KKQRCaptureElement class] name:@"qr"];
}

-(instancetype) init {
    if((self = [super init])) {
        [self set:@"view" value:NSStringFromClass([KKQRCaptureView class])];
    }
    return self;
}

-(void) dealloc {
    [_session stopRunning];
    [_previewLayer removeFromSuperlayer];
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

-(void) setView:(UIView *)view {
    [_previewLayer removeFromSuperlayer];
    [(KKQRCaptureView *) self.view setOnVisible:nil];
    [super setView:view];
    __weak KKQRCaptureElement * v = self;
    [(KKQRCaptureView *) self.view setOnVisible:^(BOOL visible) {
        if(visible && KKBooleanValue([v get:@"capture"])) {
            [v startCapture];
        } else {
            [v stopCapture];
        }
    }];
}

-(void) startCapture {
    
    AVCaptureVideoPreviewLayer * layer = [self previewLayer];
    
    if(layer) {
        layer.frame = self.view.bounds;
        [self.view.layer addSublayer:layer];
    }
    
    [self.session startRunning];
}

-(void) stopCapture {
    [_session stopRunning];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    if([key isEqualToString:@"capture"]) {
        if(self.view.window != nil && KKBooleanValue([self get:@"capture"])) {
            [self startCapture];
        } else {
            [self stopCapture];
        }
    }
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
