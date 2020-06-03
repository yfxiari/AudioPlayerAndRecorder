//
//  AudioPlayerUtil.h
//  WisdomClassroom
//
//  Created by yfxiari on 2020/6/2.
//  Copyright © 2020 qd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioPlayerDelegate <NSObject>
@optional
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
- (void)audioPlayingAtTime:(float)currentTime duration:(float)duration;
@end

@interface AudioPlayer : NSObject

@property (strong, nonatomic) NSURL *audioURL;
@property (weak, nonatomic) id<AudioPlayerDelegate> audioPlayerDelegate;

- (void)startPlay;
- (void)pausePlay;
- (void)stopPlay;
//单位：秒
- (void)setPlayTime:(NSTimeInterval)currentTime;

//音量大小，取值范围0-1
- (void)changeVolume:(float)volume;

@end


