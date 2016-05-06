//
//  VideoPlayerView.h
//  videoDemo
//
//  Created by Yuan on 16/3/11.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoPlayerView : UIView

@property (strong, nonatomic) NSURL *video_url;

@property (strong, nonatomic) AVURLAsset *urlAsset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

-(instancetype)initWithFrame:(CGRect)frame
               playerWithUrl:(NSURL *)url;

@end
