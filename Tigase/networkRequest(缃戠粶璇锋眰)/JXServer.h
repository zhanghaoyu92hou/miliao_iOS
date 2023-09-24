//
//  JXServer.h
//  sjvodios
//
//  Created by  on 19-5-5-22.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ATMHud.h"
#import <AddressBook/AddressBook.h>
#import "JXAddressBook.h"

@class AppDelegate;
@class WH_JXConnection;
@class WH_JXImageView;
@class McDownload;
@class WeiboReplyData;
@class jobData;
@class JXExam;
@class companyData;
@class WH_SearchData;
@class WH_RoomData;
@class memberData;
@class WH_JXLocation;

#define WH_page_size 12
#define WH_login_view -5100001
#define WH_connect_timeout 15
#define WH_did_yes 0
#define WH_did_no 1
#define WH_showImage_time 2.0

#define WH_show_error 1
#define WH_hide_error 0

#define wh_act_Register @"user/register" //注册
#define wh_act_UserLogin @"user/login" //登录
#define wh_act_UserLogout @"user/logout" //登出
#define wh_act_AppStartupImage @"basic/media/startup"    //获取启动图片

//用户签到
#define wh_act_UserSign @"extend/signIn" //立即签到
//获取用户签到信息
#define wh_act_SingWeek @"extend/getUserSignDateByWeek"
//获取用户某月签到信息
#define wh_act_SingMouth @"extend/getUserSignDateByMonth"
//底部导航自定义菜单
#define wh_act_CustomMenu @"console/appDiscoverList"
//进入后台，纪录数据
#define wh_act_OutTime @"user/outtime"
//获取当前服务器时间
#define wh_act_getCurrentTime @"getCurrentTime"

//自动登录
#define wh_act_UserLoginAuto @"user/login/auto"
//搜索用户
#define wh_act_UserSearch @"user/query"
//搜索公众号列表
#define wh_act_PublicSearch @"public/search/list"
//获取信息
#define wh_act_UserGet @"user/get"
//更新信息
#define wh_act_UserUpdate @"user/update"
//设置token
#define wh_act_PKPushSetToken @"user/apns/setToken"
//绑定用户
#define wh_act_BindUser @"user/acct/add"
//解绑用户
#define wh_act_unbindUser @"user/acct/delete"
//添加照片
#define wh_act_PhotoAdd @"user/photo/add"
//删除照片
#define wh_act_PhotoDel @"user/photo/delete"
//更新照片
#define wh_act_PhotoMod @"user/photo/update"
//照片列表
#define wh_act_PhotoList @"user/photo/list"
//设置头像
#define wh_act_SetHeadImage @"avatar/set"
//密码修改
#define wh_act_PwdUpdate @"user/password/update"
//忘记密码
#define wh_act_PwdReset @"user/password/reset"
//举报用户
#define wh_act_Report @"user/report"


//上传文件
#define wh_act_UploadFile @"upload/UploadServlet"
//上传头像
#define wh_act_UploadHeadImage @"upload/UploadAvatarServlet"
//上传群组头像
#define wh_act_SetGroupAvatarServlet @"upload/GroupAvatarServlet"
//检测手机号
#define wh_act_CheckPhone @"verify/telephone"
//获取图片验证码
#define wh_act_GetCode @"getImgCode"
//发送短信
#define wh_act_SendSMS @"basic/randcode/sendSms"
//获取配置信息
#define wh_act_Config @"config"
//删除朋友
#define wh_act_FriendDel @"friends/delete"
//加关注
#define wh_act_AttentionAdd @"friends/attention/add"
//取消关注
#define wh_act_AttentionDel @"friends/attention/delete"
// 更新朋友的聊天消息过期时间
#define wh_act_FriendsUpdate @"friends/update"
//更改好友验证设置
#define wh_act_SettingsUpdate @"user/settings/update"
//获取设置
#define wh_act_Settings @"user/settings"
//关注列表
#define wh_act_AttentionList @"friends/attention/list"
//加入黑名单
#define wh_act_BlacklistAdd @"friends/blacklist/add"
#define wh_act_BlacklistDel @"friends/blacklist/delete" //取消黑名单
#define wh_act_BlacklistList @"friends/blacklist" //黑名单列表
#define wh_act_FriendRemark @"friends/remark" //备注好友名

#define wh_act_MsgGet @"b/circle/msg/get" //获取单条生活圈
#define wh_act_MsgList @"b/circle/msg/list" //获取生活圈列表
#define wh_act_MsgAdd @"b/circle/msg/add" //加生活圈
#define wh_act_MsgDel @"b/circle/msg/delete" //删除生活圈
#define wh_act_PraiseList @"b/circle/msg/praise/list" //赞列表
#define wh_act_PraiseAdd @"b/circle/msg/praise/add" //加赞
#define wh_act_PraiseDel @"b/circle/msg/praise/delete" //取消赞
#define wh_act_CommentList @"b/circle/msg/comment/list" //评论列表
#define wh_act_CommentAdd @"b/circle/msg/comment/add" //评论
#define wh_act_CommentDel @"b/circle/msg/comment/delete" //取消评论
#define wh_act_GiftAdd @"b/circle/msg/gift/add" //送礼

#define wh_act_MsgListNew @"b/circle/msg/square"//最新生活圈
#define wh_act_MsgListUser @"b/circle/msg/user"//个人主页
#define wh_act_ShengHuoQuanDeleteCollect @"b/circle/msg/deleteCollect"//朋友圈取消收藏


#define wh_act_resumeUpdate @"resume/update"

#define wh_act_resumeList @"resume/list"
#define wh_act_resumeUpdateE @"resume/e/update"
#define wh_act_resumeUpdateW @"resume/w/update"
#define wh_act_resumeUpdateP @"resume/projectList/update"

#define wh_act_payBuy @"pay_goods/buy" //下单
#define wh_act_bizList @"biz_goods/list" //商品列表
#define wh_act_bizBuy @"biz_goods/buy" //下单

#define wh_act_nearbyUser @"nearby/user"
#define wh_act_nearNewUser @"nearby/newUser"//附近新用户

#define wh_act_deleteMemebers @"room/members/delete" //批量删除群成员

#define wh_act_roomAdd @"room/add"//创建群组
#define wh_act_roomDel @"room/delete"//删除
#define wh_act_roomGet @"room/get"//获取
#define wh_act_roomSet @"room/update"//设置
#define wh_act_roomList @"room/list"//获取群主列表
#define wh_act_roomListHis @"room/list/his"//
#define wh_act_roomGetRoom @"room/getRoom" // 获取群组信息
#define wh_act_roomMemberGetMemberListByPage @"room/member/getMemberListByPage"    // 群成员分页获取

#define wh_act_roomMemberList @"room/member/list"//获取成员列表
#define wh_act_roomMemberGet @"room/member/get"//获取群成员
#define wh_act_roomMemberDel @"room/member/delete"//删除群成员
#define wh_act_roomMemberSet @"room/member/update"//设置群成员
#define wh_act_roomSetAdmin @"room/set/admin"//设置管理员
#define wh_act_roomSetInvisibleGuardian @"room/setInvisibleGuardian"//设置隐身人、监控人
#define wh_act_roomTransfer    @"room/transfer"    // 群主转让
#define wh_act_roomDeleteNotice    @"room/notice/delete"    // 删除群组公告

#define wh_act_shareAdd @"room/add/share"//添加共享文件
#define wh_act_shareList @"room/share/find"//获取文件列表
#define wh_act_shareGet @"room/share/get"//下载单个文件
#define wh_act_shareDelete @"room/share/delete"//删除文件

#define wh_act_setPushChannelId @"user/channelId/set"
#define wh_act_getUserMoeny @"user/getUserMoeny"//获取余额
#define wh_act_getSign @"user/recharge/getSign" //获取签名
#define wh_act_getAliPayAuthInfo @"user/bind/getAliPayAuthInfo" //获取支付宝授权authInfo
#define wh_act_aliPayUserId @"user/bind/aliPayUserId" //保存支付宝用户Id
#define wh_act_alipayTransfer @"alipay/transfer" //支付宝提现

#define wh_act_codePayment @"pay/codePayment"//二维码支付
#define wh_act_codeReceipt @"pay/codeReceipt"//二维码收款
#define wh_act_receiveTransfer @"tigTransfer/receiveTransfer"//接受转账
#define wh_act_getTransferInfo @"tigTransfer/getTransferInfo" //获取转账信息
#define wh_act_getConsumeRecordList @"friend/consumeRecordList" //好友交易记录明细
#define wh_act_sendTransfer @"tigTransfer/sendTransfer" //转账
#define act_sendRedPacket @"redPacket/sendRedPacket"//发红包
#define wh_act_sendRedPacketV1 @"redPacket/sendRedPacket/v1"//发红包(新)
#define wh_act_getRedPacket @"redPacket/getRedPacket"//获取红包详情
#define wh_act_openRedPacket @"redPacket/openRedPacket"//领取红包
#define wh_act_redPacketGetSendRedPacketList @"redPacket/getSendRedPacketList"// 获取发送的红包
#define wh_act_redPacketGetRedReceiveList @"redPacket/getRedReceiveList"   // 收到的红包
#define wh_act_redPacketReply @"redPacket/reply"   // 红包回复
#define wh_act_userWithdrawMethodSet @"user/withdrawMethodSet"//增加提现账号
#define wh_act_userWithdrawMethodGet @"user/withdrawMethodGet"//获取提现账号列表
#define wh_act_userWithdrawMethodDelete @"user/withdrawMethodDelete"//删除提现账号

#define wh_act_consumeRecord @"user/consumeRecord/list"//交易记录
#define wh_act_readDelMsg @"tigase/deleteMsg"//阅后即焚
#define wh_act_creatCompany @"org/company/create"//创建公司
#define wh_act_setManager @"org/setManager"//指定管理员
#define wh_act_getCompany @"org/company/getByUserId"//自动查找公司
#define wh_act_managerList @"org/company/managerList"//管理员列表
#define wh_act_updataCompanyName @"org/company/modify"//修改公司名
#define wh_act_changeNotice @"org/company/changeNotice"//更改公司公告
#define wh_act_seachCompany @"org/company/search"//查找公司
#define wh_act_deleteCompany @"org/company/delete"//删除公司
#define wh_act_createDepartment @"org/department/create"//创建部门
#define wh_act_updataDepartmentName @"org/department/modify"//修改部门名称
#define wh_act_deleteDepartment @"org/department/delete"//删除部门
#define wh_act_addEmployee @"org/employee/add"//添加员工
#define wh_act_deleteEmployee @"org/employee/delete"//删除员工
#define wh_act_modifyDpart @"org/employee/modifyDpart"//更改员工部门
#define wh_act_empList @"org/departmemt/empList"//部门员工列表
#define wh_act_modifyRole @"org/employee/modifyRole"//更改员工角色
#define wh_act_modifyPosition @"org/employee/modifyPosition"//更改员工职位(头衔）
#define wh_act_companyList @"org/company/list"//公司列表
#define wh_act_departmentList @"org/department/list"//部门列表

#define wh_act_employeeList @"org/employee/list"//员工列表
#define wh_act_companyInfo @"org/company/get"//公司详情
#define wh_act_employeeInfo @"org/employee/get"//员工详情
#define wh_act_dpartmentInfo @"org/department/get"//部门详情
#define wh_act_companyNum @"org/company/empNum"//公司员工人数
#define wh_act_dpartmentNum @"org/department/empNum"//部门员工数量
#define wh_act_companyQuit @"org/company/quit"//退出公司/解散公司




#define wh_act_tigaseGetLastChatList   @"tigase/getLastChatList"   //  获取首页的最近一条的聊天记录列表
#define wh_act_tigaseMsgs @"tigase/tig_msgs" // 获取单聊漫游聊天记录
#define wh_act_tigaseMucMsgs @"tigase/tig_muc_msgs"  // 获取群聊漫游聊天记录

#define wh_act_publicMenuList @"public/menu/list"  // 公众号菜单
#define wh_act_tigaseDeleteMsg @"tigase/deleteMsg" // 撤回&删除聊天记录
#define wh_act_EmptyMsg    @"tigase/emptyMyMsg" // 清空聊天记录
#define wh_act_FriendsUpdateOfflineNoPushMsg @"friends/update/OfflineNoPushMsg"    // 消息免打扰

#define wh_act_userEmojiAdd @"user/emoji/add"  // 收藏表情
#define wh_act_userEmojiDelete @"user/emoji/delete"    // 取消收藏
#define wh_act_userEmojiList @"user/emoji/list"   // 收藏表情列表
#define wh_act_userCollectionList @"user/collection/list"   // 收藏列表

#pragma mark - 自定义表情相关
#define wh_act_emojiStoreList @"user/emojiUserStoreList/page"  // 表情商店
#define wh_act_emojiMyDownListPage @"user/emojiUserList/page"    // 用户下载的表情
#define wh_act_emojiUserListAdd @"user/emojiUserList/add"   // 用户下载表情添加
#define wh_act_emojiUserListDelete @"user/emojiUserList/delete"   // 用户移出表情

#define wh_act_userCourseAdd       @"user/course/add"      // 添加课程
#define wh_act_userCourseList      @"user/course/list"     // 查询课程
#define wh_act_userCourseUpdate    @"user/course/update"   // 修改课程
#define wh_act_userCourseDelete    @"user/course/delete"   // 删除课程
#define wh_act_userCourseGet       @"user/course/get"      // 课程详情

#define wh_act_userChangeMsgNum    @"user/changeMsgNum"     // 更新角标
#define wh_act_roomMemberSetOfflineNoPushMsg   @"room/member/setOfflineNoPushMsg"  // 设置群消息免打扰

// 标签
#define wh_act_FriendGroupAdd      @"friendGroup/add" // 添加标签
#define wh_act_FriendGroupUpdateGroupUserList  @"friendGroup/updateGroupUserList"// 修改好友标签
#define wh_act_FriendGroupUpdate   @"friendGroup/update"  // 更新标签名
#define wh_act_FriendGroupDelete   @"friendGroup/delete"  // 删除标签
#define wh_act_FriendGroupList     @"friendGroup/list"    // 标签列表
#define wh_act_FriendGroupUpdateFriend     @"friendGroup/updateFriend"// 修改好友的  分组Id列表

#define wh_act_UploadCopyFileServlet @"upload/copyFile" // 拷贝文件

// 通讯录
#define wh_act_AddressBookUpload @"addressBook/upload" // 上传本地联系人
#define wh_act_AddressBookGetAll @"addressBook/getAll" // 查询通讯录好友
#define wh_act_FriendsAttentionBatchAdd    @"friends/attention/batchAdd"   // 联系人内加好友 不需要验证

#define wh_act_UserBindWXCode @"user/bind/wxcode" // 用户绑定微信code，获取openid
#define wh_act_TransferWXPay @"transfer/wx/pay" // 余额微信提现
#define wh_act_CheckPayPassword @"user/checkPayPassword" // 检查支付密码是否是否正确
#define wh_act_UpdatePayPassword @"user/update/payPassword" // 更新支付密码

#define wh_act_UserOpenMeet @"user/openMeet"   // 获取音视频域名

#define wh_act_CircleMsgPureVideo  @"b/circle/msg/pureVideo"  // 朋友圈纯视频接口
#define wh_act_MusicList @"music/list"    // 获取音乐接口

#define wh_act_OpenAuthInterface   @"open/authInterface"  // 第三方权限认证


#define wh_act_GetWxOpenId   @"user/getWxOpenId"  // 第三方登录获取openid
#define act_sdkLogin    @"user/sdkLogin"  // 第三方登录接口
#define wh_act_thirdLogin    @"user/bindingTelephone" //第三方登录绑定手机号码
#define wh_act_RegisterSDK    @"user/registerSDK" //第三方登录接口注册


#define act_otherLogin     @"user/otherLogin"//第三方登录测试接口(新添加登录既绑定逻辑) 注释掉则用老的第三方登录逻辑
//用户绑定手机号（新版）
#define act_otherBindPhonePassWord     @"user/otherBindPhonePassWord"
//第三方登录设置邀请码（新版）
#define act_otherSetInviteCode     @"user/otherSetInviteCode"
//用户绑定第三方账号（新版）
#define act_otherBindUserInfo     @"user/otherBindUserInfo"



#define wh_act_openCodeAuthorCheck     @"open/codeAuthorCheck" //网页第三方认证
#define wh_act_userCheckReportUrl  @"user/checkReportUrl" //检查网址是不是被锁定
#define wh_act_getBindInfo     @"user/getBindInfo" //第三方绑定
#define wh_act_unbind    @"user/unbind" //第三方解绑

// 面对面建群
#define wh_act_RoomLocationQuery @"room/location/query"   // 面对面建群查询
#define wh_act_RoomLocationJoin  @"room/location/join"    // 面对面建群加入
#define wh_act_RoomLocationExit  @"room/location/exit"    // 面对面建群退出

// Tigase支付
#define wh_act_PayGetOrderInfo @"pay/getOrderInfo"     //接口获取订单信息
#define wh_act_PayPasswordPayment  @"pay/passwordPayment"  //输入密码后支付接口

//推广邀请
#define wh_act_InviteGetUserInviteInfo  @"invite/getUserInvite"//查询用户推广邀请码信息
#define wh_act_InviteFindUserPassCard @"invite/findUserPassCard"//查询用户通证列表（分页）
#define wh_act_InviteDelUserPassCard @"invite/delUserPassCard" //清除已使用状态的通证
#define wh_act_InviteFindUserInviteMember @"invite/findUserInviteMember" //查询用户邀请人记录（分页）

#define wh_act_NewVersion @"newVersion" //新版本查询接口

#define wh_act_forgetPayPassword @"user/forget/password" //忘记支付密码接口

//用户提现
#define wh_act_TransferToAdmin @"user/transferToAdmin" //用户提现接口

#define wh_act_withdrawWay @"user/getWithdrawWay" //提现到后台的提现方式

#define wh_act_consoleLoginPublicAcc @"mp/loginPublicAcc" //公众号登录

#define wh_act_openLoginPublicOpenAcc @"open/loginPublicOpenAcc" //开放平台登录

#define act_pwsSecList @"question/list" //密保问题列表
#define act_pwsSecSet @"question/set" //密保设置
#define act_pwdSecCheck @"question/check" //!< 密保校验

#define act_getPayMethod @"pay/getPayMethod" //获取支付银行列表
#define act_payGetOrderDetails @"pay/getOrderDetails" // 获取订单详情

//群签到相关
#define act_SignInDetails @"room/signInDetails" //签到详情
#define act_SignInRightNow @"room/signInRightNow" //立即签到
#define act_SignInDate @"room/getSignInDate" //得到签到日期日历
#define act_SignInDetailsRoom @"room/signInDetailsRoom" //签到列表
#define act_ExchangeGift @"room/exchangeGift" //兑换礼物

//银行卡充值相关
#define act_getBankInfoByUserId @"bank/getBankInfoByUserId" //获取自己添加的银行卡列表
#define act_deleteBankInfoById @"bank/delBankInfoById" //删除添加的银行卡
#define act_userBindBandInfo   @"bank/userBindBandInfo" //添加银行卡

//支付系统接口
#define act_portalIndexGetZhxx @"portal/index/GetZhxx" //支付类型接口：
#define act_portalIndexPostCz @"portal/index/PostCz" //提交充值生成订单接口
#define act_portalIndexGetOrder @"portal/index/GetOrder" //显示订单接口
#define act_portalIndexGetCancelOrder @"portal/index/GetCancelOrder" //取消订单接口
#define act_portalIndexGetPayOrder @"portal/index/GetPayOrder" //我已付款接口
#define act_portalIndexGetOrderList @"portal/index/GetOrderList" //充值订单列表
#define act_portalIndexGetOrderDetail @"portal/index/GetOrderDetail" //订单详情接口
#define act_portalIndexPostTb @"portal/index/PostTb" //提币生成订单接口
#define act_portalIndexGetTbinfo @"portal/index/GetTbinfo" //提币信息、等待付币、确认收币、已完成详情接口
#define act_portalIndexGetQrtb @"portal/index/GetQrtb" //确认提币
#define act_portalIndexGetQrsb @"portal/index/GetQrsb" //确认收币
#define act_portalIndexGetMyorder @"portal/index/GetMyorder" //提币列表
#define act_getCircleWithCondition @"b/circle/msg/getMsgWithCondition" //朋友圈模糊搜索
#define act_roomSignInGroup @"room/signInGroup" //群聊积分机器人

//==================扫码登录
#define act_ScanLogin @"user/login/scan" //扫码登录

//xmpp连接异常上报
#define act_LogReport @"logReport"


//删除会话列表需要调用的接口
#define act_deleteOneLastChat @"tigase/deleteOneLastChat"

//h5支付
#define act_h5Payment @"mobile/chongzhi/xlsubmit"

#define act_feedOff @"/messages/feed/off" //关闭第二通道连接
 
#define act_delectRoomMsg @"/tigase/delectRoomMsg" //双向撤回


@protocol JXServerResult;
@class AlixPayResult;
@class loginViewController;
@class TencentOAuth;
@class WBEngine;


@interface JXServer : NSObject<CLLocationManagerDelegate>{
    NSMutableDictionary* _dictWaitViews;
    
//    CLLocationManager *_location;
    int               _locationCount;
    BOOL              _bAlreadyAutoLogin;
    
    NSMutableArray*      _arrayConnections;
    NSMutableDictionary* _dictSingers;
    int _imgSongIndex;
    ATMHud* _hud;
}
@property (nonatomic, strong) WH_VersionManageTool *config;
+ (instancetype)sharedServer;

//签到详情
- (void)requestSignInDetailsWithRoomId:(NSString *)roomId toView:(id)toView;

//立即签到
- (void)requestSignInRightNowWithRoomId:(NSString *)roomId nickName:(NSString *)nickName toView:(id)toView;

//群签到日期
- (void)requestSignInDateWithRoomId:(NSString *)roomId monthStr:(NSString *)monthStr toView:(id)toView;

//签到列表
- (void)requestSignInDetailsListWithRoomId:(NSString *)roomId toView:(id)toView;

//兑换礼物
- (void)requestExchangeGiftWithData:(NSString *)data toView:(id)toView;

//用户签到
- (void)requestUserSignInWithUserId:(NSString *)userId  toView:(id)toView;

//用户签到信息
- (void)requestUserSignHandle7DaySignWithUserId:(NSString *)userId toView:(id)toView ;

//获取用户某月签到信息
- (void)requestUserSignMothWithUserId:(NSString *)userId monthStr:(NSString *)monthStr toView:(id)toView;

//发现界面中的自定义菜单
- (void)requestCustomMenuWithToView:(id)toView;

// 通用接口请求，只是单纯的请求接口，不做其他操作
- (void)requestWithUrl:(NSString *)url toView:(id)toView;

-(WH_JXConnection*)addTask:(NSString*)action param:(NSString*)param toView:(id)toView;
-(void)stopConnection:(id)toView;
-(NSString*)getString:(NSString*)s;

-(void)waitStart:(UIView*)view;
-(void)waitEnd:(UIView*)view;
-(void)waitFree:(UIView*)sender;
-(void)showMsg:(NSString*)s;
-(void)showMsg:(NSString*)s delay:(float)delay;
//-(void)doError:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array resultMsg:(NSString*)string errorMsg:(NSString*)errorMsg;

//-(void)addAnimation:(UIView*)iv time:(int)nTime;
//-(void)addAnimationPage:(UIView*)iv time:(int)nTime;
-(void)locate;
-(void)showLogin;
/*
 * 登录成功信息
 *
 * @dict 登录成功返回数据
 * @user 用户信息
 */
-(void)doLoginOK:(NSDictionary*)dict user:(WH_JXUserObject*)user;
-(void)doSaveUser:(NSDictionary*)dict;
- (void)getCurrentTimeToView:(id)toView;
-(void)login:(WH_JXUserObject*)user loginType:(NSInteger)type toView:(id)toView;
-(void)login:(WH_JXUserObject*)user toView:(id)toView;
-(void)logout:(NSString *)areaCode toView:(id)toView;

-(void)outTime:(id)toView;

//自动登录
-(BOOL)autoLogin:(id)toView;
//获取启动图
- (void)getStartUpImageToView:(id)toView;
#pragma mark -------------- 扫码登录
- (void)requestScanLoginWithScanContent:(NSString *)scanContent toView:(id)toView ;

#pragma mark -------------- Tigase连接日志上报
- (void)logReportWithLogContext:(NSString *)logContext toView:(id)toView;

//检查手机号
-(void)WH_checkPhoneWithPhoneNum:(NSString*)phone areaCode:(NSString *)areaCode verifyType:(int)verifyType toView:(id)toView NS_DEPRECATED_IOS(2_0, 7_0,"使用checkUser或checkPhoneNum");
//重置密码
- (void)resetPwd:(NSString*)telephone areaCode:(NSString *)areaCode randcode:(NSString*)randcode newPwd:(NSString*)newPassword registerType:(NSInteger)registerType toView:(id)toView;
-(void)WH_resetPwd:(NSString*)telephone areaCode:(NSString *)areaCode randcode:(NSString*)randcode newPwd:(NSString*)newPassword toView:(id)toView;

//更新密码
-(void)WH_updatePwd:(NSString*)telephone areaCode:(NSString *)areaCode oldPwd:(NSString*)oldPassword newPwd:(NSString*)newPassword toView:(id)toView;

//发送验证码
-(void)WH_sendSMSCodeWithTel:(NSString*)telephone areaCode:(NSString *)areaCode isRegister:(BOOL)isRegister imgCode:(NSString *)imgCode toView:(id)toView;

//验证手机号
-(void)WH_checkPhoneWithPhoneNum:(NSString*)phone toView:(id)toView NS_DEPRECATED_IOS(2_0, 7_0,"使用checkUser或checkPhoneNum");

-(void)WH_checkPhoneWithPhoneNum:(NSString*)phone inviteCode:(NSString *)inviteCode toView:(id)toView NS_DEPRECATED_IOS(2_0, 7_0,"使用checkUser或checkPhoneNum");

- (void)checkPhone:(NSString*)phone registerType:(NSInteger)registerType smsCode:(NSString *)smsCode inviteCode:(NSString *)inviteCode toView:(id)toView NS_DEPRECATED_IOS(2_0, 7_0,"使用checkUser或checkPhoneNum");

#pragma mark ---- 当前使用的验证手机号/用户名接口
- (void)checkUser:(NSString *)userName inviteCode:(NSString *)inviteCode toView:(id)toView;
- (void)checkPhoneNum:(NSDictionary *)params toView:(id)toView;

//获取图形码
-(NSString *)getImgCode:(NSString*)telephone areaCode:(NSString *)areaCode;
//注册用户
-(void)WH_registerUserWithUserData:(WH_JXUserObject*)user inviteCode:(NSString *)inviteCode workexp:(int)workexp diploma:(int)diploma isSmsRegister:(BOOL)isSmsRegister toView:(id)toView;
-(void)registerUser:(WH_JXUserObject*)user inviteCode:(NSString *)inviteCode  isSmsRegister:(BOOL)isSmsRegister registType:(NSInteger)registType passSecurity:(NSString *)passSecurity smsCode:(NSString *)smsCode toView:(id)toView;
//更新用户
-(void)WH_updateUser:(WH_JXUserObject*)user toView:(id)toView;
//更新Tigase号
-(void)WH_updateWaHuNum:(WH_JXUserObject*)user toView:(id)toView;

//获取用户信息
-(void)getUser:(NSString*)theUserId toView:(id)toView;
// 搜索公众号列表
- (void)WH_searchPublicWithKeyWorld:(NSString *)keyWorld limit:(int)limit page:(int)page toView:(id)toView;
-(void)WH_reportUserWithToUserId:(NSString *)toUserId roomId:(NSString *)roomId webUrl:(NSString *)webUrl reasonId:(NSNumber *)reasonId toView:(id)toView;

-(void)addPhoto:(NSString*)photos toView:(id)toView;
-(void)delPhoto:(NSString*)photoId toView:(id)toView;
-(void)updatePhoto:(NSString*)photoId oUrl:(NSString*)oUrl tUrl:(NSString*)tUrl toView:(id)toView;
-(void)listPhoto:(NSString*)theUserId toView:(id)toView;
-(NSString *) getPhotoLocalPath:(NSString*)s;
-(void)WH_getMessageWithMsgId:(NSString*)messageId toView:(id)toView;
-(void)WH_getMessageWithMsgId:(int)type messageId:(NSString*)messageId toView:(id)toView;
-(void)WH_addMessage:(NSString*)text type:(int)type data:(NSDictionary*)dict flag:(int)flag visible:(int)visible lookArray:(NSArray *)lookArray coor:(CLLocationCoordinate2D)coor location:(NSString *)location remindArray:(NSArray *)remindArray lable:(NSString *)lable isAllowComment:(int)isAllowComment toView:(id)toView;

-(void)WH_deleteMessageWithMsgId:(NSString*)messageId toView:(id)toView;
-(void)getNewMessage:(NSString*)messageId toView:(id)toView;
-(void)getUserMessage:(NSString*)userId messageId:(NSString*)messageId toView:(id)toView;
// 朋友圈评论列表
-(void)WH_listCommentWithMsgId:(NSString*)messageId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize commentId:(NSString*)commentId  toView:(id)toView;
// 朋友圈点赞列表
-(void)WH_listPraiseWithMsgId:(NSString*)messageId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize praiseId:(NSString*)praiseId toView:(id)toView;

//使用msgId添加评论
-(void)WH_addPraiseWithMsgId:(NSString*)messageId toView:(id)toView;
//使用msgId删除评论
-(void)WH_delPraiseWithMsgId:(NSString*)messageId toView:(id)toView;

//使用data添加评论
-(void)WH_addCommentWithData:(WeiboReplyData*)reply toView:(id)toView;
//根据msgid删除评论
-(void)WH_delCommentWithMsgId:(NSString*)messageId commentId:(NSString*)commentId toView:(id)toView;

//删除好友
-(void)delFriend:(NSString*)toUserId toView:(id)toView;

//双向撤回
- (void)wh_twoWayDelectRoomMsg:(NSString *)userId roomId:(NSString *)roomId toView:(id)toView ;

//添加Attention
-(void)WH_addAttentionWithUserId:(NSString*)toUserId fromAddType:(int)fromAddType toView:(id)toView;
//删除Attention
-(void)WH_delAttentionWithToUserId:(NSString*)toUserId toView:(id)toView;
//添加黑名单
-(void)WH_addBlacklistWithToUserId:(NSString*)toUserId toView:(id)toView;
//删除黑名单
-(void)WH_delBlacklistWithToUserId:(NSString*)toUserId toView:(id)toView;
//黑名单列表
-(void)WH_listBlacklistWithPage:(int)page toView:(id)toView;

//设置好友名字
-(void)WH_setFriendNameWithToUserId:(NSString*)toUserId noteName:(NSString*)noteName describe:(NSString *)describe toView:(id)toView;

// 修改好友的聊天记录过期时间
-(void)friendsUpdate:(NSString *)toUserId chatRecordTimeOut:(NSString *)chatRecordTimeOut toView:(id)toView;

-(void)uploadFile:(NSArray*)files audio:(NSString*)audio video:(NSString*)video file:(NSString*)file type:(int)type validTime:(NSString *)validTime timeLen:(int)timeLen toView:(id)toView;
// 上传文件（传路径）
-(void)uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView;
// 上传文件（传data）
-(void)uploadFileData:(NSData*)data key:(NSString *)key toView:(id)toView;
-(void)setHeadImage:(NSString*)photoId toView:(id)toView;//弃用

//得到小头像
-(void)WH_getHeadImageSmallWIthUserId:(NSString*)userId userName:(NSString *)userName imageView:(UIImageView*)iv;
//得到大头像
-(void)WH_getHeadImageLargeWithUserId:(NSString*)userId userName:(NSString *)userName imageView:(UIImageView*)iv;
//获取群头像
-(void)WH_getRoomHeadImageSmallWithUserId:(NSString*)userId roomId:(NSString *)roomId imageView:(UIImageView*)iv;
//根据URL得到图像
-(void)WH_getImageWithUrl:(NSString*)url imageView:(UIImageView*)iv;
//得到大头像URL
-(NSString*)WH_getHeadImageOUrlWithUserId:(NSString*)userId;
//得到小头像URL
-(NSString*)WH_getHeadImageTUrlWithUserId:(NSString*)userId;
//第二通道新增接口  2020/05/21 by:hlx
-(void)syncMessages:(NSString*)theUserId orDelete:(NSString*)isDelete withUrl:(NSString*)url toView:(id)toView;
// 上传群组头像
-(void)setGroupAvatarServlet:(NSString*)roomId image:(UIImage *)image toView:(id)toView;
//上传头像
-(void)WH_uploadHeadImageWithUserId:(NSString*)userId image:(UIImage*)image toView:(id)toView;
//删除头像
-(void)WH_delHeadImageWithUserId:(NSString*)userId;

//获取支付签名
- (void)WH_getPaySignWithPrice:(NSString *)price payType:(NSInteger)payType toView:(id)toView;

//用户余额充值(黑马交易用)
- (void)hmTransactionPayWithPrice:(NSString *)price payType:(NSInteger)payType payWap:(NSString *)payWap userIp:(NSString *)userIp toView:(id)toView;

//获取支付宝授权authInfo
- (void)WH_getAliPayAuthInfoToView:(id)toView;

//保存支付宝用户的Id
- (void)WH_safeAliPayUserIdWithUserId:(NSString *)aliUserId toView:(id)toView;

//支付宝提现
- (void)WH_alipayTransferWithAmount:(NSString *)amount secret:(NSString *)secret time:(NSNumber *)time toView:(id)toView;

//二维码支付
- (void)WH_codePaymentWithCodeUrlStr:(NSString *)paymentCode money:(NSString *)money time:(long)time desc:(NSString *)desc secret:(NSString *)secret toView:(id)toView;

//二维码收款
- (void)WH_codeReceiptWithUserId:(NSString *)toUserId money:(NSString *)money time:(long)time desc:(NSString *)desc secret:(NSString *)secret toView:(id)toView;

//接受转账
- (void)WH_getTransferWithTransferId:(NSString *)transferId toView:(id)toView;
//获取转账相关信息
- (void)WH_transferDetailWithTransId:(NSString *)transferId toView:(id)toView;
//获取好友交易记录明细信息
- (void)WH_getConsumeRecordListInfoWithToUserId:(NSString *)toUserId pageIndex:(int)pageIndex pageSize:(int)pageSize toView:(id)toView;
//转账给某人
- (void)WH_transferToPeopleWithUserId:(NSString *)toUserId money:(NSString *)money remark:(NSString *)remark time:(long)time secret:(NSString *)secret toView:(id)toView;

//附近的新用户
- (void)WH_nearbyNewUserWithData:(WH_SearchData*)search nearOnly:(BOOL)bNearOnly page:(int)page toView:(id)toView;//新用户



-(void)order:(int)goodId count:(int)count type:(int)rechargeType toView:(id)toView;
-(void)listBizs:(id)toView;
-(void)buy:(int)goodId count:(int)count toView:(id)toView;
-(void)getSetting:(id)toView;
-(void)showWebPage:(NSString*)url title:(NSString*)s;
-(void)updateResume:(NSString*)resumeId nodeName:(NSString*)nodeName text:(NSString*)text toView:(id)toView;

-(void)nearbyUser:(WH_SearchData*)search nearOnly:(BOOL)nearOnly lat:(double)lat lng:(double)lng page:(int)page toView:(id)toView;
-(void)addRoom:(WH_RoomData*)room isPublic:(BOOL)isPublic isNeedVerify:(BOOL)isNeedVerify category:(NSInteger)category toView:(id)toView;

-(void)addRoom:(WH_RoomData*)room userArray:(NSArray*)array isPublic:(BOOL)isPublic isNeedVerify:(BOOL)isNeedVerify category:(NSInteger)category toView:(id)toView;

-(void)delRoom:(NSString*)roomId toView:(id)toView;
-(void)getRoom:(NSString*)roomId toView:(id)toView;

-(void)updateRoom:(WH_RoomData*)room toView:(id)toView;
-(void)updateRoomShowRead:(WH_RoomData*)room key:(NSString *)key value:(BOOL)value toView:(id)toView;
- (void)updateRoom:(WH_RoomData *)room key:(NSString *)key value:(NSString *)value toView:(id)toView;
-(void)WH_updateRoomDescWithRoom:(WH_RoomData*)room toView:(id)toView;
-(void)WH_updateRoomMaxUserSizeWithRoom:(WH_RoomData*)room toView:(id)toView;
//根据roomdata获取相关信息
-(void)WH_updateRoomNotifyWithRoom:(WH_RoomData*)room toView:(id)toView;
//列举群
-(void)listRoom:(int)page roomName:(NSString *)roomName toView:(id)toView;
//列举别人的群
-(void)WH_listHisRoomWithPage:(int)page pageSize:(int)pageSize toView:(id)toView;

//列举aattention
-(void)WH_listAttentionWithPage:(int)page userId:(NSString*)userId toView:(id)toView;

//根据群id获取群成员
-(void)WH_getRoomMemberWithRoomId:(NSString*)roomId userId:(long)userId toView:(id)toView;

//删除群成员
-(void)WH_delRoomMemberWithRoomId:(NSString*)roomId userId:(long)userId toView:(id)toView;
//设置群成员
-(void)WH_setRoomMemberWithRoomId:(NSString*)roomId member:(memberData*)member toView:(id)toView;
//添加群成员
-(void)WH_addRoomMemberWithRoomId:(NSString*)roomId userId:(NSString*)userId nickName:(NSString*)nickName toView:(id)toView;
//添加多个群成员
-(void)WH_addRoomMemberWithRoomId:(NSString*)roomId userArray:(NSArray*)array toView:(id)toView;
//设置别人say
-(void)WH_setDisableSayWithRoomId:(NSString*)roomId member:(memberData*)member toView:(id)toView;
//设置转让管理员
-(void)WH_setRoomAdminWithRoomId:(NSString*)roomId userId:(NSString*)userId type:(int)type  toView:(id)toView;
// 指定监控人、隐身人
-(void)WH_setRoomInvisibleGuardianWithRoomId:(NSString*)roomId userId:(NSString*)userId type:(int)type toView:(id)toView;
// 转让群主
- (void)WH_roomTransferWithRoomId:(NSString *)roomId toUserId:(NSString *)toUserId toView:(id)toView;
// 群成员分页获取
- (void)WH_roomMemberGetMemberListByPageWithRoomId:(NSString *)roomId joinTime:(long)joinTime toView:(id)toView;

//表情商店
- (void)getEmjioStoreListWithPageIndex:(int)pageIndex toView:(id)toView;

//我的下载表情列表
- (void)getMyEmjioListWithPageIndex:(int)pageIndex toView:(id)toView;

//移除我的下载表情
- (void)deleteMyEmjioListWithCustomEmoId:(NSString *)customEmoId toView:(id)toView;

//添加我的下载表情
- (void)AddEmjioListToMineWithCustomEmoId:(NSString *)customEmoId toView:(id)toView;

/**
 添加共享文件

 @param roomId 房间id
 @param fileUrl 已上传文件的网络地址
 @param size 文件大小kb
 @param type 类型1：图片  2：音频	3：视频   4：ppt	   5：excel	 6：word
 7：zip    8：txt   9：其他
 @param toView 代理控制器
 */
-(void)WH_roomShareAddRoomId:(NSString *)roomId url:(NSString *)fileUrl fileName:(NSString *)fileName size:(NSNumber *)size type:(NSInteger)type toView:(id)toView;
/**
 获取文件列表
 */
-(void)WH_roomShareListRoomIdWithRoomId:(NSString *)roomId userId:(NSString *)userId pageSize:(int)pageSize pageIndex:(int)pageIndex toView:(id)toView;

/**
 删除文件
 */
-(void)WH_roomShareDeleteRoomIdWithRoomId:(NSString *)roomId shareId:(NSString *)shareId toView:(id)toView;

//保存文件到数据库
-(void)WH_saveImageToFileWithImage:(UIImage*)image file:(NSString*)file isOriginal:(BOOL)isOriginal;// isOriginal 是否原图
//保存数据到文件
-(void)WH_saveDataToFileWithData:(NSData*)data file:(NSString*)file;

//对对象进行MD5加密
-(NSString*)WH_getMD5StringWithStr:(NSString*)s;
//对对象进行MD5加盐
- (NSString *)MD5WithStr:(NSString *)str AndSalt:(NSString *)salt;

//根据经纬度获取位置信息
-(double)WH_getLocationWithLatitude:(double)latitude1 longitude:(double)longitude1;
//好友验证
- (void)WH_getFriendSettingsWithUserId:(NSString *)userID toView:(id)toView;
-(void)WH_changeFriendSettingWithFriendsVerify:(NSString *)friendsVerify allowAtt:(NSString *)allowAtt allowGreet:(NSString*)allowGreet key:(NSString *)key value:(NSString *)value toView:(id)toView;


//获取红包
-(void)WH_getUserMoenyToView:(id)toView;

//发送红包操作
- (void)WH_sendRedPacketWithMoneyNum:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId time:(long)time secret:(NSString *)secret toView:(id)toView;
//发红包(新版)
- (void)WH_sendRedPacketV1WithMoneyNum:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId time:(long)time secret:(NSString *)secret toView:(id)toView;
//指定联系人发红包
- (void)WH_sendRedPacketV1WithMoneyNum:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId toUserIds:(NSString *)toUserIds time:(long)time secret:(NSString *)secret toView:(id)toView;

//获取红包信息
- (void)WH_getRedPacketWithMsg:(NSString *)redPacketId toView:(id)toView;
//打开红包
- (void)WH_openRedPacketWithRedPacketId:(NSString *)redPacketId money:(NSString *)moneyStr toView:(id)toView;
//获取红包记录
- (void)WH_getConsumeRecordWithIndex:(NSInteger)pageIndex toView:(id)toView;
// 获得发送的红包
- (void)WH_redPacketGetSendRedPacketListIndex:(NSInteger)index toView:(id)toView;
// 获得接收的红包
- (void)WH_redPacketGetRedReceiveListIndex:(NSInteger)index toView:(id)toView;
// 红包回复
- (void)WH_redPacketReplyWithRedPacketid:(NSString *)redPacketId content:(NSString *)content toView:(id)toView;
- (void)WH_addWithdrawalAccountWithParam:(NSDictionary *)param toView:(id)toView;// 增加提现账号
- (void)WH_getWithdrawalAccountListWithParam:(NSDictionary *)param toView:(id)toView;// 获取提现账号列表
- (void)WH_deleteWithdrawalAccountWithAccountId:(NSString *)accountId accountType:(NSString *)type toView:(id)toView;// 删除提现账号
//组织
- (void)WH_createCompanyWithCompanyName:(NSString *)companyName toView:(id)toView;//创建公司
- (void)WH_quitCompanyWithCompanyId:(NSString *)companyId toView:(id)toView;//退出公司/解散公司
- (void)WH_getAutoSearchCompany:(id)toView;//自动获取公司
- (void)settingAdministrator:(NSString *)userId toView:(id)toView;//指定管理员
- (void)WH_getCompanyAdminListWithCompanyId:(NSString *)companyId toView:(id)toView;//管理员列表
- (void)WH_updataCompanyNameWithCompanyName:(NSString *)companyName companyId:(NSString *)companyId toView:(id)toView;//修改公司名
- (void)WH_updataCompanyNoticeWithContent:(NSString *)noticeContent companyId:(NSString *)companyId toView:(id)toView;//更换公司公告
- (void)WH_seachCompanyWithKeywordId:(NSString *)keyworld toView:(id)toView;//查找公司
- (void)WH_deleteCompanyWithCompanyId:(NSString *)companyId userId:(NSString *)userId toView:(id)toView;//删除公司
- (void)WH_createDepartmentWithCompanyId:(NSString *)companyId parentId:(NSString *)parentId departName:(NSString *)departName createUserId:(NSString *)createUserId toView:(id)toView;//创建部门
- (void)WH_updataCompanyDepartmentNameWithName:(NSString *)departmentName departmentId:(NSString *)departmentId toView:(id)toView;//修改部门名
- (void)WH_deleteDepartmentWithId:(NSString *)departmentId toView:(id)toView;//删除部门
- (void)WH_addEmployeeWithIdArr:(NSArray *)userIdArray companyId:(NSString *)companyId departmentId:(NSString *)departmentId roleArray:(NSArray *)roleArray toView:(id)toView;//添加员工
- (void)WH_deleteEmployeeWithDepartmentId:(NSString *)departmentId userId:(NSString *)userId toView:(id)toView;//删除员工
- (void)WH_modifyDpartWithUserId:(NSString *)userId companyId:(NSString *)companyId newDepartmentId:(NSString *)newDepartmentId toView:(id)toView;//更改员工部门
- (void)WH_getEmpListWithDepartmentId:(NSString *)departmentId toView:(id)toView;//部门员工列表
- (void)WH_modifyRoleWithUserId:(NSString *)userId companyId:(NSString *)companyId role:(NSNumber *)role toView:(id)toView;//更改员工角色
- (void)WH_modifyPosition:(NSString *)position companyId:(NSString *)companyId userId:(NSString *)userId toView:(id)toView;//更改员工职位(头衔)
- (void)WH_companyListPageWithPageIndex:(NSNumber *)pageIndex toView:(id)toView;//公司列表
- (void)WH_getDepartmentListPageWithPageIndex:(NSNumber *)pageIndex companyId:(NSString *)companyId toView:(id)toView;//部门列表
- (void)employeeListPage:(NSNumber *)pageIndex companyId:(NSString *)companyId departmentId:(NSString *)departmentId toView:(id)toView;//员工列表
- (void)getCompanyInfo:(NSString *)companyId toView:(id)toView;//获取公司详情
- (void)getEmployeeInfo:(NSString *)userId toView:(id)toView;//员工详情
- (void)getDepartmentInfo:(NSString *)departmentId toView:(id)toView;//部门详情
- (void)getCompanyCount:(NSString *)companyId toView:(id)toView;//公司员工数
- (void)getDepartmentCount:(NSString *)departmentId toView:(id)toView;//部门员工数

//批量删除群成员
- (void)wh_deleteMembersWithRoomId:(NSString *)roomId userId:(NSString *)userId toView:(id)toView;

//  获取首页的最近一条的聊天记录列表
- (void)WH_getLastChatListWithStartTime:(NSNumber *)startTime toView:(id)toView;
// 获取单聊漫游聊天记录
- (void)WH_tigaseMsgsWithReceiver:(NSString *)receiver StartTime:(long)startTime EndTime:(long)endTime PageIndex:(int)pageIndex toView:(id)toView;
// 获取群聊漫游聊天记录
- (void)WH_tigaseMucMsgsWithRoomId:(NSString *)roomId StartTime:(long)startTime EndTime:(long)endTime PageIndex:(int)pageIndex PageSize:(int)pageSize toView:(id)toView;

// 公众号菜单
- (void)WH_getPublicMenuListWithUserId:(NSString *)userId toView:(id)toView;
// 删除&撤回聊天记录
- (void)WH_tigaseDeleteMsgWithMsgId:(NSString *)msgId type:(int)type deleteType:(int)deleteType roomJid:(NSString *)roomJid toView:(id)toView;
// 消息免打扰
- (void)WH_friendsUpdateOfflineNoPushMsgUserId:(NSString *)userId toUserId:(NSString *)toUserId offlineNoPushMsg:(int)offlineNoPushMsg toView:(id)toView;

//设置token
-(void)pkpushSetToken:(NSString *)token deviceId:(NSString *)deviceId isVoip:(int)isVoip toView:(id)toView;

//收藏
-(void)WH_addFavoriteWithEmoji:(NSMutableArray *)emoji toView:(id)toView;

// 取消收藏
- (void)WH_userEmojiDeleteWithId:(NSString *)emojiId toView:(id)toView;
// 朋友圈里面取消收藏
- (void)WH_userPengYouQunEmojiDeleteWithId:(NSString *)messageId toView:(id)toView;
// 收藏列表
-(void)WH_userCollectionListWithType:(int)type pageIndex:(int)pageIndex toView:(id)toView;
//收藏的表情列表
- (void)WH_userEmojiListWithPageIndex:(int)pageIndex toView:(id)toView;

// 添加课程
- (void)WH_userCourseAddWithMessageIds:(NSString *)messageIds CourseName:(NSString *)courseName RoomJid:(NSString *)roomJid toView:(id)toView;
// 查询课程
- (void)WH_userCourseList:(id)toView;
// 修改课程
- (void)WH_userCourseUpdateWithCourseId:(NSString *)courseId MessageIds:(NSString *)messageIds CourseName:(NSString *)courseName CourseMessageId:(NSString *)courseMessageId toView:(id)toView;
// 删除课程
- (void)WH_userCourseDeleteWithCourseId:(NSString *)courseId toView:(id)toView;
// 课程详情
- (void)WH_userCourseGetWithCourseId:(NSString *)courseId toView:(id)toView;

// 更新角标
- (void)WH_userChangeMsgNum:(NSInteger)num toView:(id)toView;

// 设置群消息免打扰
- (void)WH_roomMemberSetOfflineNoPushMsgWithRoomId:(NSString *)roomId userId:(NSString *)userId offlineNoPushMsg:(int)offlineNoPushMsg toView:(id)toView;

// 添加标签
- (void)WH_friendGroupAdd:(NSString *)groupName toView:(id)toView;
// 修改好友标签
- (void)WH_friendGroupUpdateGroupUserListWithGroupId:(NSString *)groupId userIdListStr:(NSString *)userIdListStr toView:(id)toView;
// 更新标签名
- (void)WH_friendGroupUpdateWithGroupId:(NSString *)groupId groupName:(NSString *)groupName toView:(id)toView;
// 删除标签
- (void)WH_friendGroupDeleteWithGroupId:(NSString *)groupId toView:(id)toView;
// 标签列表
- (void)WH_friendGroupListToView:(id)toView;
// 修改好友的分组列表
- (void)WH_friendGroupUpdateFriendToUserId:(NSString *)toUserId groupIdStr:(NSString *)groupIdStr toView:(id)toView;

// 删除群组公告
- (void)WH_roomDeleteNoticeWithRoomId:(NSString *)roomId noticeId:(NSString *)noticeId ToView:(id)toView;

// 拷贝文件
- (void)WH_uploadCopyFileServletWithPaths:(NSString *)paths validTime:(NSString *)validTime toView:(id)toView;

// 清空聊天记录
- (void)WH_emptyMsgWithTouserId:(NSString *)toUserId type:(NSNumber *)type toView:(id)toView;

//清空群组聊天记录
- (void)WH_ClearGroupChatHistoryWithRoomId:(NSString *)roomId toView:(id)toView;

// 获取通讯录所有号码
- (void)WH_getUserAllAddressBook:(id)toView;
// 上传通讯录
- (void)WH_uploadAddressBookWithUploadStr:(NSString *)uploadStr toView:(id)toView;
// 添加手机联系人好友
- (void)WH_friendsAttentionBatchAddToUserIds:(NSString *)toUserIds toView:(id)toView;

// 用户绑定微信code，获取openid
- (void)WH_userBindWXCodeWithCode:(NSString *)code toView:(id)toView;

// 获取群组信息
- (void)WH_roomGetRoom:(NSString *)roomId toView:(id)toView;

/**
 * 余额微信提现
 * amout -- 提现金额，0.3=30，单位为分，最少0.5
 * secret -- 提现秘钥
 * time -- 请求时间，服务器检查，允许5分钟时差
 */
- (void)WH_transferWXPayWithAmount:(NSString *)amount secret:(NSString *)secret time:(NSNumber *)time toView:(id)toView;

// 检查支付密码是否正确
- (void)WH_checkPayPasswordWithUser:(WH_JXUserObject *)user toView:(id)toView;

// 更新支付密码
- (void)WH_updatePayPasswordWithUser:(WH_JXUserObject *)user toView:(id)toView;

// 获取集群音视频服务地址
- (void)WH_userOpenMeetWithToUserId:(NSString *)toUserId toView:(id)toView;

// 朋友圈纯视频接口
- (void)WH_circleMsgPureVideoPageIndex:(NSInteger)pageIndex lable:(NSString *)lable toView:(id)toView;
// 获取音乐列表
- (void)WH_musicListPageIndex:(NSInteger)pageIndex keyword:(NSString *)keyword toView:(id)toView;

// 第三方认证
- (void)WH_openOpenAuthInterfaceWithUserId:(NSString *)userId appId:(NSString *)appId appSecret:(NSString *)appSecret type:(NSInteger)type toView:(id)toView;

// 获取微信登录openid
- (void)WH_getWxOpenId:(NSString *)code toView:(id)toView;


- (void)WH_wxSdkLogin:(WH_JXUserObject *)user type:(NSInteger)type openId:(NSString *)openId toView:(id)toView;
//第三方登录接口 test
- (void)WH_otherLogin:(WH_JXUserObject *)user type:(NSInteger)type openId:(NSString *)openId toView:(id)toView token:(NSString *)token;



// 第三方绑定手机号
-(void)WH_thirdLogin:(WH_JXUserObject*)user type:(NSInteger)type openId:(NSString *)openId isLogin:(BOOL)isLogin toView:(id)toView;

- (void)WH_bindPhonePassWord:(NSString *)phone pws:(NSString *)pws areaCode:(NSString *)areaCode smsCode:(NSString *)smsCode loginType:(NSString *)loginType toView:(id)toView;

//绑定第三方账号
- (void)WH_otherBindUserInfoWithOpenId:(NSString *)openId otherToken:(NSString *)otherToken otherType:(NSString *)otherType toView:(id)toView;

// 第三方登录设置邀请码（新版）
- (void)WH_otherSetInviteCode:(NSString *)inviteCode access_token:(NSString *)access_token userId:(NSString *)userId toView:(id)toView;

// 第三方网页授权
- (void)WH_openCodeAuthorCheckAppId:(NSString *)appId state:(NSString *)state callbackUrl:(NSString *)callbackUrl toView:(id)toView;
// 检查网址是否被锁定
- (void)WH_userCheckReportUrl:(NSString *)webUrl toView:(id)toView;
// 第三方解绑   type  第三方登录类型  1: QQ  2: 微信
- (void)WH_setAccountUnbind:(int)type toView:(id)toView;
// 获取用户绑定信息接口
- (void)WH_getBindInfo:(id)toView;


#pragma mark - 密保问题
- (void)getPasswordSecListWithUserName:(NSString *)userName toDelegate:(id)delegate;
- (void)getPasswordSecListData:(id)toView;

/**
 校验密保问题
 
 @param params userName=xx&qid=xx&answer=xx
 @param delegate 回调对象
 */
- (void)checkPwdSecAnswer:(NSDictionary *)params toDelegate:(id)delegate;
- (void)setPasswordSecQuesAns:(NSString *)ans toView:(id)toView;




// 获取用户绑定信息接口
- (void)WH_getUserBindInfo:(id)toView;

// 面对面建群
//面对面建群查询
- (void)WH_roomLocationQueryWithIsQuery:(int)isQuery password:(NSString *)password toView:(id)toView;
//面对面建群加入
- (void)WH_roomLocationJoinWithJid:(NSString *)jid toView:(id)toView;
//面对面建群退出
- (void)WH_roomLocationExitWithJid:(NSString *)jid toView:(id)toView;

// Tigase支付
// 接口获取订单信息
- (void)WH_payGetOrderInfoWithAppId:(NSString *)appId prepayId:(NSString *)prepayId toView:(id)toView;
// 输入密码后支付接口
- (void)payPasswordPaymentWithAppId:(NSString *)appId prepayId:(NSString *)prepayId sign:(NSString *)sign time:(NSString *)time secret:(NSString *)secret toView:(id)toView;
#pragma mark - 推广邀请
//查询用户邀请码信息
- (void)QueryUserInvitationCodeInformationWithUserId:(NSString *)userId toView:(id)toView;
//查询用户通证列表（分页）
- (void)QueryUserInvitePassCardWithUserId:(NSString *)userId PageIndex:(int)pageIndex toView:(id)toView;
//清除已使用状态的通证
- (void)ClearHaveUsedPassCardWithUserId:(NSString *)userId toView:(id)toView;
//查询用户邀请人记录（分页）
- (void)FindUserInviteMemberWithUserId:(NSString *)userId PageIndex:(int)pageIndex toView:(id)toView;

- (void)WH_DeleteOneLastChatWithToUser:(NSString *)toUser toView:(id)toView;

/**
 新版本请求
 
 @param isAppStore 是否是appStore YES: appStore NO: 企业包
 @param toView 代理
 */
- (void)newVersionReqWithIsAppStore:(BOOL)isAppStore toView:(id)toView;

//用户提现
- (void)userWithdrawalWithUserId:(NSString *)userId amount:(NSString *)amount secret:(NSString *)secret context:(NSString *)context accountType:(NSString *)type toView:(id)toView time:(NSString *)time;

/**
 * 提现到后台的提现方式
 */
- (void)userWithdrawWayWithToView:(id)toView;

/**
 忘记支付密码
 
 @param modifyType 修改类型 1=支付
 @param oldPassword 登录密码
 @param newPassword 新支付密码
 @param toView 代理
 */
- (void)forgetPayPswWithModifyType:(NSString *)modifyType oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword toView:(id)toView;

/**
 登录公众号
 
 @param qcCodeToken 公众号二维码扫码结果
 @param toView 代理
 */
- (void)loginPublicAccountReqWithQrCodeToken:(NSString *)qcCodeToken toView:(id)toView;
    
/**
 登录开放平台
 
 @param qcCodeToken 公众号二维码扫码结果
 @param toView 代理
 */
- (void)openLoginPublicOpenAccReqWithQrCodeToken:(NSString *)qcCodeToken toView:(id)toView;

/**
 获取支付银行列表
 */
- (void)getPayBankListWithView:(id)toView;

/**
 银行卡充值
 
 @param serialAmount 金额
 @param toView 代理
 */
- (void)payGetOrderDetailsReqWithSerialAmount:(NSString *)serialAmount toView:(id)toView;

/**
 获取绑定银行卡信息
 
 @param toView 代理
 */
- (void)getBankInfoByUserIdReqWithToView:(id)toView;

/**
 删除绑定的银行卡
 
 @param bankId 银行卡id
 @param toView 代理
 */
- (void)deleteBankInfoByIdReqWithBankId:(NSString *)bankId toView:(id)toView;

/**
 添加银行卡
 
 @param realName 账户姓名
 @param cardNum 银行卡号
 @param toView 代理
 */
- (void)userBindBankInfoReqWithRealName:(NSString *)realName cardNum:(NSString *)cardNum toView:(id)toView;

/**
 获取支付类型
 
 @param toView 代理
 */
- (void)paySystem_getPayTypeToView:(id)toView;

/**
 提交充值订单
 
 @param money 金额
 @param zfid 支付类型id
 @param zfzh zfzh:支付账号，会员输入充值的账号
 @param toView 代理
 */
- (void)paySystem_commitRechargeOrderWithMoney:(NSString *)money zfid:(NSString *)zfid zfzh:(NSString *)zfzh toView:(id)toView;

/**
 获取订单
 
 @param toView 代理
 */
- (void)paySystem_getOrderWithToView:(id)toView;

/**
 获取取消订单
 
 @param ordernum 订单号
 @param toView 代理
 */
- (void)paySystem_getCancelOrderWithOrderNum:(NSString *)ordernum toView:(id)toView;

/**
 获取我已付款
 
 @param ordernum 订单号
 @param toView 代理
 */
- (void)paySystem_getPayOrderWithOrderNum:(NSString *)ordernum toView:(id)toView;

/**
 获取充值订单列表
 
 @param types 不传默认为全部订单
 @param pagenum 页码,分页使用，默认一页10条
 @param toView 代理
 */
- (void)paySystem_getOrderListWithTypes:(NSString *)types pagenum:(NSString *)pagenum toView:(id)toView;

/**
 获取订单详情接口
 
 @param ID 订单id
 @param toView 代理
 */
- (void)paySystem_getOrderDetailWithId:(NSString *)ID toView:(id)toView;

/**
 提币生成订单接口
 
 @param nums 提币数量
 @param address 提币地址
 @param toView 提币地址
 */
- (void)paySystem_withdrawCoinWithNums:(NSString *)nums address:(NSString *)address toView:(id)toView;

/**
 获取提币信息 等待付币、确认收币、已完成详情接口
 
 @param orderid 订单id
 @param toView 代理
 */
- (void)paySystem_getWithdrawCoinInfoWithOrderid:(NSString *)orderid toView:(id)toView;

/**
 确认提币
 
 @param orderid 订单id
 @param toView 代理
 */
- (void)paySystem_getConfirmWithdrawCoinWithOrderid:(NSString *)orderid toView:(id)toView;


/**
 确认收币
 
 @param orderid 订单id
 @param toView 代理
 */
- (void)paySystem_getConfirmAcceptCoinWithOrderid:(NSString *)orderid toView:(NSString *)toView;

/*
 h5充值
 */
- (void)h5PaymentWithMoney:(NSString *)money notifyUrl:(NSString *)notifyUrl tradeNo:(NSString *)tradeNo pId:(NSString *)pId returnUrl:(NSString *)returnUrl sign:(NSString *)sign type:(NSString *)type userId:(NSString *)userId userIp:(NSString *)userIp toView:(id)toView;

/**
 提币列表
 
 @param pagenum 页码
 @param types 不传默认全部
 0全部
 1待放行
 2待放行
 3已取消
 4待付币
 @param toView 代理
 */
- (void)paySystem_getMyOrderWithPagenum:(NSString *)pagenum types:(NSString *)types toView:(id)toView;

//手机型号
- (NSString*)deviceVersion;

//关闭第二通道
- (void)closeSecondFeedOff:(id)toView;
//朋友圈搜索
- (void)searchCircleWithUserId:(NSString *)userId keyWord:(NSString *)keyWord monthStr:(NSString *)monthStr pageIndex:(NSString *)pageIndex pageSize:(NSString *)pageSize type:(NSString *)type toView:(id)toView;
//群聊积分机器人
- (void)roomSignInGroupWithUserId:(NSString *)uId fraction:(NSString *)fraction roomId:(NSString *)roomId type:(NSString *)type toView:(id)toView;
@property(nonatomic) long user_id;
@property(nonatomic) long user_type;
@property(nonatomic) long count_money;
@property(nonatomic,strong) NSString* access_token;

@property(nonatomic,strong) WH_JXUserObject* myself;
@property (nonatomic, strong) JXMultipleLogin *multipleLogin;
@property(assign) double latitude;
@property(assign) double longitude;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString * countryCode;
@property (nonatomic,strong) NSString * cityName;
@property (nonatomic,assign) int cityId;

@property(nonatomic,strong) NSString * locationAddress;
@property(nonatomic,strong) NSString* locationCity;

@property (nonatomic, strong) JXAddressBook *addressBook;
@property (nonatomic, strong) WH_JXLocation *location;

@property(assign) BOOL isLoginWeibo;
@property(assign) BOOL isLogin;
@property(assign) NSTimeInterval lastOfflineTime;

@property(nonatomic,strong) NSString* openId;
@property (nonatomic, assign) NSInteger thirdType;


// 服务器当前时间
@property (nonatomic,assign)  NSTimeInterval serverCurrentTime;
// 服务器时间与本地时间的时间差
@property (nonatomic,assign)  NSTimeInterval timeDifference;

@end

@protocol JXServerResult <NSObject>
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1;
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict;
#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error;//error为空时，代表超时
#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload;


@end
