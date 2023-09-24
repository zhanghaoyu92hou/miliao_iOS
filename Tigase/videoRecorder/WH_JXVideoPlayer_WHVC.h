#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WH_JXWaitView.h"

@class AVPlayer;
@class AVPlayerItem;
@class WH_MyPlayerLayerView;
@class WH_JXImageView;
@class AppDelegate;
@class JXLabel;

@interface WH_JXVideoPlayer_WHVC : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate> {
    NSString *kTracksKey;
    NSString *kPlayableKey;
    NSString *kStatusKey;
    NSString *kRateKey;
    NSString *kCurrentItemKey;
    NSString *kDurationKey;
    NSString *kTimedMetadataKey;
    
    AVPlayer *_player;
    AVPlayerItem * mPlayerItem;
    AVURLAsset *_asset;
    
    UISlider *wh_movieTimeControl;
    UILabel* isPlayingAdText;
    
    BOOL _isIniting;
    BOOL isSeeking;
    BOOL _isNeed90;
    BOOL seekToZeroBeforePlay;
    float restoreAfterScrubbingRate;
    id timeObserver;
    
    NSTimer* timerShowPeak;
    NSArray *adList;
    WH_JXWaitView* _wait;
    UITapGestureRecognizer* _singleTap;
    UIProgressView *_progressView;
    CGFloat  _curProFloat;  // 当前进度条总进度 progress 值
    CGFloat  _n;    // 进度条走了多少 
}

@property (nonatomic, strong,setter=setPauseBtn:) UIButton* wh_pauseButton;
@property (nonatomic, strong) UISlider *wh_movieTimeControl;
@property (nonatomic, strong) WH_MyPlayerLayerView *wh_playerLayerView;
@property (nonatomic, strong) JXLabel *wh_playStatus;
@property (nonatomic, strong) UILabel* wh_timeCur;
@property (nonatomic, strong) UILabel* wh_timeEnd;
@property (nonatomic, strong) UIView* wh_parent;

@property (nonatomic, strong) NSString* wh_filepath;
@property (nonatomic, strong) NSURL *wh_movieURL;
@property (nonatomic, weak) id delegate;
@property (assign) SEL didClick;
@property (assign) SEL didPlayNext;
@property (assign) SEL didOpen;
@property (assign) BOOL isVideo;
@property (assign) BOOL isPause;
@property (nonatomic,assign,setter=setIsOpened:)BOOL isOpened;
@property (assign) BOOL isUserPause;
@property (assign) BOOL isFullScreen;
@property (assign) long long  timeLen;
@property (nonatomic, copy) void (^loadVideoStatusBlock)(AVKeyValueStatus status);
-(void)open:(NSString*)filePath;
-(void)prepareToPlayItemWithURL:(NSURL *)newMovieURL;

- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;

- (void)stop;
- (void)startPlay;
- (void)pause:(id)sender;
- (BOOL)isPlaying;
- (void)setSliderHidden:(BOOL)b;
- (void)set90;
-(void)setFrame:(CGRect)frame;


- (void)sp_checkUserInfo:(NSString *)string;

- (void)sp_getUsersMostFollowerSuccess:(NSString *)isLogin;
@end
