//
//  WH_AdvertisingViewController.m
//  Tigase
//
//  Created by Apple on 2019/10/11.
//  Copyright © 2019 Reese. All rights reserved.
//  启动页，展示启动页和广告图

#import "WH_AdvertisingViewController.h"
#import "WH_AdvertisingView.h"

NSInteger adTime = 3;

@interface WH_AdvertisingViewController ()
{
    NSTimer *_adTimer; //定时器
    UIImageView *lunchImageView; //!< 在自动登录时显示启动图
    WH_AdvertisingView *_advertisingView;// 启动广告图
}
@end

@implementation WH_AdvertisingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载子视图
    [self buildSubviews];
    //请求网络广告图
    [self requestStartupImage];
    _adTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(adTimeCountAction:) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
    
}

#pragma mark -- 创建底部视图
- (void)buildSubviews {
    lunchImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    lunchImageView.image = [UIImage imageNamed:[self getLaunchImageName]];
    [self.view addSubview:lunchImageView];
}

#pragma mark -- 创建广告图
- (void)buildAdversitingView {
    _advertisingView = [[WH_AdvertisingView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT * 0.85) withImage:[g_default objectForKey:advertisingImageUrl] showSkipButton:NO];
    [self.view addSubview:_advertisingView];
    __weak typeof(self) weakSelf = self;
    _advertisingView.skipAdBlock = ^{
        NSLog(@"跳过");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.skipActionBlock) {
            strongSelf.skipActionBlock();
        }
    };
}

#pragma mark -- 网络请求广告图
- (void)requestStartupImage {
    [[JXServer sharedServer] getStartUpImageToView:self];
}

#pragma mark ------ 网络请求
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    [g_default setBool:YES forKey:kTHIRD_LOGIN_AUTO];
    NSLog(@"网络请求成功：%@ %@ %@", dict, aDownload, array1);
    if ([array1 isKindOfClass:[NSArray class]]) {
        NSDictionary *firstImageDic = [array1 firstObject];
        if (firstImageDic) {
            NSString *addr = firstImageDic[@"addr"];
            [g_default setObject:addr forKey:advertisingImageUrl];
            [self buildAdversitingView];
        }
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    NSLog(@"网络请求失败：%@", dict);
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error {//error为空时，代表超时
    NSLog(@"网络请求出错：%@", error);
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_MiXinStart:(WH_JXConnection*)aDownload{
    NSLog(@"开始请求");
}

#pragma mark -- 倒计时方法
- (void)adTimeCountAction:(NSTimer *)timer {
    adTime--;
    if (adTime <= 0) {
        //倒计时结束,自动跳过
        [self skipAction];
    }
    _advertisingView.countTime = adTime;
}

#pragma makr -- 跳过
- (void)skipAction {
    if (_adTimer) {
        [_adTimer invalidate];
        _adTimer = nil;
    }
    //调用跳过时机
    if (self.skipActionBlock) {
        self.skipActionBlock();
    }
}

- (void)dealloc {
    if (_adTimer) {
        [_adTimer invalidate];
        _adTimer = nil;
    }
}


#pragma mark ---- 获取启动图
// 获取启动图
- (NSString *)getLaunchImageName
{
    NSString *viewOrientation = @"Portrait";
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        viewOrientation = @"Landscape";
    }
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}

@end
