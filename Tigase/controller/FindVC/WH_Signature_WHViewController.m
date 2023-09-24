//
//  WH_Signature_WHViewController.m
//  WaHu
//
//  Created by Apple on 2019/3/1.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WH_Signature_WHViewController.h"
#import "LDCalendarView.h"
//#import <Masonry/Masonry.h>
#import "UICountingLabel.h"
#import "WeekSignatureModel.h"

#import "WH_JXCashWithDraw_WHViewController.h"
#import "JX_NewWithdrawViewController.h"
#import "WH_WithdrawalToBackground_WHViewController.h"

#define PocketViewTag   1000
#define PocketImgViewTag    6
@interface WH_Signature_WHViewController ()
@property (nonatomic, strong)LDCalendarView    *calendarView;//日历控件
@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UICountingLabel *totalMoneyLable;

@property (weak, nonatomic) IBOutlet UILabel *day1Lbl;
@property (weak, nonatomic) IBOutlet UIImageView *day1Img;
@property (weak, nonatomic) IBOutlet UILabel *day2Lbl;

@property (weak, nonatomic) IBOutlet UIImageView *day2Img;
@property (weak, nonatomic) IBOutlet UILabel *day3Lbl;
@property (weak, nonatomic) IBOutlet UIImageView *day3Img;
@property (weak, nonatomic) IBOutlet UIImageView *day4Lbl;

@property (weak, nonatomic) IBOutlet UIImageView *da4Img;
@property (weak, nonatomic) IBOutlet UILabel *day5Lbl;
@property (weak, nonatomic) IBOutlet UIImageView *day5Img;

@property (weak, nonatomic) IBOutlet UIImageView *day6Img;
@property (weak, nonatomic) IBOutlet UILabel *day6Lbl;
@property (weak, nonatomic) IBOutlet UIImageView *day7Img;
@property (weak, nonatomic) IBOutlet UILabel *day7Lbl;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (weak, nonatomic) IBOutlet UILabel *tip1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *tip2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *seriesDayLbl;
@property (weak, nonatomic) IBOutlet UIButton *signBtn;

@property (weak, nonatomic) IBOutlet UIButton *adjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *adventureBtn;
@property (weak, nonatomic) IBOutlet UIButton *adBtn;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipTopCons;

@end

@implementation WH_Signature_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"WaHu_SignRedPacket_WaHu");
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    
    [self createHeadAndFoot];
    
    [self.wh_tableHeader addSubview:self.wh_listButton];
    
    [self.wh_tableBody setHidden:YES];
    
    self.adjustBtn.adjustsImageWhenHighlighted = false;
    [self.adBtn setAdjustsImageWhenHighlighted:true];

    [_btn setBackgroundImage:[UIImage imageNamed:@"WH_SignatureBottomBtn2"] forState:UIControlStateNormal];
    [_btn setBackgroundImage:[UIImage imageNamed:@"WH_SignatureBottomBtn2"] forState:UIControlStateHighlighted];
    
    self.totalMoneyLable.wh_method = UILabelCountingMethodLinear;
    self.totalMoneyLable.wh_format = @"%.2f";
    
    [self.totalMoneyLable countFrom:0.00
                    to:0.00
          withDuration:1.0f];
   
    [self requestWeek];
 
    _tipTopCons.constant = JX_SCREEN_TOP + 20;
    
}

-(UIButton *)wh_listButton{
    if(!_wh_listButton){
        _wh_listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _wh_listButton.frame = CGRectMake(JX_SCREEN_WIDTH-70-15, JX_SCREEN_TOP - 38, 70, 35);
        [_wh_listButton setTitle:Localized(@"WaHu_SignCalander_WaHu") forState:UIControlStateNormal];
        [_wh_listButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _wh_listButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
        _wh_listButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_wh_listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wh_listButton;
}

-(void) listButtonAction{
    [self.calendarView show];
}
- (LDCalendarView *)calendarView {
    //    if (!_calendarView) {
    _calendarView = [[LDCalendarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];

    [self.view addSubview:_calendarView];

    return _calendarView;
}
- (void) openRedPocket:(NSInteger) dayIndex{
    NSInteger vTag = PocketViewTag + dayIndex;
    UIView *view = [_stackView viewWithTag:vTag];
    UIImageView *imgView = [view viewWithTag:PocketImgViewTag];
    imgView.image = [UIImage imageNamed:@"WH_OpenRedPocket"];
    [imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top).with.offset(12); //with is an optional semantic filler
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(@33);
        make.height.equalTo(@80);
    
//        make.right.equalTo(view.mas_right).with.offset(-padding.right);
    }];

}

- (IBAction)signatureBtn:(id)sender {
   
    [self requestSign];
    
}
-(void) requestSign{
    //用户签到
    [g_server requestUserSignInWithUserId:MY_USER_ID toView:self];
    
//    [g_server useSignWithWithUserId:g_myself.userId toView:self];
}

-(void) requestWeek{
//    [g_server userSignHandle7DaySignWithUserId:g_myself.userId toView:self];
    [g_server requestUserSignHandle7DaySignWithUserId:MY_USER_ID toView:self];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if([aDownload.action isEqualToString:wh_act_UserSign] ){
        NSString *msg = [dict objectForKey:@"msg"]?:@"签到";
        [g_App showAlert:msg];
        
        [self day7SignStatus:dict];
        //更新余额信息
        [g_server WH_getUserMoenyToView:self];
    }else if ([aDownload.action isEqualToString:wh_act_SingWeek]) {
        //签到信息
        if ([[dict objectForKey:@"seriesSignCount"] integerValue] > 0) {
            self.seriesDayLbl.text = [NSString stringWithFormat: @"%@%@%@",@"你已连续签到",[dict objectForKey:@"seriesSignCount"],@"天"];
        }
        [self day7SignStatus:dict];
    }else if ([aDownload.action isEqualToString:wh_act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
    }
}

#pragma mark - 请求失败回调
- (int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    NSString *errorMsg = [dict objectForKey:@"resultMsg"]?:@"请求报错,请重试!";
    [g_App showAlert:errorMsg];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [g_App showAlert:@"请求报错,请重试!"];
    return WH_hide_error;
}

-(void) day7SignStatus:(NSDictionary *)dict {
    if ([[dict objectForKey:@"signStatus"] integerValue] == 1) {
        [self signBtnDisable];
    }
    
    NSString *money = @"";
    //[self awardMoney:[dict objectForKey:@"signAward"]?:@""];
    if ([dict objectForKey:@"signAward"]) {
        money = [self awardMoney:[dict objectForKey:@"signAward"]?:@""];
    }
    if (money.length > 0) {
        [self.totalMoneyLable countFrom:0.00
                                     to:money.floatValue
                           withDuration:1.0f];
    }
    NSInteger signCount = [[dict objectForKey:@"seriesSignCount"] integerValue];
    for(int i=1;i<signCount+1;i++){
        [self openRedPocket:i];
    }
}

-(NSString *) awardMoney:(NSString *) award{
    NSArray *awardArr = [award componentsSeparatedByString:@","];
    //    NSDictionary * jsonDic = [JSON objectFromJSONString:weekSignModel.signAward];
    if (awardArr.count){
        NSString *strMoney = awardArr[0];
        NSArray *arr1 = [strMoney componentsSeparatedByString:@":"];
        NSString *money = arr1[1];
        return money;
    }
    
    return nil;
}
-(void) signBtnDisable{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    self.tip1Lbl.text = [NSString stringWithFormat:@"恭喜你今天领到%@红包" ,appName];
    [self.signBtn setTitle:@"今日已签到" forState:UIControlStateNormal];
    [self.signBtn setBackgroundImage:[UIImage imageNamed:@"WH_PinkBtn"] forState:UIControlStateNormal];
    self.signBtn.userInteractionEnabled = false;
}

#pragma mark 提现
- (IBAction)withDrawBtn:(id)sender {
    //提现界面
    if ([g_config.isWithdrawToAdmin intValue] == 1) {
        //提现到后台审核
//        JX_NewWithdrawViewController *wvVC = [[JX_NewWithdrawViewController alloc] init];
//        [g_navigation pushViewController:wvVC animated:YES];
        
        WH_WithdrawalToBackground_WHViewController *withdrawalBGVC = [[WH_WithdrawalToBackground_WHViewController alloc] init];
        [g_navigation pushViewController:withdrawalBGVC animated:YES];
        
    } else {
        WH_JXCashWithDraw_WHViewController * cashWithVC = [[WH_JXCashWithDraw_WHViewController alloc] init];
        [g_navigation pushViewController:cashWithVC animated:YES];
    }
    
}

- (IBAction)adventureBtn:(id)sender {
//    AdventureViewController *adventureVC = [[AdventureViewController alloc] initWithNibName:@"AdventureViewController" bundle:nil];
//    [self.navigationController pushViewController:adventureVC animated:YES];
}



@end
