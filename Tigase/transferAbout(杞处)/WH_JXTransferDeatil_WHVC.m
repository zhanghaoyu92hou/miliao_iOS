//
//  WH_JXTransferDeatil_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/2.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTransferDeatil_WHVC.h"
#import "WH_JXTransferModel.h"
#import "WH_JXMyMoney_WHViewController.h"

#import "WH_MyWallet_WHViewController.h"

typedef NS_ENUM(NSInteger, JXTransferDeatilType) {
    JXTransferDeatilTypeMySend,        // 我发送的转账
    JXTransferDeatilTypeWait,          // 待确定收款
    JXTransferDeatilTypeComplete,      // 完成收款
    JXTransferDeatilTypeOverdue,       // 过期
};

@interface WH_JXTransferDeatil_WHVC () <UIAlertViewDelegate>

@property (nonatomic, assign) JXTransferDeatilType type;
@property (nonatomic, strong) WH_JXTransferModel *model;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *hintLab;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *oneDayLabel;
@property (nonatomic, strong) UILabel *clickLab;
@property (nonatomic, strong) UIButton *completeBtn;

@property (nonatomic, strong) UILabel *transferTime;
@property (nonatomic, strong) UILabel *getTime;

@end

@implementation WH_JXTransferDeatil_WHVC

- (instancetype)init {
    if (self = [super init]) {
        self.wh_heightHeader = 0;
        self.wh_heightFooter = 0;
        [self createHeadAndFoot];
        self.model = [[WH_JXTransferModel alloc] init];
        
        [self WH_setupViews];
        
        [g_notify addObserver:self selector:@selector(transferReceive:) name:kXMPPMessageTransferReceive_WHNotification object:nil]; // 已领取转账
        [g_notify addObserver:self selector:@selector(transferBack:) name:kXMPPMessageTransferBack_WHNotification object:nil]; // 转账过期
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self WH_getServerData];
}

- (void)WH_setupViews {
    self.wh_tableBody.backgroundColor = HEXCOLOR(0xefeff4);

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(18, JX_SCREEN_TOP - 38, 31, 31)];
    [btn setBackgroundImage:[UIImage imageNamed:@"transfer_cha"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableBody addSubview:btn];
    
    // 顶部图标
    _imgV = [[UIImageView alloc] init];
    [self.wh_tableBody addSubview:_imgV];
    // 等待提示语
    _hintLab = [[UILabel alloc] init];
    _hintLab.font = sysFontWithSize(14);
    [self.wh_tableBody addSubview:_hintLab];
    
    //金额
    _moneyLabel = [[UILabel alloc] init];
    _moneyLabel.font = sysFontWithSize(30);
    _moneyLabel.textAlignment = NSTextAlignmentCenter;
    [self.wh_tableBody addSubview:_moneyLabel];

    _oneDayLabel = [[UILabel alloc] init];
    _oneDayLabel.textColor = [UIColor lightGrayColor];
    _oneDayLabel.font = sysFontWithSize(14);
    [self.wh_tableBody addSubview:_oneDayLabel];
    
    _clickLab = [[UILabel alloc] init];
    _clickLab.font = sysFontWithSize(14);
    _clickLab.textColor = HEXCOLOR(0x383893);
    _clickLab.userInteractionEnabled = YES;
    [self.wh_tableBody addSubview:_clickLab];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLab)];
    [_clickLab addGestureRecognizer:tap];

    _completeBtn = [[UIButton alloc] init];
    _completeBtn.layer.masksToBounds = YES;
    _completeBtn.layer.cornerRadius = 3.f;
    [_completeBtn setTitle:Localized(@"JX_ConfirmReceipt") forState:UIControlStateNormal];
    [_completeBtn setBackgroundColor:HEXCOLOR(0x1aad19)];
    [_completeBtn addTarget:self action:@selector(clickCompleteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableBody addSubview:_completeBtn];
    
    
    _transferTime = [[UILabel alloc] init];
    _transferTime.textColor = [UIColor lightGrayColor];
    _transferTime.font = sysFontWithSize(14);
    [self.wh_tableBody addSubview:_transferTime];
    
    _getTime = [[UILabel alloc] init];
    _getTime.textColor = [UIColor lightGrayColor];
    _getTime.font = sysFontWithSize(14);
    [self.wh_tableBody addSubview:_getTime];
}

- (void)updateViews {
    UIImage *image;
    NSString *hintStr;
    NSString *oneDayStr;
    NSString *clickLabStr;
    NSString *botTimeStr;
    NSString *botTime;
    if (self.type == JXTransferDeatilTypeMySend) {
        image = [UIImage imageNamed:@"ic_ts_status2"];
        hintStr = [NSString stringWithFormat:Localized(@"JX_ReceiptConfirmedBy%@"),self.model.userName];
        oneDayStr = Localized(@"JX_FriendNotConfirm1Day");
        clickLabStr = Localized(@"JX_ResendTransferMessage");
    }else if (self.type == JXTransferDeatilTypeWait) {
        image = [UIImage imageNamed:@"ic_ts_status2"];
        hintStr = Localized(@"JX_PaymentConfirmed");
        oneDayStr = Localized(@"JX_SelfNotConfirm1Day");
    }else if (self.type == JXTransferDeatilTypeComplete) {
        image = [UIImage imageNamed:@"ic_ts_status1"];
        clickLabStr = Localized(@"JX_LookAtTheChange");
        botTimeStr = Localized(@"JX_CollectMoneyTime");
        botTime = self.model.receiptTime;
    }else if (self.type == JXTransferDeatilTypeOverdue) {
        image = [UIImage imageNamed:@"ic_ts_status3"];
        hintStr = Localized(@"JX_Returned(expired)");
        botTimeStr = Localized(@"JX_ExpirationTime");
        oneDayStr = Localized(@"JX_TheChangeHasBeenRefunded,");
        clickLabStr = Localized(@"JX_LookAtTheChange");
        botTime = self.model.outTime;
    }
    // 顶部图标
    _imgV.frame = CGRectMake((JX_SCREEN_WIDTH-40)/2, JX_SCREEN_TOP+20, 40, 40);
    _imgV.image = image;
    
    // 等待提示语
    CGSize size = [hintStr sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(14)}];
    _hintLab.frame = CGRectMake((JX_SCREEN_WIDTH-size.width)/2, CGRectGetMaxY(_imgV.frame)+20, size.width, size.height);
    _hintLab.text = hintStr;
    
    //金额
    _moneyLabel.frame = CGRectMake(0, CGRectGetMaxY(_hintLab.frame)+18, JX_SCREEN_WIDTH, 30);
    _moneyLabel.text = [NSString stringWithFormat:@"¥%.2f",self.model.money];
    
    // 1天内朋友未确认，将退还给你 ||  已退款到零钱，
    CGSize oneDaySize = [oneDayStr sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(14)}];
    CGSize clickLabSize = [clickLabStr sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(14)}];
    _oneDayLabel.frame = CGRectMake((JX_SCREEN_WIDTH-oneDaySize.width-clickLabSize.width)/2, CGRectGetMaxY(_moneyLabel.frame)+20, oneDaySize.width, oneDaySize.height);
    _oneDayLabel.text = oneDayStr;
    
    // 查看零钱 || 重发转账消息
    _clickLab.frame = CGRectMake(CGRectGetMaxX(_oneDayLabel.frame), _oneDayLabel.frame.origin.y, clickLabSize.width, clickLabSize.height);
    _clickLab.hidden = clickLabStr.length <= 0;
    _clickLab.text = clickLabStr;

    // 确认收款按钮
    _completeBtn.frame = CGRectMake(100, CGRectGetMaxY(_oneDayLabel.frame)+40, JX_SCREEN_WIDTH-100*2, 40);
    _completeBtn.hidden = self.type != JXTransferDeatilTypeWait;

    //转账时间
    NSString *tranStr = [NSString stringWithFormat:@"%@:%@",Localized(@"JX_TransferTime"),self.model.createTime];
    CGSize trSize = [tranStr sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(14)}];
    _transferTime.frame = CGRectMake((JX_SCREEN_WIDTH-trSize.width)/2, JX_SCREEN_HEIGHT-130, trSize.width, 20);
    _transferTime.text = tranStr;
    
    //收款 || 过期  时间
    NSString *getStr = [NSString stringWithFormat:@"%@:%@",botTimeStr,botTime];
    CGSize getSize = [getStr sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(14)}];
    _getTime.frame = CGRectMake(_transferTime.frame.origin.x, JX_SCREEN_HEIGHT-100, getSize.width, 20);
    _getTime.text = getStr;
    _getTime.hidden = self.type != JXTransferDeatilTypeComplete && self.type != JXTransferDeatilTypeOverdue;
}

- (void)clickCompleteBtn {
    [g_server WH_getTransferWithTransferId:self.wh_msg.objectId toView:self];
}

- (void)onClickLab {
    if (self.type == JXTransferDeatilTypeComplete || self.type == JXTransferDeatilTypeOverdue) {
//        WH_JXMyMoney_WHViewController *moneyVC = [[WH_JXMyMoney_WHViewController alloc] init];
//        [g_navigation pushViewController:moneyVC animated:YES];
        
        WH_MyWallet_WHViewController *moneyVC = [[WH_MyWallet_WHViewController alloc] init];
        [g_navigation pushViewController:moneyVC animated:YES];
        
    }else if (self.type == JXTransferDeatilTypeMySend) {
        [g_App showAlert:Localized(@"JX_ResendTransferMessage") delegate:self];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        int time = (int)([[NSDate date] timeIntervalSince1970] - [self.wh_msg.timeSend timeIntervalSince1970]) / 60 % 60;
        if (time >= 5) {            
            if (self.delegate && [self.delegate respondsToSelector:self.onResend]) {
                [self.delegate performSelectorOnMainThread:self.onResend withObject:self.wh_msg waitUntilDone:NO];
                [self actionQuit];
            }
        }else {
            [g_App showAlert:[NSString stringWithFormat:Localized(@"JX_ Again%dMinutesLater"),5-time]];
        }
    }
}


- (void)transferReceive:(NSNotification *)noti {
//    WH_JXMessageObject *msg = noti.object;
    // 收到收钱消息，获取当前时间并刷新界面
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", time];
    self.model.receiptTime = [self getTime:timeString];
    self.type = JXTransferDeatilTypeComplete;
    
    [self updateViews];
}

- (void)transferBack:(NSNotification *)noti {
    // 收到过期消息，获取当前时间并刷新界面
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", time];
    self.model.outTime = [self getTime:timeString];
    self.type = JXTransferDeatilTypeOverdue;
    
    [self updateViews];
}

- (void)WH_getServerData {
    [g_server WH_transferDetailWithTransId:self.wh_msg.objectId toView:self];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_getTransferInfo]){
        [self.model getTransferDataWithDict:dict];
        if (self.model.status == 1) {
            if (self.model.userId == [[NSString stringWithFormat:@"%@",MY_USER_ID] longLongValue]) {
                self.type = JXTransferDeatilTypeMySend;
            }else {
                self.type = JXTransferDeatilTypeWait;
            }
        }
        else if (self.model.status == 2) {
            self.type = JXTransferDeatilTypeComplete;
        }
        else if (self.model.status == -1) {
            self.type = JXTransferDeatilTypeOverdue;
        }
        [self updateViews];
    }
    if([aDownload.action isEqualToString:wh_act_receiveTransfer]){
        self.model.receiptTime = [self getTime:dict[@"time"]];
        
        self.wh_msg.fileSize = [NSNumber numberWithInt:2];
        [self.wh_msg updateReceivedYourTransferState:self.wh_msg.messageId];
        self.type = JXTransferDeatilTypeComplete;
        
        [g_notify postNotificationName:WHUpdateReceivedYourTransfer_WHNotification object:nil];
        [self updateViews];
    }

}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

// 时间戳转换时间
- (NSString *)getTime:(NSString *)time {
    NSTimeInterval interval    = [time doubleValue];
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString*currentDateStr = [formatter stringFromDate: date];
    
    return currentDateStr;
}

@end
