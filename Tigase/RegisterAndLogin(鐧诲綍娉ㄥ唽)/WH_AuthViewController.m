//
//  WH_AuthViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AuthViewController.h"
#import "SDImageCache.h"
//#import "UIImageView+WebCache.h"
#import "AFNetworking.h"

@interface WH_AuthViewController ()
{
    UIImageView *logo;
    UILabel *apply;
}
@property (nonatomic, strong) NSDictionary *user;
@end

@implementation WH_AuthViewController

- (void)actionQuitt {
    [self clickCancelLoginBtn:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.title = @"授权登录";
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    [self shareAuthType:@"1" callBack:nil];
    [self createHeadAndFoot];
    [self createMain];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, JX_SCREEN_TOP - 38, 31, 31)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuitt) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableHeader addSubview:btn];
}

- (void)createMain {
    UIView *tt = [self.wh_tableBody createLine:CGRectMake(16, 30, 23, 23) color:HEXCOLOR(0x979797) radio:0 border:nil];
    logo = [[UIImageView alloc]initWithFrame:tt.bounds];
    
    [tt addSubview:logo];
    //[logo sd_setImageWithURL:[NSURL URLWithString:self.fromLogo]];
    [self.wh_tableBody addSubview:tt];
    
    apply = [tt createLab:CGRectMake(tt.right+10, 30, JX_SCREEN_WIDTH-tt.right-20, 23) font:sysFontWithSize(14) color:HEXCOLOR(0x333333) text:[NSString stringWithFormat:@"%@ 申请使用", self.infoDic[@"appName"]]];
    [self.wh_tableBody addSubview:apply];
    
    UILabel *info = [tt createLab:CGRectMake(16, tt.bottom+15, JX_SCREEN_WIDTH-32, 40) font:sysFontWithSize(20) color:HEXCOLOR(0x333333) text:@"你的Tigase头像、昵称、地区和性别信息"];
    info.numberOfLines = 0;
    [self.wh_tableBody addSubview:info];
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(16, info.bottom+46, 42, 42)];
    [icon setRadiu:21 color:nil];
    [self.wh_tableBody addSubview:icon];
    [g_server WH_getHeadImageSmallWIthUserId:g_myself.userId userName:g_myself.userNickname imageView:icon];
    [tt createLine:CGRectMake(16, icon.top-15, JX_SCREEN_WIDTH-32, 1.5) color:HEXCOLOR(0xF4F4F4) radio:0 border:nil sup:self.wh_tableBody];
    [tt createLine:CGRectMake(16, icon.bottom+15, JX_SCREEN_WIDTH-32, 1.5) color:HEXCOLOR(0xF4F4F4) radio:0 border:nil sup:self.wh_tableBody];
    
    UILabel *name = [tt createLab:CGRectMake(icon.right+8, icon.top, JX_SCREEN_WIDTH-icon.right-20, 22) font:sysFontWithSize(17) color:HEXCOLOR(0x333333) text:MY_USER_NAME];
    [self.wh_tableBody addSubview:name];
    UILabel *detail = [tt createLab:CGRectMake(icon.right+8, name.bottom+2, JX_SCREEN_WIDTH-icon.right-20, 17) font:sysFontWithSize(14) color:HEXCOLOR(0x999999) text:@"Tigase个人信息"];
    [self.wh_tableBody addSubview:detail];
    
    UIButton *confirm = [tt createBtn:CGRectMake(JX_SCREEN_WIDTH/2-80, icon.bottom+230, 160, 35) font:sysFontWithSize(16) color:[UIColor whiteColor] text:@"同意" img:nil target:self sel:@selector(clickLoginBtn:)];
    confirm.backgroundColor = HEXCOLOR(0x0093FF);
    [confirm setRadiu:10 color:nil];
    [self.wh_tableBody addSubview:confirm];
    
    UIButton *cancel = [tt createBtn:CGRectMake(JX_SCREEN_WIDTH/2-80, confirm.bottom+20, 160, 35) font:sysFontWithSize(16) color:HEXCOLOR(0x0093FF) text:@"拒绝" img:nil target:self sel:@selector(clickCancelLoginBtn:)];
    cancel.backgroundColor = HEXCOLOR(0xEDEDED);
    [cancel setRadiu:10 color:nil];
    [self.wh_tableBody addSubview:cancel];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    logo.image = self.sdkImage ? : nil;
    apply.text = [NSString stringWithFormat:@"%@ 申请使用", self.infoDic[@"appName"]];
}

#pragma mark ----- 登录
- (void)clickLoginBtn:(UIButton *)loginBtn {
    //NSDateFormatter *formt = [[NSDateFormatter alloc]init];
    //[formt setDateFormat:@"yyyy-MM-dd"];
    
    if (!_user) {
        [g_server showMsg:@"获取用户信息失败"];
        //[self clickCancelLoginBtn:nil];
        return;
    }
    NSDictionary *tempDic = @{@"type":@"Login",@"result":@(YES), @"info":@{@"birthday":_user[@"birthday"], @"image":_user[@"image"], @"nickName":_user[@"nickName"], @"openId":_user[@"openId"], @"sex":_user[@"sex"], @"cityId":_user[@"cityId"], @"provinceId":_user[@"provinceId"]}};
    
    NSString *result = [NSString stringWithFormat:@"%@://%@/%@",self.fromSchema, BackToSDKIdentifier,[tempDic mj_JSONString]];
    result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self backToAPP:result];
    [self actionQuit];
}


- (void)backToAPP:(NSString *)result {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData *data = [[NSData alloc] init];
    [pasteboard setData:data forPasteboardType:@"BLNLogin"];
    [pasteboard setData:data forPasteboardType:@"BLNImage"];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://",@"ska"]];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ska://%@",[self.fromScheme stringByReplacingOccurrencesOfString:@"ska" withString:@""]]];
    //BOOL isCanOpen = [[UIApplication sharedApplication] canOpenURL:url];
    //if (isCanOpen) {

    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result] options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
    }
    
    //[g_server loginPublicAccountReqWithQrCodeToken:@"" toView:self];
    
}

- (void)clickCancelLoginBtn:(UIButton *)cancelLoginBtn{
    NSDictionary *tempDic = @{@"type":@"Login",@"result":@(NO), @"info":@{@"resultMsg":@"您取消了授权登录"}};
    NSString *result = [NSString stringWithFormat:@"%@://%@/%@",self.fromSchema, BackToSDKIdentifier,[tempDic mj_JSONString]];
    [self backToAPP:result];
    [self actionQuit];
}

- (void)showErrorAlertView:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:NO completion:nil];
}
#pragma mark - 请求成功回调
//登录或分享授权
- (void)shareAuthType:(NSString *)type callBack:(void (^)(id _Nonnull))block {
    NSDictionary *dic = [g_default objectForKey:@"beAuth"];
    if (dic) {
        self.infoDic = dic[@"info"];
        UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
        UIImage *image;
        NSData *data = [pasteboard dataForPasteboardType:@"BLNLogin"];
        if (data) {
            image = [UIImage imageWithData:data];
            self.sdkImage = image;
        }else {
            NSLog(@"图片不存在");
        }
        
        NSURL *url = [NSURL URLWithString:dic[@"url"]];
        self.fromSchema = url.host;
        [g_default removeObjectForKey:@"beAuth"];
    }
   
    if (!self.fromSchema || !self.infoDic[@"appSecret"]) {
        NSLog(@"TigaseAPP授权失败,请检查您的appId等参数不可为空");
        [GKMessageTool showError:@"TigaseAPP授权失败,请检查您的appId等参数不可为空"];
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    long time = (long)[[NSDate date] timeIntervalSince1970];
    param[@"time"] = [NSString stringWithFormat:@"%ld",time];
    param[@"appSecret"] = self.infoDic[@"appSecret"];
    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_TOKEN];
    param[@"secret"] = [self getSecret:self.infoDic[@"appSecret"] appId:self.fromSchema time:param[@"time"] userid:MY_USER_ID token:token];
    param[@"appId"] = self.fromSchema;
    param[@"userId"] = MY_USER_ID;
    param[@"type"] = type;
    param[@"access_token"] = token;
    NSString *urlString = [NSString stringWithFormat:@"%@open/authInterface",g_config.apiUrl];
    NSLog(@"param === %@, urlString = %@",param, urlString);
    [self GET:urlString param:param success:^(id dic) {
        if ([dic[@"resultCode"]integerValue]==1) {
            
            [self codeAuthorCheck:token];
        }else {
            NSString *msg = [NSString stringWithFormat:@"%@",dic[@"resultMsg"]];
            NSLog(@"%@",msg);
            [GKMessageTool showError:msg];
        }
    } fail:^(NSError *error) {
        NSString *msg = [NSString stringWithFormat:@"%@",@"网络错误,请检查您的网络"];
        [GKMessageTool showError:msg];
    }];
}


- (void)codeAuthorCheck:(NSString *)token {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];

    param[@"appId"] = self.fromSchema;
    param[@"state"] = token;
    param[@"callbackUrl"] = [NSString stringWithFormat:@"%@code/oauth",g_config.apiUrl];
    //@"http://10.10.10.213:8092/code/oauth";

    [self GET:[NSString stringWithFormat:@"%@open/codeAuthorCheck",g_config.apiUrl]
 param:param success:^(id dic) {
     
        if ([dic[@"resultCode"]integerValue]==1) {
            NSDictionary *data = dic[@"data"];
            [self openCodeOauth:data[@"code"]];
        }else {
            NSString *msg = [NSString stringWithFormat:@"%@",dic[@"resultMsg"]];
            [GKMessageTool showMessage:msg];
        }

    } fail:^(NSError *error) {
        NSString *msg = [NSString stringWithFormat:@"%@",@"网络错误,请检查您的网络"];
        [GKMessageTool showMessage:msg];
    }];
}



- (void)openCodeOauth:(NSString *)code {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    param[@"code"] = code;

    [self GET:[NSString stringWithFormat:@"%@open/code/oauth",g_config.apiUrl]
 param:param success:^(id dic) {
        if ([dic[@"resultCode"]integerValue]==1) {
            _user = dic[@"data"];
        }else {
            [GKMessageTool showMessage:[NSString stringWithFormat:@"%@",dic[@"resultMsg"]]];
        }

    } fail:^(NSError *error) {
        [GKMessageTool showMessage:[NSString stringWithFormat:@"网络错误,请检查您的网络"]];
        
    }];
}




- (void)GET:(NSString *)url param:(id)param success:(void (^)(id dic))success fail:(void (^)(NSError *error))fail {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 5;
    manager.responseSerializer.acceptableContentTypes= [NSSet setWithObjects:@"text/plain",@"text/json",@"application/json",@"text/html", nil];
    
    [manager GET:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"----%@",responseObject);
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (fail) {
            fail(error);
        }
    }];
}


// 登录分享授权接口加密
//md5(apikey+appId+userid+md5(token+time)+md5(appSecret))
- (NSString *)getSecret:(NSString *)appSecret appId:(NSString *)appId time:(NSString *)time userid:(NSString *)userid token:(NSString *)token {
    NSString *secret;
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:appId];
    [str1 appendString:userid];
    
    [str1 appendString:[g_server WH_getMD5StringWithStr:[token stringByAppendingString:time]]];
    [str1 appendString:[g_server WH_getMD5StringWithStr:appSecret]];
    
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    secret = [str1 copy];
    return secret;
}



@end
