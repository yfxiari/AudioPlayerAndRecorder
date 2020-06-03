//
//  AudioPlayer.m
//  WisdomClassroom
//
//  Created by yfxiari on 2020/6/2.
//  Copyright © 2020 qd. All rights reserved.
//

#import "AudioPlayer.h"

@interface AudioPlayer () <AVAudioPlayerDelegate>
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *playProgressTimer;//播放进度
@end

@implementation AudioPlayer

#pragma mark - 播放
- (void)startPlay {
    if (![self.audioPlayer isPlaying]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
        BOOL isPlay = [self.audioPlayer play];
        if (isPlay) {
            [self.playProgressTimer setFireDate:[NSDate distantPast]];
        }else{
            NSLog(@"音频错误");
        }
    }
}

- (void)pausePlay {
    [self.audioPlayer pause];
    [self.playProgressTimer setFireDate:[NSDate distantFuture]];
}

- (void)stopPlay {
    [self.audioPlayer stop];
    self.audioPlayer.currentTime = 0;
    [self.playProgressTimer invalidate];
    self.playProgressTimer = nil;
}

- (void)setPlayTime:(NSTimeInterval)currentTime {
    self.audioPlayer.currentTime = currentTime;
}

- (void)changeVolume:(float)volume {
    self.audioPlayer.volume = volume;
}

- (BOOL)isPlaying {
    return self.audioPlayer.isPlaying;
}


- (void)playProgressChange {
    if (self.audioPlayerDelegate && [self.audioPlayerDelegate respondsToSelector:@selector(audioPlayingAtTime:duration:)]) {
        [self.audioPlayerDelegate audioPlayingAtTime:self.audioPlayer.currentTime duration:self.audioPlayer.duration];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.audioPlayerDelegate && [self.audioPlayerDelegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:successfully:)]) {
        [self.audioPlayerDelegate audioPlayerDidFinishPlaying:player successfully:flag];
    }
    if (self.audioPlayerDelegate && [self.audioPlayerDelegate respondsToSelector:@selector(audioPlayingAtTime:duration:)]) {
        [self.audioPlayerDelegate audioPlayingAtTime:player.duration duration:player.duration];
    }
    [self.playProgressTimer invalidate];
    self.playProgressTimer = nil;
}



#pragma mark - Getter

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSError *error = nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:self.audioURL error:&error];
        _audioPlayer.delegate = self;
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.volume = 1;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}


- (NSTimer *)playProgressTimer {
    if (!_playProgressTimer) {
        _playProgressTimer = [NSTimer scheduledTimerWithTimeInterval:self.audioPlayer.currentTime / 50.0 target:self selector:@selector(playProgressChange) userInfo:nil repeats:YES];
    }
    return _playProgressTimer;
}

- (void)setAudioURL:(NSURL *)audioURL {
    _audioURL = audioURL;
    _audioPlayer = nil;
}


@end
