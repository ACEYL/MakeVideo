//
//  PushVideoViewController.m
//  News
//
//  Created by 袁亮 on 16/3/31.
//  Copyright © 2016年 石世彪. All rights reserved.
//

#import "PushVideoViewController.h"

@interface PushVideoViewController ()

@end

@implementation PushVideoViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"发布";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSURL *video_url = [NSURL fileURLWithPath:_videoPath];
    NSLog(@"%@",video_url);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
