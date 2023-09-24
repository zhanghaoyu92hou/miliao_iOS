//
//  newVersion.h
//  sjvodios
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WH_VersionManageTool : NSObject{
    NSMutableDictionary* _msg;
}

@property(strong,nonatomic) NSString* ftpHost;//!<FTP主机
@property(strong,nonatomic) NSString* ftpUsername;//!<FTP用户名
@property(strong,nonatomic) NSString* ftpPassword;//!<FTP密码

@property(strong,nonatomic) NSString* aboutUrl;//!<关于界面Url
@property(strong,nonatomic) NSString* buyUrl;//!<促销Url
@property(strong,nonatomic) NSString* helpUrl;//!<使用帮助
@property(strong,nonatomic) NSString* softUrl;//!<新版本的下载Url，分苹果安卓
@property(strong,nonatomic) NSString* shareUrl;//!<分享后，访问的Url

@property(strong,nonatomic) NSString* website;//!<官方网址
@property(strong,nonatomic) NSString* backUrl;//!<后台api入口
@property(strong,nonatomic) NSString* apiUrl;//!<java api入口
@property(strong,nonatomic) NSString* uploadUrl;//!<上传文件的前缀
@property(strong,nonatomic) NSString* downloadUrl;//!<下载文件的前缀
@property(strong,nonatomic) NSString* downloadAvatarUrl;//!<下载头像的前缀

@property(strong,nonatomic) NSString* XMPPDomain;//!<tigase的域名
@property(strong,nonatomic) NSString* XMPPHost;//!<tigase的域名
@property(assign,nonatomic) NSInteger XMPPHostPort;//!<端口号
@property(assign,nonatomic) int XMPPTimeout;    //!<xmpp超时时间
@property(assign,nonatomic) int XMPPPingTime;    //!<xmpp ping时间间隔
@property(strong,nonatomic) NSString* isOpenSMSCode;//!<是否打开短信验证码
@property(strong,nonatomic) NSString *isOpenReceipt;//!< 是否开启发送回执
@property(strong,nonatomic) NSString *isOpenCluster;//!< 是否开启集群
@property(strong,nonatomic) NSString *isOpenOSStatus;//!< 是否开启OBS上传功能

@property(strong,nonatomic) NSString *endPoint;//!<访问点

@property(strong,nonatomic) NSString *accessSecretKey;//!<sk   obs 密钥  配合 ak 使用  已通过 RSA 加密
@property(strong,nonatomic) NSString *accessKeyId;//!<ak  obs 用户 唯一 表示  ，已通过 RSA 加密
@property(strong,nonatomic) NSString *bucketName;//!<桶 名称  服务器提供，所有上传文件存入 此桶
@property(strong,nonatomic) NSString *osType;//!<"1：华为云，2：腾讯云",
@property(strong,nonatomic) NSString *osAppId;//!<腾讯云id
@property(strong,nonatomic) NSString *location;//!<访问区域 服务器已为桶配置 无需配置
/*
 OBS授权ID与OBS授权Secret需要使用RSA公钥解密：
 MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDg/CxgoI8m6EXa6QJsleT1k+X6
 Cg2cGC2aS9il05kW7zfIgoIUwqGO6EXlcIWsRFgJQWvxS94vtbbCWqC9Os4SvfazikT8T
 myQtCNnfGSqM7eZKql/jR6XAGBEN4OIQOrtb8GdO4PSpi5NhBziaGEGeSC4LmmolFic
 9Fm6FHYD4wIDAQAB
 */

@property(strong,nonatomic) NSString* meetingHost;//!<视频会议的主机
@property(strong,nonatomic) NSString *jitsiServer;//!<jitsi音视频

@property (nonatomic, strong) NSString *fileValidTime;

@property(strong,nonatomic) NSString* version;//!<目前版本
@property(strong,nonatomic) NSString* theNewVersion;//!<最新版本
@property(strong,nonatomic) NSString* versionRemark;//!<新版本说明
@property(strong,nonatomic) NSString* disableVersion;//!<禁用版本列表
@property(strong,nonatomic) NSString* message;//!<通知
@property(strong,nonatomic) NSString* iosDisable;//!< 禁用以下版本号
@property(strong,nonatomic) NSString* appleId;//!< appleId 用于跳转App Store
@property (nonatomic, strong) NSNumber *hideSearchByFriends; //!< 是否隐藏好友搜索功能 0:隐藏 1：开启
@property(strong,nonatomic) NSString* companyName;//!< 公司名称
@property(strong,nonatomic) NSString* copyright;//!< appleId 版权信息
@property (nonatomic, strong) NSNumber *regeditPhoneOrName; //!< 0：使用手机号注册，1：使用用户名注册
@property (nonatomic, strong) NSNumber *lastLoginType; //!< 记录最后一次登录方式 0：使用手机号注册，1：使用用户名注册
@property (nonatomic, strong) NSNumber *registerInviteCode; //!<  注册邀请码   0：关闭,1:开启一对一邀请（一码一用，且必填），2:开启一对多邀请（一码多用，选填项）
@property (nonatomic, strong) NSNumber *nicknameSearchUser; //!<昵称搜索用户  0:关闭 1:精确搜索 2:模糊搜索   默认模糊搜索

@property (nonatomic, strong) NSNumber *isCommonFindFriends; //!< 普通用户是否能搜索好友 0:允许 1：不允许
@property (nonatomic, strong) NSNumber *isCommonCreateGroup; //!< 普通用户是否能建群 0:允许 1：不允许
@property (nonatomic, strong) NSNumber *isOpenPositionService; //!< 是否开启位置相关服务 0：开启 1：关闭

@property (nonatomic, strong) NSString *headBackgroundImg;//!< (发现界面)头部导航背景图

@property (nonatomic ,assign) NSNumber *isThirdPartyLogins; //!<是否第三方登录

@property (nonatomic, strong) NSNumber *isNodesStatus; //!< 是否支持多节点服务 0：不支持 1：支持
@property (nonatomic, strong) NSArray *nodesInfoList; //!< 如果支持多节点,存放多节点的相关信息
@property (nonatomic, strong) NSString *isOpenRegister; //是否允许用户注册

@property (nonatomic, strong) NSDictionary *tabBarConfigList;

@property (nonatomic, strong) NSNumber *isWithdrawToAdmin; //!< 是否开启提现到台 1 是开启
@property (nonatomic, strong) NSString *minWithdrawToAdmin; //!<    提现到后台，最小金额 单位 是 元
@property (nonatomic, strong) NSString *transferRate;   //提现的手续费
@property (nonatomic, strong) NSNumber *isUserSignRedPacket; //!<   是否开启签到红包
@property(nonatomic)int uploadMaxSize;//!<  上传文件和视频最大时长 (单位MByte)
@property(nonatomic)int videoMaxLen;//!<    录像最大时长
@property(nonatomic)int audioMaxLen;//!<    录音最大时长
@property(nonatomic)int money_login;//!<    登录送多少
@property(nonatomic)int money_share;//!<    分享送多少
@property(nonatomic)int money_intro;//!<    推荐送多少
@property(nonatomic)int money_videoMeeting;//!< 视频会议扣多少
@property(nonatomic)int money_audioMeeting;//!< 音频会议扣多少
@property(nonatomic)BOOL isCanChange;//!<   礼物能兑换
@property(strong,nonatomic) NSString* appUrlNew;//!<    新版本AppStoreUrl
@property (nonatomic, strong) NSNumber *isQestionOpen;//!<  是否开启密保问题

@property (nonatomic ,strong) NSNumber *aliPayStatus;  //!< 支付宝充值状态 1:开启 2：关闭
@property (nonatomic ,strong) NSNumber *aliWithdrawStatus; //!< 支付宝提现状态 1:开启 2：关闭
@property (nonatomic ,strong) NSNumber *wechatPayStatus ; //!<  微信充值状态1：开启 2：关闭
@property (nonatomic ,strong) NSNumber *wechatWithdrawStatus; //!<微信提现状态1：开启 2：关闭

@property (nonatomic, strong) NSNumber *yunPayStatus; //是否开启云支付(银行转账) 新版本1:开启 2：关闭

@property (nonatomic, strong) NSString *wechatAppId; //!<微信登录的Appid

@property (nonatomic, strong) NSString *qqLoginAppId;  //!< QQ登录AppId

//第三方登录是否开启
@property (nonatomic ,strong) NSNumber *aliLoginStatus;  //!< 支付宝登录状态：1：开启 2：关闭
@property (nonatomic ,strong) NSNumber *qqLoginStatus; //!< QQ登录状态：1：开启 2：关闭
@property (nonatomic ,strong) NSNumber *wechatLoginStatus; //!<  微信登录状态：1：开启 2：关闭

//个人资料中设置
@property (nonatomic ,strong) NSNumber *isOpenTwoBarCode;//!< 是否启用个人二维码 1:开启  0:关闭
@property (nonatomic ,strong) NSNumber *isOpenTelnum;//!< 是否启用个人手机号码 1:开启 0:关闭

@property (nonatomic ,copy) NSString *hmPayStatus; //hmPayStatus   黑马支付充值状态1：开启 2：关闭
@property (nonatomic ,copy) NSString *hmWithdrawStatus; //hmWithdrawStatus    Int    黑马支付提现状态1：开启 2：关闭

@property (nonatomic ,copy) NSString *isAudioStatus; //是否开启音视频  0 关闭 1开启

@property (nonatomic ,copy) NSString *maxSendRedPagesAmount; //发红包最大金额
@property (nonatomic ,copy) NSString *isDelAfterReading; //是否开启阅后即焚

@property(nonatomic,copy) void (^block)(void);
-(void)getDefaultValue;
-(void)didReceive:(NSDictionary*)dict;
-(void)showDisableUse;



@end
