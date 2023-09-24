//
//  WH_JXOpenRedPacket_WHVC.m
//  Tigase_imChatT
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXOpenRedPacket_WHVC.h"
#import "WH_JXredPacketDetail_WHVC.h"
@interface WH_JXOpenRedPacket_WHVC ()

@end

@implementation WH_JXOpenRedPacket_WHVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [UIColor clearColor];
        _wait = [ATMHud sharedInstance];
        _pSelf = self;
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    _wait = [ATMHud sharedInstance];
    
    self.wh_blackBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.wh_blackBgView.backgroundColor = [UIColor blackColor];
    self.wh_blackBgView.alpha = 0.15;
    [self.view addSubview:self.wh_blackBgView];
    
    self.wh_centerRedPView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 288)];
    self.wh_centerRedPView.center = self.view.center;
    [self.view addSubview:self.wh_centerRedPView];
    
    UIImageView *redBgImage = [[UIImageView alloc] initWithFrame:self.wh_centerRedPView.bounds];
    redBgImage.image = [UIImage imageNamed:Localized(@"JX_BigRed")];
    [self.wh_centerRedPView addSubview:redBgImage];
    
    self.wh_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 48, 48)];
    self.wh_headerImageView.center = CGPointMake(self.wh_centerRedPView.frame.size.width / 2, self.wh_headerImageView.center.y);
    self.wh_headerImageView.image = [UIImage imageNamed:@"avatar_normal"];
    [self.wh_centerRedPView addSubview:self.wh_headerImageView];
    
    self.wh_fromUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.wh_headerImageView.frame) + 7, self.wh_centerRedPView.frame.size.width, 21)];
    self.wh_fromUserLabel.textAlignment = NSTextAlignmentCenter;
    self.wh_fromUserLabel.text = Localized(@"JX_LuckyStar");
    self.wh_fromUserLabel.textColor = [UIColor whiteColor];
    self.wh_fromUserLabel.font = [UIFont systemFontOfSize:15.0];
    [self.wh_centerRedPView addSubview:self.wh_fromUserLabel];
    
    self.wh_greetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.wh_fromUserLabel.frame) + 8, self.wh_centerRedPView.frame.size.width, 21)];
    self.wh_greetLabel.textAlignment = NSTextAlignmentCenter;
    self.wh_greetLabel.text = Localized(@"JX_KungHeiFatChoi");
    self.wh_greetLabel.textColor = [UIColor whiteColor];
    self.wh_greetLabel.font = [UIFont systemFontOfSize:14.0];
    [self.wh_centerRedPView addSubview:self.wh_greetLabel];
    
    self.wh_moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.wh_greetLabel.frame) + 12, 122, 45)];
    self.wh_moneyLabel.textAlignment = NSTextAlignmentCenter;
    self.wh_moneyLabel.center = CGPointMake(self.wh_centerRedPView.frame.size.width / 2, self.wh_moneyLabel.center.y);
    self.wh_moneyLabel.text = @"100.01";
    self.wh_moneyLabel.textColor = [UIColor yellowColor];
    self.wh_moneyLabel.font = [UIFont systemFontOfSize:32.0];
    [self.wh_centerRedPView addSubview:self.wh_moneyLabel];
    
    UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.wh_moneyLabel.frame), self.wh_moneyLabel.frame.origin.y + 15, 17, 16)];
    yuan.textAlignment = NSTextAlignmentCenter;
    yuan.text = Localized(@"JX_ChinaMoney");
    yuan.textColor = [UIColor blackColor];
    yuan.font = [UIFont systemFontOfSize:13.0];
    [self.wh_centerRedPView addSubview:yuan];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.wh_centerRedPView.frame.size.width - 30, 0, 30, 30)];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_centerRedPView addSubview:closeBtn];
    
    UIButton *detailBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.wh_centerRedPView.frame.size.height - 53, self.wh_centerRedPView.frame.size.width, 30)];
    [detailBtn setTitle:Localized(@"JX_ShowDetail") forState:UIControlStateNormal];
    detailBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [detailBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [detailBtn addTarget:self action:@selector(toRedPacketDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_centerRedPView addSubview:detailBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self WH_shakeToShow:_wh_centerRedPView];
    
    //解析数据,获取红包详情
    _wh_packetObj = [WH_JXPacketObject getPacketObject:_wh_dataDict];
    _wh_packetListArray = [WH_JXGetPacketList getPackList:_wh_dataDict];
    
    [self WH_setViewSize];
    [self WH_setViewData];
}

-(void)WH_setViewSize{
    _wh_headerImageView.layer.cornerRadius = 24;
    _wh_headerImageView.clipsToBounds = YES;
}

-(void)WH_setViewData{
    [g_server WH_getHeadImageSmallWIthUserId:_wh_packetObj.userId userName:_wh_packetObj.userName imageView:_wh_headerImageView];
    _wh_fromUserLabel.text = _wh_packetObj.userName;
    _wh_greetLabel.text = _wh_packetObj.greetings;
//    //1是普通红包，2是手气红包
//    if (_packetObj.type == 1) {
//        _moneyLabel.text = [NSString stringWithFormat:@"%ld",_packetObj.money];
//    }else if (_packetObj.type == 2){
    for (WH_JXGetPacketList * listObj in _wh_packetListArray) {
        NSString * userIdStr = [NSString stringWithFormat:@"%@",listObj.userId];
        if ([MY_USER_ID isEqualToString:userIdStr]) {
            _wh_moneyLabel.text = [NSString stringWithFormat:@"%.2f",listObj.money];
        }
//        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self WH_quitOutAnimate];
}
- (IBAction)toRedPacketDetail:(id)sender {
    WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
    redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:self.wh_dataDict];
//    [g_window addSubview:redPacketDetailVC.view];
    [g_navigation pushViewController:redPacketDetailVC animated:YES];
    [self WH_quitOutAnimate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)WH_quitOutAnimate{
    _wh_blackBgView.alpha = 0.0;
    [self WH_viewControllerSmallAnimation:self];
}

- (void)WH_doRemove{
    [self.view removeFromSuperview];
    _pSelf = nil;
}

- (void)dealloc {
//    [_headerImageView release];
//    [_fromUserLabel release];
//    [_greetLabel release];
//    [_moneyLabel release];
//    [_centerRedPView release];
//    [_blackBgView release];
//    [super dealloc];
}

- (void)WH_shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}


- (void)WH_viewControllerSmallAnimation:(UIViewController *)aView{
    [UIView beginAnimations:@"doViewSmall" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:aView];
    [UIView setAnimationDidStopSelector:@selector(WH_doRemove)];
    CGAffineTransform newTransform =  CGAffineTransformScale(aView.view.transform, 0.1, 0.1);
    [aView.view setTransform:newTransform];
    [UIView commitAnimations];
}


- (void)sp_getMediaData {
    NSLog(@"Check your Network");
}
@end
