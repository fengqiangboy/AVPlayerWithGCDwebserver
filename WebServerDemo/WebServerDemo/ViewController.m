//
//  ViewController.m
//  WebServerDemo
//
//  Created by 广州加减信息技术有限公司 on 16/1/28.
//  Copyright © 2016年 奉强. All rights reserved.
//

#import "ViewController.h"
#import "VideoCacheTool.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) VideoCacheTool *videoCacheTool;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoCacheTool = [[VideoCacheTool alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    NSString *realUrlStr = @"http://res.pmit.cn/F3Video/hls/c93835aa5bc595b24943304f31e46323/list.m3u8";
    
    
    NSString *urlStr = [self.videoCacheTool getUrlStringWithRealUrlString:realUrlStr];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    layer.frame = self.view.frame;
    
    [self.view.layer addSublayer:layer];
    
    [player play];
    
//    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(stopWebServer) userInfo:nil repeats:NO];
    
}

- (void)stopWebServer {
    [self.videoCacheTool stopWebSever];
    self.videoCacheTool = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

