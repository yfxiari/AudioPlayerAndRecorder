//
//  ViewController.m
//  AudioPlayerAndRecorder
//
//  Created by yfxiari on 2020/6/2.
//  Copyright © 2020 cytx. All rights reserved.
//

#import "ViewController.h"
#import "AudioRecord.h"
#import "AudioPlayer.h"
#import "LameConver.h"
#import "LameConver.h"

#define WAV_PATH [NSString stringWithFormat:@"%@/recod.wav", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject]
#define MP3_PATH [NSString stringWithFormat:@"%@/recod.mp3", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject]

@interface ViewController () <AudioPlayerDelegate, AudioRecordDelegate>
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *playTotalTimeLbl;

@property (strong, nonatomic) AudioPlayer *audioPlayer;
@property (strong, nonatomic) AudioRecord *audioRecord;
@property (weak, nonatomic) IBOutlet UIProgressView *playProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *recordPeekPowerProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioPlayer = [[AudioPlayer alloc] init];
    self.audioPlayer.audioPlayerDelegate = self;
    self.audioRecord = [[AudioRecord alloc] init];
    self.audioRecord.audioRecordDelegate = self;
    self.audioRecord.savePath = WAV_PATH;
    self.audioPlayer.audioURL = [NSURL fileURLWithPath:MP3_PATH];
}


- (IBAction)startRecord:(id)sender {
    [self.audioRecord startRecord];
}

- (IBAction)pauseRecord:(id)sender {
    [self.audioRecord pauseRecord];
}

- (IBAction)stopRecord:(id)sender {
    [self.audioRecord stopRecord];
}
- (IBAction)startPlay:(id)sender {
    [self.audioPlayer startPlay];
}
- (IBAction)pausePlay:(id)sender {
    [self.audioPlayer pausePlay];
}
- (IBAction)stopPlay:(id)sender {
    [self.audioPlayer stopPlay];
}

- (void)audioRecorderDidRecordWithTime:(int)secend {
    self.recordTimeLbl.text = [NSString stringWithFormat:@"%d", secend];
}

- (void)audioRecorderPeakPowerPercentDidChange:(float)peakPowerPercent {
    self.recordPeekPowerProgress.progress = peakPowerPercent;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            LameConver *lameConver = [[LameConver alloc] init];
            [lameConver converWav:WAV_PATH toMp3:MP3_PATH successBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"转码成功");
                });
            }];
        });
    }
}

- (void)audioPlayingAtTime:(float)currentTime duration:(float)duration {
    self.playTimeLbl.text = [NSString stringWithFormat:@"%d", (int)currentTime];
    self.playTotalTimeLbl.text = [NSString stringWithFormat:@"%d", (int)duration];
    self.playProgress.progress = currentTime / duration;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
}

@end
