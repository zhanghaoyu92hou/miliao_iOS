//
//  addMsgVC.m
//  sjvodios
//
//  Created by  on 19-5-5-23.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "addMsgVC.h"
#import "AppDelegate.h"
#import "WH_JXImageView.h"
#import "JXServer.h"
#import "WH_JXConnection.h"
#import "ImageResize.h"
#import "UIFactory.h"
#import "JXTableView.h"
#import "QBImagePickerController.h"
#import "WH_recordVideo_WHViewController.h"
#import "JXTextView.h"
#import "WH_JXMediaObject.h"
#import "LXActionSheet.h"
#import "WH_myMedia_WHVC.h"
#import "JXLocationVC.h"
#import "JXMapData.h"
#import "WhoCanSeeViewController.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "RITLPhotosViewController.h"
#import "RITLPhotosDataManager.h"
#import "WH_JXMyFile.h"
#import "UIImageView+WH_FileType.h"
#import "WH_JXFileDetail_WHViewController.h"
#import "WH_JXShareFileObject.h"
#import "WH_webpage_WHVC.h"
#import "WH_JXSelector_WHVC.h"
#ifdef Meeting_Version
#ifdef Live_Version
#import "JXSmallVideoViewController.h"
#endif
#endif
#import "WH_JXActionSheet_WHVC.h"
#import "WH_JXCamera_WHVC.h"
#import "QCheckBox.h"

#import "WH_GKDYHome_WHViewController.h"
#import "OBSHanderTool.h"

#define insert_photo_tag -100000
typedef enum {
    MsgVisible_public = 1,
    MsgVisible_private,
    MsgVisible_see,
    MsgVisible_nonSee,
//    MsgVisible_remind,
}MsgVisible;


@interface addMsgVC()<VisibelDelegate,RITLPhotosViewControllerDelegate,WH_JXSelector_WHVCDelegate, WH_JXActionSheet_WHVCDelegate, WH_JXCamera_WHVCDelegate>

@property (nonatomic) UIButton * lableBtn;
@property (nonatomic) UIButton * locBtn;
@property (nonatomic) UIButton * canSeeBtn;
@property (nonatomic) UIButton * remindWhoBtn;
@property (nonatomic) UIButton * replybanBtn;
@property (nonatomic, strong) QCheckBox *checkbox;

@property (nonatomic) UILabel * lableLabel;
@property (nonatomic) UILabel * visibleLabel;
@property (nonatomic) UILabel * remindLabel;

@property (nonatomic) MsgVisible visible;
@property (nonatomic) NSArray * userArray;
@property (nonatomic) NSArray * userIdArray;
@property (nonatomic) NSMutableArray * selLabelsArray;
@property (nonatomic) NSMutableArray * mailListUserArray;
@property (nonatomic) CLLocationCoordinate2D coor;
@property (nonatomic) NSString * locStr;
@property (nonatomic) NSArray * remindArray;
@property (nonatomic) NSArray * remindNameArray;

@property (nonatomic) NSArray * visibelArray;

@property (nonatomic, assign) int timeLen;

@property (nonatomic, assign) NSInteger currentLableIndex;


@property (nonatomic, strong) JXLocationVC *locationVC;
@property (nonatomic, strong) UIButton *finishBtn;
@end

@implementation addMsgVC
@synthesize isChanged;
@synthesize wh_audioFile;
@synthesize wh_videoFile;
@synthesize wh_fileFile;
@synthesize dataType;

#define video_tag -100
#define audio_tag -200
#define pause_tag -300
#define file_tag  -400


- (addMsgVC *) init
{
	self  = [super init];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_maxImageCount = 9;
    self.wh_isGotoBack = YES;
    self.wh_isFreeOnClose = YES;
    self.title = Localized(@"addMsgVC_SendFriend");
    //self.view.frame = g_window.bounds;
    [self createHeadAndFoot];
    
    self.wh_tableBody.backgroundColor = [UIColor whiteColor];
    _images = [[NSMutableArray alloc]init];
    _imageStrings = [[NSMutableArray alloc] init];
    _visible = MsgVisible_public;
    _remindArray = [NSArray array];
    _visibelArray = [NSArray arrayWithObjects:Localized(@"JXBlogVisibel_public"), Localized(@"JXBlogVisibel_private"), Localized(@"JXBlogVisibel_see"), Localized(@"JXBlogVisibel_nonSee"), nil];
#ifdef Meeting_Version
#ifdef Live_Version
    _currentLableIndex = JXSmallVideoTypeOther - 1;
#endif
#endif
    
    _finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_finishBtn setTitle:@"发表" forState:UIControlStateNormal];
    [_finishBtn setTitle:@"发表" forState:UIControlStateHighlighted];
    [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _finishBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 43 - 10, JX_SCREEN_TOP - 8 - 28, 43, 28);
    [_finishBtn addTarget:self action:@selector(actionSave) forControlEvents:UIControlEventTouchUpInside];
    _finishBtn.layer.cornerRadius = CGRectGetHeight(_finishBtn.frame) / 2.f;
    _finishBtn.layer.masksToBounds = YES;
    _finishBtn.backgroundColor = HEXCOLOR(0x0093FF);
    _finishBtn.titleLabel.font = sysFontWithSize(14);
    [self.wh_tableHeader addSubview:_finishBtn];
    

	return self;
}

-(void)dealloc{
//    NSLog(@"addMsgVC.dealloc");
    [_images removeAllObjects];
    [_imageStrings removeAllObjects];
//    [_images release];
//    [super dealloc];
}

-(void)setDataType:(int)value{
    dataType = value;

    [g_factory removeAllChild:self.wh_tableBody];
    _buildHeight=0;
    
    if(dataType >= weibo_dataType_text){
        [self buildTextView];
        self.title = Localized(@"JX_SendWord");
        
        //在发布信息后调用，并使其刷新
    }
    if(dataType == weibo_dataType_image){
        [self buildImageViews];
        self.title = Localized(@"JX_SendImage");
        if (self.wh_shareUr) {
            __block UIImage *image = nil;
            if ([self.wh_shareUr containsString:@"file:///"]) {//系统相册
               
            }else {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.wh_shareUr]];
                image = [[UIImage alloc] initWithData:data];
            }
            
            [_images addObject:image];
        }
    }
    if(dataType == weibo_dataType_audio){
        [self buildAudios];
        [self showAudios];
        self.title = Localized(@"JX_SendVoice");
    }
    if(dataType == weibo_dataType_video){
        [self buildVideos];
        if (self.wh_shareUr) {//SDK分享到朋友圈
            wh_videoFile = self.wh_shareUr;
        }
        if (wh_videoFile.length > 0) {
            
            UIImage *image = [FileInfo getFirstImageFromVideo:wh_videoFile];
            if (image) {
                [_images addObject:image];
            }
        }
        [self showVideos];
        self.title = Localized(@"JX_SendVideo");
    }
    if (dataType == weibo_dataType_file) {
        
        [self buildFiles];
        [self showFiles];
        self.title = Localized(@"JX_SendFile");
    }
    
    if (dataType == weibo_dataType_share) {
        [self buildShare];
        self.title = Localized(@"JX_ShareLifeCircle");
    }
    
    int h=9,w=JX_SCREEN_WIDTH-9*2;
    CGFloat maxY = 0;
    
    
    //可见
    
    [self.wh_tableBody addSubview:self.canSeeBtn];
    self.canSeeBtn.frame = CGRectMake(10, h+_buildHeight, JX_SCREEN_WIDTH-20, 50);
    maxY = CGRectGetMaxY(self.canSeeBtn.frame);
    
    
    //提醒
    [self.wh_tableBody addSubview:self.remindWhoBtn];
    self.remindWhoBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.canSeeBtn.frame), JX_SCREEN_WIDTH-20, 50);
    maxY = CGRectGetMaxY(self.remindWhoBtn.frame);
    
    if (self.wh_isShortVideo) {
        //标签
        [self.wh_tableBody addSubview:self.lableBtn];
        self.lableBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.remindWhoBtn.frame), JX_SCREEN_WIDTH-20, 50);
        maxY = CGRectGetMaxY(self.lableBtn.frame);
    }
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        //位置
        [self.wh_tableBody addSubview:self.locBtn];
        if (self.wh_isShortVideo) {
            self.locBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.lableBtn.frame), JX_SCREEN_WIDTH-20, 50);
        }else {
            self.locBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.remindWhoBtn.frame), JX_SCREEN_WIDTH-20, 50);
        }
        maxY = CGRectGetMaxY(self.locBtn.frame);
    }
    
    //禁止他人评论
    [self.wh_tableBody addSubview:self.replybanBtn];
    self.replybanBtn.frame = CGRectMake(10, maxY, JX_SCREEN_WIDTH-20, 50);
    maxY = CGRectGetMaxY(self.replybanBtn.frame);
    
    
//    UIButton* btn;
//    
//    btn = [UIFactory WH_create_WHButtonWithTitle:Localized(@"JX_Send")
//                                 titleFont:sysFontWithSize(15)
//                                titleColor:[UIColor whiteColor]
//                                    normal:nil
//                                 highlight:nil];
//    [btn setBackgroundImage:[g_theme themeTintImage:@"feaBtn_backImg_sel"] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[g_theme themeTintImage:@"feaBtn_backImg_sel"] forState:UIControlStateHighlighted];
//    
//    btn.frame = CGRectMake(9, h+maxY+20, w, h1);
//    btn.custom_acceptEventInterval = .25f;
//    [btn addTarget:self action:@selector(actionSave) forControlEvents:UIControlEventTouchUpInside];
//    [self.wh_tableBody addSubview:btn];
    
    [self wh_showImages];
}
- (void)updateUI {
    int h=9,w=JX_SCREEN_WIDTH-9*2;
    CGFloat maxY = 0;
    
    
    //可见
    self.canSeeBtn.frame = CGRectMake(10, h + svImages.bottom, JX_SCREEN_WIDTH-20, 50);
    maxY = CGRectGetMaxY(self.canSeeBtn.frame);
    
    
    //提醒
    self.remindWhoBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.canSeeBtn.frame), JX_SCREEN_WIDTH-20, 50);
    maxY = CGRectGetMaxY(self.remindWhoBtn.frame);
    
    if (self.wh_isShortVideo) {
        //标签
        self.lableBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.remindWhoBtn.frame), JX_SCREEN_WIDTH-20, 50);
        maxY = CGRectGetMaxY(self.lableBtn.frame);
    }
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        //位置
        if (self.wh_isShortVideo) {
            self.locBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.lableBtn.frame), JX_SCREEN_WIDTH-20, 50);
        }else {
            self.locBtn.frame = CGRectMake(10, h+CGRectGetMaxY(self.remindWhoBtn.frame), JX_SCREEN_WIDTH-20, 50);
        }
        maxY = CGRectGetMaxY(self.locBtn.frame);
    }
    
    //禁止他人评论
    self.replybanBtn.frame = CGRectMake(10, maxY, JX_SCREEN_WIDTH-20, 50);
    maxY = CGRectGetMaxY(self.replybanBtn.frame);
    if (self.replybanBtn.bottom > self.wh_tableBody.height) {
        self.wh_tableBody.scrollEnabled = YES;
        self.wh_tableBody.contentSize = CGSizeMake(self.wh_tableBody.width, self.replybanBtn.bottom + 20);
    }
    
}
- (UIButton *)lableBtn {
    if (!_lableBtn) {
        _lableBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lableBtn setBackgroundColor:[UIColor whiteColor]];
        [_lableBtn setTitle:Localized(@"JX_SelectionLabel") forState:UIControlStateNormal];
        [_lableBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_lableBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateSelected];
        _lableBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_lableBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
        _lableBtn.titleLabel.font = sysFontWithSize(16);
        _lableBtn.custom_acceptEventInterval = 1.0f;
        [_lableBtn addTarget:self action:@selector(lableBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(15, 0, JX_SCREEN_WIDTH-15*2, 0.8);
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [_lableBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap"]];
        locImg.frame = CGRectMake(25, 15, 20, 20);
        [_lableBtn addSubview:locImg];
        
        //        _locLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:@"所在位置" font:sysFontWithSize(15) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        //        _locLabel.frame = CGRectMake(CGRectGetMaxX(locImg.frame)+10, 8, JX_SCREEN_WIDTH-CGRectGetMaxX(locImg.frame)-10-50, 30);
        //        [_locBtn addSubview:_locLabel];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 16, 20, 20)];
        arrowView.image = [UIImage imageNamed:@"set_list_next"];
        [_lableBtn addSubview:arrowView];
        
        _lableLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:Localized(@"OTHER") font:sysFontWithSize(16) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _lableLabel.frame = CGRectMake(arrowView.frame.origin.x - 200 - 10, 10, 200, 30);
        _lableLabel.textAlignment = NSTextAlignmentRight;
        [_lableBtn addSubview:_lableLabel];
        
    }
    return _lableBtn;
}

-(UIButton *)locBtn{
    if (!_locBtn) {
        _locBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locBtn setBackgroundColor:[UIColor whiteColor]];
        [_locBtn setTitle:Localized(@"WaHu_JXUserInfo_WaHuVC_Loation") forState:UIControlStateNormal];
        [_locBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_locBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateSelected];
        _locBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_locBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
        _locBtn.titleLabel.font = sysFontWithSize(16);
        _locBtn.custom_acceptEventInterval = 1.0f;
        [_locBtn addTarget:self action:@selector(locBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(20, 0, JX_SCREEN_WIDTH-15*2-10, 0.8);
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [_locBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newicon_currentLocation_gray"]];
        locImg.frame = CGRectMake(20, 15, 20, 20);
        [_locBtn addSubview:locImg];
        
//        _locLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:@"所在位置" font:sysFontWithSize(15) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
//        _locLabel.frame = CGRectMake(CGRectGetMaxX(locImg.frame)+10, 8, JX_SCREEN_WIDTH-CGRectGetMaxX(locImg.frame)-10-50, 30);
//        [_locBtn addSubview:_locLabel];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-10-3, 19, 7, 12)];
        arrowView.image = [UIImage imageNamed:@"WH_Back"];
        [_locBtn addSubview:arrowView];

    }
    return _locBtn;
}

-(UIButton *)canSeeBtn{
    if (!_canSeeBtn) {
        _canSeeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_canSeeBtn setBackgroundColor:[UIColor whiteColor]];
        [_canSeeBtn setTitle:Localized(@"JXBlog_whocansee") forState:UIControlStateNormal];
//        [_canSeeBtn setTitle:Localized(@"JXBlog_whocansee") forState:UIControlStateSelected];
        [_canSeeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_canSeeBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        _canSeeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_canSeeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
        _canSeeBtn.titleLabel.font = sysFontWithSize(16);
        _canSeeBtn.custom_acceptEventInterval = 1.0f;
        [_canSeeBtn addTarget:self action:@selector(whoCanSeeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(20, 0, JX_SCREEN_WIDTH-15*2-10, 0.8);
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [_canSeeBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newicon_seeVisibel_gray"]];
        locImg.frame = CGRectMake(20, 15, 20, 20);
        [_canSeeBtn addSubview:locImg];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-20-3, 19, 7, 12)];
        arrowView.image = [UIImage imageNamed:@"WH_Back"];
        [_canSeeBtn addSubview:arrowView];
        
        _visibleLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:_visibelArray[_visible-1] font:sysFontWithSize(16) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _visibleLabel.frame = CGRectMake(CGRectGetMaxX(_canSeeBtn.titleLabel.frame)+_canSeeBtn.titleEdgeInsets.left+10, 10, CGRectGetMinX(arrowView.frame)-CGRectGetMaxX(_canSeeBtn.titleLabel.frame)-_canSeeBtn.titleEdgeInsets.left-10-10, 30);
        _visibleLabel.textAlignment = NSTextAlignmentRight;
        [_canSeeBtn addSubview:_visibleLabel];
        
    }
    return _canSeeBtn;
}

-(UIButton *)remindWhoBtn{
    if (!_remindWhoBtn) {
        _remindWhoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_remindWhoBtn setBackgroundColor:[UIColor whiteColor]];
        [_remindWhoBtn setTitle:Localized(@"JXBlog_remindWho") forState:UIControlStateNormal];
        [_remindWhoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_remindWhoBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [_remindWhoBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _remindWhoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_remindWhoBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
        _remindWhoBtn.titleLabel.font = sysFontWithSize(16);
        _remindWhoBtn.custom_acceptEventInterval = 1.0f;
        [_remindWhoBtn addTarget:self action:@selector(remindWhoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(20, 0, JX_SCREEN_WIDTH-15*2-10, 0.8);
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [_remindWhoBtn addSubview:line];
        
        UIImageView * locImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newicon_blogRemind_gray"]];
        locImg.frame = CGRectMake(20, 15, 20, 20);
        [_remindWhoBtn addSubview:locImg];
        
        UIImageView * arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-10-3, 19, 7, 12)];
        arrowView.image = [UIImage imageNamed:@"WH_Back"];
        [_remindWhoBtn addSubview:arrowView];

        _remindLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:@"" font:sysFontWithSize(16) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        _remindLabel.frame = CGRectMake(CGRectGetMaxX(_remindWhoBtn.titleLabel.frame)+_remindWhoBtn.titleEdgeInsets.left+30, 10, CGRectGetMinX(arrowView.frame)-CGRectGetMaxX(_remindWhoBtn.titleLabel.frame)-_remindWhoBtn.titleEdgeInsets.left-10-30, 30);
        _remindLabel.textAlignment = NSTextAlignmentRight;
        [_remindWhoBtn addSubview:_remindLabel];
        
        
    }
    return _remindWhoBtn;
}

- (UIButton *)replybanBtn {
    if (!_replybanBtn) {
        _replybanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkbox = [[QCheckBox alloc] initWithDelegate:self];
        _checkbox.frame = CGRectMake(20, 15, 20, 20);
        [_replybanBtn addSubview:_checkbox];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(20, 0, JX_SCREEN_WIDTH-15*2-10, 0.8);
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [_replybanBtn addSubview:line];
        
        UILabel *tint = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_checkbox.frame)+20, 15, 100, 20)];
        tint.text = Localized(@"JX_DoNotCommentOnThem");
        tint.font = sysFontWithSize(16);
        [_replybanBtn addSubview:tint];
        
        UILabel *tintGray = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tint.frame)+5, 15, 220, 20)];
        tintGray.text = Localized(@"JX_ EveryoneCanNotComment");
        tintGray.textColor = [UIColor lightGrayColor];
        tintGray.font = sysFontWithSize(14);
        [_replybanBtn addSubview:tintGray];
        
        [_replybanBtn addTarget:self action:@selector(clickReplyBanBtn:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _replybanBtn;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

-(void)wh_doRefresh{
    _refreshCount++;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.wh_urlShare.length > 0) {
        _remark.text = self.wh_urlShare;
    }

}

-(void)buildTextView{
    _buildHeight = 0;
    _remark = [[UITextView alloc] initWithFrame:CGRectMake(30, 1, JX_SCREEN_WIDTH -30-30,78)];
//    _remark.target = self;
//    _remark.didTouch = @selector(actionSave);
    //_remark.placeHolder = @"这一刻的想法..";
    _remark.backgroundColor = [UIColor clearColor];
//    _remark.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
//    _remark.layer.borderWidth = 0.65f;
//    _remark.layer.cornerRadius = 6.0f;
    _remark.returnKeyType = UIReturnKeyDone;
    _remark.font = sysFontWithSize(16);
    _remark.text = Localized(@"addMsgVC_Mind");
    _remark.textColor = [UIColor grayColor];
    _remark.delegate = self;
    
    [self.wh_tableBody addSubview:_remark];
    _buildHeight += 80;
}

-(void)buildImageViews{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"addMsgVC_AddPhoto");
//    lb.font = g_UIFactory.font16;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.wh_tableBody addSubview:lb];
    
    svImages = [[UIScrollView alloc] initWithFrame:CGRectMake(30, _buildHeight+25, JX_SCREEN_WIDTH-60,120)];
    svImages.pagingEnabled = YES;
    svImages.delegate = self;
    svImages.showsVerticalScrollIndicator = NO;
    svImages.showsHorizontalScrollIndicator = NO;
    svImages.backgroundColor = [UIColor clearColor];
    svImages.userInteractionEnabled = YES;
    [self.wh_tableBody addSubview:svImages];
    
    _buildHeight += 165;
}

-(void)buildAudios{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"addMsgVC_AddVoice");
//    lb.font = g_UIFactory.font14;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.wh_tableBody addSubview:lb];
    
    svAudios = [[UIScrollView alloc] initWithFrame:CGRectMake(30, _buildHeight+25, JX_SCREEN_WIDTH-60,120)];
    svAudios.pagingEnabled = YES;
    svAudios.delegate = self;
    svAudios.showsVerticalScrollIndicator = NO;
    svAudios.showsHorizontalScrollIndicator = NO;
    svAudios.backgroundColor = [UIColor clearColor];
    svAudios.userInteractionEnabled = YES;
    [self.wh_tableBody addSubview:svAudios];
    
   _buildHeight += 165;
}

-(void)buildVideos{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"addMsgVC_AddVideo");
//    lb.font = g_UIFactory.font14;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.wh_tableBody addSubview:lb];
    
    svVideos = [[UIScrollView alloc] initWithFrame:CGRectMake(30, _buildHeight+25, JX_SCREEN_WIDTH-60 ,120)];
    svVideos.pagingEnabled = YES;
    svVideos.delegate = self;
    svVideos.showsVerticalScrollIndicator = NO;
    svVideos.showsHorizontalScrollIndicator = NO;
    svVideos.backgroundColor = [UIColor clearColor];
    svVideos.userInteractionEnabled = YES;
    [self.wh_tableBody addSubview:svVideos];
    
    _buildHeight += 165;
}

-(void)buildFiles{
//    UILabel* lb = [[UILabel alloc]initWithFrame:CGRectMake(0, _buildHeight, JX_SCREEN_WIDTH, 25)];
//    lb.text = Localized(@"JX_AddMsgVC_AddFile");
//    lb.font = g_UIFactory.font14;
//    lb.backgroundColor = [UIColor clearColor];
//    [self.wh_tableBody addSubview:lb];
    
    svFiles = [[UIScrollView alloc] initWithFrame:CGRectMake(30, _buildHeight+25, JX_SCREEN_WIDTH-60 ,120)];
    svFiles.pagingEnabled = YES;
    svFiles.delegate = self;
    svFiles.showsVerticalScrollIndicator = NO;
    svFiles.showsHorizontalScrollIndicator = NO;
    svFiles.backgroundColor = [UIColor clearColor];
    svFiles.userInteractionEnabled = YES;
    [self.wh_tableBody addSubview:svFiles];
    
    _buildHeight += 165;
}

- (void)buildShare{
    
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(10, _buildHeight + 25, JX_SCREEN_WIDTH - 20, 70)];
    view.backgroundColor = HEXCOLOR(0xf0f0f0);
    [view addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableBody addSubview:view];
    
    WH_JXImageView *imageView = [[WH_JXImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
//    imageView.image = [UIImage imageNamed:@"appLogo"];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.wh_shareIcon] placeholderImage:[UIImage imageNamed:@"appLogo"]];
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, imageView.frame.origin.y, view.frame.size.width - CGRectGetMaxX(imageView.frame) - 15, imageView.frame.size.height)];
    label.numberOfLines = 0;
//    label.text = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈";
    label.text = self.wh_shareTitle;
    label.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:label];
    
    _buildHeight += 105;
}

- (void)shareAction:(UIButton *)btn {
    
    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
    webVC.wh_isGotoBack= YES;
    webVC.isSend = YES;
    webVC.title = self.wh_shareTitle;
    webVC.url = self.wh_shareUr;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}

-(void)wh_showImages{
    int i;
    [g_factory removeAllChild:svImages];
    
    NSInteger n = [_images count];
    CGFloat width = (svImages.width - 20)/3;
    svImages.contentSize = CGSizeMake(svImages.width, (n / 3 + 1) * (width + 5));
    svImages.frame = CGRectMake(svImages.frame.origin.x, svImages.frame.origin.y, svImages.width, svImages.contentSize.height);
    for(i=0;i<n&&i<9;i++){
        WH_JXImageView* iv = [[WH_JXImageView alloc]initWithFrame:CGRectMake((i % 3) * (width +5), (i / 3) * (width + 5), width,width)];
        iv.wh_delegate = self;
        iv.userInteractionEnabled = YES;
//        iv.layer.cornerRadius = 6;
//        iv.layer.masksToBounds = YES;
        iv.didTouch = @selector(actionImage:);
        iv.wh_animationType = WH_JXImageView_Animation_Line;
        iv.tag = i;
        iv.image = [_images objectAtIndex:i];
        [svImages addSubview:iv];
//        [iv release];
    }
    
//    UIButton* btn = [self WH_createMiXinButton:[NSString stringWithFormat:@"%@%@",Localized(@"JX_Add"),Localized(@"JX_Image")] icon:@"add_picture" action:@selector(actionImage:) parent:svImages];
//    [btn setBackgroundColor:HEXCOLOR(0xF2F2F2)];
//    btn.frame = CGRectMake(i*105+5, 5, 100, 100);
//    btn.tag = insert_photo_tag;
    if (n == 9) {
        svImages.contentSize = CGSizeMake(svImages.width, 3 * (width + 5));
        svImages.frame = CGRectMake(svImages.frame.origin.x, svImages.frame.origin.y, svImages.width, 3 * (width + 5));
        if (self.dataType == 2) {
            [self updateUI];
            return;
        }
    }
    if (self.dataType == 2) {
    [self updateUI];
    }
    //添加图片
    UIButton *addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addImageBtn setBackgroundImage:[UIImage imageNamed:@"newicon_publishImage"] forState:UIControlStateNormal];
    [svImages addSubview:addImageBtn];
    addImageBtn.frame = CGRectMake((i % 3) * (width +5), (i / 3) * (width + 5), width, width);
    addImageBtn.tag = insert_photo_tag;
    [addImageBtn addTarget:self action:@selector(actionImage:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showAudios{
//    int i;
    [g_factory removeAllChild:svAudios];
    
    if(wh_audioFile){
        WH_JXImageView* iv = [[WH_JXImageView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
        iv.userInteractionEnabled = YES;
//        iv.layer.cornerRadius = 6;
//        iv.layer.masksToBounds = YES;
        iv.wh_delegate = self;
//        iv.didTouch = @selector(onDelAudio);
        iv.didTouch = @selector(donone);
        iv.wh_animationType = WH_JXImageView_Animation_Line;
        iv.tag = audio_tag;
        [svAudios addSubview:iv];
//        [iv release];
        
        if([_images count]>0)
            iv.image = [_images objectAtIndex:0];
        else
            [g_server WH_getHeadImageSmallWIthUserId:g_myself.userId userName:g_myself.userNickname imageView:iv];

        audioPlayer = [[WH_AudioPlayerTool alloc] initWithParent:iv];
        audioPlayer.wh_isOpenProximityMonitoring = NO;
        audioPlayer.wh_audioFile = wh_audioFile;
        
    }else{
//        UIButton* btn = [self WH_createMiXinButton:[NSString stringWithFormat:@"%@%@",Localized(@"JX_Add"),Localized(@"addMsgVC_AVoice")] icon:@"add_voice" action:@selector(onAddAudio) parent:svAudios];
//        btn.frame = CGRectMake(10, 10, 60, 60);
        
        UIButton *AddAudioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [AddAudioBtn setBackgroundImage:[UIImage imageNamed:@"newicon_add_voice"] forState:UIControlStateNormal];
        [svAudios addSubview:AddAudioBtn];
        AddAudioBtn.frame = CGRectMake(10, 10, 100, 100);
        [AddAudioBtn addTarget:self action:@selector(onAddAudio) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)showVideos{
//    int i;
    [g_factory removeAllChild:svVideos];
    
    if(wh_videoFile){
        WH_JXImageView* iv = [[WH_JXImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
        iv.userInteractionEnabled = YES;
        iv.layer.cornerRadius = 6;
        iv.layer.masksToBounds = YES;
        iv.wh_delegate = self;
//        iv.didTouch = @selector(onDelVideo);
        iv.didTouch = @selector(donone);
        iv.wh_animationType = WH_JXImageView_Animation_Line;
        iv.tag = video_tag;
        if([_images count]>0)
            iv.image = [_images objectAtIndex:0];
        else
            [g_server WH_getHeadImageSmallWIthUserId:g_myself.userId userName:g_myself.userNickname imageView:iv];
        [svVideos addSubview:iv];
//        [iv release];
        UIButton *pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        pauseBtn.center = CGPointMake(iv.frame.size.width/2,iv.frame.size.height/2);
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
        [pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
        [iv addSubview:pauseBtn];

//        videoPlayer = [[WH_JXVideoPlayer alloc] initWithParent:iv];
//        videoPlayer.videoFile = videoFile;
        
    }else{
//        UIButton* btn = [self WH_createMiXinButton:[NSString stringWithFormat:@"%@%@",Localized(@"JX_Add"),Localized(@"JX_Video1")] icon:@"add_video" action:@selector(onAddVideo) parent:svVideos];
//        btn.frame = CGRectMake(10, 10, 60, 60);
        
        UIButton *VideosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [VideosBtn setBackgroundImage:[UIImage imageNamed:@"newicon_add_video"] forState:UIControlStateNormal];
        [svVideos addSubview:VideosBtn];
        VideosBtn.frame = CGRectMake(10, 10, 100, 100);
        [VideosBtn addTarget:self action:@selector(onAddVideo) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)showTheVideo {
//    UIView *playerView = [[UIView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:playerView];
    videoPlayer= [WH_JXVideoPlayer alloc];
    videoPlayer.videoFile = wh_videoFile;
    videoPlayer.WH_didVideoPlayEnd = @selector(WH_didVideoPlayEnd);
    videoPlayer.isStartFullScreenPlay = YES; //全屏播放
    videoPlayer.delegate = self;
    videoPlayer = [videoPlayer initWithParent:self.view];
    [videoPlayer wh_switch];
}

-(void)showFiles{
    //    int i;
    [g_factory removeAllChild:svFiles];
    
    if(wh_fileFile){
        WH_JXImageView* iv = [[WH_JXImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
        iv.userInteractionEnabled = YES;
//        iv.layer.cornerRadius = 6;
//        iv.layer.masksToBounds = YES;
        iv.wh_delegate = self;
        iv.didTouch = @selector(actionFile:);
        iv.wh_animationType = WH_JXImageView_Animation_Line;
        iv.tag = file_tag;
        
        NSString * fileExt = [wh_fileFile pathExtension];
        NSInteger fileType = [self fileTypeWithExt:fileExt];
        
        [iv setFileType:fileType];
//        if([_images count]>0)
//            iv.image = [_images objectAtIndex:0];
//        else
//            [g_server WH_getHeadImageSmallWIthUserId:g_myself.userId imageView:iv];
        [svFiles addSubview:iv];
        
    }else{
//        UIButton* btn = [self WH_createMiXinButton:[NSString stringWithFormat:@"%@%@",Localized(@"JX_Add"),Localized(@"JX_File")] icon:@"add_file" action:@selector(onAddFile) parent:svFiles];
//        btn.frame = CGRectMake(10, 10, 60, 60);
        
        UIButton *addFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addFileBtn setBackgroundImage:[UIImage imageNamed:@"newicon_add_file"] forState:UIControlStateNormal];
        [svFiles addSubview:addFileBtn];
        addFileBtn.frame = CGRectMake(10, 10, 100, 100);
        [addFileBtn addTarget:self action:@selector(onAddFile) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)actionFile:(WH_JXImageView *)imageView {
//    WH_JXFileDetail_WHViewController * detailVC = [[WH_JXFileDetail_WHViewController alloc] init];
//    NSDictionary *dict = @{
//                           @"url":fileFile,
//                           @"name":[fileFile pathExtension]
//                           };
//    WH_JXShareFileObject *fileObj = [WH_JXShareFileObject shareFileWithDict:dict];
//    detailVC.shareFile = fileObj;
//    [g_navigation pushViewController:detailVC animated:YES];
    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
    webVC.wh_isGotoBack= YES;
    webVC.isSend = YES;
    webVC.title = [wh_fileFile pathExtension];
    webVC.url = wh_fileFile;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}

-(int)fileTypeWithExt:(NSString *)fileExt{
    int fileType = 0;
    if ([fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"] || [fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"gif"] || [fileExt isEqualToString:@"bmp"])
        fileType = 1;
    else if ([fileExt isEqualToString:@"amr"] || [fileExt isEqualToString:@"mp3"] || [fileExt isEqualToString:@"wav"])
        fileType = 2;
    else if ([fileExt isEqualToString:@"mp4"] || [fileExt isEqualToString:@"mov"])
        fileType = 3;
    else if ([fileExt isEqualToString:@"ppt"] || [fileExt isEqualToString:@"pptx"])
        fileType = 4;
    else if ([fileExt isEqualToString:@"xls"] || [fileExt isEqualToString:@"xlsx"])
        fileType = 5;
    else if ([fileExt isEqualToString:@"doc"] || [fileExt isEqualToString:@"docx"])
        fileType = 6;
    else if ([fileExt isEqualToString:@"zip"] || [fileExt isEqualToString:@"rar"])
        fileType = 7;
    else if ([fileExt isEqualToString:@"txt"])
        fileType = 8;
    else if ([fileExt isEqualToString:@"pdf"])
        fileType = 10;
    else
        fileType = 9;
    return fileType;
}

- (void)viewDidload{
    [super viewDidLoad];
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:Localized(@"addMsgVC_Mind")]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}



- (void)textViewDidEndEditing:(UITextView *)textView{
//    [textView resignFirstResponder];
    
    return;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] ) {
        [self.view endEditing:YES];
    }
    return YES;
}

-(void)actionImage:(WH_JXImageView*)sender{
    _photoIndex = sender.tag;
    
    if(_photoIndex==insert_photo_tag&&[_images count]>8){
        [g_App showAlert:Localized(@"addMsgVC_SelNinePhoto")];
        return;
    }else if(_photoIndex==insert_photo_tag){
        
        WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
        actionVC.delegate = self;
        actionVC.wh_tag = 111;
        [self presentViewController:actionVC animated:NO completion:nil];
        
        return;
    }
    LXActionSheet* _menu = [[LXActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:Localized(@"JX_Cencal")
                            destructiveButtonTitle:Localized(@"JX_Update")
                            otherButtonTitles:@[Localized(@"JX_Delete")]];
    [g_window addSubview:_menu];
//    [_menu release];
}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {

    if (index == 0) {
        
        self.wh_maxImageCount = self.wh_maxImageCount - (int)[_images count];
        [self pickImages:YES];
        
    }else {
        WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
        vc.cameraDelegate = self;
        vc.isPhoto = YES;
        vc = [vc init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}

#pragma mark - 拍摄视频
- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    [_images addObject:image];
    [self wh_showImages];
    
    if ([g_config.isOpenOSStatus integerValue]) {
        // 普通图片
        NSString *name = @"jpg";
        
        NSString *file = [FileInfo getUUIDFileName:name];
        //图片存储到本地
        [g_server WH_saveImageToFileWithImage:image file:file isOriginal:YES];
        
        [_imageStrings addObject:file];
    }
}


- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
    if(buttonIndex<0)
        return;
    _nSelMenu = buttonIndex;
    [self doOutputMenu];
}


-(void)doOutputMenu{
    if(_nSelMenu==0){
        if(_photoIndex == audio_tag){
            [self onAddAudio];
            return;
        }
        if(_photoIndex == video_tag){
            [self onAddVideo];
            return;
        }
        [self pickImages:NO];
    }
    if(_nSelMenu==1){
        if(_photoIndex == audio_tag){
            [self onDelAudio];
            return;
        }
        if(_photoIndex == video_tag){
            [self onDelVideo];
            return;
        }
        [_images removeObjectAtIndex:_photoIndex];
        [self wh_showImages];
    }
}

-(void)pickImages:(BOOL)Multi{
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 9 - _images.count;//最大的选择数目
    photoController.configuration.containVideo = NO;//选择类型，目前只选择图片不选择视频
    
    photoController.photo_delegate = self;
    photoController.thumbnailSize = CGSizeMake(320, 320);//缩略图的尺寸
    //    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoController animated:true completion:^{}];

//    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//    __weak id weakSelf = self;
//    imagePickerController.delegate = weakSelf;
//    imagePickerController.allowsMultipleSelection = YES;
//    imagePickerController.limitsMaximumNumberOfSelection = YES;
////    imagePickerController.limitsMinimumNumberOfSelection = YES;
//    imagePickerController.maximumNumberOfSelection = self.maxImageCount;
////    imagePickerController.minimumNumberOfSelection = 1;
//
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
//    [self presentViewController:navigationController animated:YES completion:NULL];
//    [imagePickerController release];
//    [navigationController release];
}

#pragma mark - 发送原图
- (void)photosViewController:(UIViewController *)viewController images:(NSArray<UIImage *> *)images infos:(NSArray<NSDictionary *> *)infos {
    [_images addObjectsFromArray:images.mutableCopy];
    [self wh_showImages];
}
#pragma mark - 发送缩略图
- (void)photosViewController:(UIViewController *)viewController thumbnailImages:(NSArray *)thumbnailImages infos:(NSArray<NSDictionary *> *)infos {
    [_images addObjectsFromArray:thumbnailImages.mutableCopy];
    [self wh_showImages];
}

#pragma mark - 发送图片
- (void)photosViewController:(UIViewController *)viewController datas:(NSArray <id> *)datas; {
    
    if ([g_config.isOpenOSStatus integerValue]) {
        for (int i = 0; i < datas.count; i++) {
            
            // 普通图片
            UIImage *chosedImage = datas[i];
            NSString *name = @"jpg";
            
            NSString *file = [FileInfo getUUIDFileName:name];
            //图片存储到本地
            [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:YES];
            
            [_imageStrings addObject:file];
            
        }
    }
    
    
}


- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if(imagePickerController.allowsMultipleSelection) {
        NSArray *mediaInfoArray = (NSArray *)info;
//        NSLog(@"Selected %d photos", mediaInfoArray.count);
        
        for(int i=0;i<[mediaInfoArray count];i++){
            NSDictionary *selected = (NSDictionary *)[mediaInfoArray objectAtIndex:i];
            [_images addObject:[selected objectForKey:@"UIImagePickerControllerOriginalImage"]];
        }
    } else {
        NSDictionary *selected = (NSDictionary *)info;
        [_images replaceObjectAtIndex:_photoIndex withObject:[selected objectForKey:@"UIImagePickerControllerOriginalImage"]];
//        NSLog(@"Selected: %@", selected);
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self wh_showImages];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos{
    
    return [NSString stringWithFormat:@"%ld photos",numberOfPhotos];
}
//- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController
//{
//    return @"全部选择";
//}
//
//- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController
//{
//    return @"取消全部";
//}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //    [g_App hideMessage:g_App.lastMsgView];
    
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_UploadFile]){
        NSDictionary *dataD;
        if (_timeLen > 0) {  // 和安卓统一，所以自己传length，暂时只有语音处理
            NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
            [dataDict setObject:@(_timeLen) forKey:@"length"];
            [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oFileName"] forKey:@"oFileName"];
            [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"status"] forKey:@"status"];
            [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oUrl"] forKey:@"oUrl"];
            NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            NSMutableArray *mutArr = [NSMutableArray arrayWithObjects:dataDict, nil];
            [mutDict setObject:mutArr forKey:@"audios"];
            dataD = mutDict;
        }else {
            dataD= dict;
        }
        
        NSString *label = nil;
        if (self.wh_isShortVideo) {
            label = [NSString stringWithFormat:@"%ld",self.currentLableIndex + 1];
        }
        
        [g_server WH_addMessage:_remark.text type:dataType data:dataD flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:label isAllowComment:self.checkbox.checked toView:self];
    }
    if([aDownload.action isEqualToString:wh_act_MsgAdd]){
        if (self.block) {
            self.block();
        }
        [g_App showAlert:Localized(@"JXAlert_SendOK")];
        
        [self hideKeyboard];
        if (self.wh_urlShare.length > 0) {
            [self.view removeFromSuperview];
        }else {
            
            if (dataType == weibo_dataType_video) {
                
//                UIViewController *target = nil;
//
//                GKDYHomeViewController *homeVC = [[GKDYHomeViewController alloc] init];
//                for (UIViewController * controller in self.navigationController.viewControllers) { //遍历
//                    if ([controller isKindOfClass:[homeVC class]]) { //这里判断是否为你想要跳转的页面
//                        target = controller;
//                    }
//                }
//
//                if (target) {
//                    [g_navigation popToViewController:target animated:YES]; //跳转
//                }
//                GKDYHomeViewController *homeVC = [[GKDYHomeViewController alloc] init];
                
                [g_notify postNotificationName:@"WaHu_PostVideo_Success" object:nil];
                
//                [g_navigation popToViewController:[WH_GKDYHome_WHViewController class] animated:YES];
                [self actionQuit];
                
            }else{
                [self actionQuit];
            }
            /*
             JXSmallVideoViewController *vc = [[JXSmallVideoViewController alloc] init];
             [g_navigation pushViewController:vc animated:YES];
             */
        }
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start:Localized(@"JX_SendNow")];
}

- (void)lableBtnAction:(UIButton *)button {
    WH_JXSelector_WHVC *vc = [[WH_JXSelector_WHVC alloc] init];
    vc.title = Localized(@"JX_SelectionLabel");
    vc.WH_array = @[Localized(@"JX_Food"),Localized(@"JX_Attractions"),Localized(@"JX_Culture"),Localized(@"JX_HaveFun"),Localized(@"JX_Hotel"),Localized(@"JX_Shopping"),Localized(@"JX_Movement"),Localized(@"OTHER"),];
    //    vc.array = @[@"简体中文", @"繁體中文(香港)", @"English",@"Bahasa Melayu",@"ภาษาไทย"];
    vc.WH_selectIndex = _currentLableIndex;
    vc.wh_selectorDelegate = self;
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selector:(WH_JXSelector_WHVC *)selector selectorAction:(NSInteger)selectIndex {
    
    self.currentLableIndex = selectIndex;
    self.lableLabel.text = selector.WH_array[selectIndex];

}

-(void)locBtnAction:(UIButton *)button{
    _locationVC = [JXLocationVC alloc];
    _locationVC.isSend = YES;
    _locationVC.locationType = JXLocationTypeCurrentLocation;
    _locationVC.delegate  = self;
    _locationVC.didSelect = @selector(onSelLocation:);
    _locationVC = [_locationVC init];
//    [g_window addSubview:_locationVC.view];
    [g_navigation pushViewController:_locationVC animated:YES];
}
-(void)whoCanSeeBtnAction:(UIButton *)button{
    WhoCanSeeViewController * whoVC = [[WhoCanSeeViewController alloc] init];
    whoVC.title = Localized(@"JXBlog_whocansee");
    whoVC.wh_visibelDelegate = self;
    whoVC.type = _visible;
    whoVC.wh_selLabelsArray = self.selLabelsArray.count > 0 ? self.selLabelsArray : [NSMutableArray array];
    whoVC.wh_mailListUserArray = self.mailListUserArray.count > 0 ? self.mailListUserArray : [NSMutableArray array];
//    [g_window addSubview:whoVC.view];
    [g_navigation pushViewController:whoVC animated:YES];
}
-(void)remindWhoBtnAction:(UIButton *)button{
    WH_JXSelectFriends_WHVC * selVC = [[WH_JXSelectFriends_WHVC alloc] init];
    selVC.delegate = self;
    selVC.didSelect = @selector(selRemindDelegate:);
    if (_visible == MsgVisible_see) {
        selVC.type = JXSelUserTypeCustomArray;
        selVC.array = [_userArray mutableCopy];
    }else if (_visible == MsgVisible_nonSee) {
        selVC.type = JXSelUserTypeDisAble;
        NSMutableSet * set = [NSMutableSet set];
        [set addObjectsFromArray:_userIdArray];
        selVC.disableSet = set;
    }
    
    
//    [g_window addSubview:selVC.view];
    [g_navigation pushViewController:selVC animated:YES];
}

- (void)clickReplyBanBtn:(UIButton *)button  {
    _checkbox.checked = !_checkbox.checked;
}

-(void)selRemindDelegate:(WH_JXSelectFriends_WHVC*)vc{
    NSArray * indexArr = [vc.set allObjects];
    NSMutableArray * adduserArr = [NSMutableArray array];
    NSMutableArray * userNameArr = [NSMutableArray array];
    for (NSNumber * index in indexArr) {
        WH_JXUserObject * selUser;
        if (vc.seekTextField.text.length > 0) {
            selUser = vc.searchArray[[index intValue] % 1000];
        }else{
            selUser = [[vc.letterResultArr objectAtIndex:[index intValue] / 1000] objectAtIndex:[index intValue] % 1000];
        }
        [adduserArr addObject:selUser.userId];
        [userNameArr addObject:selUser.userNickname];
    }
    _remindArray = [NSArray arrayWithArray:adduserArr];
    _remindNameArray = [NSArray arrayWithArray:userNameArr];
    if (_remindNameArray.count > 0) {
        _remindLabel.text = [_remindNameArray componentsJoinedByString:@","];
    }
}

-(void)seeVisibel:(int)visibel userArray:(NSArray *)userArray selLabelsArray:(NSMutableArray *)selLabelsArray mailListArray:(NSMutableArray *)mailListArray{
    _visible = visibel+1;
    _selLabelsArray = selLabelsArray;
    _mailListUserArray = mailListArray;
    _visibleLabel.text = _visibelArray[visibel];
    
    if (_visible == 3 || _visible == 4) {
        NSMutableArray * uArray = [NSMutableArray array];
        NSMutableArray * userIdArray = [NSMutableArray array];
        for (WH_JXUserObject * selUser in userArray) {
            [uArray addObject:selUser];
            [userIdArray addObject:selUser.userId];
        }
        _userIdArray = userIdArray;
        _userArray = uArray;
    }
    
    switch (_visible) {
        case 1:
        case 3:
        case 4:
            _remindWhoBtn.enabled = YES;
            _remindArray = [NSArray array];
            _remindLabel.text = @"";
            break;
        case 2:
            _remindWhoBtn.enabled = NO;
            _remindArray = nil;
            _remindLabel.text = @"";
            break;
        
        default:
            break;
    }
    
//    if (visibel == 3 || visibel ==4) {
//        NSMutableArray * nameArray = [NSMutableArray array];
//        for (WH_JXUserObject * selUser in userArray) {
//            [nameArray addObject:selUser.userNickname];
//        }
//        if (nameArray.count > 0) {
//            NSString * nameStr = [nameArray componentsJoinedByString:@","];
//            _visibleLabel.text = nameStr;
//        }
//    }
    
    
//    NSMutableArray * nameArray = [NSMutableArray array];
//    for (WH_JXUserObject * selUser in userArray) {
//        [nameArray addObject:selUser.userNickname];
//    }
    
}


#pragma mark - 点击发布调用的方法
-(void)actionSave{

    [audioPlayer wh_stop];
    audioPlayer = nil;
    [videoPlayer stop];
    videoPlayer = nil;
    
    [self hideKeyboard];
 
    if(self.dataType == weibo_dataType_image) {
        if (_images.count <=0 && _remark.text.length <= 0) {
            [g_App showAlert:Localized(@"JXAlert_InputSomething")];
            return;
        }
        else if(_images.count <= 0 && _remark.text.length > 0) {
                if ([_remark.text isEqualToString:Localized(@"addMsgVC_Mind")]) {
                    [g_App showAlert:Localized(@"JXAlert_InputSomething")];
                    return;
                }
            [g_server WH_addMessage:_remark.text type:1 data:nil flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:nil isAllowComment:self.checkbox.checked toView:self];
            
        }else if(_images.count > 0){
            if ([_remark.text isEqualToString:Localized(@"addMsgVC_Mind")]){
                _remark.text = @"";
            }
            if ([g_config.isOpenOSStatus intValue]) {
//                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [_wait start];
                [OBSHanderTool handleUploadFile:_imageStrings audio:wh_audioFile video:wh_videoFile file:wh_fileFile type:self.dataType+1 validTime:@"-1" timeLen:_timeLen toView:self success:^(int code, NSDictionary * _Nonnull dict) {
//                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [_wait stop];
                    if (code == 1) {

                        NSDictionary *dataD;
                        if (_timeLen > 0) {  // 和安卓统一，所以自己传length，暂时只有语音处理
                            NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
                            [dataDict setObject:@(_timeLen) forKey:@"length"];
                            [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oFileName"] forKey:@"oFileName"];
                            [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"status"] forKey:@"status"];
                            [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oUrl"] forKey:@"oUrl"];
                            NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                            NSMutableArray *mutArr = [NSMutableArray arrayWithObjects:dataDict, nil];
                            [mutDict setObject:mutArr forKey:@"audios"];
                            dataD = mutDict;
                        }else {
                            dataD= dict;
                        }

                        NSString *label = nil;
                        if (self.wh_isShortVideo) {
                            label = [NSString stringWithFormat:@"%d",self.currentLableIndex + 1];
                        }

                        [g_server WH_addMessage:_remark.text type:dataType data:dataD flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:label isAllowComment:self.checkbox.checked toView:self];
                    }
                } failed:^(NSError * _Nonnull error) {
                    [_wait stop];
                }];
            }else{
                [g_server uploadFile:_images audio:wh_audioFile video:wh_videoFile file:wh_fileFile type:self.dataType+1 validTime:@"-1" timeLen:_timeLen toView:self];
            }
            
            
            
        }
    }
    else if (self.dataType == weibo_dataType_share) {
        NSDictionary *dict = @{
                               @"sdkUrl" : self.wh_shareUr,
                               @"sdkIcon" : self.wh_shareIcon,
                               @"sdkTitle": self.wh_shareTitle
                               };
        [g_server WH_addMessage:_remark.text type:dataType data:dict flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:nil isAllowComment:self.checkbox.checked toView:self];
    }
    else{
        if (_images.count <= 0 && wh_audioFile.length <= 0 && wh_videoFile.length <= 0 && wh_fileFile.length <= 0) {
            [g_App showAlert:Localized(@"JX_AddFile")];
            return;
        }
        if ([_remark.text isEqualToString:Localized(@"addMsgVC_Mind")]){
            _remark.text = @"";
        }
        
        if ([g_config.isOpenOSStatus intValue] && self.dataType != weibo_dataType_file) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [OBSHanderTool handleUploadFile:_imageStrings audio:wh_audioFile video:wh_videoFile file:wh_fileFile type:self.dataType validTime:@"-1" timeLen:_timeLen toView:self success:^(int code, NSDictionary * _Nonnull dict) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (code == 1) {

                    NSDictionary *dataD;
                    if (_timeLen > 0) {  // 和安卓统一，所以自己传length，暂时只有语音处理
                        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
                        [dataDict setObject:@(_timeLen) forKey:@"length"];
                        [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oFileName"] forKey:@"oFileName"];
                        [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"status"] forKey:@"status"];
                        [dataDict setObject:[[[dict objectForKey:@"audios"] firstObject] objectForKey:@"oUrl"] forKey:@"oUrl"];
                        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                        NSMutableArray *mutArr = [NSMutableArray arrayWithObjects:dataDict, nil];
                        [mutDict setObject:mutArr forKey:@"audios"];
                        dataD = mutDict;
                    }else {
                        dataD= dict;
                    }

                    NSString *label = nil;
                    if (self.wh_isShortVideo) {
                        label = [NSString stringWithFormat:@"%ld",self.currentLableIndex + 1];
                    }

                    [g_server WH_addMessage:_remark.text type:dataType data:dataD flag:3 visible:_visible lookArray:_userIdArray coor:_coor location:_locStr remindArray:_remindArray lable:label isAllowComment:self.checkbox.checked toView:self];
                }
            } failed:^(NSError * _Nonnull error) {

            }];
        }else{
            [g_server uploadFile:_images audio:wh_audioFile video:wh_videoFile file:wh_fileFile type:self.dataType validTime:@"-1" timeLen:_timeLen toView:self];
        }
        
        
        
    }

}

- (BOOL) hideKeyboard {
    [_remark resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

-(void)onAddVideo{
    [self hideKeyboard];
    
//    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
//    {
//        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
//        return;
//    }
//    if ([[WH_JXMediaObject sharedInstance] fetch].count <= 0) {
//
//        WH_myMedia_WHVC* vc = [[WH_myMedia_WHVC alloc]init];
//        vc.delegate = self;
//        vc.didSelect = @selector(onSelMedia:);
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//        [vc onAddVideo];
//    }else {
//        WH_myMedia_WHVC* vc = [[WH_myMedia_WHVC alloc]init];
//        vc.delegate = self;
//        vc.didSelect = @selector(onSelMedia:);
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//    }
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 1;//最大的选择数目
    photoController.configuration.containVideo = YES;//选择类型，目前只选择图片不选择视频
    photoController.configuration.containImage = NO;//选择类型，目前只选择视频不选择图片
    photoController.photo_delegate = self;
//    photoController.thumbnailSize = CGSizeMake(220, 220);//缩略图的尺寸
    //    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoController animated:true completion:^{}];

//    WH_recordVideo_WHViewController * videoRecordVC = [WH_recordVideo_WHViewController alloc];
//    videoRecordVC.maxTime = 30;
//    videoRecordVC.isReciprocal = NO;
//    videoRecordVC.delegate = self;
//    videoRecordVC.didRecord = @selector(newVideo:);
//    [videoRecordVC init];
//    [g_window addSubview:videoRecordVC.view];
}

#pragma mark - 发送视频
- (void)photosViewController:(UIViewController *)viewController media:(WH_JXMediaObject *)media {
    [_images removeAllObjects];
    media.userId = g_myself.userId;
    media.isVideo = [NSNumber numberWithBool:YES];
    [media insert];
    
    NSString* file = media.fileName;
    UIImage *image = [FileInfo getFirstImageFromVideo:file];
    wh_videoFile = [file copy];
//    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
//    [_images addObject:[UIImage imageWithContentsOfFile:file]];
    [_images addObject:image];

    if ([g_config.isOpenOSStatus integerValue]) {
        NSString *name = @"jpg";
        NSString *imagefile = [FileInfo getUUIDFileName:name];
        //图片存储到本地
        [g_server WH_saveImageToFileWithImage:image file:imagefile isOriginal:YES];
        [_imageStrings addObject:imagefile];
        
    }
    
    [self showVideos];
    
}

-(void)onSelMedia:(WH_JXMediaObject*)p{
// 
//    p.userId = g_myself.userId;
//    p.isVideo = [NSNumber numberWithBool:YES];
////    [p insert];
//
//    NSString* file = p.fileName;
//    videoFile = [file copy];
//    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
//    [_images addObject:[UIImage imageWithContentsOfFile:file]];
//    [self showVideos];
//    
}

-(void)onAddFile{
    [self hideKeyboard];
    
    WH_JXMyFile* vc = [[WH_JXMyFile alloc]init];
    vc.delegate = self;
    vc.didSelect = @selector(onSelFile:);
    [g_navigation pushViewController:vc animated:YES];
}
-(void)onSelFile:(NSString*)file{
    //发送文件，file仅仅包含文件在本地的地址
    
    wh_fileFile = [file copy];
//    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
//    [_images addObject:[UIImage imageWithContentsOfFile:file]];
    [self showFiles];
}

-(void)onAddAudio{
    [self hideKeyboard];
//    recordAudioVC* vc = [[recordAudioVC alloc]init];
//    vc.delegate = self;
//    vc.didRecord = @selector(newAudio:);
//    [g_window addSubview:vc.view];

//    [self stopAllPlayer];
    //跳转音频录制界面
    WH_JXAudioRecorder_WHViewController * audioRecordVC = [[WH_JXAudioRecorder_WHViewController alloc] init];
    audioRecordVC.delegate = self;
    audioRecordVC.wh_maxTime = 60;
//    [g_window addSubview:audioRecordVC.view];
    [g_navigation pushViewController:audioRecordVC animated:YES];
    

}

//音频录制返回
#pragma mark JXaudioRecorder delegate
-(void)WH_AudioRecorderDidFinish:(NSString *)filePath TimeLen:(int)timenlen{
//    _editingType = @"audio";
//    _voiceTimeLen = timenlen;
    //上传
//    [_wait start:@"正在上传音频"];
//    [g_server uploadFile:filePath toView:self];
    
//    NSString* file = sender.outputFileName;
    
    WH_JXMediaObject* p = [[WH_JXMediaObject alloc]init];
    p.userId = g_myself.userId;
    p.fileName = filePath;
    p.isVideo = [NSNumber numberWithBool:NO];
    p.timeLen = [NSNumber numberWithInt:timenlen];
//    [p insert];
    //    [p release];
    self.timeLen = timenlen;
    wh_audioFile = [filePath copy];
    [self showAudios];
    filePath = nil;
    
}

-(void)newVideo:(WH_recordVideo_WHViewController *)sender;
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:sender.outputFileName] )
        return;
    NSString* file = sender.outputFileName;

    WH_JXMediaObject* p = [[WH_JXMediaObject alloc]init];
    p.userId = g_myself.userId;
    p.fileName = file;
    p.isVideo = [NSNumber numberWithBool:YES];
    p.timeLen = [NSNumber numberWithInt:sender.timeLen];
//    [p insert];
//    [p release];
    
    wh_videoFile = [file copy];
    file = [NSString stringWithFormat:@"%@.jpg",[file stringByDeletingPathExtension]];
    [_images addObject:[UIImage imageWithContentsOfFile:file]];
    [self showVideos];
    file = nil;
}


-(void)onSelLocation:(JXMapData*)location{
    
    _coor = (CLLocationCoordinate2D){[location.latitude doubleValue],[location.longitude doubleValue]};
    
    if (location.title.length > 0) {
        _locStr = [NSString stringWithFormat:@"%@ %@",location.title,location.subtitle];
    }else{
        _locStr = location.subtitle;
    }
//    _locLabel.text = _locStr;
    [self.locBtn setTitle:_locStr forState:UIControlStateSelected];
    self.locBtn.selected = YES;
}

//-(void)newAudio:(recordAudioVC *)sender
//{
//    if( ![[NSFileManager defaultManager] fileExistsAtPath:sender.outputFileName] )
//        return;
//    NSString* file = sender.outputFileName;
//
//    WH_JXMediaObject* p = [[WH_JXMediaObject alloc]init];
//    p.userId = g_myself.userId;
//    p.fileName = file;
//    p.isVideo = [NSNumber numberWithBool:NO];
//    p.timeLen = [NSNumber numberWithInt:sender.timeLen];
//    [p insert];
////    [p release];
//
//    audioFile = [file copy];
//    [self showAudios];
//    file = nil;
//}

-(UIButton*)WH_createMiXinButton:(NSString*)title icon:(NSString*)icon action:(SEL)action parent:(UIView*)parent{
    UIButton* btn = [UIFactory WH_create_WHButtonWithImage:icon
                           highlight:nil
                              target:self
                            selector:action];
    btn.titleEdgeInsets = UIEdgeInsetsMake(45, -60, 0, 0);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:HEXCOLOR(0xA9A9A9) forState:UIControlStateNormal];
    btn.titleLabel.font = sysFontWithSize(12);
    [parent addSubview:btn];
    return btn;
}

-(void)onDelVideo{
    wh_videoFile = nil;
    [self showVideos];
}

-(void)onDelAudio{
    wh_audioFile = nil;
    [self showAudios];
}

-(void)actionQuit{
    [super actionQuit];
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:NO];
}



@end
