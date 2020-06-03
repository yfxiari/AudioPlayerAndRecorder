//
//  AudioRecordUtil.m
//  WisdomClassroom
//
//  Created by yfxiari on 2020/6/2.
//  Copyright © 2020 qd. All rights reserved.
//

#import "AudioRecord.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioRecord () <AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioRecorder *audioRecorder; //音频录音机
@property (nonatomic, strong) NSTimer *audioPowerTimer;
@property (nonatomic, strong) NSTimer *recorderTimeTimer; //录音时长
@property (assign, nonatomic) int recoderTime;//录音时长
@end

@implementation AudioRecord

#pragma mark - 录音
- (void)startRecord {
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];
        self.audioPowerTimer.fireDate = [NSDate distantPast];
        [self.recorderTimeTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)pauseRecord {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.audioPowerTimer.fireDate = [NSDate distantFuture];
        self.recorderTimeTimer.fireDate = [NSDate distantFuture];
    }
}

- (void)stopRecord {
    [self.audioRecorder stop];
    self.audioRecorder = nil;
    [self.audioPowerTimer invalidate];
    self.audioPowerTimer = nil;
    [self.recorderTimeTimer invalidate];
    self.recorderTimeTimer = nil;
    self.recoderTime = 0;
}

- (BOOL)isRecording {
    return self.audioRecorder.isRecording;
}

#pragma mark - 私有方法

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(ETRECORD_RATE) forKey:AVSampleRateKey];
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];

    return dicM;
}

/**
 *  录音声波
 */
- (void)audioPowerChange {
    [self.audioRecorder updateMeters]; //更新测量值
    float lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));

    CGFloat pro = 0;
    if (0 < lowPassResults <= 0.27) {
        pro = 0;
    } else if (0.27 < lowPassResults <= 0.34) {
        pro = 0.2;
    } else if (0.34 < lowPassResults <= 0.41) {
        pro = 0.4;
    } else if (0.41 < lowPassResults <= 0.48) {
        pro = 0.6;
    } else if (0.48 < lowPassResults <= 0.55) {
        pro = 0.8;
    } else if (0.55 < lowPassResults) {
        pro = 1;
    }

    if (self.audioRecordDelegate && [self.audioRecordDelegate respondsToSelector:@selector(audioRecorderPeakPowerPercentDidChange:)]) {
        [self.audioRecordDelegate audioRecorderPeakPowerPercentDidChange:pro];
    }
}

- (void)updateRecordTime {
    if (self.audioRecordDelegate && [self.audioRecordDelegate respondsToSelector:@selector(audioRecorderDidRecordWithTime:)]) {
        [self.audioRecordDelegate audioRecorderDidRecordWithTime:self.audioRecorder.currentTime];
    }
}

#pragma mark - 录音机代理方法

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.audioRecordDelegate && [self.audioRecordDelegate respondsToSelector:@selector(audioRecorderDidFinishRecording:successfully:)]) {
        [self.audioRecordDelegate audioRecorderDidFinishRecording:recorder successfully:flag];
    }
}

#pragma mark - Getter

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];

        //创建录音格式设置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.savePath] settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES; //如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@", error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
- (NSTimer *)audioPowerTimer{
    if (!_audioPowerTimer) {
        _audioPowerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _audioPowerTimer;
}


- (NSTimer *)recorderTimeTimer {
    if (!_recorderTimeTimer) {
        _recorderTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_recorderTimeTimer forMode:NSRunLoopCommonModes];
    }
    return _recorderTimeTimer;
}


- (void)setSavePath:(NSString *)savePath {
    _savePath = savePath;
    _audioRecorder = nil;
}
@end

