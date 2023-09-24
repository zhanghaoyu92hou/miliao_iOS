//
//  WH_QRCode_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/7/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_QRCode_WHViewController.h"

#import "WH_QRImage.h"
#import "WH_JXShareModel.h"
#import "WH_JXShareManager.h"

@interface WH_QRCode_WHViewController ()
@property (nonatomic, strong) UIImageView *groupHeadImg;
@end

@implementation WH_QRCode_WHViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    self.wh_baseView = [[UIView alloc] init];
    self.wh_baseView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self.view addSubview:self.wh_baseView];
    
    [self createContentView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.3f animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.wh_baseView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}

- (void)createContentView {
    Boolean thirdLogin;
    if ([g_config.wechatLoginStatus integerValue] == 1) {
        thirdLogin = YES;
    }else{
        thirdLogin = NO;
    }
    
    //先去掉分享到微信功能
//    thirdLogin = NO;
    self.wh_contentView = [[UIView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 451)/2, JX_SCREEN_WIDTH - 40, (self.type == QR_GroupType && thirdLogin)?492:451)];
    [self.wh_contentView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_baseView addSubview:self.wh_contentView];
    self.wh_contentView.layer.masksToBounds = YES;
    self.wh_contentView.layer.cornerRadius = g_factory.cardCornerRadius;
    
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 65, 65)];
    self.groupHeadImg = headImg;
    [self.wh_contentView addSubview:headImg];
    headImg.layer.masksToBounds = YES;
    headImg.layer.cornerRadius = (MainHeadType)?(CGRectGetWidth(headImg.frame)/2):(g_factory.headViewCornerRadius);
    if (self.type == QR_GroupType) {
        [g_server WH_getRoomHeadImageSmallWithUserId:self.wh_roomJId roomId:self.wh_userId imageView:headImg];
    }else {
        [g_server WH_getHeadImageLargeWithUserId:self.wh_userId userName:self.wh_nickName imageView:headImg];
    }
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(headImg.frame.origin.x + headImg.frame.size.width + 16, headImg.frame.origin.y, self.wh_contentView.frame.size.width - CGRectGetMaxX(headImg.frame) - 26, headImg.frame.size.height)];
    if ([self.wh_groupNum integerValue] > 0) {
        [name setText:[NSString stringWithFormat:@"%@(%@)" ,self.wh_nickName?:@"" ,self.wh_groupNum]];
    }else{
        [name setText:self.wh_nickName?:@"" ];
    }
    
    [self.wh_contentView addSubview:name];
    [name setTextColor:HEXCOLOR(0x3A404C)];
    [name setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 20]];
    
    NSMutableString * qrStr = [NSMutableString stringWithFormat:@"%@?action=",g_config.website];
    if(self.type == QR_UserType)
        [qrStr appendString:@"user"];
    else if(self.type == QR_GroupType)
        [qrStr appendString:@"group"];
    if(self.wh_userId != nil)
        [qrStr appendFormat:@"&tigId=%@",self.wh_userId];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = (MainHeadType)?(63/2):(g_factory.headViewCornerRadius);
    if (self.type == QR_GroupType) {
        [g_server WH_getRoomHeadImageSmallWithUserId:self.wh_roomJId roomId:self.wh_userId imageView:imageView];
    }else {
        [g_server WH_getHeadImageLargeWithUserId:self.wh_userId userName:self.wh_nickName imageView:imageView];
    }
    
    UIImage * qrImage = [WH_QRImage qrImageForString:qrStr imageSize:255 logoImage:imageView.image logoImageSize:63];
    self.wh_qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.wh_contentView.frame.size.width-255)/2, CGRectGetMaxY(headImg.frame) + 30, 255, 255)];
    self.wh_qrImageView.image = qrImage;
    [self.wh_contentView addSubview:self.wh_qrImageView];
    
    UILabel *label = [[UILabel alloc] init];
    if (self.type == QR_GroupType && thirdLogin) {
        [label setText:@"扫一扫上面的二维码图案进群"];
        [label setFrame:CGRectMake(0, self.wh_contentView.frame.size.height - 27 - 44 - 40, self.wh_contentView.frame.size.width, 20)];
    }else{
        [label setText:(self.type == QR_GroupType)?@"扫一扫上面的二维码图案进群":@"扫一扫上面的二维码图案加为好友"];
        [label setFrame:CGRectMake(0, self.wh_contentView.frame.size.height - 50, self.wh_contentView.frame.size.width, 20)];
    }
    
    [label setTextColor:HEXCOLOR(0x969696)];
    [label setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 12]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.wh_contentView addSubview:label];
    
    if (self.type == QR_GroupType && thirdLogin) {
        NSArray *array = @[@"保存到手机" ,@"发送给微信好友"];
        for (int i = 0; i < array.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(20 + i*((CGRectGetWidth(self.wh_contentView.frame) - 40 - 15)/2 + 15), CGRectGetHeight(self.wh_contentView.frame) - 27 - 44, (CGRectGetWidth(self.wh_contentView.frame) - 40 - 15)/2, 44)];
            [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:(i == 0)?HEXCOLOR(0x8C9AB8):HEXCOLOR(0xffffff) forState:UIControlStateNormal];
            [button setBackgroundColor:(i == 0)?HEXCOLOR(0xffffff):HEXCOLOR(0x0093FF)];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = g_factory.cardCornerRadius;
            if (i == 0) {
                button.layer.borderColor = g_factory.cardBorderColor.CGColor;
                button.layer.borderWidth = g_factory.cardBorderWithd;
            }
            [button setTag:i];
            [self.wh_contentView addSubview:button];
            [button addTarget:self action:@selector(buttonClickMethod:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewController];
}

- (void)buttonClickMethod:(UIButton *)button {
    //0:保存到手机 1:发送给微信好友
    [self dismissViewController];
    if (button.tag == 0) {
        UIImageWriteToSavedPhotosAlbum(self.wh_qrImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }else{
        //发给微信好友
        WH_JXShareModel *shareModel = [[WH_JXShareModel alloc] init];
        shareModel.shareTo = 0;
        
        NSMutableString *qrStr = [NSMutableString stringWithFormat:@"%@appQCCodeShare?roomId=%@" ,g_config.apiUrl ,self.wh_userId];
        [qrStr appendFormat:@"&userId=%@&nickName=%@" ,MY_USER_ID ,[self.groupRoom getNickNameInRoom]];
        
//        UIImage * qrImage = [WH_QRImage qrImageForString:qrStr imageSize:255 logoImage:nil logoImageSize:63];
        UIImage * qrImage = self.groupHeadImg.image;
        
        shareModel.shareImage = qrImage; //群头像

        shareModel.shareContent = [NSString stringWithFormat:@"\"%@\"邀请你加入群聊%@，进入可查看详情。",g_myself.userNickname,self.wh_nickName];//内容 群说明
        shareModel.shareTitle = @"邀请你加入群聊";//标题 群名称//self.wh_nickName
        shareModel.shareUrl = qrStr;//链接
        
        [[WH_JXShareManager defaultManager] shareWith:shareModel delegate:self];
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error){
        [g_server showMsg:Localized(@"ImageBrowser_saveFaild")];
    }else{
        [g_server showMsg:Localized(@"ImageBrowser_saveSuccess")];
    }
}

- (void)dismissViewController {
    [UIView animateWithDuration:.3f animations:^{
        self.wh_contentView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self) {
            [self.view removeFromSuperview];
        }
    }];
}


@end
