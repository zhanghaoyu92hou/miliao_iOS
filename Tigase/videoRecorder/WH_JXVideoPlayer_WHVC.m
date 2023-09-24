#import "WH_JXVideoPlayer_WHVC.h"
//#import "StreamPlayerViewController.h"
#import "WH_MyPlayerLayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "JXLabel.h"

static void *StreamPlayerViewControllerTimedMetadataObserverContext = &StreamPlayerViewControllerTimedMetadataObserverContext;
static void *StreamPlayerViewControllerRateObservationContext = &StreamPlayerViewControllerRateObservationContext;
static void *StreamPlayerViewControllerCurrentItemObservationContext = &StreamPlayerViewControllerCurrentItemObservationContext;
static void *StreamPlayerViewControllerPlayerItemStatusObserverContext = &StreamPlayerViewControllerPlayerItemStatusObserverContext;


@interface WH_JXVideoPlayer_WHVC ()

@end

@implementation WH_JXVideoPlayer_WHVC
@synthesize wh_movieTimeControl;
@synthesize wh_playerLayerView;
@synthesize wh_playStatus;
@synthesize didClick;
@synthesize wh_pauseButton,isVideo,delegate,timeLen,isPause,isUserPause,wh_timeCur,wh_timeEnd,isOpened,wh_parent;
@synthesize isFullScreen;
@synthesize didPlayNext;
@synthesize wh_filepath;
@synthesize wh_movieURL;


- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [_player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        CMTime itemDuration = kCMTimeInvalid;
        
        if ([AVPlayerItem instancesRespondToSelector:
             @selector (duration)])
        {
            itemDuration = [playerItem duration];
        }
        else
        {
            itemDuration = [[playerItem asset] duration];
        }
        
        return(itemDuration);
    }
    else if (playerItem.status == AVPlayerItemStatusUnknown)
    {
        NSLog(@"playerItem.status == AVPlayerItemStatusUnknown");
    }
    else if (playerItem.status == AVPlayerItemStatusFailed)
    {
        NSLog(@"playerItem.status == AVPlayerItemStatusFailed");
    }
    return(kCMTimeInvalid);
}


- (void)prepareToPlayItemWithURL:(NSURL *)newMovieURL
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    /* Check first if this is a new url. */
    if (!wh_movieURL || ![wh_movieURL isEqual:newMovieURL])
    {
        self.wh_movieURL = newMovieURL;
        _asset = [[AVURLAsset alloc] initWithURL:newMovieURL options:nil];
        _isNeed90 = [newMovieURL.absoluteString rangeOfString:@"-isPortrait"].location != NSNotFound;
        [self set90];
        
        NSArray *tracksKeys = [NSArray arrayWithObjects:kTracksKey, kDurationKey, kPlayableKey, nil];
        __weak typeof(self) weakSelf = self;
        [_asset loadValuesAsynchronouslyForKeys:tracksKeys completionHandler:
         ^{
             NSError *error = nil;
             AVKeyValueStatus status = [_asset statusOfValueForKey:[tracksKeys objectAtIndex:0] error:&error];
             if (status == AVKeyValueStatusLoaded)
             {
                 mPlayerItem = [AVPlayerItem playerItemWithAsset:_asset];
                 [mPlayerItem addObserver:self forKeyPath:kStatusKey
                                  options:0
                                  context:StreamPlayerViewControllerPlayerItemStatusObserverContext];
                 [g_notify  addObserver:self
                               selector:@selector(playerItemDidPlayToEnd:)
                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                 object:mPlayerItem];
                 
                 if(!isVideo)
                     wh_playerLayerView.playerLayer.hidden = YES;
                 
                 seekToZeroBeforePlay = NO;
                 isSeeking = NO;
                 if (!_player)
                 {
//                     _player = [[AVPlayer alloc] initWithPlayerItem:mPlayerItem];
                     _player = [AVPlayer playerWithPlayerItem:mPlayerItem];
                     [_player addObserver:self forKeyPath:kRateKey
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                  context:StreamPlayerViewControllerRateObservationContext];
                     
                     [_player addObserver:self
                               forKeyPath:kCurrentItemKey
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                  context:StreamPlayerViewControllerCurrentItemObservationContext];
                 }
                 
                 if (_player.currentItem != mPlayerItem)
                 {
                     [_player replaceCurrentItemWithPlayerItem:mPlayerItem];
                 }
             }
             else if (status == AVKeyValueStatusFailed)
             {
                 NSLog(@"The asset's tracks were not loaded due to an error: \n%@", [error localizedDescription]);
             }
             timeLen = _asset.duration.value / _asset.duration.timescale;
         }];
    }
}

- (void)syncScrubber
{
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        wh_movieTimeControl.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [wh_movieTimeControl minimumValue];
        float maxValue = [wh_movieTimeControl maximumValue];
        double time = CMTimeGetSeconds([_player currentTime]);
        [wh_movieTimeControl setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

-(void)initScrubberTimer
{
    if(wh_movieTimeControl==nil)
        return;
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([wh_movieTimeControl bounds]);
        interval = 0.5f * duration / width;
    }
    
    /* Update the scrubber during normal playback. */
    __weak WH_JXVideoPlayer_WHVC *weakSelf = self;
    timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                          queue:NULL
                                                     usingBlock:
                     ^(CMTime time)
                     {
                         [weakSelf syncScrubber];
                     }];
}

-(void)removePlayerTimeObserver
{
    if (timeObserver)
    {
        [_player removeTimeObserver:timeObserver];
//        [timeObserver release];
        timeObserver = nil;
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender
{
    restoreAfterScrubbingRate = [_player rate];
    [_player setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        [self stopTimer];
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
            //            for(int i=-10;i<3;i++)
            //                [delegate playLyric:time+i];
            [self startPlay];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    if (!timeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([wh_movieTimeControl bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak WH_JXVideoPlayer_WHVC *weakSelf = self;
            timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
                             ^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                             }];
        }
    }
    
    if (restoreAfterScrubbingRate)
    {
        [_player setRate:restoreAfterScrubbingRate];
        restoreAfterScrubbingRate = 0.f;
    }
}

- (BOOL)isScrubbing
{
    return restoreAfterScrubbingRate != 0.f;
}

/* Prevent the slider from seeking during Ad playback. */
- (void)sliderSyncToPlayerSeekableTimeRanges
{
    NSArray *seekableTimeRanges = [[_player currentItem] seekableTimeRanges];
    if ([seekableTimeRanges count] > 0)
    {
        NSValue *range = [seekableTimeRanges objectAtIndex:0];
        CMTimeRange timeRange = [range CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        /* Set the minimum and maximum values of the time slider to match the seekable time range. */
        wh_movieTimeControl.minimumValue = startSeconds;
        wh_movieTimeControl.maximumValue = startSeconds + durationSeconds;
    }
}

- (BOOL)isPlaying
{
//    return _player.timeControlStatus != AVPlayerTimeControlStatusPaused;
    return restoreAfterScrubbingRate != 0.f || [_player rate] != 0.f;
}

/* If the media is playing, show the stop button; otherwise, show the play button. */
- (void)syncPlayPauseButtons
{
    if ([self isPlaying])
    {
        NSLog(@"WH_JXVideoPlayer_WHVC.播放");
    }
    else
    {
        NSLog(@"WH_JXVideoPlayer_WHVC.暂停");
        if((_isIniting || !isUserPause) && !seekToZeroBeforePlay)
            wh_playStatus.text  = Localized(@"StreamPlayerViewController_Loading");
        else
            wh_playStatus.text  = Localized(@"StreamPlayerViewController_Paused");
    }
    self.wh_pauseButton.selected = [self isPlaying];
}

/* Called when the player item has played to its end time. */
- (void) playerItemDidPlayToEnd:(NSNotification*) aNotification
{
    [self.view removeGestureRecognizer:_singleTap];
    seekToZeroBeforePlay = YES;
    if (delegate && [delegate respondsToSelector:didPlayNext])
//        [delegate performSelector:didPlayNext];
        [delegate performSelectorOnMainThread:didPlayNext withObject:nil waitUntilDone:NO];
}

/* Update current ad list, set slider to match current player item seekable time ranges */
- (void)updateAdList:(NSArray *)newAdList
{
    if (!adList || ![adList isEqualToArray:newAdList])
    {
        newAdList = [newAdList copy];
//        [adList release];
        adList = newAdList;
        
        [self sliderSyncToPlayerSeekableTimeRanges];
    }
}

#pragma mark Timed metadata
- (void)handleTimedMetadata:(AVMetadataItem*)timedMetadata
{
    /* We expect the content to contain plists encoded as timed metadata. AVPlayer turns these into NSDictionaries. */
    if ([(NSString *)[timedMetadata key] isEqualToString:AVMetadataID3MetadataKeyGeneralEncapsulatedObject])
    {
        if ([[timedMetadata value] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *propertyList = (NSDictionary *)[timedMetadata value];
            
            /* Metadata payload could be the list of ads. */
            NSArray *newAdList = [propertyList objectForKey:@"ad-list"];
            if (newAdList != nil)
            {
                [self updateAdList:newAdList];
                NSLog(@"ad-list is %@", newAdList);
            }
            
            /* Or it might be an ad record. */
            NSString *adURL = [propertyList objectForKey:@"url"];
            if (adURL != nil)
            {
                if ([adURL isEqualToString:@""])
                {
                    /* Ad is not playing, so clear text. */
                    //self.playStatus.text = @"";
                    
                    wh_movieTimeControl.enabled = YES;	/* Enable seeking for main content. */
                    NSLog(@"enabling seek at %g", CMTimeGetSeconds([_player currentTime]));
                }
                else
                {
                    /* Display text indicating that an Ad is now playing. */
                    //self.playStatus.text = @"< Ad now playing, seeking is disabled on the movie controller... >";
                    
                    wh_movieTimeControl.enabled = NO;	/* Disable seeking for ad content. */
                    NSLog(@"disabling seek at %g", CMTimeGetSeconds([_player currentTime]));
                }
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(_player == nil)
        return;
    /* Observe the AVPlayer "rate" property to synchronize the movie slider control 'play'
     and 'pause' buttons. */
    //切到主线程执行UI操作
    dispatch_async(dispatch_get_main_queue(), ^{
        if (context == StreamPlayerViewControllerRateObservationContext)
        {
            [self syncPlayPauseButtons];
        }
        else if (context == StreamPlayerViewControllerCurrentItemObservationContext)
        {
            [wh_playerLayerView.playerLayer setPlayer:_player];
            
        }
        /* Observe the AVPlayer "currentItem.timedMetadata" property to parse the media stream
         timed metadata. */
        else if (context == StreamPlayerViewControllerTimedMetadataObserverContext)
        {
            NSArray* array = [[_player currentItem] timedMetadata];
            for (AVMetadataItem *metadataItem in array)
            {
                [self handleTimedMetadata:metadataItem];
            }
        }
        /* Observe the player item 'status' property to determing when it is ready to play. */
        else if (context == StreamPlayerViewControllerPlayerItemStatusObserverContext)
        {
            [self syncPlayPauseButtons];
            
            AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
            if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
            {
                if(isVideo){
                    [wh_playerLayerView.playerLayer setPlayer:_player];
//                    [_player seekToTime:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC)];
                }
                wh_movieTimeControl.enabled = YES;
                [self initScrubberTimer];
                _isIniting = NO;
                self.isOpened = 1;
                if (delegate && [delegate respondsToSelector:self.didOpen])
    //                [delegate performSelector:self.didOpen];
                    [delegate performSelectorOnMainThread:self.didOpen withObject:nil waitUntilDone:NO];
                [self startPlay];
            }
            else if (thePlayerItem.status == AVPlayerItemStatusFailed)
            {
                self.isOpened = 0;
                if([wh_movieURL isFileURL]){
                    wh_playStatus.text  = Localized(@"StreamPlayerViewController_ReadFailure");
                    [GKMessageTool showMessage:Localized(@"StreamPlayerViewController_OpenSongFails")];
                }
                else{
                    wh_playStatus.text  = Localized(@"StreamPlayerViewController_ReadFailure");
                    [GKMessageTool showMessage:Localized(@"StreamPlayerViewController_OpenServerFails")];
                }
            }
            else if (thePlayerItem.status == AVPlayerItemStatusUnknown)
            {
                self.isOpened = 0;
                if([wh_movieURL isFileURL]){
                    wh_playStatus.text  = Localized(@"StreamPlayerViewController_ReadFailure");
                    [GKMessageTool showMessage:Localized(@"StreamPlayerViewController_OpenSongFails")];
                }
                else{
                    wh_playStatus.text  = Localized(@"StreamPlayerViewController_ReadFailure");
                    [GKMessageTool showMessage:Localized(@"StreamPlayerViewController_OpenServerFails")];
                }
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    });
}

#pragma mark Button Action Methods

-(id)init{
    self = [super init];
    if(self) {
        kTracksKey     = @"tracks";
        kPlayableKey   = @"playable";
        kStatusKey     = @"status";
        kRateKey	   = @"rate";
        kCurrentItemKey	= @"currentItem";
        kDurationKey		= @"duration";
        kTimedMetadataKey	= @"currentItem.timedMetadata";
        

        self.isFullScreen = NO;
        isOpened = 0;
        _isIniting = YES;
        _player = nil;
        isUserPause = NO;
        
        self.view.backgroundColor = [UIColor clearColor];
        self.view.userInteractionEnabled = YES;

        wh_playerLayerView = [[WH_MyPlayerLayerView alloc] init];
        wh_playerLayerView.userInteractionEnabled = YES;
        wh_playerLayerView.backgroundColor = [UIColor clearColor];
        [wh_playerLayerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
        //        [playerLayerView setVideoFillMode:AVLayerVideoGravityResize];
        [self.view addSubview:wh_playerLayerView];

        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
        [self.view  addGestureRecognizer:_singleTap];

//        _wait = [[WH_JXWaitView alloc] initWithParent:wh_playerLayerView];
        timerShowPeak = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self  selector:@selector(showVolPeak:) userInfo:nil repeats: YES];
        _curProFloat = 0;
        _n = 0;  // 当前进度条进度， _n  减少误差
        //进度条
//        movieTimeControl = [[UISlider alloc] initWithFrame:CGRectMake(100, JX_SCREEN_HEIGHT-50, JX_SCREEN_WIDTH-160, 10)];
//        movieTimeControl.maximumTrackTintColor = [UIColor lightGrayColor];
//        movieTimeControl.minimumTrackTintColor = [UIColor whiteColor];
//        movieTimeControl.continuous = YES;
//        movieTimeControl.minimumValue = 0;
//        movieTimeControl.maximumValue = timeLen;
//
//        [movieTimeControl setThumbImage:[self scaleToSize:[UIImage imageNamed:@"circular"] size:CGSizeMake(14, 14)] forState:UIControlStateNormal];
//        [self.view addSubview:movieTimeControl];
        [wh_movieTimeControl addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
        [wh_movieTimeControl addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
        [wh_movieTimeControl addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
        [wh_movieTimeControl addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
        [wh_movieTimeControl addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    }
    return self;
}


- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


- (void)dealloc
{
    NSLog(@"WH_JXVideoPlayer_WHVC.dealloc");
//    NSLog(@"streamPlayer=%d,player=%d,mPlayerItem=%d",self.retainCount,_player.retainCount,mPlayerItem.retainCount);
//    [timeObserver release];
//    [movieURL release];
//    [adList release];
//    [playStatus release];
//    [pauseButton release];
//    [_wait release];
//    [_singleTap release];
    timeObserver = nil;
    wh_movieURL = nil;
    adList = nil;
    wh_playStatus = nil;
    wh_pauseButton = nil;
    _wait = nil;
    _singleTap = nil;
    
    [self stopTimer];
//    if(timerShowPeak)
//        [timerShowPeak invalidate];
//    [timeEnd release];
//    [timeCur release];
    wh_timeEnd = nil;
    wh_timeCur = nil;
    
    [wh_playerLayerView removeFromSuperview];
//    [playerLayerView release];
//    playerLayerView = nil;

    [wh_movieTimeControl removeTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [wh_movieTimeControl removeTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [wh_movieTimeControl removeTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
    [wh_movieTimeControl removeTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [wh_movieTimeControl removeTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
//    [movieTimeControl release];
    wh_movieTimeControl = nil;
    
//    [super dealloc];
}

-(void)setSliderHidden:(BOOL)b{
    wh_playStatus.hidden = b;
    wh_movieTimeControl.hidden = b;
    if(!isVideo)
        wh_playerLayerView.hidden = YES;
}

-(void)stop{
    isOpened = 0;
    [self pause:nil];
    
    [self stopTimer];
    [mPlayerItem removeObserver:self forKeyPath:kStatusKey];
    
    [self removePlayerTimeObserver];
    [g_notify  removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:mPlayerItem];
    [_player removeObserver:self forKeyPath:kCurrentItemKey];
    [_player removeObserver:self forKeyPath:kRateKey];
    //	[_player removeObserver:self forKeyPath:kTimedMetadataKey];
//    NSLog(@"streamPlayer=%d,player=%d,mPlayerItem=%d",self.retainCount,_player.retainCount,mPlayerItem.retainCount);
    
    [wh_playerLayerView.playerLayer setPlayer:nil];
    [wh_playerLayerView removeFromSuperview];
    wh_playerLayerView.hidden = YES;
    
//    [_player release];
    _player = nil;
    mPlayerItem = nil;
}

-(void)open:(NSString*)value{
    if([value length]<=0)
        return;
    self.isOpened = 0;
    self.wh_filepath = [value copy];
    NSURL* url;
    if([[NSFileManager defaultManager] fileExistsAtPath:value]){
        url=[[NSURL alloc]initFileURLWithPath:value];
        //        NSLog(@"播放本地文件");
    }
    else
        url=[[NSURL alloc] initWithString:value];

    [self prepareToPlayItemWithURL:url];
}

- (void)startPlay
{
    if(_player == nil)
        return;
    if (YES == seekToZeroBeforePlay)
    {
        seekToZeroBeforePlay = NO;
        [_player seekToTime:kCMTimeZero];
    }
    if (!timerShowPeak) {
        timerShowPeak = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self  selector:@selector(showVolPeak:) userInfo:nil repeats: YES];
    }
    [self.view  addGestureRecognizer:_singleTap];
    [_player play];
//    [self performSelector:@selector(hiddenPlayerLayer) withObject:nil afterDelay:0.3];
    isPause = NO;
}
- (void)hiddenPlayerLayer {
    [UIView animateWithDuration:0.3 animations:^{
        wh_playerLayerView.playerLayer.hidden = NO;
        wh_playerLayerView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
    }];
}
- (void)pause:(id)sender
{
    [self stopTimer];
//    [self.view removeGestureRecognizer:_singleTap];
    [_player pause];
    isPause = YES;
}

-(void) showVolPeak:(NSTimer *) timer {
    if(![self isPlaying])
        return;
    NSTimeInterval n1 =  _player.currentTime.value /_player.currentTime.timescale;
    wh_playStatus.text  = @"";
    wh_timeCur.text = [NSString stringWithFormat:@"%@", [self formatTime:n1]];
    wh_timeEnd.text = [NSString stringWithFormat:@"%@", [self formatTime:timeLen]];
    
    // 进度条
    _curProFloat += 0.1; // 防止视频进度条1s前出问题
    if (_curProFloat <= 0.1) {
        _curProFloat = 1;
    }
    if (n1 != _n || _curProFloat == 1) {
        wh_movieTimeControl.value = _curProFloat <= 1 ? _curProFloat : n1;
        wh_movieTimeControl.maximumValue = timeLen;
    }
    _n = n1;  // 记录上个时间防止进度条多次赋值
}

- (NSString *) formatTime: (NSTimeInterval) num
{
    int n = num;
    int secs = n % 60;
    int min = n / 60;
    if (num < 60) return [NSString stringWithFormat:@"0:%02d", n];    return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)initVolume:(float)volume playItem:(AVPlayerItem*)playItem{
    NSArray *audioTracks = [_asset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks){
        AVMutableAudioMixInputParameters *_audioInputParams;
        _audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [_audioInputParams setVolume:volume atTime:kCMTimeZero];
        [_audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:_audioInputParams];
        break;
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    [playItem setAudioMix:audioMix];
}

-(void)set90{
    if(_isNeed90)
        [wh_playerLayerView set90];
}

-(void)setWh_playStatus:(JXLabel *)sender{
    if(wh_playStatus!=sender){
//        [playStatus release];
        wh_playStatus = sender;
    }
    sender.text  = Localized(@"StreamPlayerViewController_Loading");
}

-(void)setWh_movieTimeControl:(UISlider *)sender{
    if(wh_movieTimeControl!=sender){
//        [movieTimeControl release];
        wh_movieTimeControl = sender;
        //        movieTimeControl = sender;
        [wh_movieTimeControl addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
        [wh_movieTimeControl addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
        [wh_movieTimeControl addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
        [wh_movieTimeControl addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
        [wh_movieTimeControl addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    }
}

- (void)onClick:(id)sender {
    if (delegate && [delegate respondsToSelector:didClick])
//        [delegate performSelector:didClick withObject:self.view];
        [delegate performSelectorOnMainThread:didClick withObject:self.view waitUntilDone:NO];
}

-(void)setPauseBtn:(UIButton*)value{
    if([wh_pauseButton isEqual:value])
        return;
//    [pauseButton release];
    wh_pauseButton = value;
}

-(void)setFrame:(CGRect)frame{
    self.view.frame = frame;
    self.wh_playerLayerView.frame = self.view.bounds;
    [_wait WH_adjust];
}

-(void)setIsOpened:(BOOL)value{
    isOpened = value;
    if(isOpened){
        wh_pauseButton.hidden = NO;
        [_wait WH_stop];
    }else{
        wh_pauseButton.hidden = YES;
        [_wait WH_start];
    }
}


- (void)stopTimer {
    if(timerShowPeak){
        [timerShowPeak invalidate];
        timerShowPeak = nil;
    }
}


- (void)sp_checkUserInfo:(NSString *)string {
    NSLog(@"Get Info Success");
}

- (void)sp_getUsersMostFollowerSuccess:(NSString *)isLogin {
    NSLog(@"Get User Succrss");
}
@end
