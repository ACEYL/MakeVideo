//
//  VideoPlayerView.m
//  videoDemo
//
//  Created by Yuan on 16/3/11.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import "VideoPlayerView.h"

@implementation VideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame playerWithUrl:(NSURL *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.video_url = url;
        
        [self.layer addSublayer:self.playerLayer];
        
        
    }
    return self;
}


#pragma 懒加载
-(AVURLAsset *)urlAsset
{
    if (!_urlAsset) {
        _urlAsset = [AVURLAsset assetWithURL:_video_url];
    }
    return _urlAsset;
}

-(AVPlayerItem *)playerItem
{
    if (!_playerItem) {
        _playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    }
    return _playerItem;
}

-(AVPlayer *)player
{
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    }
    return _player;
}

-(AVPlayerLayer *)playerLayer
{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.frame;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerLayer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    }
    return _playerLayer;
}



@end
