//
//  VideoTranscodeModel.h
//  News
//
//  Created by 袁亮 on 16/3/31.
//  Copyright © 2016年 石世彪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface VideoTranscodeModel : NSObject

//视频转换MP4格式
+(void)videoTranscodeMP4:(NSURL *)videoPath transcodeSuccess:(void (^)(id responseObject))success;

//保存视频
+(void)saveVideoToAblm:(NSURL *)videoUrl completionBlock:(void(^)())completion;


@end
