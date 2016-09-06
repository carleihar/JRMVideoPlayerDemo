//
//  JRMVideoPlayerViewController.m
//  JRMVideoPlayerDemo
//
//  Created by Caroline on 8/24/16.
//  Copyright © 2016 Caroline Harrison. All rights reserved.
//

#import "JRMVideoPlayerViewController.h"
#import "JRMPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface JRMVideoPlayerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet JRMPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *timeLabelContainerView;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) AVPlayer *player;
@property BOOL isPlaying;

@end

@implementation JRMVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *fileURL = [info objectForKey:UIImagePickerControllerMediaURL];
    self.playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.playerView setPlayer:self.player];
    self.uploadButton.hidden = YES;
    self.playPauseButton.hidden = NO;
    self.slider.maximumValue = CMTimeGetSeconds(self.playerItem.asset.duration);
    self.slider.hidden = NO;
    self.timeLabelContainerView.hidden = NO;
    Float64 durInMiliSec = 1000 * CMTimeGetSeconds(self.playerItem.asset.duration);
    self.timeLabel.text = [self formatInterval:durInMiliSec];
}

#pragma mark - Actions

- (IBAction)playPauseButtonTouched:(id)sender {
    if (self.isPlaying) {
        [self.player pause];
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.timer invalidate];
    } else {
        [self.player play];
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    }
    self.isPlaying = !self.isPlaying;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self updateTimeLabel];
}

- (IBAction)uploadButtonTouched:(id)sender {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    self.imagePickerController.delegate = self;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Video" message:@"Choose where to get the video from" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - Player Notifications

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    self.isPlaying = NO;
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.timer invalidate];
    [self.slider setValue:0];
}

#pragma mark - Helpers

- (void)updateSlider {
    [self updateTimeLabel];
    CGFloat val = self.slider.value + 0.1f;
    [self.slider setValue:val];
}

- (void)updateTimeLabel {
    Float64 dur = CMTimeGetSeconds([self.player currentTime]);
    Float64 durInMiliSec = 1000*dur;
    self.timeLabel.text = [self formatInterval:durInMiliSec];
}

- (NSString *)formatInterval:(Float64)totalMilliseconds {
    unsigned long milliseconds = totalMilliseconds;
    unsigned long seconds = milliseconds / 1000;
    milliseconds %= 1000;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    return [NSString stringWithFormat:@"%02lu:%02lu.%02lu",minutes, seconds, milliseconds];
}

@end
