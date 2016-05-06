//
//  MakeVideoViewController.m
//  videoDemo
//
//  Created by Yuan on 16/2/19.
//  Copyright © 2016年 Ace. All rights reserved.
//

#define MVW (self.view.frame.size.width)
#define MVH (self.view.frame.size.height)

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#import "MakeVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "PreviewVideoViewController.h"

@interface MakeVideoViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层


@property (strong,nonatomic) UIButton *makeVideoBtn;

@property (strong,nonatomic) UILabel *timeLabel;
@property (strong,nonatomic) NSTimer *timer;
@property (assign,nonatomic) NSInteger second;

@end

@implementation MakeVideoViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;

        
        
    }
    return self;
}
/*
 *     隐藏状态栏
 */
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark --- 创建顶部UI
-(void) createTopView
{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MVW, 44)];
    topView.backgroundColor = [UIColor colorWithRed:1 / 255.0f green:147 / 255.0f blue:222 / 255.0f alpha:1.0f];
    [self.view addSubview:topView];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 24, 24)];
    [closeBtn setImage:[UIImage imageNamed:@"close_video_btn.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:closeBtn];
    
    UIButton *changeBtn = [[UIButton alloc]initWithFrame:CGRectMake(MVW - 50, 2, 40, 40)];
    [changeBtn setImage:[UIImage imageNamed:@"change_device_btn"] forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:changeBtn];
}
#pragma mark --- 顶部所有按钮方法
-(void) closeBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --- 创建底部UI
-(void) createDownView
{
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, MVH - MVH / 3, MVW, MVH / 3)];
    downView.backgroundColor = [UIColor colorWithRed:1 / 255.0f green:147 / 255.0f blue:222 / 255.0f alpha:1.0f];
    [self.view addSubview:downView];
    
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, MVW, 20)];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"0.0 s";
    [downView addSubview:_timeLabel];
    
    
    CGFloat makeVideoSize = downView.frame.size.height / 3;
    CGFloat makeVideoX = downView.frame.size.width / 2 - makeVideoSize / 2;
    CGFloat makeVideoY = downView.frame.size.height / 2 - makeVideoSize / 2;
    self.makeVideoBtn = [[UIButton alloc]initWithFrame:CGRectMake(makeVideoX, makeVideoY, makeVideoSize, makeVideoSize)];
    [self.makeVideoBtn setImage:[UIImage imageNamed:@"make_video_start.png"] forState:UIControlStateNormal];
    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(makeVideoMethod:)];
    longPressed.minimumPressDuration = 0.1;

    [self.makeVideoBtn addGestureRecognizer:longPressed];
    [downView addSubview:self.makeVideoBtn];
    
    
    UILabel *pressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, downView.frame.size.height - 40, downView.frame.size.width, 20)];
    pressLabel.text = @"长按开始录制";
    pressLabel.textColor = [UIColor whiteColor];
    pressLabel.textAlignment = NSTextAlignmentCenter;
    [downView addSubview:pressLabel];
    
}

#pragma mark --- 底部所有按钮方法
-(void)makeVideoMethod:(UILongPressGestureRecognizer *)gestureRecognizer
{

    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        [self.makeVideoBtn setImage:[UIImage imageNamed:@"make_video_pressed.png"] forState:UIControlStateNormal];
        AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
        NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        
        NSLog(@"开始");
        
    }else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self.makeVideoBtn setImage:[UIImage imageNamed:@"make_video_start.png"] forState:UIControlStateNormal];
        [self.captureMovieFileOutput stopRecording];//停止录制
        NSLog(@"结束");
        
    }
    
}

#pragma mark --- 创建定时器

- (void)createTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(videoTimeMethod) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)videoTimeMethod
{
    _second++;
    _timeLabel.text = [NSString stringWithFormat:@"%lu.0 s",_second];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTopView];
    [self createDownView];
    
    [self initVideoMain];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    _second = 0;
    _timeLabel.text = [NSString stringWithFormat:@"%lu.0 s",_second];

    
}

#pragma mark --- 主体部分创建
-(void) initVideoMain
{
    //初始化会话
    _captureSession=[[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//设置分辨率
        _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
    }
    //获得输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    
    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.frame = self.view.bounds;
    
    //将视频预览层添加到界面中
    [self.view.layer insertSublayer:self.captureVideoPreviewLayer atIndex:0];//
    
    [self.captureSession startRunning];
}


-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

- (void)changeCameraDevice:(id)sender
{
    
    NSArray *inputs = self.captureSession.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [self.captureSession beginConfiguration];
            
            [self.captureSession removeInput:input];
            [self.captureSession addInput:newInput];
            
            [self.captureSession commitConfiguration];
            break;
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}


#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    
    NSLog(@"开始录制...");
    //开始定时器
    [self createTimer];
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
    NSLog(@"视频录制完成.");
    //停止定时器
    [_timer invalidate];
    
    PreviewVideoViewController *playerController = [[PreviewVideoViewController alloc]init];
    playerController.video_url = outputFileURL;
    [self.navigationController pushViewController:playerController animated:YES];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
