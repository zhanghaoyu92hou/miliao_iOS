//
//  JXXMPPManager.h
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h> 
#import "XMPPFramework.h"

#define login_status_yes 1  //登录成功
#define login_status_ing 0  //登录中
#define login_status_no  -1 //登录失败

@class WH_JXMessageObject;
@class WH_JXRoomPool;
@class XMPPMessage,XMPPRoster,XMPPRosterCoreDataStorage,FMDatabase;

@interface JXXMPP : NSObject <UIApplicationDelegate>

{
    XMPPStream * __unsafe_unretained xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    XMPPAutoPing *xmppAutoPing;
    int pingTimeoutCount;
    
   	NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    FMDatabase* _db;
    NSString* _userIdOld;
}

- (NSManagedObjectContext *)managedObjectContext_roster;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign, nonatomic) XMPPStream* stream;
@property (assign, nonatomic) int isLogined;
@property (strong, nonatomic) WH_JXRoomPool* roomPool;
@property (strong, nonatomic) XMPPStreamManagementPersistentStorage *streamStorage;
@property (strong, nonatomic) XMPPStreamManagement *xmppStreamManagement;
@property (strong, nonatomic) NSMutableDictionary * poolSend;
@property (strong, nonatomic) NSMutableArray * poolSendRead;
@property (strong, nonatomic) NSMutableSet * blackList;
@property (strong, nonatomic) NSMutableArray * chatingUserIds;
//@property (assign, nonatomic) BOOL isEncryptAll;
@property (assign, nonatomic) int  newMsgAfterLogin;//刚连线时，收到的新消息总数量（刚连线时，此值为0,在一定时间内收完所有新消息后，才发通知更新界面，避免重复刷新UI；之后有一条消息，就累加1)
@property (assign, nonatomic) NSTimeInterval lastNewMsgTime;//最近一条新消息的时间

@property (nonatomic, assign) BOOL isReconnect;
@property (nonatomic, strong) NSTimer *reconnectTimer;

// 是否弹登录状态提示
@property (nonatomic, assign) BOOL isShowLoginChange;

// 是否关闭流
@property (nonatomic, assign) BOOL isCloseStream;

// XMPP密码是否错误
@property (nonatomic, assign) BOOL isPasswordError;

@property (nonatomic ,assign) BOOL enableMsgIQ ;

@property (nonatomic ,strong) NSTimer *IQTimer  ;
@property (nonatomic ,assign) NSInteger IQNum;

@property (nonatomic ,strong) NSMutableArray *poolSendIQ;

/*
原理就是2秒之内没有新消息到达，则认为收取完毕，一次性刷新
连线收消息时，批量收消息，刷新界面只刷一次：
1.声明2个变量：新消息数量A（刚连线时，此值为0;收完所有消息并刷新后再有新消息，此值累加)；最近一条消息的收到时间B
2.收到消息时，A=0,则B=Now，并在2秒后执行C函数；A>0,则A++,并刷新单条消息
3.C判断Now-B>2,则A=1,并刷新全部消息；
*/


//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)connect;
- (void)disconnect;
//- (FMDatabase*)getDatabase;
- (FMDatabase*)openUserDb:(NSString*)userId;




+(JXXMPP*)sharedInstance;


#pragma mark -------配置XML流-----------

- (void)setupStream;
- (void)teardownStream;

// 关闭流
-(void)applicationWillTerminate;

#pragma mark ----------收发信息------------
- (void)goOnline;
- (void)goOffline;

- (void)login;
- (void)logout;

- (void)sendMessageInvite:(WH_JXMessageObject *)msg;
- (void)sendMessage:(WH_JXMessageObject*)msg roomName:(NSString*)roomName;
#pragma  mark ------------多点登录转发发消息------------
- (void)relaySendMessage:(WH_JXMessageObject*)msg relayUserId:(NSString *)relayUserId roomName:(NSString*)roomName;
- (void)addSomeBody:(NSString *)userId;

-(void)notifyNewMsg;

#pragma mark ---------文件传输-----------
//-(void)sendFile:(NSData*)aData toJID:(XMPPJID*)aJID;

// XMPP没连上时弹框询问是否重连
- (void) showXmppOfflineAlert;

-(BOOL)deleteMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId;//删除一条聊天记录
-(WH_JXMessageObject*)findMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId;//搜索一条记录
//获取今日日期
+ (NSString *)getCurrentDay;
+ (NSString *)getString:(id)json;
//Label创建
+ (UILabel *)createLabelWith:(NSString *)text frame:(CGRect)frame color:(UIColor *)color font:(float)font;
//TextFiled创建
+ (UITextField *)createTextFiledWith:(NSString *)placeholder frame:(CGRect)frame color:(UIColor *)color font:(float)font;
//无图片Button创建
+ (UIButton *)createButtonWith:(NSString *)text frame:(CGRect)frame color:(UIColor *)color font:(float)font;
//有图片无标题Button创建
+ (UIButton *)createButtonWithFrame:(CGRect)frame image:(UIImage *)image;
//有图片有标题Button创建
+ (UIButton *)createButtonWith:(NSString *)text frame:(CGRect)frame color:(UIColor *)color font:(float)font image:(UIImage *)image;
//实现button上图下文
+ (void)getButtonStyle:(UIButton *)button;
//实现button左文右图
+ (void)becomeButtonStyle:(UIButton *)button;
// 设置label的部分字体颜色(该方法最好对每一个label仅调用一次，若多次调用，请在每次调用之前 重新设置(初始化)label.textColor)
+(void)getAttributeTextWithLabel:(UILabel *)label textString:(NSString *)textString color:(UIColor *)color;
//计算label高度
+ (CGFloat)getLabelHeightWithContent:(NSString *)content andLabelWidth:(CGFloat)width andLabelFontSize:(int)font;
@end
