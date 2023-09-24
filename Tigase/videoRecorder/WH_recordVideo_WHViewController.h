#import <UIKit/UIKit.h>
#import "WH_ImageSelector_WHViewController.h"
#import "WH_JXVideoPlayer.h"

@class WH_JXCaptureMedia;
@class JXLabel;
@class WH_JXImageView;

@interface WH_recordVideo_WHViewController : UIViewController <ImageSelectorViewDelegate>{
    WH_JXCaptureMedia* _capture;

    UIView* preview;
    UIImageView *_timeBGView;
    UILabel *_timeLabel;
    WH_JXImageView* _flash;
    WH_JXImageView* _flashOn;
    WH_JXImageView* _flashOff;
    WH_JXImageView* _cammer;
    UIButton* _recrod;
    WH_JXImageView* _close;
    WH_JXImageView* _save;
//    UIImageView *_noticeView;
    UILabel *_noticeLabel;
    UILabel * _recordLabel;
    UIView *_bottomView;
    WH_recordVideo_WHViewController* _pSelf;
}

//- (IBAction)doFileConvert;

@property(nonatomic,assign) BOOL isReciprocal;//是否倒计时,为该参赋值一定也要给mixTime赋值
@property(nonatomic,assign) int maxTime;
@property(nonatomic,assign) int minTime;
@property(nonatomic,assign) BOOL isShowSaveImage;//是否显示选择保存截图界面
@property(nonatomic,assign) int timeLen;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didRecord;
@property (nonatomic,strong) NSString* outputFileName;//返回的video
@property (nonatomic,strong) NSString* outputImage;//返回的截图
@property (nonatomic,strong) WH_JXCaptureMedia* wh_recorder;


@property (nonatomic, strong) UIView *wh_playerView;
@property (nonatomic, strong) WH_JXVideoPlayer *wh_player;






@end
