//
//  WH_JXBaseChat_WHCell.m
//  wahu_im
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXBaseChat_WHCell.h"
#import "WH_JXImageView.h"
#import "WH_RoomData.h"


#define CER_HEIGHT 3  // 管理员边框和头像的距离

@interface WH_JXBaseChat_WHCell ()
/*******************************阅后即焚使用********************************/
@property (nonatomic ,strong) UIView *readDeleteView;//阅后即焚view
//@property (nonatomic ,strong) UIView *bottomView;//阅后即焚使用
//@property (nonatomic ,strong) UIImageView *clockImageV;
//@property (nonatomic ,strong) UIButton *settingBtn;

@property (nonatomic, assign) NSInteger timerIndex;
@property (nonatomic, assign) NSInteger timerTotal;

@property (nonatomic,  copy) void(^block)(WH_JXMessageObject *msg);
@end


static double g_timeSend=0;

@implementation WH_JXBaseChat_WHCell
//没有xib的初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _bubbleBg = [[UIButton alloc] init];
    [self.contentView addSubview:self.bubbleBg];
//    [self setViewShadow:self.bubbleBg];
    _bubbleBg.layer.cornerRadius = 4;
    [_bubbleBg addTarget:self action:@selector(didTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor clearColor];

    [self creatBaseUI];
    [self creatUI];
    
    [g_notify addObserver:self selector:@selector(notifyDrawIsReceive:) name:kMsgDrawIsReceiveNotifaction object:nil];//
    [g_notify addObserver:self selector:@selector(updateLoadFileProgress:) name:kUploadFileProgressNotifaction object:nil];
    self.layer.masksToBounds = YES;
    
    //添加长按手势
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doLongPress:)];
    longPress.minimumPressDuration = 1;
    [self.contentView addGestureRecognizer:longPress];
    
    return self;
}
//有xib的初始化
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _bubbleBg = [[UIButton alloc]init];
    [self.contentView addSubview:self.bubbleBg];
//    [self setViewShadow:self.bubbleBg];
    _bubbleBg.layer.cornerRadius = 4;
    [_bubbleBg addTarget:self action:@selector(didTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor clearColor];
    [self creatBaseUI];
    [self creatUI];
}

- (void)setViewShadow:(UIView *)view{
    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.14].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,1);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 6;
}

//子类创建对应UI
- (void)creatUI{
    
}
//子类根据数据显示界面
-(void)setCellData{    
    _readImage.hidden = YES;
    memberData *data = [[memberData alloc] init];
    data.roomId = self.room.roomId;
    data = [data getCardNameById:self.msg.fromUserId];
    WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
    allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
    memberData *userData = [_room getMember:[NSString stringWithFormat:@"%ld",data.userId]];
    memberData *data1 = [_room getMember:MY_USER_ID];
    if ([data1.role intValue] == 1) {
    //        self.nicknameLabel.text = data.lordRemarkName.length > 0  ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName.length > 0  ? data.userNickName : self.msg.fromUserName;
            self.nicknameLabel.text = data.lordRemarkName.length > 0  ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : userData.userNickName;
            if (!allUser && !userData) {
            self.nicknameLabel.text =  data.userNickName.length > 0  ? data.userNickName : self.msg.fromUserName;;
            }
        }else {
    //        self.nicknameLabel.text = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName.length > 0  ? data.userNickName : self.msg.fromUserName;
            self.nicknameLabel.text = allUser.remarkName.length > 0  ? allUser.remarkName : userData.userNickName;
            if (!allUser && !userData) {
            self.nicknameLabel.text =  data.userNickName.length > 0  ? data.userNickName : self.msg.fromUserName;;
            }
    //        self.nicknameLabel.text = self.msg.fromUserName;

        }
    if (!_room.allowSendCard && [data1.role intValue] != 1 && [data1.role intValue] != 2) {
        if (GroupMemberShowPlaceholderString) {
            self.nicknameLabel.text = [self.nicknameLabel.text substringToIndex:[self.nicknameLabel.text length]-1];
            self.nicknameLabel.text = [self.nicknameLabel.text stringByAppendingString:@"*"];
        }
    }
    
    if (self.msg.isGroup && !self.msg.isMySend) {
        self.nicknameLabel.hidden = NO;
    }else {
        self.nicknameLabel.hidden = YES;
    }
    memberData *roleData = [_room getMember:self.msg.fromUserId];
    NSString *imageStr = @"";
    if ([roleData.role intValue] == 1) {
        imageStr = @"icon_certification_owner";
    }else if ([roleData.role intValue] == 2) {
        imageStr = @"icon_certification";
    }
    if (MainHeadType && !IsStringNull(imageStr)) { //头像圆形
        _cerImgView.image = [UIImage imageNamed:imageStr];
    }else{ //头像方形
        imageStr = [imageStr stringByAppendingString:@"_1"];
        _cerImgView.image = [UIImage imageNamed:imageStr];
    }
    
    
    
    //用户等级
    if ([roleData.vip integerValue] != 0)  {
        [self.headImage addSubview:self.gradeImgView];
        NSString *imageName = @"";
        if (roleData.vip.integerValue == 10) {
            imageName = [NSString stringWithFormat:@"grade_%@", roleData.vip];
        }else {
            imageName = [NSString stringWithFormat:@"grade_0%@", roleData.vip];
        }
        self.gradeImgView.image = [UIImage imageNamed:imageName];
    }

    if (self.msg.isGroup) {
        if ([roleData.role intValue] == 1 || [roleData.role intValue] == 2) {
            self.cerImgView.hidden = NO;
        }else {
            self.cerImgView.hidden = YES;
        }
    }
    
    //[self creatLongPressItems];
    NSArray *array = [self.msg fetchReadList];
    _readNum.text = [NSString stringWithFormat:@"%ld%@",array.count,Localized(@"JXLiveVC_countPeople")];
    
    
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([self.msg.isReadDel boolValue]) {
        if (self.msg.isMySend) {
            if([self.msg.isSend intValue] == transfer_status_yes){
                [self refreshWHProg];
            }
        }else {
            if([self.msg.isRead intValue] == transfer_status_yes){
                [self refreshWHProg];
            }
        }
    }
    }
//#else
//#endif
}

//-(void)setBottomTip {
//    NSArray * timeArr = @[@"5秒", @"10秒", @"30秒", @"1分钟", @"5分钟", @"30分钟", @"1小时", @"6小时", @"12小时", @"1天", @"一星期"];
//    if ([self.msg.fromUserId isEqualToString:MY_USER_ID]) {
//        if ([self.msg.isReadDel integerValue] - 1 < timeArr.count) {
//            self.bottomTitleLb.text = [NSString stringWithFormat:@"您设置了消息%@后消失", timeArr[[self.msg.isReadDel integerValue] - 1]];
//        }
//    }else {
//
//        self.bottomTitleLb.text = [NSString stringWithFormat:@"对方设置了阅读消息%@后消失", timeArr[[self.msg.isReadDel integerValue] - 1]];
//    }

    
//    NSDate *readDate = self.msg.readTime;
//    NSInteger count = [[NSDate date] timeIntervalSince1970] - [readDate timeIntervalSince1970];
//    //计算时间
//    NSArray *secondArr = @[@(5), @(10), @(30), @(60),@(300) , @(30 * 60), @(60 * 60), @(6 * 60 * 60), @(12 * 60 * 60), @(24 * 60 * 60), @(7 * 24 * 60 * 60)];
//    NSInteger second = 0;
//    if ([self.msg.isReadDel integerValue] >= 1) {
//        second = [secondArr[[self.msg.isReadDel integerValue] - 1] integerValue];
//    }

//}
- (UIImageView *)gradeImgView {
    if (!_gradeImgView) {
        _gradeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headImage.width - 8, self.headImage.top - 8, 16, 16)];
    }
    return _gradeImgView;
}
//创建子类通用
-(void)startTimeer:(void(^)(WH_JXMessageObject *msg))block {
    _block = block;
    //NSLog(@"===========%@",self.msg.readTime);
    [self.readDelTimer invalidate];
    self.readDelTimer = nil;
    
    NSDate *readDate = self.msg.readTime;
    if (self.msg.isMySend) {
        readDate = self.msg.timeSend;
    }
    
    NSInteger count = [[NSDate date] timeIntervalSince1970] - [readDate timeIntervalSince1970];
    //计算时间
    NSArray *secondArr = @[@(5), @(10), @(30), @(60),@(300) , @(30 * 60), @(60 * 60), @(6 * 60 * 60), @(12 * 60 * 60), @(24 * 60 * 60), @(7 * 24 * 60 * 60)];
    NSInteger second = 0;
    if ([self.msg.isReadDel integerValue] >= 1) {
        second = [secondArr[[self.msg.isReadDel integerValue] - 1] integerValue];
    }
    
    if (count <= second && second != 0) {
        self.whprogress.progress = (second-count)/second*1.0;
        self.readDelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        //解决滑动阻塞计时器问题
        [[NSRunLoop currentRunLoop] addTimer:self.readDelTimer forMode:NSRunLoopCommonModes];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.timerTotal = second;
            self.timerIndex = second-count;
            
        });

    }else {
        self.whprogress.progress = 0;
        //阅后即焚通知
        [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
        block(self.msg);
    }
}


- (void)timerAction:(NSTimer *)timer {
    
    if (self.timerIndex <= 1) {
        self.whprogress.progress = 0;
        [self.readDelTimer invalidate];
        self.readDelTimer = nil;
        
        //阅后即焚通知
        [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
        _block(self.msg);
        return;
    }
    self.timerIndex--;

    self.whprogress.progress = self.timerIndex*1.0/self.timerTotal;
}



//创建子类通用UI
-(void)creatBaseUI{
    
    _checkBox = [[QCheckBox alloc] initWithDelegate:self];
    _checkBox.frame = CGRectMake(INSETS, INSETS, 20, 20);
    [self.contentView addSubview:_checkBox];
    
    NSLog(@"=============MSG.TYPE3:%@" ,_msg.type);
    
    //头像
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE)];
    if (MainHeadType) {
        [_headImage headRadiusWithAngle:HEAD_SIZE / 2];
    }else{
       [_headImage headRadiusWithAngle:g_factory.headViewCornerRadius];
    }
    
//    _headImage.layer.cornerRadius = HEAD_SIZE / 2;
//    [self setViewShadow:_headImage];
    [self.contentView addSubview:_headImage];
    _headImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_headImage addGestureRecognizer:tap];
    
    _cerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(INSETS, INSETS, HEAD_SIZE, HEAD_SIZE)];
    [self.contentView addSubview:_cerImgView];
    
    
 
    
    
    //已读人数
    _readView = [[JXLabel alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    _readView.backgroundColor = [UIColor clearColor];
    _readView.userInteractionEnabled = YES;
    _readView.wh_delegate = self;
    _readView.didTouch = @selector(showReadPersons);
    [self.contentView addSubview:_readView];
    
    _readNum = [[JXLabel alloc] initWithFrame:CGRectMake(_readView.frame.size.width - 30, 0, 30, 15)];
    _readNum.textColor = [UIColor whiteColor];
    _readNum.layer.cornerRadius = 3.0;
    _readNum.layer.masksToBounds = YES;
    _readNum.backgroundColor = HEXCOLOR(0x7bd581);
    _readNum.text = @"10人";
    _readNum.font = [UIFont systemFontOfSize:11];
    _readNum.textAlignment = NSTextAlignmentCenter;
    [_readView addSubview:_readNum];
    
    _nicknameLabel = [[UILabel alloc] init];
    _nicknameLabel.textColor = [UIColor grayColor];
    _nicknameLabel.font = sysFontWithSize(12.0);
    _nicknameLabel.text = @"userName";
    [self.contentView addSubview:_nicknameLabel];
    
    //等待
    _wait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_wait];
    //    [_wait release];
    
    //发送失败
    _sendFailed = [[WH_JXImageView alloc]init];
    _sendFailed.image = [UIImage imageNamed:@"im_send_fail_nor"];
    //    _sendFailed.textColor = [UIColor redColor];
    //    _sendFailed.userInteractionEnabled = YES;
    _sendFailed.backgroundColor = [UIColor clearColor];
    //    _sendFailed.text = @"!";
    _sendFailed.wh_delegate = self;
    _sendFailed.didTouch = @selector(showResendMenu);
    //    _sendFailed.font = [UIFont boldSystemFontOfSize:35];
    //    _sendFailed.textAlignment = NSTextAlignmentRight;
    _sendFailed.hidden = YES;
    [self.contentView addSubview:_sendFailed];
    //    [_sendFailed release];
    
    
    
    
    if (!self.readDeleteView) {
        self.readDeleteView = [[UIView alloc] init];
        [self.contentView addSubview:self.readDeleteView];
        _whprogress = [[WHProgress alloc]initWithFrame:CGRectMake(0, 0, 16, 16)];
        _whprogress.backgroundColor = [UIColor clearColor];

        [_readDeleteView addSubview:_whprogress];
        
        //self.readDeleteView.backgroundColor = [UIColor redColor];
        //self.readDeleteView.layer.cornerRadius = 7.5;
        ///self.readDeleteView.layer.masksToBounds = YES;
        //self.clock = [[clockLayer alloc] init];
        //self.clock.backgroundColor = [UIColor whiteColor];
        //[self.readDeleteView addSubview:self.clock];
        //self.clock.frame = CGRectMake(0, 0, 15, 15);
    }
}



//- (UIView *)bottomView{
//    if (!_bottomView) {
//        _bottomView = [[UIView alloc] init];
//        self.clockImageV = [UIImageView new];
//
//        self.settingBtn = [UIButton new];
//        self.bottomTitleLb = [UILabel new];
//
//        [_bottomView addSubview:self.bottomTitleLb];
//        [_bottomView addSubview:self.settingBtn];
//        [_bottomView addSubview:self.clockImageV];
//
//        self.bottomTitleLb.font = [UIFont systemFontOfSize:10];
//        self.bottomTitleLb.textColor = RGB(140, 154, 184);
//        self.bottomTitleLb.text = @"您设置了消息5秒后消失";
//        self.clockImageV.image = [UIImage imageNamed:@"闹钟"];
//
//
//
//
//        [self.settingBtn setTitle:@"点击更改" forState:UIControlStateNormal];
//        self.settingBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [self.settingBtn setTitleColor:RGB(0, 147, 255) forState:UIControlStateNormal];
//        [self.settingBtn addTarget:self action:@selector(clickSettingBtn) forControlEvents:UIControlEventTouchUpInside];
//
//        [self layoutIfNeeded];
//
//        //设置销毁时间
//        [self.clockImageV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(_bottomView.mas_top).offset(10);
//            make.centerX.mas_equalTo(_bottomView.mas_centerX);
//            make.height.width.mas_equalTo(14);
//        }];
//
//        [self.bottomTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.clockImageV.mas_bottom).offset(14);
//            make.height.mas_equalTo(10);
//            make.centerX.mas_equalTo(self.clockImageV.mas_centerX);
//        }];
//        [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.bottomTitleLb.mas_bottom);
//            make.bottom.mas_equalTo(_bottomView.mas_bottom);
//            make.centerX.mas_equalTo(self.bottomTitleLb);
//        }];
//    }
//    return  _bottomView;
//}
//设置按钮
//- (void) clickSettingBtn{
//    !self.clickSettingBtnClick ? : self.clickSettingBtnClick();
//}


- (void)layoutSubviews{
    [super layoutSubviews];
}


- (void) tapAction {
    _headImage.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _headImage.userInteractionEnabled = YES;
    });
    [g_notify postNotificationName:kCellHeadImageNotification object:self.msg];
}

//发送失败，重新发送
-(void)showResendMenu{
    [g_window endEditing:YES];
    if (self.chatCellDelegate && [self.chatCellDelegate respondsToSelector:@selector(chatCell:resendIndexNum:)]) {
        [self.chatCellDelegate chatCell:self resendIndexNum:self.indexNum];
    }
//    LXActionSheet* _menu = [[LXActionSheet alloc]
//                            initWithTitle:nil
//                            delegate:self
//                            cancelButtonTitle:Localized(@"JX_Cencal")
//                            destructiveButtonTitle:Localized(@"WH_JXBaseChat_WHCell_SendAngin")
//                            otherButtonTitles:@[Localized(@"JX_Delete")]];
//    [g_window addSubview:_menu];
//    [_menu release];
}

//- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
//
//    if(buttonIndex == 0)
//        [g_notify postNotificationName:kCellResendMsgNotifaction object:[NSNumber numberWithInt:self.indexNum]];
//    if(buttonIndex == 1)
//        [g_notify postNotificationName:kCellDeleteMsgNotifaction object:[NSNumber numberWithInt:self.indexNum]];
//}

// 群组内几人查看点击
- (void)showReadPersons {
    [g_notify postNotificationName:kCellShowReadPersonsNotifaction object:[NSNumber numberWithInt:self.indexNum]];
}

//展示发言时间
-(void)isShowSendTime{
    
    //系统提示发送消息时间
    if(self.msg.isShowTime && [self.msg.type intValue] != kWCMessageTypeRemind){//超过15分钟则显示时间
        if(_timeLabel == nil){
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _timeLabel.textColor = HEXCOLOR(0x8C9AB8);
            _timeLabel.font = pingFangMediumFontWithSize(10);
            _timeLabel.userInteractionEnabled = NO;
            _timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH/2 -40, 17, 80, 15);
            _timeLabel.layer.cornerRadius = 3;
            _timeLabel.layer.masksToBounds = YES;

            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_timeLabel];

        }
        _timeLabel.hidden = NO;
        NSDateFormatter* f=[[NSDateFormatter alloc]init];
        [f setDateFormat:@"MM-dd HH:mm"];
        _timeLabel.text = [f stringFromDate:self.msg.timeSend];
        
        g_timeSend = [self.msg.timeSend timeIntervalSince1970];
    }else{
        _timeLabel.hidden = YES;
    }
}

//获取头像
-(void)setHeaderImage {
    
    if ([self.msg.type intValue] == kWCMessageTypeRemind) {
        self.checkBox.hidden = YES;
    }else {
        if (self.isSelectMore) {
            self.checkBox.hidden = NO;
        }else {
            self.checkBox.hidden = YES;
        }
    }
    
    if([_msg.type intValue] != kWCMessageTypeRemind && ![_msg isPinbaMsg]){
        if ([_msg.type intValue] == kWCMessageTypePhoneAsk) {
            if (_msg.isMySend) {
                return;
            }
        }
        if(_msg.isMySend){//头像
            _headImage.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-HEAD_SIZE, INSETS, HEAD_SIZE, HEAD_SIZE);
            _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT*0.5, _headImage.frame.origin.y-CER_HEIGHT*0.5, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
//            _headImage.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-HEAD_SIZE, INSETS, HEAD_SIZE, HEAD_SIZE);
//            _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT*0.5, _headImage.frame.origin.y-CER_HEIGHT*0.5, 0, 0);
            _nicknameLabel.textAlignment = NSTextAlignmentRight;
            _nicknameLabel.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-HEAD_SIZE - 200 - 10, 6, 200, 12);
            
            
//            _gradeImgView.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-HEAD_SIZE + CGRectGetWidth(_headImage.frame) - 16, INSETS + CGRectGetHeight(_headImage.frame) - 16, 16, 16);
            
            
            if (_msg.isShowTime) {
                _headImage.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-HEAD_SIZE, INSETS + 40, HEAD_SIZE , HEAD_SIZE);
                _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT*0.5, _headImage.frame.origin.y-CER_HEIGHT*0.5, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
                _nicknameLabel.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-HEAD_SIZE - 200 - 10, 6 + 40, 200, 12);
                
//                _gradeImgView.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-HEAD_SIZE + CGRectGetWidth(_headImage.frame) - 16, INSETS + 40 + _headImage.height - 16, 16, 16);
            }
        }else{
            if (self.isSelectMore) {
                if ([self.msg.type intValue] != kWCMessageTypeRemind) {
                    _headImage.frame =  CGRectMake(CGRectGetMaxX(_checkBox.frame) + INSETS, INSETS,HEAD_SIZE , HEAD_SIZE);
                }else {
                    _headImage.frame =  CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE);
                }
            }else {
                _headImage.frame =  CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE);
            }
            _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT/2, _headImage.frame.origin.y-CER_HEIGHT/2, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
            _nicknameLabel.textAlignment = NSTextAlignmentLeft;
            _nicknameLabel.frame = CGRectMake(CGRectGetMaxX(_headImage.frame) + 15, 6, 200, 12);
            
//            _gradeImgView.frame = CGRectMake(_headImage.frame.origin.x + CGRectGetWidth(_headImage.frame) - 16, _headImage.frame.origin.y + CGRectGetHeight(_headImage.frame) - 16, 16, 16);
            
            if (_msg.isShowTime) {
                _headImage.frame = CGRectMake(_headImage.frame.origin.x, INSETS + 40, HEAD_SIZE , HEAD_SIZE);
                _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT/2, _headImage.frame.origin.y-CER_HEIGHT/2, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
                _nicknameLabel.frame = CGRectMake(_nicknameLabel.frame.origin.x, 6 + 40, 200, 12);
            }
        }
        
        _checkBox.center = CGPointMake(_checkBox.center.x, _headImage.center.y);
        
//        if () {
        NSString *headUserId = _msg.fromUserId;
//        if (_msg.isMySend) {
//            if ([_msg.toUserId isEqualToString:ANDROID_USERID] || [_msg.toUserId isEqualToString:PC_USERID] || [_msg.toUserId isEqualToString:MAC_USERID]) {
//                headUserId = IOS_USERID;
//            }
//        }
//        if (self.isShowHead) {
        _headImage.image = nil;
        [g_server WH_getHeadImageLargeWithUserId:headUserId userName:_msg.fromUserName imageView:_headImage];
//        }else {
//            _headImage.image = [UIImage imageNamed:@"avatar_normal"];
//        }
//        }else{
//            [g_server getHeadImageSmall:[_msg.fromUserId longLongValue]-1 imageView:_headImage];
//        }
    }
}

//聊天框
- (void)setBackgroundImage{
    _readDeleteView.hidden = YES;
     //初步过滤不需要bgImage的cell
    if([_msg.type intValue] == kWCMessageTypeRemind || [_msg isPinbaMsg] || [_msg.type intValue] == kWCMessageTypeSystemImage1 || [_msg.type intValue] == kWCMessageTypeSystemImage2){
        
        _readView.hidden = YES;
        return;
    }
    if (self.msg.isGroup && self.msg.showRead) {
        _readView.hidden = NO;
    }else {
        _readView.hidden = YES;
    }
    
    //依数据过滤不需要bgImage的cell
    if ([_msg.type intValue] == kWCMessageTypePhoneAsk || [_msg.type intValue] == kWCMessageTypeResumeAsk) {
        if (_msg.isMySend) {
            return;
        }
    }
    
    //送达已读图标
    int n = 26;
    int h = _bubbleBg.frame.size.height;
    if(self.msg.isMySend){
        _wait.frame = CGRectMake(_bubbleBg.frame.origin.x-n-INSETS, (h-n)/2+INSETS, n, n);
        
        _readView.frame = CGRectMake(_bubbleBg.frame.origin.x - _readView.frame.size.width - INSETS - 2,  _bubbleBg.frame.origin.y + 2, _readView.frame.size.width, _readView.frame.size.height);
        _readNum.frame = CGRectMake(_readView.frame.size.width - 30, _readNum.frame.origin.y, _readNum.frame.size.width, _readNum.frame.size.height);
        
    }else{
        _wait.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+INSETS, (h-n)/2+INSETS, n, n);
        _readView.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+INSETS + 2, _bubbleBg.frame.origin.y + 2, _readView.frame.size.width, _readView.frame.size.height);
        _readNum.frame = CGRectMake(0, _readNum.frame.origin.y, _readNum.frame.size.width, _readNum.frame.size.height);
    }
    if (self.msg.isShowTime) {
        CGRect frame = _wait.frame;
        frame.origin.y = _wait.frame.origin.y + 40;
        _wait.frame = frame;
    }
    
    _sendFailed.frame = _wait.frame;
    
    // 阅后即焚标记(使用时才创建)
    if (!_burnImage) {
        _burnImage = [[WH_JXImageView alloc] init];
        //_burnImage.image = [UIImage imageNamed:@"burn_default"];
        _burnImage.hidden = YES;
        [self.contentView addSubview:_burnImage];
    }

    //送达
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([self.msg.isReadDel boolValue]) {
        self.readDeleteView.frame = CGRectMake(_bubbleBg.left+_bubbleBg.width/2-8, _bubbleBg.bottom + 5, 16, 16);
//        self.whprogress.progress = 1;
        self.readDeleteView.hidden = NO;
        
//        self.bottomView.frame = CGRectMake(0, _readDeleteView.bottom+8, JX_SCREEN_WIDTH, 85);
//        self.bottomView.hidden = NO;
//        [self.contentView addSubview:self.bottomView];
        
//        [self setBottomTip];
        
        
        
        
        
    }else {
        //self.bottomView.hidden = YES;
        self.readDeleteView.hidden = YES;
    }
    //[self.clock startClock];
    }
//#else
//#endif
    
    if(self.msg.isMySend){
        
        //[self drawIsSend];
        [self drawSendOrReadImage];
        if (([_msg.type intValue] == kWCMessageTypeFile || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVideo) && [self.msg.isRead intValue] == 0 && [self.msg.isSend intValue] == transfer_status_yes) {
            // 进度条发送时可能会出现进度条一直存在， 这里处理， 收到回执就隐藏进度条
            [self sendMessageToUser];
        }
    }else{
        //[self drawIsRead];
        
        if([self.msg.type intValue] != kWCMessageTypeVoice && [self.msg.type intValue] != kWCMessageTypeVideo && [self.msg.type intValue] != kWCMessageTypeFile && [self.msg.type intValue] != kWCMessageTypeLocation && [self.msg.type intValue] != kWCMessageTypeCard && [self.msg.type intValue] != kWCMessageTypeLink && [self.msg.type intValue] != kWCMessageTypeMergeRelay)
            _readImage.hidden = YES;
        _sendFailed.hidden = YES;
        }
    
        if ([_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVideo || [_msg.type intValue] == kWCMessageTypeLocation || [_msg.type intValue] == kWCMessageTypeRedPacket || [_msg.type intValue] == kWCMessageTypeRedPacketExclusive || [_msg.type intValue] == kWCMessageTypeFile || [_msg.type intValue] == kWCMessageTypeCard || [_msg.type intValue] == kWCMessageTypeLink || [_msg.type intValue] == kWCMessageTypeGif || [_msg.type intValue] == kWCMessageTypeShake || [_msg.type intValue] == kWCMessageTypeMergeRelay || [_msg.type intValue] == kWCMessageTypeShare || [_msg.type intValue] == kWCMessageTypeTransfer) {
            return;
        }
    
        if(_msg.isMySend){
            [_bubbleBg setBackgroundImage:[self returnResizableImageWithImageName:@"chat_bg_blue"] forState:UIControlStateNormal];
            [_bubbleBg setBackgroundImage:[self returnResizableImageWithImageName:@"chat_bg_blue_press"] forState:UIControlStateHighlighted];

        }else{

            [_bubbleBg setBackgroundImage:[self returnResizableImageWithImageName: @"chat_bg_white"] forState:UIControlStateNormal];
            [_bubbleBg setBackgroundImage:[self returnResizableImageWithImageName:@"chat_bg_white_press"] forState:UIControlStateHighlighted];
    }
}

- (void)refreshWHProg {
    NSDate *readDate = self.msg.readTime;
    if (self.msg.isMySend) {
        readDate = self.msg.timeSend;
    }
    
    NSInteger count = [[NSDate date] timeIntervalSince1970] - [readDate timeIntervalSince1970];
    //计算时间
    NSArray *secondArr = @[@(5), @(10), @(30), @(60),@(300) , @(30 * 60), @(60 * 60), @(6 * 60 * 60), @(12 * 60 * 60), @(24 * 60 * 60), @(7 * 24 * 60 * 60)];
    NSInteger second = 0;
    if ([self.msg.isReadDel integerValue] >= 1) {
        second = [secondArr[[self.msg.isReadDel integerValue] - 1] integerValue];
    }
    
    if (count <= second) {
        self.whprogress.progress = (second-count)/second*1.0;
    }else {
        self.whprogress.progress = 0;
    }
}




- (UIImage *)returnResizableImageWithImageName:(NSString *)imageName
{
    // 加载原有图片
    UIImage * image = [UIImage imageNamed:imageName];
    // 获取原有图片的宽高的一半
    CGFloat w = image.size.width * 0.5;
    // 生成可以拉伸指定位置的图片
    UIImage * newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(30, w, 10, w) resizingMode:UIImageResizingModeStretch];
    return newImage;
}



//阅后即焚标记
//- (void)drawReasdDelView:(BOOL)isSelected {
    // isSelected    YES 文本倒计时状态   NO 文本未点击状态
//    _burnImage.frame = CGRectMake(CGRectGetMaxX(_bubbleBg.frame)+(isSelected ? 11 : 6), _bubbleBg.frame.origin.y+(isSelected ? 22 : 14), 15, 15);
//#ifdef IS_SHOW_NEWReadsDelete
//#else
//#endif
    

//    if ([self.msg.type intValue] == kWCMessageTypeGif || [self.msg.type intValue] == kWCMessageTypeShake) {
//        _burnImage.frame = CGRectMake(CGRectGetMaxX(_bubbleBg.frame)+(isSelected ? 11 : 6), 22+(isSelected ? 22 : 14), _burnImage.frame.size.width, _burnImage.frame.size.height);
//        if (self.msg.isShowTime) {
//            CGRect burnFrame = _burnImage.frame;
//            burnFrame.origin.y = _burnImage.frame.origin.y + 40;
//            _burnImage.frame = burnFrame;
//        }
//    }
//    if (([_msg.type intValue] == kWCMessageTypeText || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVoice || [_msg.type intValue] == kWCMessageTypeVideo)) {
//        _burnImage.hidden = ![_msg.isReadDel boolValue];
//
//    }else {
//        _burnImage.hidden = YES;
//    }
//
//    if (self.isCourse) {
//        _burnImage.hidden = YES;
//    }
//}


//下载
//-(void)downloadFile:(WH_JXImageView*)iv{
//    if([_msg.content length]<=0)
//        return;
//    if(_msg.isMySend && [[NSFileManager defaultManager] fileExistsAtPath:_msg.fileName] ){//如本地文件存在
//        if([[_msg.fileName pathExtension] isEqualToString:@"jpg"] && iv!=nil){
//            UIImage* p = [[UIImage alloc]initWithContentsOfFile:_msg.fileName];
//            iv.image = p;
////            [p release];
//        }
//        return;
//    }
//    
//    NSString* ext  = [[_msg.content lastPathComponent] pathExtension];
//    NSString *filepath = [myTempFilePath stringByAppendingPathComponent:[_msg.content lastPathComponent]];
//    
//    if( ![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
//        [g_server addTask:_msg.content param:iv toView:self];
//    }
//    else{
//        [self MiXin_doSaveOK];
//        if([ext isEqualToString:@"jpg"] && iv!=nil){
//            UIImage* p = [[UIImage alloc]initWithContentsOfFile:filepath];
//            iv.image = p;
////            [p release];
//        }
//    }
//    
//    filepath = nil;
//    ext = nil;
//}

- (void)WH_didServerResult_WHSucces:(WH_JXConnection *)task dict:(NSDictionary *)dict array:(NSArray *)array1{
    [self MiXin_doSaveOK];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [self MiXin_doSaveError];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{
    [self MiXin_doSaveError];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
}

-(void)MiXin_doSaveError{
    NSLog(@"http失败");
    [_msg updateIsReceive:transfer_status_no];
    [self drawIsReceive];
}

-(void)MiXin_doSaveOK{
    _msg.fileName = [myTempFilePath stringByAppendingPathComponent:[_msg.content lastPathComponent]];
    [_msg updateIsReceive:transfer_status_yes];
    [self setBackgroundImage];
    [self drawIsReceive];
}

//语音红点
-(void)drawIsRead{

    if (self.msg.isMySend) {
        
        return;
    }
    if([self.msg.isRead boolValue]){
        if (_readImage == nil) {
            WH_JXImageView * imageV = (WH_JXImageView *) [self viewWithTag:131];
            imageV.hidden = YES;
        }else{
            _readImage.hidden = YES;
        }
    }
    else{
        if(_readImage==nil){
            _readImage=[[WH_JXImageView alloc]initWithImage:[UIImage imageNamed:@"new_tips"]];
            _readImage.hidden = YES;
            [self.contentView addSubview:_readImage];
        }
        _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+INSETS*0.5, _bubbleBg.frame.origin.y+13, 10, 10);
        _readImage.image = [UIImage imageNamed:@"new_tips"];
        _readImage.tag = 131;
        _readImage.hidden = YES;
        
    }
}
//改为消息已发送
-(void)drawIsSend{

    int n = [self.msg.isSend intValue];
    _wait.hidden = n != transfer_status_ing;
    if(n){
        [_wait stopAnimating];
        if (self.msg.isGroup) {
            
            NSArray *array = [self.msg fetchReadList];
            _readNum.text = [NSString stringWithFormat:@"%ld%@",array.count,Localized(@"JXLiveVC_countPeople")];
        }else {
            if (self.msg.isMySend) {
                //送达
                [self drawSendOrReadImage];
            }
        }
        if (([_msg.type intValue] == kWCMessageTypeFile || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVideo) && [self.msg.isRead intValue] == 0 && [self.msg.isSend intValue] == transfer_status_yes) {
            // 进度条发送时可能会出现进度条一直存在， 这里处理， 收到回执就隐藏进度条
            [self sendMessageToUser];
        }

    }
    else
        [_wait startAnimating];
    if(n == transfer_status_no){
        _sendFailed.hidden = NO;
//        _readImage.hidden = YES;
    }else{
        _sendFailed.hidden = YES;
//        _readImage.hidden = NO;
    }
    
    if (self.isCourse) {
        _sendFailed.hidden = YES;
    }
    
}

-(void)drawSendOrReadImage{
    //消息发送失败
    if([self.msg.isSend intValue] == transfer_status_no){
        _readImage.hidden = YES;
        _sendFailed.hidden = NO;
        return;
    }
    //消息发送成功
    if([self.msg.isSend intValue] == transfer_status_yes){

        _sendFailed.hidden = YES;
        //不显示的条件
        if ([self.msg.type intValue] == kWCMessageTypeRemind || self.msg.isGroup || !self.msg.isVisible || [_msg isPinbaMsg]) {
            _readImage.hidden = YES;
            return;
        }
        
        //判断是否要新建
        if (_readImage == nil) {
            _readImage = [[WH_JXImageView alloc]init];
            _readImage.hidden = YES;
            [self.contentView addSubview:_readImage];

        }
        //设置图片
        _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x-20-INSETS*0.5, _bubbleBg.frame.origin.y+2, 20, 10);
//        _readImage.frame = CGRectMake(CGRectGetMaxX(_bubbleBg.frame), _bubbleBg.frame.origin.y+2, 9.5f, 7.0);
        _burnImage.frame = CGRectMake(_bubbleBg.frame.origin.x-20-INSETS*0.5+2, _bubbleBg.frame.origin.y+20, 15, 15);
        
        if ([self.msg.type intValue] == kWCMessageTypeGif || [self.msg.type intValue] == kWCMessageTypeShake) {
//            _readImage.frame = CGRectMake(JX_SCREEN_WIDTH-HEAD_SIZE-imageItemHeight-INSETS*2 + 40 - 20 - INSETS * .5, 20, _readImage.frame.size.width, _readImage.frame.size.height);
            
            _readImage.frame = CGRectMake(JX_SCREEN_WIDTH - INSETS -HEAD_SIZE - CHAT_WIDTH_ICON - imageItemHeight - _readImage.frame.size.width, 20, _readImage.frame.size.width, _readImage.frame.size.height);
            _burnImage.frame = CGRectMake(JX_SCREEN_WIDTH-HEAD_SIZE-imageItemHeight-INSETS*2 + 40 - 20 - INSETS * .5+2, 20+18, _burnImage.frame.size.width, _burnImage.frame.size.height);
            if (self.msg.isShowTime) {
                CGRect frame = _readImage.frame;
                frame.origin.y = _readImage.frame.origin.y + 40;
                _readImage.frame = frame;
                
                CGRect burnFrame = _burnImage.frame;
                burnFrame.origin.y = _burnImage.frame.origin.y + 40;
                _burnImage.frame = burnFrame;
            }
        }
        if( [self.msg.isRead intValue] == 0){
            _readImage.image = [UIImage imageNamed:@"send"];
//            _readImage.image = nil;
        }else{
            _readImage.image = [UIImage imageNamed:@"read"];
        }
        
        _readImage.hidden = NO;
        if (([_msg.type intValue] == kWCMessageTypeText || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVoice || [_msg.type intValue] == kWCMessageTypeVideo)) {
            _burnImage.hidden = ![_msg.isReadDel boolValue];
        }else {
            _burnImage.hidden = YES;
        }
    }
    
    if (self.isCourse) {
        _sendFailed.hidden = YES;
        _readImage.hidden = YES;
        _burnImage.hidden = YES;
    }
}

- (void)sendMessageToUser {
    // 消息已经送达
    
}


- (void)drawReadPersons:(int)num{
    _readNum.text = [NSString stringWithFormat:@"%d%@",num,Localized(@"JXLiveVC_countPeople")];
}

-(void)drawIsReceive{
    int n = [_msg.isReceive intValue];
    _wait.hidden = n!=0;
    if(_wait.hidden)
        [_wait stopAnimating];
    else
        [_wait startAnimating];
    
    if(n == transfer_status_no){
        _sendFailed.hidden = NO;
        _readImage.hidden = YES;
    }else{
        _sendFailed.hidden = YES;
        _readImage.hidden = NO;
    }
    
    if (self.isCourse) {
        _sendFailed.hidden = YES;
        _readImage.hidden = YES;
    }
}

-(void)notifyDrawIsReceive:(NSNotification*)sender{
    if(sender.object == self.msg)
        [self drawIsReceive];
}

- (void)updateLoadFileProgress:(NSNotification *)noti {
    NSDictionary *dict = noti.object;
    NSProgress *progress = [dict objectForKey:@"uploadProgress"];
    self.fileDict = [dict objectForKey:@"file"];
    self.loadProgress = progress.fractionCompleted;
    NSLog(@"-------------- %f--- %@  ---  %@",self.loadProgress,self.fileDict, self.msg.messageId);
    
    [self updateFileLoadProgress];
}

- (void)updateFileLoadProgress {
}

-(void)didTouch:(UIButton*)button{
}

//回应交换电话后更新按钮状态
- (void)setAgreeRefuseBtnStatusAfterReply{
    
}

// 设置图片外框
- (void)setMaskLayer:(UIImageView *)imageView {
    UIImage *maskImage = nil;
    if(self.msg.isMySend){
        maskImage = [self returnResizableImageWithImageName:@"chat_bg_blue"];
        
    }else{
        maskImage = [self returnResizableImageWithImageName:@"chat_bg_white"];
        
    }
    
    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:maskImage];
    maskImageView.userInteractionEnabled = YES;
    maskImageView.frame = imageView.bounds;
    imageView.layer.mask = maskImageView.layer;
}

// 获取cell 高度
+ (float) getChatCellHeight:(WH_JXMessageObject *)msg {

    return 0;
}

#pragma mark ------------------设置plasticPopupMenu位置---------------------
- (void)doLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (self.isSelectMore) {
        return;
    }
    if(longPress.state == UIGestureRecognizerStateBegan)
    {
        
        [self creatLongPressItems];
        
        if (longPress.view == self.contentView) {
            CGPoint touchPoint = [longPress locationInView:self.contentView];
            BOOL iscontain = CGRectContainsPoint(self.headImage.frame, touchPoint);
            if (iscontain) {
                //@
                if ([self.msg.fromUserId isEqualToString:MY_USER_ID]) {
                    return;
                }
                [g_notify postNotificationName:kCellLongGesHeadImageNotification object:self.msg];
                return;
            }
        }
        
        CGRect frame = [self.contentView convertRect:self.bubbleBg.frame toView:self.superview.superview.superview];
     
        UIView *view = self.superview.superview;
        CGFloat y = frame.origin.y;
        if (view.frame.origin.y > 0) {
            y = frame.origin.y - 64;
        }
        
        
        //判断是否自己发送的
        if (!self.msg.isMySend) {
//            [self.plasticPopupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y, self.bubbleBg.frame.size.width + 120, 35) animated:YES];
            [self.popupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y, self.bubbleBg.frame.size.width + 120, 35) animated:YES];
        }else{

//            [self.plasticPopupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y,(self.bubbleBg.frame.origin.x +  self.bubbleBg.frame.size.width /2)*2, 35) animated:YES];
            [self.popupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y,(self.bubbleBg.frame.origin.x +  self.bubbleBg.frame.size.width /2)*2, 35) animated:YES];
        }
    }
}

- (void)creatLongPressItems
{
    
    if ([self.msg.type intValue] == kWCMessageTypeRemind || self.isSelectMore) {
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    //复制
    if (([self.msg.type intValue] == kWCMessageTypeText || [self.msg.type intValue] == kWCMessageTypeReply) && ![self.msg.isReadDel boolValue]) {
        QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_Copy")] target:self action:@selector(myCopy)];
        [items addObject:item1];
    }
    
    //回复
    if (!self.msg.isMySend) {
        QBPopupMenuItem *item8 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ",Localized(@"JX_Reply")] target:self action:@selector(replyMsg)];
        [items addObject:item8];
    }
    
    
    
    //收藏
    if ([self.msg.type intValue] == kWCMessageTypeImage || [self.msg.type intValue] == kWCMessageTypeVideo || [self.msg.type intValue] == kWCMessageTypeFile || [self.msg.type intValue] == kWCMessageTypeVoice || [self.msg.type intValue] == kWCMessageTypeText || [self.msg.type intValue] == kWCMessageTypeReply) {
        if ([self.msg.type intValue] == kWCMessageTypeImage && ![self.msg.isReadDel boolValue]) {
            QBPopupMenuItem *item5 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_AddToTheExpression")] target:self action:@selector(favoritEmojiAction)];
            [items addObject:item5];
        }
        if (![self.msg.isReadDel boolValue]) {
            QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_Collection")] target:self action:@selector(favoritAction)];
            [items addObject:item6];
        }
        
    }
    
    //删除
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_Delete")] target:self action:@selector(deleteAction)];
    [items addObject:item4];
    
    if (self.isCourse) {
        QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
        popupMenu.highlightedColor = [UIColor lightGrayColor];
        popupMenu.height = 35;
        self.popupMenu = popupMenu;

//        QBPlasticPopupMenu *plasticPopupMenu = [QBPlasticPopupMenu popupMenuWithItems:items];
//        plasticPopupMenu.height = 35;
//        self.plasticPopupMenu = plasticPopupMenu;
        return;
    }
    

    if ([self.msg.type intValue] == kWCMessageTypeText || [self.msg.type intValue] == kWCMessageTypeReply || [self.msg.type intValue] == kWCMessageTypeImage || [self.msg.type intValue] == kWCMessageTypeVoice || [self.msg.type intValue] == kWCMessageTypeLocation || [self.msg.type intValue] == kWCMessageTypeGif || [self.msg.type intValue] == kWCMessageTypeVideo || [self.msg.type intValue] == kWCMessageTypeAudio || [self.msg.type intValue] == kWCMessageTypeCard || [self.msg.type intValue] == kWCMessageTypeFile || [self.msg.type intValue] == kWCMessageTypeLink || [self.msg.type intValue] == kWCMessageTypeShare) {
        if (![self.msg.isReadDel boolValue]) {
            QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_Relay")] target:self action:@selector(relayAction)];
            [items addObject:item2];
        }
        
        if (self.isWithdraw) {
            // 自己发的5分钟之内可以撤回
            //            NSDate * today = [NSDate date];
            //            long long now = [today timeIntervalSince1970];
            //            long distance = now - [self.msg.timeSend timeIntervalSince1970];
            //            long distanceM = distance / 60;
            //            if (distanceM < 5) {
            QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_Withdraw")] target:self action:@selector(withdrawAction)];
            [items addObject:item3];
            //            }
        }
    }
    
    
    
    if ([self.msg.type intValue] != kWCMessageTypeRemind) {
        
        QBPopupMenuItem *item7 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", Localized(@"JX_Multiselect")] target:self action:@selector(selectMoreAction)];
        [items addObject:item7];
    }
    
    if (self.msg.isMySend) {
        NSString *str;
        if (self.isShowRecordCourse && [self.msg.isReadDel intValue] != 1) {
            if (![self.chatCellDelegate getRecording]) {
                str = Localized(@"JX_StartRecording");
                QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:str target:self action:@selector(recordAction)];
                //[items addObject:item6];  //2019年11月1日去掉开始录制按钮
            }else if (self.indexNum >= [self.chatCellDelegate getRecordStarNum]) {
                str = Localized(@"JX_StopRecording");
                QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"   %@   ", str] target:self action:@selector(recordAction)];
                //[items addObject:item6];  //2019年11月1日去掉结束录制按钮
            }
        }
    }
    
    
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [UIColor lightGrayColor];
    popupMenu.height = 35;
    self.popupMenu = popupMenu;

//    QBPlasticPopupMenu *plasticPopupMenu = [QBPlasticPopupMenu popupMenuWithItems:items];
//    plasticPopupMenu.height = 35;
//    self.plasticPopupMenu = plasticPopupMenu;
    
}

// 转发
- (void)relayAction {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:RelayIndexNum:)]) {
        [self.chatCellDelegate chatCell:self RelayIndexNum:self.indexNum];
    }
}

// 撤回
- (void)withdrawAction {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:withdrawIndexNum:)]) {
        [self.chatCellDelegate chatCell:self withdrawIndexNum:self.indexNum];
    }
}

// 收藏
- (void)favoritAction{
    int msgType = [self.msg.type intValue];
    CollectType collectType = 0;
          if (msgType == kWCMessageTypeImage) {
        collectType = CollectTypeImage;
    }else if (msgType == kWCMessageTypeVideo) {
        collectType = CollectTypeVideo;
    }else if (msgType == kWCMessageTypeFile) {
        collectType = CollectTypeFile;
    }else if (msgType == kWCMessageTypeVoice) {
        collectType = CollectTypeVoice;
    }else if (msgType == kWCMessageTypeText) {
        collectType = CollectTypeText;
    }else {
        
    }
    if (collectType == 0) {
        return;
    }
    
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:favoritIndexNum:type:)]) {
        [self.chatCellDelegate chatCell:self favoritIndexNum:self.indexNum type:collectType];
    }
}

-(void)favoritEmojiAction{
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:favoritIndexNum:type:)]) {
        [self.chatCellDelegate chatCell:self favoritIndexNum:self.indexNum type:CollectTypeEmoji];
    }
}
// 回复
- (void)replyMsg {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:replyIndexNum:)]) {
        [self.chatCellDelegate chatCell:self replyIndexNum:self.indexNum];
    }
}

// 删除
- (void)deleteAction {
    
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:deleteIndexNum:)]) {
        [self.chatCellDelegate chatCell:self deleteIndexNum:self.indexNum];
    }
}

// 多选
- (void)selectMoreAction {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:selectMoreIndexNum:)]) {
        [self.chatCellDelegate chatCell:self selectMoreIndexNum:self.indexNum];
    }
}
// 多选选择
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:checkBoxSelectIndexNum:isSelect:)]) {
        [self.chatCellDelegate chatCell:self checkBoxSelectIndexNum:self.indexNum isSelect:checked];
    }
}

// 录制
- (void)recordAction {
    if ([self.chatCellDelegate getRecording]) {
        if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:stopRecordIndexNum:)]) {
            [self.chatCellDelegate chatCell:self stopRecordIndexNum:self.indexNum];
        }
    }else {
        if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:startRecordIndexNum:)]) {
            [self.chatCellDelegate chatCell:self startRecordIndexNum:self.indexNum];
            
        }
    }
    [self creatLongPressItems];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)dealloc{
    NSLog(@"WH_JXBaseChat_WHCell.delloc");
//    [super dealloc];
//    [_bubbleBg release];
    _bubbleBg = nil;
    [self.readDelTimer invalidate];
    self.readDelTimer = nil;
}

@end
