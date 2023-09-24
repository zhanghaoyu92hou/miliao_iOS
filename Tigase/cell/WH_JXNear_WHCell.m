//
//  JXExpertCell.m
//  Tigase_imChatT
//
//  Created by MacZ on 2016/10/20.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXNear_WHCell.h"
//#import "WH_JXVideoPlayer.h"

@interface WH_JXNear_WHCell (){
//    WH_JXVideoPlayer* _player;
//    UIImageView *_jobSalaryImg;
//    UILabel *_jobSalary;
}

@property (nonatomic,strong) UIImageView *imgview;
@property (nonatomic,strong) UILabel *skillName;

//@property (nonatomic,strong) UIImageView *salaryImg;
@property (nonatomic,strong) UILabel *salary; //创建时间
@property (nonatomic,strong) UILabel *loginTime; //登录时间
//@property (nonatomic,strong) UIImageView *siteImg;
//@property (nonatomic,strong) UIImageView *playImgV;
//@property (nonatomic,strong) UILabel *site; //工作地点
//@property (nonatomic,strong) UIImageView *experienceImg;
//@property (nonatomic,strong) UILabel *experience; //工作年限
//@property (nonatomic,strong) UIImageView *academyImg;
//@property (nonatomic,strong) UILabel *academy; //学历要求

@property (nonatomic,strong) WH_JXImageView *headImg;
@property (nonatomic,strong) UILabel *expertName;
//@property (nonatomic,strong) UILabel *distance;
//头像上性别
@property (nonatomic,strong) UIImageView *sexImgview;

// 广告标识
//@property (nonatomic, strong) UILabel *adLabel;

@property (nonatomic,strong) UILabel *phoneNum;
@property (nonatomic,strong) UILabel *callTime;
@property (nonatomic,strong) UILabel *authLabel;

@end

@implementation WH_JXNear_WHCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.layer.cornerRadius = 5;
//        self.layer.masksToBounds = YES;
        
        [self customViewWithFrame:frame];
//        _player= [[WH_JXVideoPlayer alloc] initWithParent:_imgview];
    }
    
    return self;
}

- (void)customViewWithFrame:(CGRect)frame{
    self.contentView.clipsToBounds = YES;
    //专长图片
    _imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
    _imgview.image = [UIImage imageNamed:@"loading"];
    _imgview.userInteractionEnabled = YES;
    [self.contentView addSubview:_imgview];
    
//    _playImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    _playImgV.center = _imgview.center;
////    _playImgV.backgroundColor = [UIColor redColor];
//    _playImgV.image = [UIImage imageNamed:@"开始"];
////    _playImgV.userInteractionEnabled = YES;
//    [self.contentView addSubview:_playImgV];

    
//    NSString *perStr = @"大神直播";
//    
//    CGSize perSize = [perStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(13.0)} context:nil].size;
//    self.adLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, perSize.width + 6, 18)];
//    self.adLabel.text = perStr;
//    self.adLabel.textAlignment = NSTextAlignmentCenter;
//    self.adLabel.layer.cornerRadius = 5;
//    self.adLabel.layer.masksToBounds = YES;
//    self.adLabel.backgroundColor = THEMECOLOR;
//    self.adLabel.textColor = [UIColor whiteColor];
//    self.adLabel.font = sysFontWithSize(14.0);
//    [self.contentView addSubview:self.adLabel];
//    self.adLabel.hidden = YES;
    
    //专长名
    _skillName = [[UILabel alloc] initWithFrame:CGRectMake(5, _imgview.frame.size.height + 5, frame.size.width - 5*2, 15)];
    _skillName.text = Localized(@"Setting_CodecsViewController_Title");
    _skillName.font = sysFontWithSize(15);
    _skillName.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_skillName];
    
    //专家头像
    _headImg = [[WH_JXImageView alloc] init];
    _headImg.frame = CGRectMake(_skillName.frame.origin.x, _skillName.frame.origin.y + _skillName.frame.size.height + 7, 33, 33);
    _headImg.userInteractionEnabled = NO;
    [_headImg headRadiusWithAngle:_headImg.frame.size.width * 0.5];
    
    _headImg.image = [UIImage imageNamed:@"11111"];
    [self.contentView addSubview:_headImg];
//    [_headImg release];
    
    if (!_sexImgview) {
        _sexImgview = [[UIImageView alloc] initWithFrame:CGRectMake(_headImg.frame.origin.x+_headImg.frame.size.width-8, _headImg.frame.origin.y-2, 10, 10)];
        //            _sexImgview.image = [UIImage imageNamed:@"manicon"];
        [self.contentView addSubview:_sexImgview];
//        [_sexImgview release];
    }
    
    //专家名
    _expertName = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.frame.origin.x + _headImg.frame.size.width + 5, _headImg.frame.origin.y, 75, 15)];
    _expertName.text = Localized(@"UserInfoVC_Fans");
    _expertName.font = sysFontWithSize(13);
    _expertName.textColor = [UIColor darkGrayColor];
//    _expertName.center = CGPointMake(_expertName.center.x, _headImg.center.y-6);
    [self.contentView addSubview:_expertName];
    
    //18938880001
    if ([g_myself.telephone isEqualToString:@"18938880001"]) {
        // 手机号
        _phoneNum = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 140, _skillName.frame.origin.y, 140, 12)];
        _phoneNum.text = @"12345678910";
        _phoneNum.font = sysFontWithSize(13);
        _phoneNum.textAlignment = NSTextAlignmentRight;
        _phoneNum.textColor = [UIColor darkGrayColor];
        //    _expertName.center = CGPointMake(_expertName.center.x, _headImg.center.y-6);
        [self.contentView addSubview:_phoneNum];
        
        _callTime = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 140, CGRectGetMaxY(_phoneNum.frame), 140, 12)];
        _callTime.font = sysFontWithSize(13);
        _callTime.textAlignment = NSTextAlignmentRight;
        _callTime.textColor = [UIColor darkGrayColor];
        //    _expertName.center = CGPointMake(_expertName.center.x, _headImg.center.y-6);
        [self.contentView addSubview:_callTime];
        
        // 登录时间
        _loginTime = [[UILabel alloc] initWithFrame:CGRectMake(_expertName.frame.origin.x + _headImg.frame.size.width + 5, _expertName.frame.origin.y, 75, 15)];
        _loginTime.text = @"1970-1-1";
        _loginTime.font = sysFontWithSize(13);
        _loginTime.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_loginTime];
        
        
        _authLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _authLabel.hidden = YES;
        _authLabel.textColor = [UIColor redColor];
        _authLabel.font = [UIFont systemFontOfSize:15.0];
        _authLabel.text = Localized(@"JX_TheAuthenticated");
        [_imgview addSubview:_authLabel];
    }
    

    _salary = [self labelWithTitle:Localized(@"JX_ChinaMoney") textColor:[UIColor darkGrayColor] font:sysFontWithSize(12)];
    _salary.frame = CGRectMake(_expertName.frame.origin.x, _expertName.frame.origin.y+_expertName.frame.size.height+3, 80, 12);
    [self.contentView addSubview:_salary];

    
}
- (UILabel *)labelWithTitle:(NSString *)title textColor:(UIColor *)color font:(UIFont *)font{
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = color;
    label.font = font;
    
    return label;
}
- (void)doRefreshNearExpert:(NSDictionary *)dict{
    
    if (!dict) {
        return;
    }
    
    
//    [cell setTitle:[dict objectForKey:@"nickname"]];
//    [cell setSuLabel:[self getDistance:indexPath.row]];
//    cell.userId = [[dict objectForKey:@"userId"] stringValue];
//    [cell getHeadImage];
//    int n = [[[dict objectForKey:@"loginLog"] objectForKey:@"loginTime"] longLongValue];
//    [cell setForTimeLabel:[TimeUtil getTimeStrStyle1:n]];
    
    
    
    _skillName.text = [dict objectForKey:@"nickname"];
    _expertName.text = [self getDistance:dict];
    CGSize size = [_expertName.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_expertName.font} context:nil].size;
    _expertName.frame = CGRectMake(_expertName.frame.origin.x, _expertName.frame.origin.y, size.width + 2, _expertName.frame.size.height);
    _loginTime.frame = CGRectMake(CGRectGetMaxX(_expertName.frame), _loginTime.frame.origin.y, _loginTime.frame.size.width, _loginTime.frame.size.height);
    long long n = [[[dict objectForKey:@"loginLog"] objectForKey:@"loginTime"] longLongValue];
    long long m = [[dict objectForKey:@"createTime"] longLongValue];
    _loginTime.text = [TimeUtil getTimeStrStyle1:n];
    _salary.text = [TimeUtil getTimeStrStyle1:m];
    NSString *telStr = [NSString stringWithFormat:@"%@",dict[@"telephone"]];
    if (telStr.length>2) {
        if ([[dict[@"telephone"] substringToIndex:2] isEqualToString:@"86"]) {
            _phoneNum.text = [dict[@"telephone"] substringFromIndex:2];
        }else {
            _phoneNum.text = dict[@"telephone"];
        }
    }
    
    NSDate *date = [g_myself.phoneDic objectForKey:_phoneNum.text];
    if (date) {
        _callTime.hidden = NO;
        long long n = (long long)[date timeIntervalSince1970];
        NSString *time = [TimeUtil getTimeStrStyle1:n];
        NSString *str = [NSString stringWithFormat:@"%@:%@",Localized(@"JX_HaveToDial"),time];
        _callTime.text = str;
    }else {
        _callTime.hidden = YES;
    }
    
    if ([[dict objectForKey:@"isAuth"] intValue] == 1) {
        _authLabel.hidden = NO;
    }else {
        _authLabel.hidden = YES;
    }

    
    _imgview.image = nil;
    _headImg.image = nil;
    
    [g_server WH_getHeadImageLargeWithUserId:[dict objectForKey:@"userId"] userName:[dict objectForKey:@"nickname"] imageView:_imgview];
    

    
    [g_server WH_getHeadImageLargeWithUserId:[dict objectForKey:@"userId"] userName:[dict objectForKey:@"nickname"] imageView:_headImg];
    
}

#pragma mark   --------------获取距离-------------
- (NSString *)getDistance:(NSDictionary* ) dict{
    
    NSString* diploma = [g_constant.diploma objectForKey:[dict objectForKey:@"dip"]];
    NSString* salary  = [g_constant.salary objectForKey:[dict objectForKey:@"salary"]];

    double latitude  = [[[dict objectForKey:@"loc"] objectForKey:@"lat"] doubleValue];
    double longitude = [[[dict objectForKey:@"loc"] objectForKey:@"lng"] doubleValue];
    double m = [g_server WH_getLocationWithLatitude:latitude longitude:longitude];
    NSString* s=[NSString stringWithFormat:@"%.2lfkm ",m/1000];
    
    //        if(address)
    //            s = [s stringByAppendingString:address];
    if(diploma){
        s = [s stringByAppendingString:@" | "];
        s = [s stringByAppendingString:diploma];
    }
    if(salary){
        s = [s stringByAppendingString:@" | "];
        s = [s stringByAppendingString:salary];
    }
    if (latitude <= 0 && longitude <= 0 && ![g_myself.telephone isEqualToString:@"18938880001"]) {
        // 未开启位置权限
        s = Localized(@"JX_FriendLocationNotEnabled");
    }
    
    return s;
}


- (void)sp_checkNetWorking {
    NSLog(@"Get User Succrss");
}
@end
