//
//  KKAudioElement.m
//  KKView
//
//  Created by zhanghailong on 2018/6/15.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKAudioElement.h"
#import <AVFoundation/AVFoundation.h>

@interface KKAudioElement()

@property(nonatomic,strong) KKViewContext * viewContext;
@property(nonatomic,strong) AVPlayer * player;
@property(nonatomic,strong) AVPlayerItem * playerItem;
@property(nonatomic,assign) BOOL playing;

@end

@implementation KKAudioElement

+(void) initialize {
    
    
    [KKViewContext setDefaultElementClass:[KKAudioElement class] name:@"audio"];
    
}

-(instancetype) init{
    if((self = [super init])) {
        self.viewContext = [KKViewContext currentContext];
    }
    return self;
}

-(void) dealloc {
    [self cancelPlaying];
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    
    if([key isEqualToString:@"src"]) {
        [self startPlaying];
    } else if([key isEqualToString:@"autoplay"]) {
        if(KKBooleanValue([self get:key])) {
            [self startPlaying];
        } else {
            [self cancelPlaying];
        }
    } else if([key isEqualToString:@"pool"]) {
        [self startPlaying];
    }
}

-(void) onError:(NSString *) error errcode:(NSInteger) errcode{
    KKElementEvent * e = [[KKElementEvent alloc] initWithElement:self];
    e.data = @{@"errmsg":error,@"errno":@(errcode)};
    [self emit:@"error" event:e];
}

-(void) startPlaying {
    
    if(_player == nil) {
        
        NSString * src = [self get:@"src"];
        
        if(![src hasPrefix:@"http://"] && ![src hasPrefix:@"https://"]) {
            return;
        }
        
        NSURL * u = nil;
        
        @try {
            u = [NSURL URLWithString:src];
        }
        @catch(NSException * ex) {
            [self onError:[ex description] errcode:500];
            return;
        }
        
        if(u == nil) {
            [self onError:@"URL错误" errcode:300];
            return;
        }
        
        NSError * error = nil;
        
        AVAudioSession * session =[AVAudioSession sharedInstance];
        
        [session setCategory:AVAudioSessionCategoryAmbient error:&error];

        if(error != nil) {
            [self onError:[error localizedDescription] errcode:500];
            return;
        }
        
        [session setActive:YES error:&error];
        
        if(error != nil) {
            [self onError:[error localizedDescription] errcode:500];
            return;
        }
        
        self.playerItem = [AVPlayerItem playerItemWithURL:u];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayingFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doApplicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doApplicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    if(_player && !_playing) {
        _playing = YES;
        [_player play];
    }
}

-(void) doApplicationDidBecomeActiveNotification {
    
    if(_player && _playing) {
        AVAudioSession * session =[AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
        [session setActive:YES error:nil];
        [_player play];
    }
    
}

-(void) doApplicationDidEnterBackgroundNotification {
    if(_player && _playing) {
        [_player pause];
    }
}

-(void) didPlayingFinished {
    
    if(KKBooleanValue([self get:@"loop"])) {
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
    }
    
}

-(void) cancelPlaying {
    if(_player) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
        [self.player pause];
        self.player = nil;
        self.playerItem = nil;
        _playing =NO;
    }
}

-(void) recycle {
    [self cancelPlaying];
    [super recycle];
}

@end
