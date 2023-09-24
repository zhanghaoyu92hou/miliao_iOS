//
//  JX_QQ_manager.m
//  Tigase
//
//  Created by 史小峰 on 2019/7/25.
//  Copyright © 2019 Reese. All rights reserved.
//


#import "JX_QQ_manager.h"

@interface JX_QQ_manager()<TencentSessionDelegate>
{
    time_t   loginTime;
    TencentOAuth *_tecentOauth;
}
@end

@implementation JX_QQ_manager




- (instancetype)init{
    if (self = [super init]) {
        loginTime = 0;
    }
    
    return self;
}


- (void)tencentDidLogin{
    
    if (_tecentOauth.accessToken && _tecentOauth.accessToken.length != 0) {
        //记录登录⽤用户的OpenID、Token以及过期时间
        /*
            登录成功后，即可获取到access token和openid。accessToken和 openid保存在TencentOAuth 对象中，并且已经本地化存储。可以通过相应的属性⽅方法直接获得
         */
        [_tecentOauth accessToken] ;
        [_tecentOauth openId] ;
        [_tecentOauth getCachedOpenID];
        [_tecentOauth getCachedToken];
        
        //回调
        
        !self.loginCallBack ? : self.loginCallBack(_tecentOauth);
        
        //用于获取用户头像
        [_tecentOauth getUserInfo];
    }else{
        //登录不不成功 没有获取到accesstoken
    }
    
    
}
//非⽹网络错误导致登录失败:
-(void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled){
        //⽤用户取消登录
        [g_App showAlert:@"登录取消"];
    }else{
        //登录失败
        [g_App showAlert:@"登录失败"];
    }
}
//⽹网络错误导致登录失败:
- (void) tencentDidNotNetWork{
    [g_App showAlert:@"网络错误"];
}


/**
 * 用户增量授权过程中因取消或网络问题导致授权失败
 * \param reason 授权失败原因，具体失败原因参见sdkdef.h文件中\ref UpdateFailType
 */
- (void)tencentFailedUpdate:(UpdateFailType)reason{
    
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*) response{
    
}





- (void)QQ_login
{
    //检测是否安装Q
//    if (![TencentOAuth iphoneQQInstalled]) {
//        [g_App showAlert:@"您未安装QQ客户端"];
//        return;
//    }
    
    
    
    TencentOAuth * oauth = [[TencentOAuth alloc] initWithAppId:g_config.qqLoginAppId andDelegate:self];
    _tecentOauth = oauth;
        
    time_t currentTime;
    time(&currentTime);
    if ((currentTime - loginTime) > 2)
    {
        
        _tecentOauth.authMode = kAuthModeClientSideToken;
        [_tecentOauth authorize:[self getPermissions] inSafari:NO];
        loginTime = currentTime;
    }
}

- (NSMutableArray *)getPermissions
{
    NSMutableArray * g_permissions = [[NSMutableArray alloc] initWithObjects:kOPEN_PERMISSION_GET_USER_INFO,
                                      kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                      kOPEN_PERMISSION_ADD_ALBUM,
                                      kOPEN_PERMISSION_ADD_TOPIC,
                                      kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                      kOPEN_PERMISSION_GET_INFO,
                                      kOPEN_PERMISSION_GET_OTHER_INFO,
                                      kOPEN_PERMISSION_LIST_ALBUM,
                                      kOPEN_PERMISSION_UPLOAD_PIC,
                                      kOPEN_PERMISSION_GET_VIP_INFO,
                                      kOPEN_PERMISSION_GET_VIP_RICH_INFO, nil];
//    g_permissions = @[@"get_user_info",@"get_simple_userinfo", @"add_t"];
    return g_permissions;
}

@end
