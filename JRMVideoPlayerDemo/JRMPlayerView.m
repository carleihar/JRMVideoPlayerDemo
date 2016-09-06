//
//  JRMPlayerView.m
//  JRMVideoDemo
//
//  Created by Caroline on 3/23/16.
//  Copyright © 2016 Caroline Harrison. All rights reserved.
//

@import AVFoundation;

#import "JRMPlayerView.h"

@implementation JRMPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    ((AVPlayerLayer *)[self layer]).videoGravity = AVLayerVideoGravityResizeAspectFill;
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
