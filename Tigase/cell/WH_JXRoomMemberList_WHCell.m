//
//  WH_JXRoomMemberList_WHCell.m
//  Tigase_imChatT
//
//  Created by p on 2018/7/3.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXRoomMemberList_WHCell.h"

#define CELL_HEIGHT 60
#define JX_OrginX 16

@interface WH_JXRoomMemberList_WHCell()

@property (nonatomic, strong) WH_JXImageView *headImageView;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic ,strong) UILabel *stateLabe;//在线状态
@property (nonatomic ,strong) UIImageView *jinyanyinshenImageV;//禁言隐身状态

@property (nonatomic ,strong) WH_JXImageView *gradeImageView; //等级

@end

@implementation WH_JXRoomMemberList_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self customView];
    }
    return self;
}

- (void)customView {
    
    _headImageView = [[WH_JXImageView alloc]init];
    _headImageView.userInteractionEnabled = NO;
    _headImageView.wh_delegate = self;
//    _headImageView.didTouch = @selector(WH_headImageDidTouch);
    _headImageView.frame = CGRectMake(14,9,42,42);
    [_headImageView headRadiusWithAngle:21];
    _headImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.contentView addSubview:self.headImageView];
    
    
//    QCheckBox *btn = [[QCheckBox alloc] initWithDelegate:self];
//    //    btn.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - 20, 20, 20, 20);
//        self.checkBtn = btn;
//        [self.contentView addSubview:self.checkBtn];
//        [self.checkBtn setHidden:YES];
    
    
    //用户等级
    _gradeImageView = [[WH_JXImageView alloc] init];
    _gradeImageView.userInteractionEnabled = NO;
    _gradeImageView.wh_delegate = self;
    _gradeImageView.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) - 16, _headImageView.frame.origin.y + CGRectGetHeight(_headImageView.frame) - 16 ,16 ,16);
    [_gradeImageView setImage:[UIImage imageNamed:@"grade_01"]];
    [self.contentView addSubview:_gradeImageView];
    
    
    
    
    
    UIView *lhView = [[UIView alloc] initWithFrame:CGRectMake(_headImageView.frame.origin.x + _headImageView.frame.size.width + 10, 0, 1, CELL_HEIGHT)];
    [lhView setBackgroundColor:g_factory.globalBgColor];
    [self.contentView addSubview:lhView];
    
    _roleLabel = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 60, 0, 50, CELL_HEIGHT)];
    _roleLabel.center = CGPointMake(_roleLabel.center.x, _headImageView.center.y);
    _roleLabel.textColor = HEXCOLOR(0x8F9CBB);
    _roleLabel.textAlignment = NSTextAlignmentRight;
    _roleLabel.text = Localized(@"JXGroup_Owner");
    _roleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 16];
//    _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
//    _roleLabel.layer.cornerRadius = 2.0;
//    _roleLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:_roleLabel];
    [_roleLabel setHidden:YES];
    
    
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.frame.origin.x + _headImageView.frame.size.width + 20, 8, JX_SCREEN_WIDTH - _headImageView.frame.origin.x - _headImageView.frame.size.width - 20 - 70, 25)];

//    _nameLabel.center = CGPointMake(_nameLabel.center.x, _roleLabel.center.y);
//    _nameLabel.text = @"陈奕迅";
    _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 16];
    [_nameLabel setTextColor:HEXCOLOR(0x3A404C)];
    [self.contentView addSubview:_nameLabel];
    
    _stateLabe = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame) + 20, CGRectGetHeight(_nameLabel.frame) + _nameLabel.frame.origin.y, JX_SCREEN_WIDTH - (2*JX_OrginX) - 110 - CGRectGetWidth(_headImageView.frame), 20)];
    _stateLabe.text = @"在线";
    _stateLabe.textColor = HEXCOLOR(0x969696);
    [_stateLabe setBackgroundColor:[UIColor whiteColor]];
    _stateLabe.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_stateLabe];
    
    //禁言隐身状态
    _jinyanyinshenImageV = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-30, (CELL_HEIGHT-20)*0.5, 20, 20)];
    [self.contentView addSubview:_jinyanyinshenImageV];
    _jinyanyinshenImageV.hidden = YES;
    

    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT - 1, JX_SCREEN_WIDTH, 1)];
    lineView.backgroundColor = g_factory.globalBgColor;
    [self.contentView addSubview:lineView];
    
}

- (void)setData:(memberData *)data {
    _data = data;
    
    [g_server WH_getHeadImageSmallWIthUserId:[NSString stringWithFormat:@"%ld", data.userId] userName:data.userNickName imageView:_headImageView];
    
    
    //在线状态
    memberData *mData2 = [self.room getMember:[NSString stringWithFormat:@"%ld", data.userId]];
    
    if ([mData2.onLineState integerValue] == 0) {
        //离线
        if (mData2.offlineTime == 0) { //机器人
            //在线
            [_stateLabe setText:@"在线"];
            _stateLabe.textColor = HEXCOLOR(0x1194F5);
        }else{
            WH_JXUserObject *allUser2 = [[WH_JXUserObject alloc] init];
            allUser2 = [allUser2 getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
            NSInteger timeIn;
            if ([NSString stringWithFormat:@"%ld",mData2.offlineTime].length > 10) {
                timeIn = mData2.offlineTime/1000;
            }else{
                timeIn = mData2.offlineTime;
            }
            NSString *data = [self dateTimeDifferenceWithStartTime:[NSNumber numberWithLongLong:timeIn]];
            [_stateLabe setText:[NSString stringWithFormat:@"%@在线" ,data]];
            [_stateLabe setTextColor:HEXCOLOR(0x999999)];
        }
        
    }else if ([mData2.onLineState integerValue] == 1) {
        //在线
        [_stateLabe setText:@"在线"];
        _stateLabe.textColor = HEXCOLOR(0x1194F5);
    }
    
//    if (self.role == 1 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])) {
//        // && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])
//        //当前用户是群主
//        [self.checkBtn setHidden:YES];
//
//    }else if (self.role == 2 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])) {
//        //[d.role intValue] == 2 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])
//        //当前用户是管理员
//        [self.checkBtn setHidden:YES];
//
//    }
    
    //禁言
    if ([[NSDate date] timeIntervalSince1970] <= mData2.talkTime) {
        [_jinyanyinshenImageV setImage:[UIImage imageNamed:@"icon_jinyanbiaozhi"]];
        [_jinyanyinshenImageV setHidden:NO];
    }else{
        [_jinyanyinshenImageV setHidden:YES];
    }
    
    //身份标识label(隐身人要放禁言后面)
    NSString *str = Localized(@"JXGroup_RoleNormal");
    [_roleLabel setHidden:YES];
    //    _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
    switch (self.role) {
        case 1:{
            str = Localized(@"JXGroup_Owner");
            [_roleLabel setHidden:NO];
//            [self.checkBtn setHidden:YES];
            _jinyanyinshenImageV.hidden = YES;
            
        }
            break;
        case 2:{
            str = Localized(@"JXGroup_Admin");
            [_roleLabel setHidden:NO];
//            [self.checkBtn setHidden:YES];
            _jinyanyinshenImageV.hidden = YES;
            
        }
            break;
        case 4:{ //隐身人
            str = Localized(@"JXInvisibleMan");
            [_roleLabel setHidden:YES];
            //            _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
            [_jinyanyinshenImageV setImage:[UIImage imageNamed:@"icon_yinshenbiaozhi"]];
            _jinyanyinshenImageV.hidden = NO;
            
            
        }
            break;
        case 5:{ //监控人
            str = Localized(@"JXMonitorPerson");
            [_roleLabel setHidden:YES];
            //            _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
            _jinyanyinshenImageV.hidden = YES;
            
        }
            break;
            
        default:
            break;
    }
    _roleLabel.text = str;
    
    //    CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _roleLabel.font} context:nil].size;
    //    _roleLabel.frame = CGRectMake(_roleLabel.frame.origin.x, _roleLabel.frame.origin.y, size.width + 5, _roleLabel.frame.size.height);
    //    _nameLabel.frame = CGRectMake(_headImageView.frame.origin.x + _headImageView.frame.size.width + 20, 8, JX_SCREEN_WIDTH - _headImageView.frame.origin.x - _headImageView.frame.size.width - 20 - 70, 25);

    
    WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
    allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
    if ([_curManager isEqualToString:MY_USER_ID]) {
        NSLog(@"user name:%@" ,data.lordRemarkName.length > 0  ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName);
        _nameLabel.text = data.lordRemarkName.length > 0  ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
    }else {
        _nameLabel.text = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
    }
    memberData *mData = [self.room getMember:[NSString stringWithFormat:@"%ld", data.userId]];

//    if (!self.room.allowSendCard && [mData.role intValue] != 1 && [mData.role intValue] != 2) {
//        _nameLabel.text = [_nameLabel.text substringToIndex:[_nameLabel.text length]-1];
//        _nameLabel.text = [_nameLabel.text stringByAppendingString:@"*"];
//    }
    /// 获取当前登录用户
    memberData *loginMember = [self getCurrentLoginMerber];
    /// 当前登录用户是不是管理者
    BOOL isManger = [self isManger:loginMember];
    
    /// 当前登录用户不是管理者 并且开启了不允许群成员私聊 进入判断
    if (!isManger && !self.room.allowSendCard) {
        /// 被点击用户不是自己 进入判断
        if (mData.userId != loginMember.userId && ![self isManger:mData]) {
            if (GroupMemberShowPlaceholderString) {
                _nameLabel.text = [_nameLabel.text substringToIndex:[_nameLabel.text length]-1];
                _nameLabel.text = [_nameLabel.text stringByAppendingString:@"*"];
            }
            
        }
    }
    
    //用户等级
    if ([mData.vip integerValue] == 0) {
        [_gradeImageView setHidden:YES];
    }else {
        [_gradeImageView setHidden:NO];
        if ([mData.vip integerValue] == 1) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_01"]];
        }else if ([mData.vip integerValue] == 2) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_02"]];
        }else if ([mData.vip integerValue] == 3) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_03"]];
        }else if ([mData.vip integerValue] == 4) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_04"]];
        }else if ([mData.vip integerValue] == 5) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_05"]];
        }else if ([mData.vip integerValue] == 6) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_06"]];
        }else if ([mData.vip integerValue] == 7) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_07"]];
        }else if ([mData.vip integerValue] == 8) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_08"]];
        }else if ([mData.vip integerValue] == 9) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_09"]];
        }else if ([mData.vip integerValue] == 10) {
            [_gradeImageView setImage:[UIImage imageNamed:@"grade_10"]];
        }
        
        
        
        //修复vip等级显示位置错误的问题
        [_gradeImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(self.headImageView);
            make.width.height.mas_equalTo(16);
        }];
        
        
        
    }
    
    

}

/**
 获取当前登录用户
 
 @return <#return value description#>
 */
- (memberData *)getCurrentLoginMerber {
    memberData *currentMember = nil;
    WH_JXUserObject *currentUser = g_myself;
    for (memberData *member in self.room.members) {
        if (member.userId == [currentUser.userId longLongValue]) {
            currentMember = member;
            break;
        }
    }
    return currentMember;
}

/**
 是否是管理员 群组(role : 1)/管理员(role : 2)均 视为 管理员
 
 @param user <#user description#>
 @return <#return value description#>
 */
- (BOOL)isManger:(memberData *)user {
    return [user.role intValue] == 1 || [user.role intValue] == 2;
}

- (NSString *)dateTimeDifferenceWithStartTime:(NSNumber *)compareDate {
    NSInteger timeInterval = [[NSDate date] timeIntervalSince1970] - [compareDate integerValue];
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"%d%@",(int)timeInterval,Localized(@"SECONDS_AGO")];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"MINUTES_AGO")];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_HoursAgo")];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_DaysAgo")];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_MonthAgo")];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_YearsAgo")];
    }
    
    return  result;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
