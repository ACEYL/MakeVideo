//
//  VideoProgressView.m
//  videoDemo
//
//  Created by Yuan on 16/3/11.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import "VideoProgressView.h"

@implementation VideoProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];

        
        [self createProgressView];
        
    }
    return self;
}


-(void) createProgressView
{
    
    _currentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
    _currentLabel.text = @"00:00";
    _currentLabel.textAlignment = NSTextAlignmentCenter;
    _currentLabel.textColor = [UIColor whiteColor];
    [self addSubview:_currentLabel];
    
    _totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 55, 0, 50, 20)];
    _totalLabel.text = @"00:00";
    _totalLabel.textAlignment = NSTextAlignmentCenter;
    _totalLabel.textColor = [UIColor whiteColor];
    [self addSubview:_totalLabel];
    
    _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(60, 10, self.frame.size.width - 120, 20)];
    [self addSubview:_progress];
    
    
    _slider = [[UISlider alloc]initWithFrame:CGRectMake(58, 1, self.frame.size.width - 115, 20)];

    // 设置slider
    [self.slider setThumbImage:[self OriginImage:[UIImage imageNamed:@"player_slider_btn.png"] scaleToSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
    self.slider.minimumTrackTintColor = [UIColor whiteColor];
    self.slider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
    
    
    [self addSubview:_slider];
}

//缩放图片
-(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size

{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    
    
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

@end
