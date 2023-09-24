//
//  addMsgVC.h
//  sjvodios
//
//  Created by  on 19-5-5-23.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_admob_WHViewController.h"
#import "WH_JXVideoPlayer.h"
#import "WH_AudioPlayerTool.h"
#import "WH_JXAudioRecorder_WHViewController.h"

@class JXTextView;
@class StreamPlayerViewController;

@protocol JXServerResult;

@interface addMsgVC : WH_admob_WHViewController<JXServerResult,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,WH_AudioRecorderDelegate,LXActionSheetDelegate>{
    int _nSelMenu;
    UIScrollView* svImages;
    UIScrollView* svAudios;
    UIScrollView* svVideos;
    UIScrollView* svFiles;

    int  _recordCount;
    int  _refreshCount;
    int  _buildHeight;
    NSInteger  _photoIndex;
    
    UITextView*  _remark;
    WH_AudioPlayerTool* audioPlayer;
    WH_JXVideoPlayer* videoPlayer;
    NSMutableArray* _array;
    NSMutableArray* _images;
    NSMutableArray* _imageStrings;
    NSString* tUrl;
    NSString* oUrl;
}
@property(assign)BOOL isChanged;
@property(nonatomic,assign)int  dataType;
@property(nonatomic,retain) NSString* wh_audioFile;
@property(nonatomic,retain) NSString* wh_videoFile;
@property(nonatomic,retain) NSString* wh_fileFile;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didSelect;

@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, copy) NSString *wh_shareTitle;
@property (nonatomic, copy) NSString *wh_shareIcon;
@property (nonatomic, copy) NSString *wh_shareUr;

@property (nonatomic, strong) NSString *wh_urlShare; // 链接分享


@property (nonatomic, assign) BOOL wh_isShortVideo;

//
@property (nonatomic,assign) int wh_maxImageCount;

@property (nonatomic,copy) void(^block)(void);

-(void)wh_showImages;
-(void)wh_doRefresh;



@end
