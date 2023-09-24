//
//  MiXin_JXMyMoney_MiXinViewController.m
//  shiku_im
//
//  Created by 1 on 17/10/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "MiXin_JXMyMoney_MiXinViewController.h"
#import "UIImage+Color.h"
#import "MiXin_JXCashWithDraw_MiXinViewController.h"
#import "JXRechargeViewController.h"
#import "JXRecordCodeVC.h"
#import "JXMoneyMenuViewController.h"
#import "JXRecordCodeVC.h"
#import "JXPayPasswordVC.h"

@interface MiXin_JXMyMoney_MiXinViewController ()

@property (nonatomic, strong) UIButton * listButton;

@property (nonatomic, strong) UIImageView * iconView;

@property (nonatomic, strong) UILabel * myMoneyLabel;
@property (nonatomic, strong) UILabel * balanceLabel;

@property (nonatomic, strong) UIButton * rechargeBtn;
@property (nonatomic, strong) UIButton * withdrawalsBtn;
@property (nonatomic, strong) UIButton * changePayPswBtn;

@property (nonatomic, strong) UIButton * problemBtn;

@end

@implementation MiXin_JXMyMoney_MiXinViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JX_MyBalance");
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kUpdateUserNotifaction object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    
    self.tableBody.backgroundColor = HEXCOLOR(0xefeff4);
    self.tableBody.alwaysBounceVertical = YES;
    
    [self.tableHeader addSubview:self.listButton];
    
    [self.tableBody addSubview:self.iconView];
    [self.tableBody addSubview:self.myMoneyLabel];
    [self.tableBody addSubview:self.balanceLabel];
    [self.tableBody addSubview:self.rechargeBtn];
    [self.tableBody addSubview:self.withdrawalsBtn];
    [self.tableBody addSubview:self.problemBtn];
    
    //修改支付密码
    [self.tableBody addSubview:self.changePayPswBtn];
    
//    [self updateBalanceLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [g_server getUserMoenyToView:self];
}

-(void)dealloc{
    [g_notify removeObserver:self];
}

-(UIButton *)listButton{
    if(!_listButton){
        _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _listButton.frame = CGRectMake(JX_SCREEN_WIDTH-70-15, JX_SCREEN_TOP - 38, 70, 35);
        [_listButton setTitle:@"消费记录" forState:UIControlStateNormal];
        [_listButton setTitle:@"消费记录" forState:UIControlStateHighlighted];
        _listButton.titleLabel.font = g_factory.font15;
//        [_listButton setImage:[UIImage imageNamed:@"money_menu"] forState:UIControlStateNormal];
        _listButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listButton;
}


-(UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.frame = CGRectMake(0, 65, 90, 100);
        _iconView.center = CGPointMake(JX_SCREEN_WIDTH/2, _iconView.center.y);
        _iconView.image = [UIImage imageNamed:@"weixinpayyue"];
        
    }
    return _iconView;
}

-(UILabel *)myMoneyLabel{
    if (!_myMoneyLabel) {
        _myMoneyLabel = [UIFactory createLabelWith:CGRectZero text:Localized(@"JXMoney_myPocket") font:g_factory.font14 textColor:[UIColor blackColor] backgroundColor:nil];
        _myMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _myMoneyLabel.frame = CGRectMake(0, CGRectGetMaxY(_iconView.frame)+20, JX_SCREEN_WIDTH, 20);
        _myMoneyLabel.center = CGPointMake(_iconView.center.x, _myMoneyLabel.center.y);
    }
    return _myMoneyLabel;
}

-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
        _balanceLabel = [UIFactory createLabelWith:CGRectZero text:moneyStr font:g_factory.font28 textColor:[UIColor blackColor] backgroundColor:nil];
        _balanceLabel.textAlignment = NSTextAlignmentCenter;
        _balanceLabel.frame = CGRectMake(0, CGRectGetMaxY(_myMoneyLabel.frame)+5, JX_SCREEN_WIDTH, 30);
        _balanceLabel.center = CGPointMake(_iconView.center.x, _balanceLabel.center.y);
    }
    return _balanceLabel;
}

-(UIButton *)rechargeBtn{
    if (!_rechargeBtn) {
        _rechargeBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXLiveVC_Recharge") titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(rechargeBtnAction:) target:self];
        _rechargeBtn.frame = CGRectMake(15, CGRectGetMaxY(_balanceLabel.frame)+40, JX_SCREEN_WIDTH-15*2, 40);
        [_rechargeBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x1aad19)] forState:UIControlStateNormal];
        [_rechargeBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
        _rechargeBtn .layer.cornerRadius = 5;
        _rechargeBtn.clipsToBounds = YES;
    }
    return _rechargeBtn;
}

-(UIButton *)withdrawalsBtn{
    if (!_withdrawalsBtn) {
        _withdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_withdrawals") titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
        _withdrawalsBtn.frame = CGRectMake(15, CGRectGetMaxY(_rechargeBtn.frame)+20, CGRectGetWidth(_rechargeBtn.frame), CGRectGetHeight(_rechargeBtn.frame));
        [_withdrawalsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_withdrawalsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
        _withdrawalsBtn .layer.cornerRadius = 5;
        _withdrawalsBtn.clipsToBounds = YES;
    }
    return _withdrawalsBtn;
}

-(UIButton *)changePayPswBtn{
    if (!_changePayPswBtn) {
        _changePayPswBtn = [UIFactory createButtonWithRect:CGRectZero title:@"修改支付密码" titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(changePayPswBtnAction:) target:self];
        _changePayPswBtn.frame = CGRectMake(15, CGRectGetMaxY(_withdrawalsBtn.frame)+20, CGRectGetWidth(_withdrawalsBtn.frame), CGRectGetHeight(_withdrawalsBtn.frame));
        [_changePayPswBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_changePayPswBtn setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        [_changePayPswBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_changePayPswBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
        _changePayPswBtn .layer.cornerRadius = 5;
        _changePayPswBtn.clipsToBounds = YES;
    }
    return _changePayPswBtn;
}



-(UIButton *)problemBtn{
    if (!_problemBtn) {
        _problemBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_FAQ") titleFont:g_factory.font14 titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(problemBtnAction) target:self];
        CGFloat drawWidth = [_problemBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_problemBtn.titleLabel.font}].width;
        _problemBtn.frame = CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-25-5, drawWidth, 25);
        _problemBtn.center = CGPointMake(JX_SCREEN_WIDTH/2, _problemBtn.center.y);
    }
    return _problemBtn;
}


-(void)updateBalanceLabel{
    NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
    self.balanceLabel.text = moneyStr;
    CGFloat Width = [self.balanceLabel.text sizeWithAttributes:@{NSFontAttributeName:self.balanceLabel.font}].width;
    CGRect frame = self.balanceLabel.frame;
    frame.size.width = Width;
    self.balanceLabel.frame = frame;
    self.balanceLabel.center = CGPointMake(self.iconView.center.x, self.balanceLabel.center.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Action

-(void)listButtonAction{
//    _listButton.enabled = NO;
//    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
//    JXMoneyMenuViewController *monVC = [[JXMoneyMenuViewController alloc] init];
//    [g_navigation pushViewController:monVC animated:YES];
    
    [self onBill];
}

//修改支付密码
- (void)changePayPswBtnAction:(UIButton *)btn
{
    [self onPayThePassword];
}

- (void)onBill {
    JXRecordCodeVC * recordVC = [[JXRecordCodeVC alloc]init];
    [g_navigation pushViewController:recordVC animated:YES];
}


- (void)onPayThePassword {
    JXPayPasswordVC * PayVC = [JXPayPasswordVC alloc];
    if ([g_server.myself.isPayPassword boolValue]) {
        PayVC.type = JXPayTypeInputPassword;
    }else {
        PayVC.type = JXPayTypeSetupPassword;
    }
    PayVC.enterType = JXEnterTypeDefault;
    PayVC = [PayVC init];
    [g_navigation pushViewController:PayVC animated:YES];
}


-(void)rechargeBtnAction:(UIButton *)button{
    [g_App showAlert:@"暂不开放"];
    return;

    _rechargeBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
    JXRechargeViewController * rechargeVC = [[JXRechargeViewController alloc] init];
    
//    [g_window addSubview:rechargeVC.view];
    [g_navigation pushViewController:rechargeVC animated:YES];
}
-(void)withdrawalsBtnAction:(UIButton *)button{
    [g_App showAlert:@"暂不开放"];
    return;

    _withdrawalsBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
    MiXin_JXCashWithDraw_MiXinViewController * cashWithVC = [[MiXin_JXCashWithDraw_MiXinViewController alloc] init];
//    [g_window addSubview:cashWithVC.view];
    [g_navigation pushViewController:cashWithVC animated:YES];
}

-(void)problemBtnAction{
    _problemBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
}

-(void)delayButtonReset{
    _rechargeBtn.enabled = YES;
    _withdrawalsBtn.enabled = YES;
    _problemBtn.enabled = YES;
    _listButton.enabled = YES;
}

-(void)doRefresh:(NSNotification *)notifacation{
    _balanceLabel.text = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
}
//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];

    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
        _balanceLabel.text = moneyStr;
    }
}

@end
