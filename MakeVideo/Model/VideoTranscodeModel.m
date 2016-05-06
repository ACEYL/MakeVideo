//
//  VideoTranscodeModel.m
//  News
//
//  Created by 袁亮 on 16/3/31.
//  Copyright © 2016年 石世彪. All rights reserved.
//

#import "VideoTranscodeModel.h"

@implementation VideoTranscodeModel



//视频转码，并裁剪成正方形
+(void)videoTranscodeMP4:(NSURL *)videoPath transcodeSuccess:(void (^)(id responseObject))success
{
    
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    CMTime totalDuration = kCMTimeZero;
    AVAsset *asset = [AVAsset assetWithURL:videoPath];
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    totalDuration = CMTimeAdd(totalDuration, asset.duration);
    
    CGSize renderSize = CGSizeMake(0, 0);
    renderSize.width = MAX(renderSize.width, videoAssetTrack.naturalSize.height);
    renderSize.height = MAX(renderSize.height, videoAssetTrack.naturalSize.width);
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    CGFloat rate;
    rate = renderW / MIN(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
    CGAffineTransform layerTransform = CGAffineTransformMake(videoAssetTrack.preferredTransform.a, videoAssetTrack.preferredTransform.b, videoAssetTrack.preferredTransform.c, videoAssetTrack.preferredTransform.d, videoAssetTrack.preferredTransform.tx * rate, videoAssetTrack.preferredTransform.ty * rate);
    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(videoAssetTrack.naturalSize.width - videoAssetTrack.naturalSize.height) / 2.0));
    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
    [layerInstruction setTransform:layerTransform atTime:kCMTimeZero];
    [layerInstruction setOpacity:0.0 atTime:totalDuration];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    instruction.layerInstructions = @[layerInstruction];
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = @[instruction];
    mainComposition.frameDuration = CMTimeMake(1, 30);
    mainComposition.renderSize = CGSizeMake(renderW, renderW);
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];//用时间给文件全名
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *exportPath = [NSString stringWithFormat:@"%@/%@.mp4",
                            [NSHomeDirectory() stringByAppendingString:@"/tmp"],[formater stringFromDate:[NSDate date]]];
    // 导出视频
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainComposition;
    exporter.outputURL = [NSURL fileURLWithPath:exportPath];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch ([exporter status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [exporter error]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"转换成功");
                success(exportPath);
                break;
            default:
                break;
        }
    }];
    
}

+(void)saveVideoToAblm:(NSURL *)videoUrl completionBlock:(void(^)())completion
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:^(NSURL *videoUrl,NSError *error){
        
        //写入相册
        [self addAssetURL:videoUrl withCompletionBlock:^(){
            completion();
        }];
    }];
}

+(void)addAssetURL:(NSURL*)assetURL withCompletionBlock:(void(^)())completionBlock
{
    //相册存在标示
    __block BOOL albumWasFound = NO;
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    //search all photo albums in the library
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group,BOOL *stop)
     {
         
         //判断相册是否存在
         if ([@"MakeVideo" compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
             //存在
             albumWasFound = YES;
             
             //get a hold of the photo's asset instance
             [assetsLibrary assetForURL: assetURL
                            resultBlock:^(ALAsset *asset) {
                                
                                //add photo to the target album
                                [group addAsset: asset];
                                
                                //run the completion block
                                completionBlock(nil);
                                
                            } failureBlock: completionBlock];
             return;
         }
         
         //如果不存在该相册创建
         if (group==nil && albumWasFound==NO)
         {
             __weak ALAssetsLibrary* weakSelf = assetsLibrary;
             
             //创建相册
             [assetsLibrary addAssetsGroupAlbumWithName:@"MakeVideo" resultBlock:^(ALAssetsGroup *group)
              {
                  NSLog(@"创建相册");
                  
                  //get the photo's instance
                  [weakSelf assetForURL: assetURL
                            resultBlock:^(ALAsset *asset)
                   {
                       
                       //add photo to the newly created album
                       [group addAsset: asset];
                       
                       //call the completion block
                       completionBlock(nil);
                       
                   } failureBlock: completionBlock];
                  
              } failureBlock: completionBlock];
             return;
         }
         
     }failureBlock:completionBlock];
}


@end
