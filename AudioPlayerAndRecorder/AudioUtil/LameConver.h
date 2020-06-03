//
//  LameConver.h
//  WisdomClassroom
//
//  Created by yfxiari on 2020/6/2.
//  Copyright © 2020 qd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^successBlock)(void);
@interface LameConver : NSObject

/**
 PCM流转MP3文件

 @param pcmbuffer pcmbuffer
 @param path 输入路径
 */
- (void)convertPCMToMp3:(AudioBuffer)pcmbuffer toPath:(NSString *)path;

/**
 wav(或caf)文件转mp3文件

 @param wavPath wav文件路径（输入）
 @param mp3Path mp3文件路径（输出）
 */
- (void)converWav:(NSString *)wavPath toMp3:(NSString *)mp3Path successBlock:(successBlock)block;
@end
