//
//  VideoProgressView.h
//  videoDemo
//
//  Created by Yuan on 16/3/11.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoProgressView : UIView

@property (strong,nonatomic) UILabel *currentLabel;
@property (strong,nonatomic) UILabel *totalLabel;

@property (strong,nonatomic) UISlider *slider;
@property (strong,nonatomic) UIProgressView *progress;

@end
