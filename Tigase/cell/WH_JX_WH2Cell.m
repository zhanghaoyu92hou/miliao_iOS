//
//  WH_JX_WH2Cell.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JX_WH2Cell.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "AppDelegate.h"


@implementation WH_JX_WH2Cell
@synthesize title,bottomTitle,headImage,bage,userId;
@synthesize index,delegate,didTouch,lbTitle,lbBottomTitle,lbSubTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){

        self.selectionStyle  = UITableViewCellSelectionStyleBlue;
        //内容
        UIFont* f0 = sysFontWithSize(13);
        //名称
        UIFont * f1 = pingFangSemiBoldFontWithSize(15);
        //时间
        UIFont* timeFont = sysFontWithSize(11);
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 4, JX_SCREEN_WIDTH - g_factory.globelEdgeInset*2, 85.0f)];
        [self.contentView addSubview:_bgView];
        _bgView.backgroundColor = [UIColor whiteColor];
//        _bgView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.14].CGColor;
//        _bgView.layer.shadowOffset = CGSizeMake(0,1);
//        _bgView.layer.shadowOpacity = 1;
//        _bgView.layer.shadowRadius = 2;
        _bgView.layer.borderWidth = g_factory.cardBorderWithd;
        _bgView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        _bgView.layer.cornerRadius = 10;
        
        int n = 64;
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH, n)];
        v.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.selectedBackgroundView = v;

        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(SEPSRATOR_WIDTH,n-0.5,JX_SCREEN_WIDTH,0.5)];
        self.lineView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [self.contentView addSubview:self.lineView];
        
        
        _headImageView = [[WH_JXImageView alloc]init];
        _headImageView.userInteractionEnabled = NO;
        _headImageView.tag = index;
        _headImageView.wh_delegate = self;
        _headImageView.didTouch = @selector(WH_headImageDidTouch);
        _headImageView.frame = CGRectMake(12,20,45,45);
        [_headImageView headRadiusWithAngle:_headImageView.frame.size.width *0.5];
//        _headImageView.layer.borderWidth = 0.5;
//        _headImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [_bgView addSubview:self.headImageView];
        
        [g_notify addObserver:self selector:@selector(headImageNotification:) name:kGroupHeadImageModifyNotifaction object:nil];
        
        CGFloat headTitleInterval = 8.0f;
        
        CGFloat timeW = 115.0f; //时间标题宽度
        CGFloat timeRightOffset = 12.0f; //时间标题右侧间隔
        CGFloat titleTimeInterval = 25.0f; //昵称和时间标题间隔
        
        CGFloat replayW = 23.0f; //快捷回复宽
        CGFloat subTitleReplayInterval = 10.0; //聊天内容和快捷回复间隔
        
        CGFloat timeReplayVerticalInterval = 7.0f;
        
        //昵称Label
        JXLabel* lb;
        lb = [[JXLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame)+headTitleInterval, CGRectGetMinY(_headImageView.frame), CGRectGetWidth(_bgView.frame) -CGRectGetMaxX(_headImageView.frame) - timeRightOffset - timeW - titleTimeInterval - headTitleInterval, CGRectGetHeight(self.headImageView.frame) / 2)];
        lb.textColor = HEXCOLOR(0x3A404C);
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.font = f1;
        lb.tag = self.index;
//        lb.delegate = self.delegate;
//        lb.didTouch = self.didTouch;
        [_bgView addSubview:lb];
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(CGRectGetMaxX(_headImageView.frame)+headTitleInterval);
            make.top.offset(CGRectGetMinY(_headImageView.frame));
            make.height.offset(CGRectGetHeight(self.headImageView.frame) / 2);
            make.width.mas_lessThanOrEqualTo(CGRectGetWidth(_bgView.frame) -CGRectGetMaxX(_headImageView.frame) - timeRightOffset - timeW - titleTimeInterval - headTitleInterval);
        }];
//        [lb release];
        [lb setText:self.title];
        self.lbTitle = lb;
        
        _positionLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(self.lbTitle.frame)+2, CGRectGetMinY(self.lbTitle.frame), 20, 20) text:@"" font:sysFontWithSize(11) textColor:[UIColor whiteColor] backgroundColor:nil];
        _positionLabel.layer.backgroundColor = [UIColor orangeColor].CGColor;
        _positionLabel.layer.cornerRadius = 5;
        _positionLabel.textAlignment = NSTextAlignmentCenter;
        _positionLabel.hidden = YES;
        [_bgView addSubview:_positionLabel];
        if (self.positionTitle.length > 0){
            self.positionTitle = self.positionTitle;
        }
        
        //聊天消息Label
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.lbTitle.frame), CGRectGetMaxY(self.lbTitle.frame), CGRectGetWidth(_bgView.frame) - CGRectGetMinX(self.lbTitle.frame) - timeRightOffset - replayW - subTitleReplayInterval, CGRectGetHeight(self.headImageView.frame) / 2)];
        lb.textColor = HEXCOLOR(0x3A404C);
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.font = f0;
        [_bgView addSubview:lb];
//        [lb release];
        [lb setText:self.subtitle];
        self.lbSubTitle = lb;
        
        //时间Label
        self.timeLabel = [[JXLabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(_bgView.frame) - timeW - timeRightOffset, 20, timeW, 20)];
        self.timeLabel.textColor = HEXCOLOR(0xBAC3D5);
        self.timeLabel.userInteractionEnabled = NO;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = timeFont;
        [_bgView addSubview:self.timeLabel];
//        [self.timeLabel release];
        [self.timeLabel setText:self.bottomTitle];
        self.lbBottomTitle = self.timeLabel;
        
        //快捷回复
        self.replayView = [[WH_JXImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_bgView.frame) - replayW - timeRightOffset, CGRectGetMaxY(_timeLabel.frame)+timeReplayVerticalInterval, replayW+timeRightOffset, 45)];
        self.replayView.hidden = YES;
        self.replayView.didTouch = @selector(WH_didQuickReply);
        self.replayView.wh_delegate = self;
        [_bgView addSubview:self.replayView];
        _replayImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
        _replayImgV.image = [UIImage imageNamed:@"msg_replay_icon"];
        [self.replayView addSubview:_replayImgV];
        
        //置顶
        self.stickView = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.stickView.right = self.timeLabel.right;
        self.stickView.centerY = self.lbSubTitle.centerY;
        self.stickView.hidden = YES;
        [_bgView addSubview:self.stickView];
        _stickImgV = [[UIImageView alloc] initWithFrame:self.stickView.bounds];
        _stickImgV.image = [UIImage imageNamed:@"msg_stick_icon"];
        [self.stickView addSubview:_stickImgV];
        
        //免打扰图标
        self.notPushImageView = [[WH_JXImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-25-15-10, 64-25-6, 15, 15)];
        self.notPushImageView.image = [UIImage imageNamed:@"msg_not_push"];
        self.notPushImageView.hidden = YES;
        [_bgView addSubview:self.notPushImageView];
        [self.notPushImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.lbTitle.mas_right).offset(5);
            make.centerY.equalTo(self.lbTitle);
        }];

        CGFloat badgeWH = g_factory.badgeWidthHeight;
        
        _bageNumber  = [[WH_JXBadgeView alloc] initWithFrame:CGRectMake(45-27, 45-25, badgeWH, badgeWH)];
        _bageNumber.image = nil;
        _bageNumber.wh_delegate = delegate;
        _bageNumber.wh_didDragout = self.didDragout;
        _bageNumber.userInteractionEnabled = YES;
        _bageNumber.wh_lb.font = sysFontWithSize(12);
        _bageNumber.layer.borderColor = [UIColor whiteColor].CGColor;
        _bageNumber.layer.borderWidth = 1;
        _bageNumber.layer.cornerRadius = CGRectGetHeight(_bageNumber.frame) / 2.0f;
//        [self.replayView addSubview:_bageNumber];
        [_bgView addSubview:_bageNumber];
//        [_headImageView addSubview:_bageNumber];
//        [_bageNumber mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_headImageView).offset(CGRectGetWidth(_headImageView.bounds) / 2 - (badgeWH / 2 - 3));
//            make.centerY.equalTo(_headImageView).offset( - CGRectGetHeight(_headImageView.bounds) / 2 + badgeWH / 2 - 3);
//            make.right.offset(-10);
//            make.width.height.offset(badgeWH);
//            make.right.top.equalTo(_replayImgV);
//        }];
        _bageNumber.center = CGPointMake(_headImageView.center.x+CGRectGetWidth(_headImageView.bounds) / 2 - (badgeWH / 2 - 3), _headImageView.center.y- CGRectGetHeight(_headImageView.bounds) / 2 + badgeWH / 2 - 3);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(WH_didQuickReply)];
        [_bageNumber addGestureRecognizer:tap];

//        [bageNumber release];
        self.bage = bage;
        
//        [self saveBadge:bage withTitle:self.title];
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"WH_JX_WH2Cell.dealloc");
//    [self.bageDict removeAllObjects];
//    self.bageDict = nil;
    
    [g_notify removeObserver:self name:kGroupHeadImageModifyNotifaction object:nil];
    self.title = nil;
    self.subtitle = nil;
    self.bottomTitle = nil;
    self.headImage = nil;
    self.bage = nil;
    self.userId = nil;
    
    self.lbSubTitle = nil;
    self.lbTitle = nil;
    self.lbBottomTitle = nil;
//    self.bageDict = nil;
//    [_headImageView release];
//    [super dealloc];
}


- (void)setIsNotPush:(BOOL)isNotPush {
    _isNotPush = isNotPush;
    
    //改变角标样式
    if (_isNotPush) {
        //免打扰
        _bageNumber.layer.borderColor = HEXCOLOR(0x8391B0).CGColor;
        _bageNumber.backgroundColor = HEXCOLOR(0xA9B3CB);
    } else {
        //关闭免打扰
        _bageNumber.layer.borderColor = HEXCOLOR(0xFFFFFF).CGColor;
        _bageNumber.backgroundColor = g_factory.badgeBgColor;
    }
    
    self.notPushImageView.hidden = !isNotPush;
}

- (void)setIsMsgVCCome:(BOOL)isMsgVCCome { // 只有WH_JXMsg_WHViewController显示回复按钮
    _isMsgVCCome = isMsgVCCome;
    self.replayView.hidden = !isMsgVCCome;
    // 这里获取需要userid   一定要在cell赋值userid 之后再调用
    //
    _replayImgV.alpha = 1-([self.userId intValue] == [WAHU_TRANSFER intValue]);
    
}


- (void)WH_didQuickReply {
    if ([self.userId intValue] == [WAHU_TRANSFER intValue]) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:self.didReplay]) {
        [self.delegate performSelectorOnMainThread:self.didReplay withObject:self waitUntilDone:YES];
    }
}

//将所有Cell的badge存到沙盒里
//- (void)saveBadge:(NSString*)badg withTitle:(NSString*)titl{
//
//    if (bage == nil || titl == nil) {
//        return;
//    }
//    NSArray * path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString * cacherDir = [[path objectAtIndex:0] stringByAppendingPathComponent:@"cellBage.txt"];
//    
//    NSData * data = [[NSData alloc]initWithContentsOfFile:cacherDir];
//    
//    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
//    
//    self.bageDict = [unarchiver decodeObjectForKey:@"dict"];
//    
//    if (self.bageDict == nil) {
//        self.bageDict = [[NSMutableDictionary alloc]init];
//    }
//    
//    [self.bageDict setObject:badg forKey:titl];
//    
//    NSMutableData * muData = [[NSMutableData alloc]init];
//    
//    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:muData];
//    
//    [archiver encodeObject:self.bageDict forKey:@"dict"];
//    
//    [archiver finishEncoding];
//
//    [muData writeToFile:cacherDir atomically:YES];
//}

//- (void)awakeFromNib
//{
//    // Initialization code
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:selected animated:animated];

//    if (selected) {
//
//        _bgView.backgroundColor = HEXCOLOR(0xe4e4e4);
//    }
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        _bgView.backgroundColor = HEXCOLOR(0xe4e4e4);
        
    }else{
        
        _bgView.backgroundColor = _isStick ? HEXCOLOR(0xF8F8F8) : [UIColor whiteColor];
        
    }
}

-(void)WH_headImageDidTouch{
    if (self.delegate && [self.delegate respondsToSelector:didTouch]) {
        [self.delegate performSelectorOnMainThread:didTouch withObject:self.dataObj waitUntilDone:YES];
    }
}
- (void)getHeadImage{
    if(headImage){
        if([headImage rangeOfString:@"http://"].location == NSNotFound)
            self.headImageView.image = [UIImage imageNamed:headImage];
        else
            [g_server WH_getImageWithUrl:headImage imageView:self.headImageView];
    }
    [g_server WH_getHeadImageSmallWIthUserId:userId userName:self.title imageView:self.headImageView];
}

-(void)setBage:(NSString *)s{
//    bageNumber.hidden = [s intValue]<=0;
//    _replayImgV.hidden = [s intValue] > 0;
    _bageNumber.wh_badgeString = s;
    if ([s intValue] >= 10 && [s intValue] <= 99) {
        _bageNumber.wh_lb.font = sysFontWithSize(12);
    }else if ([s intValue] > 0 && [s intValue] < 10) {
        _bageNumber.wh_lb.font = sysFontWithSize(13);
    }else if([s intValue] > 99){
        _bageNumber.wh_lb.font = sysFontWithSize(9);
    }
    bage = s;
}

-(void)setForTimeLabel:(NSString *)s{
    self.bottomTitle = s;
//    self.bottomTitle = [s retain];
    self.timeLabel.text = s;
}

-(void)setTitle:(NSString *)s{
//    title = [s retain];
    title = s;
    self.lbTitle.text = s;
}
-(void)setPositionTitle:(NSString *)positionTitle{
    _positionTitle = positionTitle;
    if (positionTitle.length > 0) {
        _positionLabel.text = positionTitle;
        _positionLabel.hidden = NO;
        CGSize positionSize =[positionTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}];
        if (positionSize.width >150)
            positionSize.width = 150;
        CGSize titleSize = [self.lbTitle.text sizeWithAttributes:@{NSFontAttributeName: self.lbTitle.font}];
        _positionLabel.frame = CGRectMake(self.lbTitle.frame.origin.x + titleSize.width + 2, CGRectGetMinY(self.lbTitle.frame) + 5, positionSize.width+4, positionSize.height);
        _positionLabel.center = CGPointMake(_positionLabel.center.x, 54 / 2);
    }
}

- (void)setSuLabel:(NSString *)s{
//    subtitle = [s retain];
    _subtitle = s;
    self.lbSubTitle.attributedText = [self setContentLabelStr:s];
}
-(void)setSubtitle:(NSString *)subtitle{
    _subtitle = subtitle;
    self.lbSubTitle.attributedText = [self setContentLabelStr:subtitle];
}
- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array {
    
    NSRange range=[message rangeOfString: @"["];
    
    NSRange range1=[message rangeOfString: @"]"];
    
    
    // 动画过滤
    if ([message isEqualToString:[NSString stringWithFormat:@"[%@]",Localized(@"emojiVC_Emoji")]]) {
        [array addObject:message];
        return;
    }
    
    
    //判断当前字符串是否还有表情的标志。
    
    if (range.length>0 && range1.length>0 && range1.location > range.location) {
        
        if (range.location > 0) {
            
            [array addObject:[message substringToIndex:range.location]];
            
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            
            NSString *str=[message substringFromIndex:range1.location+1];
            
            [self getMessageRange:str :array];
            
        }else {
            
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            
            //排除文字是“”的
            
            if (![nextstr isEqualToString:@""]) {
                
                [array addObject:nextstr];
                
                NSString *str=[message substringFromIndex:range1.location+1];
                
                [self getMessageRange:str :array];
                
            }else {
                
                return;
                
            }
            
        }
        
    } else if (message != nil) {
        
        [array addObject:message];
        
    }
    
}
- (NSAttributedString *) setContentLabelStr:(NSString *) str {
    NSMutableArray *contentArray = [NSMutableArray array];
    
    [self getMessageRange:str :contentArray];
    
    NSMutableAttributedString *strM = [[NSMutableAttributedString alloc] init];
    
    NSInteger count = contentArray.count;
    if (contentArray.count > 15) {
        count = 15;
    }
    
    for (NSInteger i = 0; i < count; i ++) {
        
        NSString *object = contentArray[i];
        
//        NSLog(@"%@",object);
        BOOL flag = NO;
        if ([object hasSuffix:@"]"]&&[object hasPrefix:@"["]) {
            
            //如果是表情用iOS中附件代替string在label上显示
            
            NSTextAttachment *imageStr = [[NSTextAttachment alloc]init];
            NSString *imageShortName = [object substringWithRange:NSMakeRange(1, object.length - 2)];
            for (NSInteger i = 0; i < g_constant.emojiArray.count; i ++) {
                NSDictionary *dict = g_constant.emojiArray[i];
                NSString *imageName = dict[@"english"];
                if ([imageName isEqualToString:imageShortName]) {
                    imageStr.image = [UIImage imageNamed:dict[@"filename"]];
                    flag = YES;
                    break;
                }
            }
            if (!flag) {
                [strM appendAttributedString:[[NSAttributedString alloc] initWithString:object]];
                
                NSRange range = [object rangeOfString:Localized(@"JX_Draft")];
                [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                
                range = [object rangeOfString:Localized(@"JX_Someone@Me")];
                [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                continue;
            }
            //            imageStr.image = [UIImage imageNamed:[object substringWithRange:NSMakeRange(1, object.length - 2)]];
            
            //这里对图片的大小进行设置一般来说等于文字的高度
            
            CGFloat height = self.lbSubTitle.font.lineHeight + 1;
            
            imageStr.bounds = CGRectMake(0, -4, height, height);
            
            NSAttributedString *attrString = [NSAttributedString attributedStringWithAttachment:imageStr];
            
            [strM appendAttributedString:attrString];
            
        }else{
            
            //如果不是表情直接进行拼接

            [strM appendAttributedString:[[NSAttributedString alloc] initWithString:object]];
            
            NSRange range = [object rangeOfString:Localized(@"JX_Draft")];
            [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            
            range = [object rangeOfString:Localized(@"JX_Someone@Me")];
            [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        }
        
    }
    
    return strM;
}


-(void)headImageNotification:(NSNotification *)notification{
    NSDictionary * groupDict = notification.object;

    NSString * roomJid = groupDict[@"roomJid"];
    if ([roomJid isEqualToString:self.userId]) {
        UIImage * hImage = groupDict[@"groupHeadImage"];
        self.headImageView.image = hImage;
    }
}

-(void)WH_headImageViewImageWithUserId:(NSString *)userId roomId:(NSString *)roomIdStr {

    if (roomIdStr != nil) {

        [g_server WH_getRoomHeadImageSmallWithUserId:userId roomId:roomIdStr imageView:self.headImageView];
//        }
    }else{
        if(headImage){
            if([headImage rangeOfString:@"http://"].location == NSNotFound)
                self.headImageView.image = [UIImage imageNamed:headImage];
            else
                [g_server WH_getImageWithUrl:headImage imageView:self.headImageView];
        }
        [g_server WH_getHeadImageSmallWIthUserId:self.userId userName:self.title imageView:self.headImageView];
    }
}

- (void)setIsSmall:(BOOL)isSmall {
    _isSmall = isSmall;
    if (!isSmall) {
        
//        _headImageView.frame = CGRectMake(12,20,45,45);
//        [_headImageView headRadiusWithAngle:_headImageView.frame.size.width*0.5];
//        self.lbTitle.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)+10, CGRectGetMinY(_headImageView.frame), JX_SCREEN_WIDTH - 100 -CGRectGetMaxX(_headImageView.frame)-10, CGRectGetHeight(self.headImageView.frame) / 2);
//        self.lineView.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)+14,64-0.5,JX_SCREEN_WIDTH,0.5);
    }else {
        
        _headImageView.frame = CGRectMake(16,5,42,42);
        [_headImageView headRadiusWithAngle:_headImageView.frame.size.width *0.5];
        self.lbTitle.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)+14, 10, JX_SCREEN_WIDTH - 100 -CGRectGetMaxX(_headImageView.frame)-14, 54 - 20);
        self.lineView.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)+14,54-0.5,JX_SCREEN_WIDTH,0.5);
    }
}
-(void)setIsStick:(BOOL)isStick {
    _isStick = isStick;
    self.stickView.hidden = !isStick;
}


@end
