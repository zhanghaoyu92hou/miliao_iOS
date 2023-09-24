//
//  WH_WeiboDetailViewController.m
//  Tigase
//
//  Created by 政委 on 2020/6/5.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_WeiboDetailViewController.h"
#import "WH_HBCoreLabel.h"
#import "TimeUtil.h"
#define ICON_WIDTH  10   // 点赞回复等按钮之前的距离

@interface WH_WeiboDetailViewController ()<WH_HBCoreLabelDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *topView;

@end

@implementation WH_WeiboDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
    
}
- (void)configUI {
    
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    self.topView = topView;
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(JX_SCREEN_WIDTH);
        make.height.mas_equalTo(JX_SCREEN_TOP);
    }];
    UIButton *back = [JXXMPP createButtonWithFrame:CGRectMake(10, JX_SCREEN_TOP - 38, 28, 28) image:[UIImage imageNamed:@"title_back"]];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:back];
    
    UILabel *title = [JXXMPP createLabelWith:@"动态详情" frame:CGRectMake(JX_SCREEN_WIDTH/2 - 50, JX_SCREEN_TOP - 35, 100, 25) color:HEXCOLOR(0x333333) font:18];
    title.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:title];
    
    /*
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topView.height, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - self.topView.height)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    self.backView = backView;
    
    
//    title = [[UILabel alloc] initWithFrame:CGRectMake(57, 17, JX_SCREEN_WIDTH - 114, 21)];
//    title.text = Localized(@"WaHu_WeiboCell_Star");
//    title.textColor = HEXCOLOR(0x576b95);
//    [self.backView addSubview:title];
    
    //说说文本
    WH_HBCoreLabel *content = [[WH_HBCoreLabel alloc]initWithFrame:CGRectMake(57, 32, JX_SCREEN_WIDTH - 120 , 21)];
    content.wh_delegate = self;
    content.textColor = HEXCOLOR(0x3A404C);
    [self.backView addSubview:content];
    self.content = content;
    //图片容器
    UIView *wh_imageContent = [[UIView alloc]initWithFrame:CGRectMake(57, 32, JX_SCREEN_WIDTH -70, 21)];
    [self.backView addSubview:wh_imageContent];
    self.wh_imageContent = wh_imageContent;
    //音频
    WH_AudioPlayerTool *wh_audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.wh_imageContent frame:CGRectNull isLeft:YES];
    wh_audioPlayer.wh_isOpenProximityMonitoring = YES;
    self.wh_audioPlayer = wh_audioPlayer;
    
    UIView *fileView = [[UIView alloc] initWithFrame:CGRectMake(57, 40, JX_SCREEN_WIDTH -100, 100)];
    fileView.backgroundColor = HEXCOLOR(0xECEDEF);
    UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileUrlCopy)];
    [fileView addGestureRecognizer:tapges];
    [self.backView addSubview:fileView];
    self.fileView = fileView;
    fileView.hidden = YES;
    
     UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 60, 60)];
        typeView.layer.cornerRadius = 3;
        typeView.layer.masksToBounds = YES;
        //        _typeView.backgroundColor = [UIColor redColor];
        [fileView addSubview:typeView];
    self.typeView = typeView;
    
    UILabel *wh_fileTitleLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:@"--.--" font:sysFontWithSize(15) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
        wh_fileTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        wh_fileTitleLabel.frame = CGRectMake(CGRectGetMaxX(typeView.frame) +5, 0, CGRectGetWidth(fileView.frame)-CGRectGetMaxX(typeView.frame)-5-5, 25);
        wh_fileTitleLabel.center = CGPointMake(wh_fileTitleLabel.center.x, typeView.center.y);
        wh_fileTitleLabel.textAlignment = NSTextAlignmentLeft;
        [fileView addSubview:wh_fileTitleLabel];
        self.wh_fileTitleLabel = wh_fileTitleLabel;

    
    [self createShareView];
    
    UIView *wh_replyContent = [[UIView alloc]initWithFrame:CGRectMake(57,67,JX_SCREEN_WIDTH -70,30)];
    wh_replyContent.backgroundColor = [UIColor clearColor];
    [self.backView addSubview:wh_replyContent];
    self.wh_replyContent = wh_replyContent;
    
    UILabel *locLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:nil font:sysFontWithSize(11) textColor:HEXCOLOR(0x576b95) backgroundColor:[UIColor clearColor]];
    locLabel.frame = CGRectMake(57, CGRectGetMaxY(wh_replyContent.frame)+5, JX_SCREEN_WIDTH -70, 14);
    locLabel.hidden = YES;
    [self.backView addSubview:locLabel];
    self.locLabel = locLabel;
    
    WH_JXImageView *mLogo = [[WH_JXImageView alloc]initWithFrame:CGRectMake(7,17,40,40)];
    mLogo.wh_delegate = self;
    
    mLogo.didTouch = @selector(actionUser:);
    [mLogo headRadiusWithAngle:mLogo.frame.size.width / 2];
    //        mLogo.backgroundColor = [UIColor brownColor];
    [self.backView addSubview:mLogo];
    self.mLogo = mLogo;
    
    //时间
    UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(0,4,130,21)];
    time.textColor = HEXCOLOR(0x88888A);
    time.font = [UIFont systemFontOfSize:12];
    
    //删除
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [delBtn setTitle:Localized(@"JX_Delete") forState:UIControlStateNormal];
    [delBtn setTitle:Localized(@"JX_Delete") forState:UIControlStateHighlighted];
    [delBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateNormal];
    [delBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateHighlighted];
    delBtn.titleLabel.font = sysFontWithSize(12);
//    delBtn.tag = self.tag;
    delBtn.hidden = YES;
    [delBtn addTarget:self action:@selector(delBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.delBtn = delBtn;
    
    
    UITableView *wh_tableReply = [[UITableView alloc]initWithFrame:CGRectMake(10,31,JX_SCREEN_WIDTH -65,0)];
    wh_tableReply.dataSource = self;
    wh_tableReply.delegate   = self;
//    wh_tableReply.tag        = self.tag;
    wh_tableReply.backgroundColor = [UIColor clearColor];
    wh_tableReply.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.wh_tableReply = wh_tableReply;
    
    UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, wh_tableReply.frame.size.width, 23)];
    moreLabel.backgroundColor = [UIColor clearColor];
    moreLabel.textAlignment = NSTextAlignmentCenter;
    moreLabel.font = sysFontWithSize(13);
    moreLabel.text=Localized(@"JX_SeeMoreComments");
    moreLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getMoreData)];
    [moreLabel addGestureRecognizer:tap];
    wh_tableReply.tableFooterView = moreLabel;
    self.moreLabel = moreLabel;
    
    UIButton *wh_moreMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    wh_moreMenu.frame = CGRectMake(JX_SCREEN_WIDTH -100,4,30,18);
    [wh_moreMenu setImage:[UIImage imageNamed:@"newicon_moreMenu"] forState:UIControlStateNormal];
    [wh_moreMenu setImage:[UIImage imageNamed:@"newicon_moreMenu"] forState:UIControlStateHighlighted];
//    _wh_moreMenu.tag = self.tag*1000+5;
    [wh_moreMenu addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
    self.wh_moreMenu = wh_moreMenu;
    
    //举报按钮
    UIButton *wh_btnReport = [UIButton buttonWithType:UIButtonTypeCustom];
    wh_btnReport.frame = CGRectMake(JX_SCREEN_WIDTH -100,1,25,25);
    [wh_btnReport setImage:[UIImage imageNamed:@"weibo_report"] forState:UIControlStateNormal];
    [wh_btnReport setImage:[UIImage imageNamed:@"weibo_reported"] forState:UIControlStateHighlighted];
//    wh_btnReport.tag = self.tag*1000+4;
    [wh_btnReport addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
    self.wh_btnReport = wh_btnReport;
    
    //收藏按钮
    UIButton *wh_btnCollection = [UIButton buttonWithType:UIButtonTypeCustom];
    wh_btnCollection.frame = CGRectMake(CGRectGetMinX(_wh_btnReport.frame)-25-ICON_WIDTH,0,25,25);
    [wh_btnCollection setImage:[UIImage imageNamed:@"weibo_collection"] forState:UIControlStateNormal];
    [wh_btnCollection setImage:[UIImage imageNamed:@"weibo_collected"] forState:UIControlStateHighlighted];
    [wh_btnCollection setImage:[UIImage imageNamed:@"weibo_collected"] forState:UIControlStateSelected];
//    _wh_btnCollection.tag = self.tag*1000+3;
    [wh_btnCollection addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
    self.wh_btnCollection = wh_btnCollection;
    
    //回复按钮
    UIButton *wh_btnReply = [UIButton buttonWithType:UIButtonTypeCustom];
    wh_btnReply.frame = CGRectMake(CGRectGetMinX(_wh_btnCollection.frame)-40-ICON_WIDTH,1,50,25);
    [wh_btnReply setTitleColor:HEXCOLOR(0x556b95) forState:UIControlStateNormal];
    [wh_btnReply.titleLabel setFont:sysFontWithSize(13)];
    [wh_btnReply setImage:[UIImage imageNamed:@"weibo_comment"] forState:UIControlStateNormal];
    [wh_btnReply setImage:[UIImage imageNamed:@"weibo_commented"] forState:UIControlStateHighlighted];
//    wh_btnReply.tag = self.tag*1000+2;
    [wh_btnReply addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
    self.wh_btnReply = wh_btnReply;
    
    //点赞，回复按钮
    UIButton *wh_btnLike = [UIButton buttonWithType:UIButtonTypeCustom];
    wh_btnLike.frame = CGRectMake(CGRectGetMinX(wh_btnReply.frame)-40-ICON_WIDTH,1,50,25);
    [wh_btnLike setTitleColor:HEXCOLOR(0x556b95) forState:UIControlStateNormal];
    [wh_btnLike.titleLabel setFont:sysFontWithSize(13)];
    [wh_btnLike setImage:[UIImage imageNamed:@"weibo_thumb"] forState:UIControlStateNormal];
    [wh_btnLike setImage:[UIImage imageNamed:@"weibo_thumbed"] forState:UIControlStateHighlighted];
    [wh_btnLike setImage:[UIImage imageNamed:@"weibo_thumbed"] forState:UIControlStateSelected];
//    wh_btnLike.tag = self.tag*1000+1;
    [wh_btnLike addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
    self.wh_btnLike = wh_btnLike;
    
    self.wh_btnReport.hidden = YES;
    self.wh_btnCollection.hidden = YES;
    self.wh_btnReply.hidden = YES;
    self.wh_btnLike.hidden = YES;
    
    
    //回复区背景图
   UIImageView  *backImg = [[UIImageView alloc]initWithFrame:CGRectMake(0,25,JX_SCREEN_WIDTH - 75,0)];
    backImg.image = [[UIImage imageNamed:@""] stretchableImageWithLeftCapWidth:30 topCapHeight:15];//AlbumTriangleB
    backImg.userInteractionEnabled = YES;
    self.back = backImg;
    //竖向分割线
    UIView *suSeparateLine = [[UIView alloc] init];
    suSeparateLine.backgroundColor = HEXCOLOR(0xE3E3E3);
    self.suSeparateLine = suSeparateLine;
    
    [wh_replyContent addSubview:time];
    [wh_replyContent addSubview:delBtn];
    [wh_replyContent addSubview:wh_btnReply];
    [wh_replyContent addSubview:_wh_btnLike];
    [wh_replyContent addSubview:_wh_btnReport];
    [wh_replyContent addSubview:_wh_btnCollection];
    [wh_replyContent addSubview:back];
    [wh_replyContent addSubview:wh_tableReply];
    [wh_replyContent addSubview:self.suSeparateLine];
    [wh_replyContent addSubview:_wh_moreMenu];
    */
    
}

- (void)backAction {
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
