//
//  WH_WeiboCell.m
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "WH_WeiboCell.h"
#import "UIImageView+HBHttpCache.h"
#import "TimeUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "NSStrUtil.h"
#import "ObjUrlData.h"
//#import "userInfoVC.h"
#import "WH_JXUserInfo_WHVC.h"
#import "UIImageView+WH_FileType.h"
#import "JXLikeListViewController.h"
#import "UILabel+WH_YBAttributeTextTapAction.h"


#define ICON_WIDTH  10   // 点赞回复等按钮之前的距离

@interface WH_WeiboCell ()<WH_HBCoreLabelDelegate,WH_YBAttributeTapActionDelegate>
{
//    MPMoviePlayerController* _player;
}

@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) WH_JXImageView *shareIcon;
@property (nonatomic, strong) UILabel *shareTitle;


@end

@implementation WH_WeiboCell
@synthesize wh_tableViewP,title,content,wh_imageContent,fileView,time,delBtn,locLabel,mLogo,wh_replyContent,wh_btnDelete,wh_btnReply,wh_btnShare,back,wh_tableReply,wh_lockView,wh_refreshCount,weibo;
@synthesize wh_pauseBtn;
@synthesize wh_imagePlayer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _pool = [[NSMutableArray alloc]init];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        title = [[UILabel alloc] initWithFrame:CGRectMake(57, 17, JX_SCREEN_WIDTH - 114, 21)];
        title.text = Localized(@"WaHu_WeiboCell_Star");
        title.textColor = HEXCOLOR(0x576b95);
        [self.contentView addSubview:title];

        //说说文本
        content = [[WH_HBCoreLabel alloc]initWithFrame:CGRectMake(57, 32, JX_SCREEN_WIDTH - 120 , 21)];
        content.wh_delegate = self;
        content.textColor = HEXCOLOR(0x3A404C);
        [self.contentView addSubview:content];

        wh_imageContent = [[UIView alloc]initWithFrame:CGRectMake(57, 32, JX_SCREEN_WIDTH -70, 21)];
        [self.contentView addSubview:wh_imageContent];

        _wh_audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.wh_imageContent frame:CGRectNull isLeft:YES];
        _wh_audioPlayer.wh_isOpenProximityMonitoring = YES;

        fileView = [[UIView alloc] initWithFrame:CGRectMake(57, 40, JX_SCREEN_WIDTH -100, 100)];
//        fileView.backgroundColor = [UIColor redColor];
//        fileView.layer.borderWidth = 0.5f;
//        fileView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        fileView.backgroundColor = HEXCOLOR(0xECEDEF);
        UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileUrlCopy)];
        [fileView addGestureRecognizer:tapges];
        [self.contentView addSubview:fileView];
        fileView.hidden = YES;
        
        if(!_typeView){
            _typeView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 60, 60)];
            _typeView.layer.cornerRadius = 3;
            _typeView.layer.masksToBounds = YES;
            //        _typeView.backgroundColor = [UIColor redColor];
            [fileView addSubview:_typeView];
        }
        
        if(!_wh_fileTitleLabel){
            _wh_fileTitleLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:@"--.--" font:sysFontWithSize(15) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
            _wh_fileTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            _wh_fileTitleLabel.frame = CGRectMake(CGRectGetMaxX(_typeView.frame) +5, 0, CGRectGetWidth(fileView.frame)-CGRectGetMaxX(_typeView.frame)-5-5, 25);
            _wh_fileTitleLabel.center = CGPointMake(_wh_fileTitleLabel.center.x, _typeView.center.y);
            _wh_fileTitleLabel.textAlignment = NSTextAlignmentLeft;
            [fileView addSubview:_wh_fileTitleLabel];
        }
        
        [self createShareView];
        
        wh_replyContent = [[UIView alloc]initWithFrame:CGRectMake(57,67,JX_SCREEN_WIDTH -70,30)];
        wh_replyContent.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:wh_replyContent];

        locLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:nil font:sysFontWithSize(11) textColor:HEXCOLOR(0x576b95) backgroundColor:[UIColor clearColor]];
        locLabel.frame = CGRectMake(57, CGRectGetMaxY(wh_replyContent.frame)+5, JX_SCREEN_WIDTH -70, 14);
        locLabel.hidden = YES;
        [self.contentView addSubview:locLabel];
        
        mLogo = [[WH_JXImageView alloc]initWithFrame:CGRectMake(7,17,40,40)];
        mLogo.wh_delegate = self;
        
        mLogo.didTouch = @selector(actionUser:);
        [mLogo headRadiusWithAngle:mLogo.frame.size.width / 2];
//        mLogo.backgroundColor = [UIColor brownColor];
        [self.contentView addSubview:mLogo];
        //时间
        time = [[UILabel alloc]initWithFrame:CGRectMake(0,4,130,21)];
        time.textColor = HEXCOLOR(0x88888A);
        time.font = [UIFont systemFontOfSize:12];

        //删除
        delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setTitle:Localized(@"JX_Delete") forState:UIControlStateNormal];
        [delBtn setTitle:Localized(@"JX_Delete") forState:UIControlStateHighlighted];
        [delBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateNormal];
        [delBtn setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateHighlighted];
        delBtn.titleLabel.font = sysFontWithSize(12);
        delBtn.tag = self.tag;
        delBtn.hidden = YES;
        [delBtn addTarget:self action:@selector(delBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        wh_tableReply = [[UITableView alloc]initWithFrame:CGRectMake(10,31,JX_SCREEN_WIDTH -65,0)];
        wh_tableReply.dataSource = self;
        wh_tableReply.delegate   = self;
        wh_tableReply.tag        = self.tag;
        wh_tableReply.backgroundColor = [UIColor clearColor];
        wh_tableReply.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, wh_tableReply.frame.size.width, 23)];
        _moreLabel.backgroundColor = [UIColor clearColor];
        _moreLabel.textAlignment = NSTextAlignmentCenter;
        _moreLabel.font = sysFontWithSize(13);
        _moreLabel.text=Localized(@"JX_SeeMoreComments");
        _moreLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getMoreData)];
        [_moreLabel addGestureRecognizer:tap];
        wh_tableReply.tableFooterView = _moreLabel;
        
        _wh_moreMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        _wh_moreMenu.frame = CGRectMake(JX_SCREEN_WIDTH -100,4,30,18);
        [_wh_moreMenu setImage:[UIImage imageNamed:@"newicon_moreMenu"] forState:UIControlStateNormal];
        [_wh_moreMenu setImage:[UIImage imageNamed:@"newicon_moreMenu"] forState:UIControlStateHighlighted];
        _wh_moreMenu.tag = self.tag*1000+5;
        [_wh_moreMenu addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
        
        //举报按钮
        _wh_btnReport = [UIButton buttonWithType:UIButtonTypeCustom];
        _wh_btnReport.frame = CGRectMake(JX_SCREEN_WIDTH -100,1,25,25);
        [_wh_btnReport setImage:[UIImage imageNamed:@"weibo_report"] forState:UIControlStateNormal];
        [_wh_btnReport setImage:[UIImage imageNamed:@"weibo_reported"] forState:UIControlStateHighlighted];
        _wh_btnReport.tag = self.tag*1000+4;
        [_wh_btnReport addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];

        //收藏按钮
        _wh_btnCollection = [UIButton buttonWithType:UIButtonTypeCustom];
        _wh_btnCollection.frame = CGRectMake(CGRectGetMinX(_wh_btnReport.frame)-25-ICON_WIDTH,0,25,25);
        [_wh_btnCollection setImage:[UIImage imageNamed:@"weibo_collection"] forState:UIControlStateNormal];
        [_wh_btnCollection setImage:[UIImage imageNamed:@"weibo_collected"] forState:UIControlStateHighlighted];
        [_wh_btnCollection setImage:[UIImage imageNamed:@"weibo_collected"] forState:UIControlStateSelected];
        _wh_btnCollection.tag = self.tag*1000+3;
        [_wh_btnCollection addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
        
        //回复按钮
        wh_btnReply = [UIButton buttonWithType:UIButtonTypeCustom];
        wh_btnReply.frame = CGRectMake(CGRectGetMinX(_wh_btnCollection.frame)-40-ICON_WIDTH,1,50,25);
        [wh_btnReply setTitleColor:HEXCOLOR(0x556b95) forState:UIControlStateNormal];
        [wh_btnReply.titleLabel setFont:sysFontWithSize(13)];
        [wh_btnReply setImage:[UIImage imageNamed:@"weibo_comment"] forState:UIControlStateNormal];
        [wh_btnReply setImage:[UIImage imageNamed:@"weibo_commented"] forState:UIControlStateHighlighted];
        wh_btnReply.tag = self.tag*1000+2;
        [wh_btnReply addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];

        //点赞，回复按钮
        _wh_btnLike = [UIButton buttonWithType:UIButtonTypeCustom];
        _wh_btnLike.frame = CGRectMake(CGRectGetMinX(wh_btnReply.frame)-40-ICON_WIDTH,1,50,25);
        [_wh_btnLike setTitleColor:HEXCOLOR(0x556b95) forState:UIControlStateNormal];
        [_wh_btnLike.titleLabel setFont:sysFontWithSize(13)];
        [_wh_btnLike setImage:[UIImage imageNamed:@"weibo_thumb"] forState:UIControlStateNormal];
        [_wh_btnLike setImage:[UIImage imageNamed:@"weibo_thumbed"] forState:UIControlStateHighlighted];
        [_wh_btnLike setImage:[UIImage imageNamed:@"weibo_thumbed"] forState:UIControlStateSelected];
        _wh_btnLike.tag = self.tag*1000+1;
        [_wh_btnLike addTarget:self action:@selector(wh_btnReply:) forControlEvents:UIControlEventTouchUpInside];
        
        _wh_btnReport.hidden = YES;
        _wh_btnCollection.hidden = YES;
        wh_btnReply.hidden = YES;
        _wh_btnLike.hidden = YES;
       
        
        //回复区背景图
        back = [[UIImageView alloc]initWithFrame:CGRectMake(0,25,JX_SCREEN_WIDTH - 75,0)];
        back.image = [[UIImage imageNamed:@""] stretchableImageWithLeftCapWidth:30 topCapHeight:15];//AlbumTriangleB
        back.userInteractionEnabled = YES;
        
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
        [self.wh_tableReply addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];

    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.wh_tableReply.contentSize.height == 0) {
        return;
    }
    CGRect frame = self.suSeparateLine.frame;
    frame.size.height = self.wh_tableReply.contentSize.height;
    self.suSeparateLine.frame = frame;
    
}
- (void)createShareView {
    
    if (!_shareView) {
        _shareView = [[UIView alloc] initWithFrame:CGRectMake(57, 25, JX_SCREEN_WIDTH - 100, 70)];
        _shareView.backgroundColor = HEXCOLOR(0xf0f0f0);
        _shareView.hidden = YES;
        UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareUrlAction)];
        [_shareView addGestureRecognizer:tapges];
        [self.contentView addSubview:_shareView];
        
        _shareIcon = [[WH_JXImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        //    imageView.image = [UIImage imageNamed:@"appLogo"];
        [_shareIcon sd_setImageWithURL:[NSURL URLWithString:weibo.sdkIcon] placeholderImage:[UIImage imageNamed:@"appLogo"]];
        [_shareView addSubview:_shareIcon];
        
       _shareTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_shareIcon.frame) + 5, _shareIcon.frame.origin.y, _shareView.frame.size.width - CGRectGetMaxX(_shareIcon.frame) - 15, _shareIcon.frame.size.height)];
        _shareTitle.numberOfLines = 0;
        //    label.text = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈";
        _shareTitle.text = weibo.sdkTitle;
        _shareTitle.font = [UIFont systemFontOfSize:14.0];
        [_shareView addSubview:_shareTitle];
        
    }
}

- (void)shareUrlAction {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(WH_WeiboCell:shareUrlActionWithUrl:title:)]) {
        [self.delegate WH_WeiboCell:self shareUrlActionWithUrl:weibo.sdkUrl title:weibo.sdkTitle];
    }
}

- (void)setupData {
    if ([weibo.userId isEqualToString:MY_USER_ID]) {
        _wh_btnCollection.frame = CGRectMake(JX_SCREEN_WIDTH -100,0,25,25);
        wh_btnReply.frame = CGRectMake(CGRectGetMinX(_wh_btnCollection.frame)-40-ICON_WIDTH,1,50,25);
        _wh_btnLike.frame = CGRectMake(CGRectGetMinX(wh_btnReply.frame)-40-ICON_WIDTH,1,50,25);
        _wh_btnReport.hidden = YES;
    }else {
        _wh_btnCollection.frame = CGRectMake(CGRectGetMinX(_wh_btnReport.frame)-25-ICON_WIDTH,0,25,25);
        wh_btnReply.frame = CGRectMake(CGRectGetMinX(_wh_btnCollection.frame)-40-ICON_WIDTH,1,50,25);
        _wh_btnLike.frame = CGRectMake(CGRectGetMinX(wh_btnReply.frame)-40-ICON_WIDTH,1,50,25);
        _wh_btnReport.hidden = NO;
    }
    
    [_wh_btnLike setTitle:[self getMaxValue:weibo.praiseCount] forState:UIControlStateNormal];
    [wh_btnReply setTitle:[self getMaxValue:weibo.commentCount] forState:UIControlStateNormal];
}

- (NSString *)getMaxValue:(int)value {
    NSString *str = [NSString string];
    if (value > 99) {
        str = @"99+";
    }else {
        str = [NSString stringWithFormat:@"%d",value];
    }
    return str;
}

//复制信息到剪贴板
- (void)fileUrlCopy{
    [self.controller fileAction:weibo];
//    ObjUrlData * url= [weibo.files firstObject];
//    if (url.url.length >0) {
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        [pasteboard setString:url.url];
//        [g_server showMsg:Localized(@"JXCopyToBoardSuccess") delay:1.5];
//    }else{
//        [g_App showAlert:Localized(@"JXFile_notExist")];
//    }
    
}

-(void)delBtnAction:(WeiboData*)cellData{

    [self.controller delBtnAction:self.weibo];
    [self.detailController delBtnAction:self.weibo];
}

- (void)setIsPraise:(BOOL)isPraise {
    _isPraise = isPraise;
    _wh_btnLike.selected = isPraise;
}

- (void)setIsCollect:(BOOL)isCollect {
    _isCollect = isCollect;
    _wh_btnCollection.selected = isCollect;
}

//莫名其妙，直接写在btnReply里无效
#pragma mark - 菜单点击
- (void)wh_btnReply:(UIButton*)button{
//    if (self.menuView) {
//        [self.menuView dismissBaseView];
//        return;
//    }
//    NSArray *strArr = @[Localized(@"JX_Good"),Localized(@"JX_Comment"),Localized(@"WaHu_JXUserInfo_WHVC_Report")];
//    NSArray *imgArr = @[@"blog_giveLike",@"blog_comments"];
//    self.baseView = [[UIView alloc] init];
//    self.baseView.backgroundColor = HEXCOLOR(0x3B4042);
//    self.baseView.layer.masksToBounds = YES;
//    self.baseView.layer.cornerRadius = 3.0f;
//    [self addSubview:self.baseView];
//    NSInteger w = 0;
//    UIButton *cellView;
//    for (int i = 0; i < strArr.count; i++) {
//        NSString *str = strArr[i];
//        CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(13)} context:nil].size;
//        cellView = [[UIButton alloc] init];
//        UIImageView *imgV;
//
//        if (imgArr.count > 0 && i < imgArr.count) {
//            CGFloat H = 14.f;
//            cellView.frame = CGRectMake(w, 0, INSET*2+H+size.width, HEIGHT);
//            imgV = [[UIImageView alloc] initWithFrame:CGRectMake(INSET, (HEIGHT-H)/2, H, H)];
//            imgV.image = [UIImage imageNamed:imgArr[i]];
//            [cellView addSubview:imgV];
//        } else {
//            cellView.frame = CGRectMake(w, 0, INSET*2+size.width, HEIGHT);
//        }
//        UILabel *textLabel = [[UILabel alloc] init];
//        textLabel.font = sysFontWithSize(13);
//        textLabel.text = str;
//        textLabel.textColor = [UIColor whiteColor];
//        if (i < imgArr.count) {
//            textLabel.frame = CGRectMake(CGRectGetMaxX(imgV.frame)+4, (HEIGHT-size.height)/2, size.width, size.height);
//        }else {
//            textLabel.frame = CGRectMake(0, (HEIGHT-size.height)/2, cellView.frame.size.width, size.height);
//            textLabel.textAlignment = NSTextAlignmentCenter;
//        }
//        [cellView addSubview:textLabel];
//        cellView.backgroundColor = [UIColor clearColor];
//        [self.baseView addSubview:cellView];
//        if (i > 0) {
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 4, 0.5, HEIGHT-8)];
//            line.backgroundColor = [UIColor whiteColor];
//            [cellView addSubview:line];
//        }
//        w += cellView.frame.size.width;
//    }
//
//    CGPoint point = replyContent.center;
//    CGFloat y = point.y-32/2-2;
//    
//    self.menuView = [[JXMenuView alloc] initWithPoint:CGPointMake(10, y) Title:strArr Images:imgArr];
//    [self addSubview:self.menuView];

    [_wh_btnLike setTitle:[self getMaxValue:weibo.praiseCount] forState:UIControlStateNormal];
    [wh_btnReply setTitle:[self getMaxValue:weibo.commentCount] forState:UIControlStateNormal];

    [self.controller btnReplyAction:button WithCell:self];
    [self.detailController btnReplyAction:button WithCell:self];
//    button.tag = self.tag;
//    [self.controller btnReplyAction:button];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self){
       
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
#pragma -mark 私有方法

-(void) prepare
{
    [super prepareForReuse];
    for(UIView * view in wh_imageContent.subviews)
        [view removeFromSuperview];
    UIView * view=[self.contentView viewWithTag:191];
    if(view){
        [view removeFromSuperview];
    }
    view=[self.contentView viewWithTag:192];
    if(view){
        [view removeFromSuperview];
    }
    linesLimit=NO;
}

//根据回复数量修改高度
+(float) heightForReply:(NSArray*)replys
{
    if([replys count]==0)
        return 0;
    float height=6;
    for(WeiboReplyData * data in replys){
        height+=data.height+4;
    }
    return height;
}
#pragma mark --------------依据图片数量设置大小-----------------
-(void)addImagesWithFiles:(float)offset
{
    //判断说说是否有图片
    if(self.weibo.imageHeight==0){
        self.wh_imageContent.hidden=YES;
        CGRect  frame=self.wh_imageContent.frame;
        frame.origin.y=self.content.frame.origin.y+self.content.frame.size.height+offset+5;
    
        frame.size.height=0;
        self.wh_imageContent.frame=frame;
        return;
    }else{
        self.wh_imageContent.hidden=NO;
        CGRect  frame=self.wh_imageContent.frame;
        
        frame.origin.y=self.content.frame.origin.y+self.content.frame.size.height+offset+5;
        frame.size.height=self.weibo.imageHeight;
        self.wh_imageContent.frame=frame;
    }
    __weak WH_WeiboCell * wself=self;
    __weak WeiboData * wweibo=self.weibo;
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (wself&&wweibo.willDisplay&&wweibo) {
            __strong WH_WeiboCell * sself=wself;
            __strong WeiboData * sweibo=wweibo;
            dispatch_async(dispatch_get_main_queue(), ^{
                WH_HBShowImageControl * control=[[WH_HBShowImageControl alloc]initWithFrame: sself.wh_imageContent.bounds];
                control.wh_controller=sself.controller;
                control.wh_smallTag=THUMB_WEIBO_SMALL_1;
//                control.smallTag=THUMB_WEIBO_BIG;
                control.wh_bigTag=THUMB_WEIBO_BIG;
                control.wh_larges = sweibo.larges;
                //缩略图显示为原图
//                [control setImagesFileStr:sweibo.smalls];
                [control WH_setImagesFileStr:sweibo.larges];
                
                [sself.wh_imageContent addSubview:control];
                control.delegate=sself;
            });
        }
    });
}
//获取头像当音视频背景
-(void)addImageForAudioVideo:(float)offset
{
    NSString* imageUrl=nil;
    if([self.weibo.larges count]>0)
        imageUrl = ((ObjUrlData*)[self.weibo.larges objectAtIndex:0]).url;
    else
        imageUrl = [g_server WH_getHeadImageOUrlWithUserId:weibo.userId];

    self.wh_imageContent.hidden=NO;
    CGRect  frame=self.wh_imageContent.frame;
    frame.origin.y=self.content.frame.origin.y+self.content.frame.size.height+offset+5;
    frame.size.height=self.weibo.imageHeight;
    self.wh_imageContent.frame=frame;
    
    //
    wh_imagePlayer = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, 0, 67.5, 120)];
    wh_imagePlayer.wh_changeAlpha = NO;
    wh_imagePlayer.didTouch = @selector(doNotThing);
    wh_imagePlayer.wh_delegate = self.controller;
    [self.wh_imageContent addSubview:wh_imagePlayer];

    
    [wh_imagePlayer sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"avatar_normal"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        
        wh_imagePlayer.contentMode = UIViewContentModeScaleAspectFit;
        
        if(weibo.isVideo){

            [FileInfo getFullFirstImageFromVideo:[self.weibo getMediaURL] imageView:wh_imagePlayer];
            UIButton *pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
            pauseBtn.center = CGPointMake(wh_imagePlayer.frame.size.width/2,wh_imagePlayer.frame.size.height/2);
            [pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
            [pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
            [wh_imagePlayer addSubview:pauseBtn];
//            _videoPlayer = [[WH_JXVideoPlayer alloc] initWithParent:imagePlayer];
//            _videoPlayer.isStartFullScreenPlay = YES;
//            _videoPlayer.videoFile = [self.weibo getMediaURL];
        }else{
//            _audioPlayer = [[WH_AudioPlayerTool alloc] initWithParent:imagePlayer];
//            _audioPlayer.audioFile = [self.weibo getMediaURL];
        }
    }];
    
    
}

- (void)setupAudioPlayer:(float)offset {
    
    if (!_wh_audioPlayer) {
        _wh_audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.wh_imageContent frame:CGRectNull isLeft:YES];
    }
    
    ObjUrlData *data = (ObjUrlData *)[self.weibo.audios firstObject];
    
    if([data.timeLen intValue] <= 0)
        data.timeLen  = @1;
    int w = (JX_SCREEN_WIDTH-HEAD_SIZE-INSETS*2-70)/30;
    w = 70+w*[data.timeLen intValue];
    if(w<70)
        w = 70;
    if(w>200)
        w = 200;

    self.wh_imageContent.hidden=NO;
    CGRect  frame=self.wh_imageContent.frame;
    frame.origin.y=self.content.frame.origin.y+self.content.frame.size.height+offset+5;
    frame.size = CGSizeMake(w, 30);
    self.wh_imageContent.frame=CGRectMake(self.wh_imageContent.frame.origin.x, frame.origin.y, self.wh_imageContent.frame.size.width, frame.size.height);
    self.wh_imageContent.layer.masksToBounds = YES;
    self.wh_imageContent.layer.cornerRadius = 3.f;
    self.wh_imageContent.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startAudioPlay)];
    [self.wh_imageContent addGestureRecognizer:tap];
    _wh_audioPlayer.wh_frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _wh_audioPlayer.wh_audioFile = [self.weibo getMediaURL];
    _wh_audioPlayer.wh_timeLen = [data.timeLen intValue];
    _wh_audioPlayer.wh_timeLenView.textColor = [UIColor darkGrayColor];
    _wh_audioPlayer.wh_voiceBtn.backgroundColor = HEXCOLOR(0xECEDEF);
//    _audioPlayer.parent.backgroundColor = HEXCOLOR(0xECEDEF);
}

- (void)startAudioPlay {
    [_wh_audioPlayer wh_switch];
}


#pragma -mark 点击播放视频
- (void)showTheVideo {
    [self.delegate WH_WeiboCell:self clickVideoWithIndex:self.tag];
}


- (void)doNotThing{
    
}



#pragma -mark 接口方法
-(void)loadReply
{
//    _replys=self.weibo.replys;
    [self.wh_tableReply reloadData];
}
#pragma  mark  ------------------填充数据--------------
-(void)setWeibo:(WeiboData *)value
{
    value.willDisplay = YES;
//    if(value.local==self.weibo.local&&linesLimit==value.linesLimit&&[self.weibo.replys count]==[value.replys count])
//        return;
    weibo=value;
    [self prepare];
    replyCount=(int)[self.weibo.replys count];
    linesLimit=self.weibo.linesLimit;

    WH_JXUserObject *userObj = [[WH_JXUserObject sharedUserInstance] getFriendWithUserId:self.weibo.userId];
    
    NSString *userName = @"";
    if ([self.weibo.userId isEqualToString:MY_USER_ID]) {
        userName = self.weibo.userNickName;
    }else{
        if (!IsStringNull(userObj.remarkName)) {
            userName = userObj.remarkName;
        }else{
            userName = userObj.userNickname;
        }
    }
    
//    title.text = self.weibo.userNickName;
    title.text = userName;
    [[JXServer sharedServer] WH_getHeadImageSmallWIthUserId:self.weibo.userId userName:self.weibo.userNickName imageView:self.mLogo];
    
    [self.content WH_registerCopyAction];
    self.content.wh_linesLimit=self.weibo.linesLimit;
    __weak WH_HBCoreLabel * wcontent=self.content;
    MatchParser* match=[self.weibo getMatch:^(MatchParser *parser,id data) {
        if (wcontent) {
            WeiboData * weibo=(WeiboData*)data;
            if (weibo.willDisplay) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   wcontent.wh_match=parser;
                });
            }
        }
    } data:self.weibo];
    self.content.wh_match=match;
    self.time.text=[TimeUtil getTimeStrStyle1:weibo.createTime];
    CGRect frame=self.time.frame;
//    frame.size.width=[self.time.text sizeWithFont:self.time.font].width+10;
    frame.size.width = [self.time.text sizeWithAttributes:@{NSFontAttributeName:self.time.font}].width + 10;
    self.time.frame=frame;
    
    CGFloat delW = [self.delBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.delBtn.titleLabel.font}].width +10;
    self.delBtn.frame = CGRectMake(CGRectGetMaxX(frame)+5, CGRectGetMinY(frame), delW, CGRectGetHeight(frame));
    if (weibo.location.length >0){
        self.locLabel.text = weibo.location;
        locLabel.hidden = NO;
    }else{
        locLabel.hidden = YES;
    }
    
    self.wh_tableReply.scrollEnabled=NO;
    float offset=0.0f;
    if(self.weibo.numberOfLineLimit<self.weibo.numberOfLinesTotal){
        UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:self.title.textColor forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:sysFontWithSize(15)];
        [self.contentView addSubview:button];
        [button addTarget:self action:@selector(limitAction) forControlEvents:UIControlEventTouchUpInside];
#pragma mark － 这里更改了说说的坐标
        if(self.weibo.linesLimit){
            [button setTitle:Localized(@"WaHu_WeiboCell_AllText") forState:UIControlStateNormal];
            content.frame=CGRectMake(57, 42, JX_SCREEN_WIDTH -20,self.weibo.heightOflimit);
            offset=25;
        }else{
            [button setTitle:Localized(@"WaHu_WeiboCell_Stop") forState:UIControlStateNormal];
            content.frame=CGRectMake(57, 42, JX_SCREEN_WIDTH -20,self.weibo.height);
            offset=25;
        }
        button.frame=CGRectMake(57, self.content.frame.origin.y+self.content.frame.size.height+6, 50, 20);
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
        button.tag=191;
    }else{
        content.frame=CGRectMake(57, 42, JX_SCREEN_WIDTH -20 ,self.weibo.height);
    }
    if([weibo.videos count]>0)
        [self addImageForAudioVideo:offset];
    else if ( [weibo.audios count]>0)
        [self setupAudioPlayer:offset];
    else
        [self addImagesWithFiles:offset];
    
    if (weibo.type == weibo_dataType_share) {
        self.shareView.hidden = NO;
        CGRect frame=CGRectMake(57, 25, JX_SCREEN_WIDTH - 100, 70);
    frame.origin.y=self.content.frame.origin.y+self.content.frame.size.height+offset+5;
        self.shareView.frame=frame;
        
        _shareTitle.text = weibo.sdkTitle;
        [_shareIcon sd_setImageWithURL:[NSURL URLWithString:weibo.sdkIcon] placeholderImage:[UIImage imageNamed:@"appLogo"]];
    }else {
        
        self.shareView.frame = CGRectZero;
        self.shareView.hidden = YES;
    }
    
    //[weibo.files count]>0
    if (weibo.type == weibo_dataType_file) {
        self.fileView.hidden = NO;
        self.fileView.frame = CGRectMake(57, 40, JX_SCREEN_WIDTH -100, 100);
        CGRect  frame = self.fileView.frame;
        frame.origin.y=self.content.frame.origin.y+self.content.frame.size.height+offset+5;
//        frame.size.height=self.weibo.imageHeight;
        self.fileView.frame=frame;
        
        ObjUrlData * url= [weibo.files firstObject];
//        url.url;
//        url.fileSize = [NSString stringWithFormat:@"%@",msg.fileSize];
//        url.type = @"4";
        NSString *urlName;
        if (url.name.length > 0) {
            urlName = url.name;
        }else {
            urlName = [url.url lastPathComponent];
        }
        _wh_fileTitleLabel.text = urlName;
        NSString * fileExt = [urlName pathExtension];
        NSInteger fileType = [self fileTypeWithExt:fileExt];
        
        [_typeView setFileType:fileType];
    }else{
        self.fileView.frame = CGRectZero;
        self.fileView.hidden = YES;
    }
    int moreH = self.weibo.replys.count == 20 ? 23 : 0;
    if (self.weibo.replys.count % 20 == 0) {
        wh_tableReply.tableFooterView = _moreLabel;
    }else {
        wh_tableReply.tableFooterView = nil;
    }
    float height=self.weibo.replyHeight;
    if(height>=0){
        [self createTableHead];
        if (self.weibo.heightPraise > 0) {
            height = self.weibo.replyHeight - self.weibo.heightPraise + _heightPraise + 5;
        }
        frame=self.wh_replyContent.frame;
        frame.origin.y=self.wh_imageContent.frame.origin.y+self.wh_imageContent.frame.size.height+5 +CGRectGetHeight(self.fileView.frame)+CGRectGetHeight(self.shareView.frame);
        frame.size.height=self.weibo.replyHeight+30+moreH;
        self.wh_replyContent.frame=frame;
        locLabel.frame = CGRectMake(57, CGRectGetMaxY(wh_replyContent.frame)+5, JX_SCREEN_WIDTH -70, 14);
        
        frame=back.frame;
        frame.size.height=height+3+moreH;
        frame.origin.y=25;
        back.frame=frame;
        
        frame=wh_tableReply.frame;
        frame.size.height=height+moreH;
        frame.origin.y=31;
        wh_tableReply.frame=frame;
        
        frame=back.frame;
        frame.size.height-=7;
        frame.origin.y+=7;
        frame.size.width = 2;
        self.suSeparateLine.frame=frame;
    }
    self.suSeparateLine.hidden = height <= 0;
    back.hidden = height<=0;
    wh_tableReply.hidden = height<=0;
    if(self.weibo.local){
        //为何要设为NO
        [self.wh_btnReply setEnabled:NO];
    }else{
        [self.wh_btnReply setEnabled:YES];
    }
    [self.wh_tableReply reloadData];
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

+(float)getHeightByContent:(WeiboData*)data
{
    float height;
    if(data.shouldExtend){
        if(data.linesLimit){
            height=data.heightOflimit+25;
        }else{
            height=data.height+25;
        }
    }else{
        height=data.height;
    }
    if (data.location.length > 0) {
        height += 15;
    }
    if ([data.replys isKindOfClass:[NSArray class]]&&([data.replys count]>0 || [data.praises count]>0)&&!data.local) {

        if (data.audios.count > 0) {
            return data.imageHeight+height+6+data.replyHeight +data.fileHeight + data.shareHeight;
        }
        return 80.0+data.imageHeight+height+6+data.replyHeight +data.fileHeight + data.shareHeight;
    } else  {
        if (data.audios.count > 0) {
            return data.imageHeight+height +data.fileHeight + data.shareHeight;
        }
        return 80.0+data.imageHeight+height +data.fileHeight + data.shareHeight;
    }
}

#pragma -mark 委托方法
-(void)WH_showImageControlFinishLoad:(WH_HBShowImageControl*)control
{
    CGRect frame=self.wh_imageContent.frame;
    frame.size.height=control.frame.size.height;
    self.wh_imageContent.frame=frame;
}


#pragma -mark 事件响应方法

-(void)limitAction
{
    self.weibo.linesLimit=!self.weibo.linesLimit;
    [self refresh];
}


#pragma -mark 回调方法

-(void)WH_lookImageAction:(WH_HBShowImageControl*)control
{
}
-(void)coreLabel:(WH_HBCoreLabel*)coreLabel linkClick:(NSString*)linkStr
{
    [g_notify postNotificationName:kCellTouchUrl_WHNotifaction object:linkStr];
}
-(void)coreLabel:(WH_HBCoreLabel *)coreLabel phoneClick:(NSString *)linkStr
{
    [g_notify postNotificationName:kCellTouchPhone_WHNotifaction object:linkStr];
}

#pragma -mark  tableReply delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeiboReplyData * data=[self.weibo.replys objectAtIndex:indexPath.row];
    NSLog(@"------%d",data.height + 4);
    CGFloat height = [JXXMPP getLabelHeightWithContent:[self getLabelText:data] andLabelWidth:JX_SCREEN_WIDTH - 80 andLabelFontSize:13];
    return height + 10;
//    return data.height+4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.viewController) {
        return 0;
    }
    NSInteger n = [self.weibo.replys count];
    return n;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *CellIdentifier = [NSString stringWithFormat:@"WeiboReplyCell%d_%d",refreshCount,indexPath.row];
    NSString *CellIdentifier = [NSString stringWithFormat:@"WeiboReplyCell"];
    ReplyCell * cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //清空cell里的数据
//    cell.label = nil;
    
    cell.backgroundColor = [UIColor clearColor];

    if(indexPath.row>=self.weibo.replys.count)
        return cell;
    //回复区的文字Label
//    cell.label = [[UILabel alloc]initWithFrame:CGRectMake(3, 4, JX_SCREEN_WIDTH, 27)];
//    [cell addSubview:cell.label];
//    cell.label.font = [UIFont systemFontOfSize:13];
//    cell.label.numberOfLines = 0;
//    cell.label.textColor = HEXCOLOR(0x576B94);
//    cell.label.backgroundColor = [UIColor clearColor];
    WeiboReplyData * data=[self.weibo.replys objectAtIndex:indexPath.row];
   
//    __weak WH_HBCoreLabel * wlabel=cell.label;
//    MatchParser * match=[data getMatch:^(MatchParser *parser, id data) {
//        if (wlabel) {
//            WeiboData * weibo=(WeiboData*)data;
//            if (weibo.willDisplay) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    wlabel.wh_match=parser;
//                });
//            }
//        }
//    } data:self.weibo];
    
//    cell.label.wh_match=data.match;
    cell.label.text = [self getLabelText:data];
    [JXXMPP getAttributeTextWithLabel:cell.label textString:data.body color:HEXCOLOR(0x333333)];
    cell.label.userInteractionEnabled=YES;
    CGFloat height = [JXXMPP getLabelHeightWithContent:[self getLabelText:data] andLabelWidth:JX_SCREEN_WIDTH - 80 andLabelFontSize:13];
    CGRect frame=cell.label.frame;
    cell.backgroundColor=[UIColor clearColor];
    frame.size.height = height + 3;
    cell.label.frame=frame;
    //设置回复被点击后颜色不变
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (NSString *)getLabelText:(WeiboReplyData *)data {
    if ([data.match.attrString.string containsString:@"回复"]) {
           WH_JXUserObject *userA = [[WH_JXUserObject sharedUserInstance] getFriendWithUserId:data.userId];
           WH_JXUserObject *userB = [[WH_JXUserObject sharedUserInstance] getFriendWithUserId:data.toUserId];
        if ([data.userId isEqualToString:g_myself.userId]) {
            data.title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@回复%@", g_myself.userNickname, userB.remarkName.length ? userB.remarkName : userB.userNickname]];
        } else if ([data.toUserId isEqualToString:g_myself.userId]) {
            data.title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@回复%@", userA.remarkName.length ? userA.remarkName : userA.userNickname, g_myself.userNickname]];
        } else if (userA.remarkName.length || userB.remarkName.length) {
               data.title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@回复%@", userA.remarkName.length ? userA.remarkName : userA.userNickname, userB.remarkName.length ? userB.remarkName : userB.userNickname]];
           }
       } else {
           if (![data.userId isEqualToString:g_myself.userId]) {
           WH_JXUserObject *userA = [[WH_JXUserObject sharedUserInstance] getFriendWithUserId:data.userId];
           if (userA.remarkName.length) {
               data.title = [[NSAttributedString alloc] initWithString:userA.remarkName];
           }
           }
       }
    return [NSString stringWithFormat:@"%@:%@", data.title.string, data.body];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ReplyCell * replyCell = [tableReply cellForRowAtIndexPath:indexPath];
    NSIndexPath * row = [NSIndexPath indexPathForRow:self.tag inSection:0];
    //获取数据，大Cell的数据
//    NSLog(@"%ld -----%ld",row.row,row.section);
    self.controller.wh_selectWH_WeiboCell = [self.wh_tableViewP cellForRowAtIndexPath:row];
    self.controller.wh_selectWeiboData = self.controller.wh_selectWH_WeiboCell.weibo;
    //小Cell里面的数据
    WeiboReplyData* p =[self.weibo.replys objectAtIndex:indexPath.row];
    if (MY_USER_ID == p.userId) {
        if (self.detailController) {
            self.detailController.replyIndex = indexPath.row;
            self.detailController.replyId = p.replyId;
            [self.detailController deleteViewShow];
            return;
        }
        [JXMyTools showTipView:Localized(@"JX_NoReplyMyself")];
        return;
        
    }
    if (self.detailController) {
        //回复者
            self.detailController.wh_replyDataTemp.userId    = MY_USER_ID;
            self.detailController.wh_replyDataTemp.userNickName  = g_myself.userNickname;
            //被回复者
            self.detailController.wh_replyDataTemp.toNickName = p.userNickName;
            self.detailController.wh_replyDataTemp.toUserId = p.userId;


        //    NSLog(@"%ld",[p.userNickName length] + [g_myself.userNickname length]);
        //    self.controller.replyDataTemp.body      = p.body;

            [self.detailController WH_doShowAddMyCustomComment:[NSString stringWithFormat:@"%@%@",Localized(@"WaHu_WeiboCell_Reply"),p.userNickName]];

    }
    //回复者
    self.controller.wh_replyDataTemp.userId    = MY_USER_ID;
    self.controller.wh_replyDataTemp.userNickName  = g_myself.userNickname;
    //被回复者
    self.controller.wh_replyDataTemp.toNickName = p.userNickName;
    self.controller.wh_replyDataTemp.toUserId = p.userId;


//    NSLog(@"%ld",[p.userNickName length] + [g_myself.userNickname length]);
//    self.controller.replyDataTemp.body      = p.body;

    [self.controller WH_doShowAddMyCustomComment:[NSString stringWithFormat:@"%@%@",Localized(@"WaHu_WeiboCell_Reply"),p.userNickName]];
   
    /*
    if (replyCell.pointIndex < [p.userNickName length]+1){
        
        [self.controller WH_doShowAddMyCustomComment:[NSString stringWithFormat:@"回复给:%@",p.userNickName]];
        
    }else if(replyCell.pointIndex < [p.userNickName length]+[p.toNickName length]+2){
        
        self.controller.replyDataTemp.toNickName = p.toNickName;
        self.controller.replyDataTemp.toUserId = p.toUserId;
        [self.controller WH_doShowAddMyCustomComment:[NSString stringWithFormat:@"回复给:%@",p.toNickName]];
        
    }else{//删除回复
        
        if([MY_USER_ID isEqualToString:self.controller.selectWeiboData.userId]||[MY_USER_ID isEqualToString:p.userId]){//微博自己发布的或评论自己发布的
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否删除评论" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [g_server WH_delCommentWithMsgId:self.controller.selectWeiboData.messageId commentId:p.replyId toView:self.controller];
                
                self.controller.deleteReply = (int)indexPath.row;
//                [self.weibo.replys removeObject:p];


//                WeiboData * data=[self.controller.datas objectAtIndex:indexPath.row];
//                [data.replys removeObject:p];
                
            }];
            
            UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [alert addAction:actionCancel];
            
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }

    }
     */
}



//#pragma mark - 请求成功回调
//-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
//    [g_wait stop];
//    if([aDownload.action isEqualToString:wh_act_CommentList]){
//        for(int i=0;i<[array1 count];i++){
//            WeiboReplyData * reply=[[WeiboReplyData alloc]init];
//            NSDictionary* dict = [array1 objectAtIndex:i];
//            reply.type=1;
//            [reply WH_getDataFromDict:dict];
//            [reply setMatch];
//            [self.replys addObject:reply];
//            [reply release];
//        }
//        _refreshCount++;
//        [_table reloadData];
//        _footer.hidden = [array1 count]<WH_page_size;
//    }
//    if([aDownload.action isEqualToString:wh_act_CommentDel]){
//        [replys removeObjectAtIndex:_deleted];
//        
//        NSIndexPath* row = [NSIndexPath indexPathForRow:_deleted inSection:0];
//        NSArray* rows=[NSArray arrayWithObject:row];
//        [_table beginUpdates];
//        [_table deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
//        [_table endUpdates];
//    }
//}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [g_wait stop];
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* p = [[WH_JXUserObject alloc]init];
        [p WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = p;
        vc.wh_fromAddType = 6;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        [_pool addObject:vc];
    }
    if ([aDownload.action isEqualToString:wh_act_CommentList]) {

        int moreHeight = 23;
        if (array1.count < 20) {
            self.weibo.replyHeight -= moreHeight;
            self.wh_tableReply.tableFooterView = nil;
            moreHeight = 0;
        }else {
            self.wh_tableReply.tableFooterView = _moreLabel;
        }
        CGFloat height = 0;
        for(int i=0;i<[array1 count];i++){
            WeiboReplyData * reply=[[WeiboReplyData alloc]init];
            NSDictionary* dict = [array1 objectAtIndex:i];
            reply.type=1;
//            reply.addHeight = 60;
            [reply WH_getDataFromDict:dict];
            [reply setMatch];
            [self.weibo.replys addObject:reply];
            //计算加载更多增加的高度
            height += (reply.height +4);
        }

        self.weibo.replyHeight = self.weibo.replyHeight+height+moreHeight;
//        [self setWeibo:self.weibo];
        [self.wh_tableReply reloadData];
        
        [self.controller setupTableViewHeight:height tag:self.tag];
        
    }
    
//    if ([aDownload.action isEqualToString:wh_act_CommentDel]) {
//        [self.wh_tableReply reloadData];
//
////        [tableView reloadData];
//    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [g_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [g_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
//    [g_wait start:Localized(@"WaHu_WeiboCell_Sending")];
    [g_wait start:nil];
}

-(void)refresh{
    NSIndexPath* row = [NSIndexPath indexPathForRow:self.tag inSection:0];
    NSArray* rows=[NSArray arrayWithObject:row];
    self.controller.wh_refreshCellIndex = self.tag;
    [self.wh_tableViewP beginUpdates];
    [self.wh_tableViewP reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
    [self.wh_tableViewP endUpdates];

    self.controller.wh_refreshCellIndex = -1;
}

-(void)setReplys:(NSArray *)replys{
    _replys = [NSArray arrayWithArray:replys];
}

-(NSArray *)getReplys{
    return _replys;
}

- (void)pushLikeVC {
    JXLikeListViewController *likeListVC = [JXLikeListViewController alloc];
    likeListVC.wh_weibo = self.weibo;
    likeListVC = [likeListVC init];
    [g_navigation pushViewController:likeListVC animated:YES];
}

#pragma mark - 创建回复区的点赞区
-(void)createTableHead{
    if([self.weibo.praises count]<=0){
        self.wh_tableReply.tableHeaderView = nil;
        return;
    }

//    self.tableReply.tableHeaderView.hidden = NO;
    WeiboReplyData* p = [[WeiboReplyData alloc]init];
    p.type = reply_data_praise;
    p.body = [self.weibo getAllPraiseUsers];
#pragma mark 点赞Label长度
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(32, 4, self.wh_tableReply.frame.size.width - 40, 32)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = HEXCOLOR(0x576b95);
    label.font = sysFontWithSize(14);
    label.numberOfLines = 0;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLikeVC)];
//    [label addGestureRecognizer:tap];

    NSMutableArray *data = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.weibo.praises.count; i++){
        WeiboReplyData* praises = [self.weibo.praises objectAtIndex:i];
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getFriendWithUserId:praises.userId];
        [data addObject:user.remarkName.length? user.remarkName : praises.userNickName];
    }
    if (data.count > 20) {
        [data removeObjectAtIndex:data.count-1];
    }
//    [data addObject:[NSString stringWithFormat:@"%d%@",self.weibo.praiseCount,Localized(@"WeiboData_PerZan1")]];
    NSAttributedString * showAttString = [self getAttributeWith:data string:p.body orginFont:14 orginColor:HEXCOLOR(0x576b95) attributeFont:14 attributeColor:HEXCOLOR(0x576b95)];
    label.attributedText = showAttString;
    
    if ([self.weibo.userId isEqualToString:g_myself.userId]) {
        [label yb_addAttributeTapActionWithStrings:data tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            if (index == self.weibo.praises.count) {
                [self pushLikeVC];
            }else{
                WeiboReplyData *user = self.weibo.praises[index];
                WH_JXUserInfo_WHVC *userInfoVC = [WH_JXUserInfo_WHVC alloc];
                userInfoVC.wh_userId = user.userId;
                userInfoVC.wh_fromAddType = 6;
                userInfoVC = [userInfoVC init];
                [g_navigation pushViewController:userInfoVC animated:YES];
            }
        }];
    }

//    [label yb_addAttributeTapActionWithStrings:data tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
//        if (index == self.weibo.praises.count) {
//            [self pushLikeVC];
//        }else{
//            WeiboReplyData *user = self.weibo.praises[index];
//            WH_JXUserInfo_WHVC *userInfoVC = [WH_JXUserInfo_WHVC alloc];
//            userInfoVC.wh_userId = user.userId;
//            userInfoVC.wh_fromAddType = 6;
//            userInfoVC = [userInfoVC init];
//            [g_navigation pushViewController:userInfoVC animated:YES];
//        }
//    }];

//    [p getMatch];
    CGSize size = [p.body boundingRectWithSize:CGSizeMake(self.wh_tableReply.frame.size.width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(14)} context:nil].size;
    size.height += 5;

    _heightPraise = size.height+5;
    CGRect frame=label.frame;
    frame.size.height=size.height;
    label.frame=frame;

    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.wh_tableReply.frame.size.width, _heightPraise)];
    [v addSubview:label];

    UIImageView* iv;
    if([weibo.replys count]>0){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, _heightPraise-0.5, self.wh_tableReply.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [v addSubview:line];
    }

    iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 15, 15)];
    iv.image = [UIImage imageNamed:@"heart_praise"];
    [v addSubview:iv];
    
    self.wh_tableReply.tableHeaderView = v;
}

-(void)actionUser:(UIView*)sender{
    [_pool removeAllObjects];
    if([self.weibo.userId isEqualToString:CALL_CENTER_USERID])
        return;
//    [g_server getUser:self.weibo.userId toView:self];
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = self.weibo.userId;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    [_pool addObject:vc];
//    _userVc = nil;
//    _userVc = [userInfoVC alloc];
//    _userVc.userId = weibo.userId;
//    [_userVc init];
//    [g_window addSubview:_userVc.view];
}

- (void)getMoreData {
    self.weibo.page ++;
    [g_server WH_listCommentWithMsgId:self.weibo.messageId pageIndex:self.weibo.page pageSize:20 commentId:nil toView:self];
}

- (void)dealloc {
    NSLog(@"WH_WeiboCell.dealloc");
    //    if (_audioPlayer != nil) {
    [_wh_audioPlayer wh_stop];
    _wh_audioPlayer = nil;
    //    }
    [self.wh_tableReply removeObserver:self forKeyPath:@"contentSize" context:NULL];
}


- (NSAttributedString *)getAttributeWith:(id)sender
                                  string:(NSString *)string
                               orginFont:(CGFloat)orginFont
                              orginColor:(UIColor *)orginColor
                           attributeFont:(CGFloat)attributeFont
                          attributeColor:(UIColor *)attributeColor
{
    /*
     NSAttributedString * showAttString = [self getAttributeWith:data string:p.body orginFont:14 orginColor:HEXCOLOR(0x576b95) attributeFont:14 attributeColor:HEXCOLOR(0x576b95)];
     */
    __block  NSMutableAttributedString *totalStr = [[NSMutableAttributedString alloc] initWithString:string];
    [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:orginFont] range:NSMakeRange(0, string.length)];
    [totalStr addAttribute:NSForegroundColorAttributeName value:orginColor range:NSMakeRange(0, string.length)];
    
    if ([sender isKindOfClass:[NSArray class]]) {
        
        __block NSString *oringinStr = string;
        __weak typeof(self) weakSelf = self;
        
        [sender enumerateObjectsUsingBlock:^(NSString *  _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRange range = [oringinStr rangeOfString:str];
            [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
            if (idx == weakSelf.weibo.praises.count) {
                [totalStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
            }else {
                [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
            }
            oringinStr = [oringinStr stringByReplacingCharactersInRange:range withString:[weakSelf getStringWithRange:range]];
        }];
        
    }else if ([sender isKindOfClass:[NSString class]]) {
        
        NSRange range = [string rangeOfString:sender];
        
        [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
        [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
    }
    return totalStr;
}

- (NSString *)getStringWithRange:(NSRange)range
{
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < range.length ; i++) {
        [string appendString:@" "];
    }
    return string;
}



- (void)sp_checkNetWorking:(NSString *)mediaCount {
    NSLog(@"Check your Network");
}
@end
