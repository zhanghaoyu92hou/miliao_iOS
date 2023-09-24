//
//  WH_Collect_WHTableViewCell.m
//  Tigase
//
//  Created by Apple on 2019/7/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_Collect_WHTableViewCell.h"

#import "WH_HBCoreLabel.h"
#import "UIImageView+WH_FileType.h"

#define Table_Width JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset

@implementation WH_Collect_WHTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //收藏的为文本
        self.wh_hcLabel = [[WH_HBCoreLabel alloc] initWithFrame:CGRectMake(20, 12, Table_Width - 40, 40)];
        [self.wh_hcLabel setTextColor:HEXCOLOR(0x3A404C)];
        [self.wh_hcLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        [self.wh_hcLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.wh_hcLabel setNumberOfLines:0];
        [self.contentView addSubview:self.wh_hcLabel];
        
        //图片
        self.wh_imageContent = [[UIView alloc] initWithFrame:CGRectMake(20, 12, 68, 68)];
//        [self.wh_imageContent setBackgroundColor:[UIColor redColor]];
        [self.contentView addSubview:self.wh_imageContent];
        
        //音频
        self.wh_audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.wh_imageContent frame:CGRectNull isLeft:YES isCollect:YES];
        self.wh_audioPlayer.wh_isOpenProximityMonitoring = YES;
        
        //文件
        self.wh_fileView = [[UIView alloc] initWithFrame:CGRectMake(20, 12, JX_SCREEN_WIDTH -40, 100)];
        self.wh_fileView.backgroundColor = HEXCOLOR(0xffffff);
        UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileUrlCopy)];
        [self.wh_fileView addGestureRecognizer:tapges];
        [self.contentView addSubview:self.wh_fileView];
        self.wh_fileView.hidden = YES;
        
        if(!_wh_typeView){
            _wh_typeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 60, 60)];
            _wh_typeView.layer.cornerRadius = 3;
            _wh_typeView.layer.masksToBounds = YES;
            //        _typeView.backgroundColor = [UIColor redColor];
            [self.wh_fileView addSubview:_wh_typeView];
        }
        
        if(!_wh_fileTitleLabel){
            _wh_fileTitleLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:@"--.--" font:sysFontWithSize(15) textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
            _wh_fileTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            _wh_fileTitleLabel.frame = CGRectMake(CGRectGetMaxX(_wh_typeView.frame) +5, 0, CGRectGetWidth(self.wh_fileView.frame)-CGRectGetMaxX(_wh_typeView.frame)-15, 25);
            _wh_fileTitleLabel.center = CGPointMake(_wh_fileTitleLabel.center.x, _wh_typeView.center.y);
            _wh_fileTitleLabel.textAlignment = NSTextAlignmentLeft;
            [self.wh_fileView addSubview:_wh_fileTitleLabel];
        }
        
        //收藏名称,时间
        self.wh_nameAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, Table_Width , 15)];
        [self.wh_nameAndTimeLabel setTextColor:HEXCOLOR(0x969696)];
        [self.wh_nameAndTimeLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 11]];
        [self.contentView addSubview:self.wh_nameAndTimeLabel];
        
        //删除
        self.wh_delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.wh_delBtn setFrame:CGRectMake(Table_Width - 20 - 40, 12, 40, 40)];
//        [self.delBtn setBackgroundColor:[UIColor redColor]];
        [self.wh_delBtn setTitle:Localized(@"JX_Delete") forState:UIControlStateNormal];
        [self.wh_delBtn setTitle:Localized(@"JX_Delete") forState:UIControlStateHighlighted];
        [self.wh_delBtn setTitleColor:HEXCOLOR(0x969696) forState:UIControlStateNormal];
        [self.wh_delBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 11]];
        [self.contentView addSubview:self.wh_delBtn];
        [self.wh_delBtn addTarget:self action:@selector(delBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setWh_weibo:(WeiboData *)value {
    value.willDisplay = YES;
    _wh_weibo = value;
    [self prepare];
    
    self.linesLimit = self.wh_weibo.linesLimit;
    
    if (value.type == weibo_dataType_text) {
        [self.wh_imageContent setHidden:YES];
        
        [self.wh_hcLabel WH_registerCopyAction];
        self.wh_hcLabel.wh_linesLimit=self.wh_weibo.linesLimit;
        __weak WH_HBCoreLabel * wcontent=self.wh_hcLabel;
        MatchParser* match=[self.wh_weibo getMatch:^(MatchParser *parser,id data) {
            if (wcontent) {
                WeiboData * weibo=(WeiboData*)data;
                if (weibo.willDisplay) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wcontent.wh_match=parser;
                    });
                }
            }
        } data:self.wh_weibo];
        self.wh_hcLabel.wh_match=match;
        
       if(self.wh_weibo.numberOfLineLimit<self.wh_weibo.numberOfLinesTotal) {
           if (self.wh_weibo.linesLimit) {
               self.wh_hcLabel.frame=CGRectMake(20, 12, Table_Width - 40,self.wh_weibo.heightOflimit);
           }else {
               self.wh_hcLabel.frame=CGRectMake(20, 12, Table_Width - 40,self.wh_weibo.height);
           }
        }else{
            self.wh_hcLabel.frame=CGRectMake(20, 12, Table_Width - 40 ,self.wh_weibo.height);
        }
        
        self.wh_nameAndTimeLabel.frame = CGRectMake(20, self.wh_hcLabel.frame.origin.y + self.wh_hcLabel.frame.size.height + 8, Table_Width - 40 - 40 , 40);
        self.wh_delBtn.frame = CGRectMake(Table_Width - 20 - 40, self.wh_hcLabel.frame.origin.y + self.wh_hcLabel.frame.size.height + 8, 40, 40);
    }else if(value.type == weibo_dataType_image){
        [self addImagesWithFiles:0];
        
        self.wh_nameAndTimeLabel.frame = CGRectMake(20, self.wh_imageContent.frame.origin.y + self.wh_imageContent.frame.size.height + 8, Table_Width , 40);
        self.wh_delBtn.frame = CGRectMake(Table_Width - 20 - 40, self.wh_imageContent.frame.origin.y + self.wh_imageContent.frame.size.height + 8, 40, 40);
    }else {
        if (value.audios.count > 0) {
            [self setupAudioPlayer:0];
        }else if (value.videos.count >0) {
            [self addImageForAudioVideo:0];
        }else if ([value.files count]>0) {
            self.wh_fileView.hidden = NO;
            self.wh_fileView.frame = CGRectMake(20, 12, Table_Width -40, 100);
            CGRect  frame=self.wh_fileView.frame;
//            frame.origin.y=self.hcLabel.frame.origin.y+self.hcLabel.frame.size.height+5;
            //        frame.size.height=self.weibo.imageHeight;
            self.wh_fileView.frame=frame;
            
            ObjUrlData * url= [value.files firstObject];
            NSString *urlName;
            if (url.name.length > 0) {
                urlName = url.name;
            }else {
                urlName = [url.url lastPathComponent];
            }
            _wh_fileTitleLabel.text = urlName;
            NSString * fileExt = [urlName pathExtension];
            NSInteger fileType = [self fileTypeWithExt:fileExt];
            
            [self.wh_typeView setFileType:fileType];
            
            self.wh_nameAndTimeLabel.frame = CGRectMake(20, self.wh_fileView.frame.origin.y + self.wh_fileView.frame.size.height -12, Table_Width , 40);
            self.wh_delBtn.frame = CGRectMake(Table_Width - 20 - 40, self.wh_fileView.frame.origin.y + self.wh_fileView.frame.size.height -12, 40, 40);
            
        }else{
            self.wh_fileView.frame = CGRectZero;
            self.wh_fileView.hidden = YES;
        }
    }
    
    NSString *createTime = [TimeUtil getTimeStrStyle1:self.wh_weibo.createTime];
    [self.wh_nameAndTimeLabel setText:[NSString stringWithFormat:@"%@  %@" ,self.wh_weibo.userNickName?:@"" ,createTime]];
}

-(void)delBtnAction:(WeiboData*)cellData{
//    [self.controller delBtnAction:cellData];
    if (self.delegate) {
        [self.delegate collectDelect:self.wh_weibo];
    }
}
#pragma mark --------------依据图片数量设置大小-----------------
-(void)addImagesWithFiles:(float)offset
{
    //判断说说是否有图片
    if(self.wh_weibo.imageHeight==0){
        self.wh_imageContent.hidden=YES;
        return;
    }else{
        if (self.wh_weibo.larges.count > 1) {
            CGRect  frame=self.wh_imageContent.frame;
            
            frame.origin.y=12;
            frame.size.height=self.wh_weibo.imageHeight;
            self.wh_imageContent.frame=frame;
        }else{
            self.wh_imageContent.frame= CGRectMake(20, 12, 68, 68);
        }
        self.wh_imageContent.hidden = NO;
        
    }
    __weak WH_Collect_WHTableViewCell * wself=self;
    __weak WeiboData * wweibo=self.wh_weibo;
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (wself&&wweibo.willDisplay&&wweibo) {
            __strong WH_Collect_WHTableViewCell * sself=wself;
            __strong WeiboData * sweibo=wweibo;
            dispatch_async(dispatch_get_main_queue(), ^{
                WH_HBShowImageControl * control=[[WH_HBShowImageControl alloc]initWithFrame: sself.wh_imageContent.bounds];
                control.wh_controller=sself.wh_controller;
                control.wh_smallTag=THUMB_WEIBO_SMALL_1;
                //                control.smallTag=THUMB_WEIBO_BIG;
                control.wh_bigTag=THUMB_WEIBO_BIG;
                control.wh_larges = sweibo.larges;
                control.wh_isCollect = YES;
                //缩略图显示为原图
                //                [control setImagesFileStr:sweibo.smalls];
                [control WH_setImagesFileStr:sweibo.larges];
                
                [sself.wh_imageContent addSubview:control];
                control.delegate=sself;
            });
        }
    });
}

#pragma -mark 委托方法
-(void)WH_showImageControlFinishLoad:(WH_HBShowImageControl*)control
{
    CGRect frame=self.wh_imageContent.frame;
    frame.size.height=control.frame.size.height;
    self.wh_imageContent.frame= CGRectMake(20, 12, 68, 68);
}

- (void)setupAudioPlayer:(float)offset {
    
    if (!_wh_audioPlayer) {
        _wh_audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.wh_imageContent frame:CGRectNull isLeft:YES isCollect:YES];
    }
    if (!_wh_audioPlayer) {
        _wh_audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.wh_imageContent frame:CGRectNull isLeft:YES];
    }
    
    ObjUrlData *data = (ObjUrlData *)[self.wh_weibo.audios firstObject];
    
    if([data.timeLen intValue] <= 0)
        data.timeLen  = @1;
    int w = (JX_SCREEN_WIDTH-HEAD_SIZE-INSETS*2-70)/30;
//    w = 45 + [data.timeLen intValue];
//    w = 70+w*[data.timeLen intValue];
//    if(w<70)
//        w = 70;
//    if(w>200)
        w = 200;
    
    self.wh_imageContent.hidden=NO;
    CGRect  frame=self.wh_imageContent.frame;
//    frame.origin.y = 12;
    frame.size = CGSizeMake(w, 45);
    self.wh_imageContent.frame=CGRectMake(self.wh_imageContent.frame.origin.x, frame.origin.y, self.wh_imageContent.frame.size.width, frame.size.height);
    self.wh_imageContent.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startAudioPlay)];
    [self.wh_imageContent addGestureRecognizer:tap];
    _wh_audioPlayer.wh_frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _wh_audioPlayer.wh_audioFile = [self.wh_weibo getMediaURL];
    _wh_audioPlayer.wh_isCollect = YES;
//    _audioPlayer.voiceBtn.image = [UIImage imageNamed:@"WH_Collect_Audio"];
    _wh_audioPlayer.wh_timeLen = [data.timeLen intValue];
    _wh_audioPlayer.wh_timeLenView.textColor = HEXCOLOR(0x3A404C);
    _wh_audioPlayer.wh_timeLenView.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    _wh_audioPlayer.wh_voiceBtn.backgroundColor = [UIColor whiteColor];
    
    NSString *createTime = [TimeUtil getTimeStrStyle1:self.wh_weibo.createTime];
    [self.wh_nameAndTimeLabel setText:[NSString stringWithFormat:@"%@  %@" ,self.wh_weibo.userNickName?:@"" ,createTime]];
    
    self.wh_nameAndTimeLabel.frame = CGRectMake(20, self.wh_imageContent.frame.origin.y + self.wh_imageContent.frame.size.height + 8, Table_Width , 40);
    self.wh_delBtn.frame = CGRectMake(Table_Width - 20 - 40, self.wh_imageContent.frame.origin.y + self.wh_imageContent.frame.size.height + 8, 40, 40);
}

//获取头像当音视频背景
-(void)addImageForAudioVideo:(float)offset
{
    NSString* imageUrl=nil;
    if([self.wh_weibo.larges count]>0)
        imageUrl = ((ObjUrlData*)[self.wh_weibo.larges objectAtIndex:0]).url;
    else
        imageUrl = [g_server WH_getHeadImageOUrlWithUserId:self.wh_weibo.userId];
    
    self.wh_imageContent.hidden=NO;
    CGRect  frame = self.wh_imageContent.frame;
//    frame.origin.y = 12;
//    frame.size.height = self.weibo.imageHeight;
    self.wh_imageContent.frame=frame;
    
    //
    self.wh_imagePlayer = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, 0, 68, 68)];
    self.wh_imagePlayer.wh_changeAlpha = NO;
    self.wh_imagePlayer.didTouch = @selector(doNotThing);
    self.wh_imagePlayer.wh_delegate = self.wh_controller;
    [self.wh_imageContent addSubview:self.wh_imagePlayer];
    
    
    [self.wh_imagePlayer sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"avatar_normal"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        self.wh_imagePlayer.contentMode = UIViewContentModeScaleAspectFit;
        
        if(self.wh_weibo.isVideo){
            
            [FileInfo getFullFirstImageFromVideo:[self.wh_weibo getMediaURL] imageView:self.wh_imagePlayer];
            UIButton *pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 68, 68)];
            pauseBtn.center = CGPointMake(self.wh_imagePlayer.frame.size.width/2,self.wh_imagePlayer.frame.size.height/2);
            [pauseBtn setImage:[UIImage imageNamed:@"icon_collectionVideoPlay"] forState:UIControlStateNormal];
            [pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
            [self.wh_imagePlayer addSubview:pauseBtn];
        }else{
            
        }
    }];
    
    self.wh_nameAndTimeLabel.frame = CGRectMake(20, self.wh_imageContent.frame.origin.y + self.wh_imageContent.frame.size.height + 8, Table_Width , 40);
    self.wh_delBtn.frame = CGRectMake(Table_Width - 20 - 40, self.wh_imageContent.frame.origin.y + self.wh_imageContent.frame.size.height + 8, 40, 40);
    
    
}

- (void)startAudioPlay {
    [_wh_audioPlayer wh_switch];
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

-(void) prepare
{
    [super prepareForReuse];
    for(UIView * view in self.wh_imageContent.subviews)
        [view removeFromSuperview];
    UIView * view=[self.contentView viewWithTag:191];
    if(view){
        [view removeFromSuperview];
    }
    view=[self.contentView viewWithTag:192];
    if(view){
        [view removeFromSuperview];
    }
    self.linesLimit=NO;
}

#pragma -mark 点击播放视频
- (void)showTheVideo {
    [self.delegate WH_WeiboCell:self clickVideoWithIndex:self.tag];
}
- (void)doNotThing{
    
}

//复制信息到剪贴板
- (void)fileUrlCopy{
    if (self.delegate) {
        [self.delegate fileAction:self.wh_weibo];
    }
//    [self.controller fileAction:self.weibo];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}




- (void)sp_getLoginState {
    NSLog(@"Check your Network");
}
@end
