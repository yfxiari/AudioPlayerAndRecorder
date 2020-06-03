//
//  AudioRecord.h
//  WisdomClassroom
//
//  Created by yfxiari on 2020/6/2.
//  Copyright © 2020 qd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define ETRECORD_RATE 44100.0

@protocol AudioRecordDelegate <NSObject>
@optional
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag;
//录音声波百分比
- (void)audioRecorderPeakPowerPercentDidChange:(float)peakPowerPercent;
- (void)audioRecorderDidRecordWithTime:(int)secend;
@end


@interface AudioRecord : NSObject

@property (copy, nonatomic) NSString *savePath;
@property (weak, nonatomic) id<AudioRecordDelegate> audioRecordDelegate;
@property (assign, nonatomic) BOOL isRecording;

/// 开始或继续
- (void)startRecord;
- (void)pauseRecord;
- (void)stopRecord;

@end
