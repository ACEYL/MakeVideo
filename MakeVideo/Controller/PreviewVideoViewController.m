//
//  PreviewVideoViewController.m
//  videoDemo
//
//  Created by Yuan on 16/3/11.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import "PreviewVideoViewController.h"
#import "MBProgressHUD.h"
#import "VideoPlayerView.h"
#import "VideoProgressView.h"

#import "VideoTranscodeModel.h"
#import "PushVideoViewController.h"
#import "SVProgressHUD.h"

@interface PreviewVideoViewController ()

@property (nonatomic, strong) VideoPlayerView *playerView;
@property (nonatomic, strong) VideoProgressView *progressView;
/** 计时器 */
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation PreviewVideoViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"预览";
    }
    return self;
}


//直播视频底层View

-(void)setupDownView
{
    _playerView = [[VideoPlayerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width) playerWithUrl:self.video_url];
    [self.view addSubview:_playerView];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建底层
    [self setupDownView];
    //注册KVO和通知中心
    [self registMonitor];
    //Player
    [self initStreamPlayer];
    
    //progressView
    [self setupProgress];
    
    //nextstepBtn
    [self setupNextStepBtnUI];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

-(void)initStreamPlayer
{
    [self.playerView.player play];
    [MBProgressHUD showHUDAddedTo:_playerView animated:NO];
}

-(void)setupProgress
{
    _progressView = [[VideoProgressView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.width - 20, self.view.frame.size.width, 20)];
    [self.view addSubview:_progressView];
    [self addProgressObserver];
    // slider开始滑动事件
    [self.progressView.slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.progressView.slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.progressView.slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}


/*
 *   建立下一步按钮UI
 */
-(void)setupNextStepBtnUI
{
    _nextButton = [[UIButton alloc]initWithFrame:CGRectMake(20, self.view.frame.size.width + 20, self.view.frame.size.width - 40, 40)];
    [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextButton setUserInteractionEnabled:NO];
    [_nextButton setBackgroundColor:[UIColor grayColor]];
    [_nextButton.layer setMasksToBounds:YES];
    [_nextButton.layer setCornerRadius:10.0];//设置矩形四个圆角半径
    [_nextButton addTarget:self action:@selector(nextStepBtnMethod:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
}


-(void)nextStepBtnMethod:(UIButton *)button
{

    //点击下一步的同时对视频进行操作，视频转码，格式转换，将视频保存到指定相册。
    [SVProgressHUD showInfoWithStatus:@"视频转码中"];
    [VideoTranscodeModel videoTranscodeMP4:_video_url transcodeSuccess:^(NSString *path){
        NSLog(@"_+_+%@",path);

        
        NSURL *videoURL = [NSURL fileURLWithPath:path];
        //保存视频到指定相册中
        [VideoTranscodeModel saveVideoToAblm:videoURL completionBlock:^(){
            [SVProgressHUD dismiss];
            NSLog(@"视频保存到相册中成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                PushVideoViewController *pushViewController = [[PushVideoViewController alloc]init];
                pushViewController.videoPath = path;
                [self.navigationController pushViewController:pushViewController animated:YES];
            });
        }];
  
    }];
}



#pragma mark --- 注册监听
-(void) registMonitor
{
    //监听视频播放状态
    [self.playerView.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //视频播放突然中止时则发送此通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoConnectLeaveOff) name:AVPlayerItemPlaybackStalledNotification object:self.playerView.playerItem];
    //视频播放完成时则发送此通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerView.playerItem];
}

-(void)videoPlayerFinish
{
    NSLog(@"视频播放完成");
    _nextButton.backgroundColor = [UIColor colorWithRed:1.0 / 255.0 green:147.0 / 255.0 blue:255.0 / 255.0 alpha:1];
    [_nextButton setUserInteractionEnabled:YES];

}


-(void)videoConnectLeaveOff
{
    //有媒体流的视频播放调用此方法，此方法用来判断视频是否为突然中止。
    //如果视频突然中止则显示加载hud即可
    [MBProgressHUD showHUDAddedTo:_playerView animated:YES];
}

//KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        
        if ([playerItem status] == AVPlayerItemStatusUnknown) {
            
            NSLog(@"视频播放 有问题");
            
        }else if([playerItem status] == AVPlayerItemStatusReadyToPlay){
            [MBProgressHUD hideAllHUDsForView:_playerView animated:YES];
        }
    }
}

#pragma mark --- 底层UIProgress事件
-(void)addProgressObserver{
    
    AVPlayerItem *playerItem=self.playerView.player.currentItem;
    UIProgressView *progress=self.progressView.progress;
    UISlider *slider = self.progressView.slider;
    UILabel *currentLabel = self.progressView.currentLabel;
    UILabel *totalLabel = self.progressView.totalLabel;
    //这里设置每秒执行一次
    [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([self.playerView.player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([self.playerView.player currentTime]) % 60;//当前分钟
        
        //duration 总时长
        NSInteger durMin = (NSInteger)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale % 60;//总分钟
        
        currentLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        totalLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
        
        
        if (current) {
            [progress setProgress:(current/total) animated:YES];
            
            slider.maximumValue = 1;//音乐总共时长
            slider.value = CMTimeGetSeconds([playerItem currentTime]) / (playerItem.duration.value / playerItem.duration.timescale);//当前进度
        }
    }];
}

#pragma mark - slider事件

// slider开始滑动事件
- (void)progressSliderTouchBegan:(UISlider *)slider
{
    NSLog(@"滑动");
    [_nextButton setBackgroundColor:[UIColor grayColor]];
    [_nextButton setUserInteractionEnabled:NO];
}

// slider滑动中事件
- (void)progressSliderValueChanged:(UISlider *)slider
{
    
    UILabel *currentLabel = self.progressView.currentLabel;
    UILabel *totalLabel = self.progressView.totalLabel;
    //拖动改变视频播放进度
    if (self.playerView.player.status == AVPlayerStatusReadyToPlay) {
        
        [self.playerView.player pause];
        //计算出拖动的当前秒数
        CGFloat total = (CGFloat)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale;
        
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        // 拖拽的时长
        NSInteger proMin = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
        
        //duration 总时长
        NSInteger durMin = (NSInteger)total / 60;//总秒
        NSInteger durSec = (NSInteger)total % 60;//总分钟
        
        currentLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        totalLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
        
    }
}

// slider结束滑动事件
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    //计算出拖动的当前秒数
    CGFloat total = (CGFloat)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale;
    
    NSInteger dragedSeconds = floorf(total * slider.value);
    
    //转换成CMTime才能给player来控制播放进度
    
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    
    [self endSlideTheVideo:dragedCMTime];
    
    
}

// 滑动结束视频跳转
- (void)endSlideTheVideo:(CMTime)dragedCMTime
{
    //[_player pause];
    [self.playerView.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        
        [self.playerView.player play];
        
    }];
}

//释放
-(void)dealloc
{
    [self.playerView.playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self.playerView.playerItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
