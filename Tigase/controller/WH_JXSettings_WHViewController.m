//
//  WH_JXSettings_WHViewController.m
//  Tigase_imChatT
//
//  Created by Apple on 16/5/6.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXSettings_WHViewController.h"
#import "UIImage+WH_Tint.h"
#import "WH_LoginViewController.h"
#import "WH_JXMoreSelect_WHVC.h"
#import "WH_JXActionSheet_WHVC.h"
#import "WH_BlackList_WHController.h"

#define HEIGHT 56

typedef enum : NSUInteger {
    Type_chatRecordTimeOut = 1,
    Type_chatSyncTimeLen,
    Type_groupChatSyncTimeLen,
} PickerViewType;

@interface WH_JXSettings_WHViewController ()<UIAlertViewDelegate, UIPickerViewDelegate,WH_JXMoreSelectVCDelegate,WH_JXActionSheet_WHVCDelegate>{
    ATMHud* _wait;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCon;
@property (nonatomic, strong) UILabel *timeOutLabel;
@property (nonatomic, strong) UILabel *syncTimeLenLabel;
@property (nonatomic, strong) UILabel *groupSyncTimeLenLabel;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerArr;
@property (nonatomic, assign) PickerViewType selType;

@property (nonatomic, strong) WH_JXMoreSelect_WHVC *moreVC;

@property (nonatomic, strong) NSString *indexStr;
@property (nonatomic, strong) UILabel *addMeTypeLab;
@property (nonatomic, strong) UILabel *seeTimeTypeLab;
@property (nonatomic, strong) UILabel *seeNumTypeLab;
@property (nonatomic, strong) NSArray *loginTimeArr;
@property (nonatomic, assign) BOOL isShowNum;


@end

@implementation WH_JXSettings_WHViewController

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeaderView];
    
    [self.view setBackgroundColor:g_factory.globalBgColor];
    
    self.topCon.constant = JX_SCREEN_TOP;
    
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
//    self.dataSorce = [[NSDictionary alloc]init];
//    [self getData];
    
    //获取服务器的好友状态
    [self changeSettingsNum];
    
    _pickerArr = @[Localized(@"JX_OutOfSync"),Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear"),Localized(@"JX_Forever")];
    _loginTimeArr = @[Localized(@"JX_SetContactYES"),Localized(@"JX_SetAllFriendYES"),Localized(@"JX_SetAllYES"),Localized(@"JX_SetAllNO")];

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, ([g_config.regeditPhoneOrName intValue] == 0) ? 282 : (282-(190-HEIGHT*2-10)))];
    headView.backgroundColor = g_factory.globalBgColor;
//    [self.myTableView addSubview:headView];
    
    CGFloat y = 12;
    
    UIView *tmView = [self createViewWithOrginY:y height:HEIGHT superView:headView];
    //消息漫游时间
    WH_JXImageView *iv = [self WH_create_WHButtonWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, HEIGHT) title:Localized(@"JX_SingleRoamTime") drawTop:NO drawBottom:YES must:NO click:@selector(syncTimeLen:) superView:tmView];
    
    _syncTimeLenLabel = [[UILabel alloc]initWithFrame:CGRectMake(210 ,0,JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 200 - 39,HEIGHT)];
    _syncTimeLenLabel.textAlignment = NSTextAlignmentRight;
    _syncTimeLenLabel.userInteractionEnabled = NO;
    _syncTimeLenLabel.textColor = HEXCOLOR(0x969696);
    _syncTimeLenLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    double syncTimeLen = [[self.dataSorce objectForKey:@"chatSyncTimeLen"] doubleValue];
    _syncTimeLenLabel.text = [self getPickerContentWithDay:syncTimeLen];
    [iv addSubview:_syncTimeLenLabel];
    
    y = CGRectGetMaxY(tmView.frame);
    
//    y += 12;
    
    UIView *cView = [self createViewWithOrginY:y + 12 height:[g_config.regeditPhoneOrName intValue] == 0 ? 190 : (HEIGHT*2+10) superView:headView];
    //谁可以看到我的上线时间
    iv = [self WH_create_WHButtonWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH, 60) title:Localized(@"JX_WhoCanSeeMyOnlineTime") drawTop:YES drawBottom:YES must:YES click:@selector(showLastLoginTime) superView:cView];
    
    self.seeNumTypeLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 33, 300, 20)];
    self.seeNumTypeLab.textColor = [UIColor grayColor];
    self.seeNumTypeLab.font = sysFontWithSize(14);
    self.seeNumTypeLab.text = [self getSeeLgoinLastTime:[self.dataSorce objectForKey:@"showLastLoginTime"]];
    [iv addSubview:self.seeNumTypeLab];
    
    CGFloat viewHeight = 0;
    if ([g_config.regeditPhoneOrName intValue] == 0) {
        //谁可以看到我的手机号码
//        y += iv.frame.size.height;
        iv = [self WH_create_WHButtonWithFrame:CGRectMake(0,iv.frame.size.height, JX_SCREEN_WIDTH, HEIGHT) title:Localized(@"JX_WhoCanSeeMyNo.") drawTop:NO drawBottom:YES must:YES click:@selector(showNumber) superView:cView];
        
        self.seeTimeTypeLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 33, 300, 20)];
        self.seeTimeTypeLab.textColor = HEXCOLOR(0x969696);
        self.seeTimeTypeLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
        self.seeTimeTypeLab.text = [self getSeeLgoinLastTime:[self.dataSorce objectForKey:@"showTelephone"]];
        [iv addSubview:self.seeTimeTypeLab];
        
        viewHeight += iv.frame.size.height;
        y += iv.frame.size.height;
    }


    //允许加我的方式
    
    iv = [self WH_create_WHButtonWithFrame:CGRectMake(0,([g_config.regeditPhoneOrName intValue] == 0) ? y : CGRectGetMaxY(iv.frame), JX_SCREEN_WIDTH, HEIGHT) title:Localized(@"JX_AddMeToWay") drawTop:NO drawBottom:NO must:YES click:@selector(selectAddMeType) superView:cView];
    
    self.addMeTypeLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 33, 300, 20)];
    self.addMeTypeLab.textColor = [UIColor grayColor];
    self.addMeTypeLab.font = sysFontWithSize(14);
    self.addMeTypeLab.text = [self getaddMeTypeText:[self.dataSorce objectForKey:@"friendFromList"]];
    [iv addSubview:self.addMeTypeLab];
    
    self.myTableView.frame = CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_TOP, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, JX_SCREEN_HEIGHT - JX_SCREEN_TOP + 40);
    [self.myTableView setBackgroundColor:g_factory.globalBgColor];
    self.myTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.myTableView.separatorColor = HEXCOLOR(0xffffff);
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    //隐藏 消息漫游时间 谁可以看到 允许加我的方式 等设置
    if (PrivacySetting_ShowOnlyTwoCell) {
        //self.myTableView.tableHeaderView = headView;
    } else {    
        self.myTableView.tableHeaderView = headView;
    }
    [self.myTableView reloadData];
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
//    [self.myTableView addGestureRecognizer:tap];
    
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, JX_SCREEN_WIDTH, 220)];
    _selectView.backgroundColor = HEXCOLOR(0xf0eff4);
    _selectView.hidden = YES;
    [self.view addSubview:_selectView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(_selectView.frame.size.width - 80, 20, 60, 20)];
    [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 20)];
    [btn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(WH_cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:btn];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, _selectView.frame.size.width, _selectView.frame.size.height - 40)];
    _pickerView.delegate = self;

//    [_pickerView selectRow:index inComponent:0 animated:NO];
    [_selectView addSubview:_pickerView];
    
    _pSelf = self;
}

- (void)showNumber {
    self.isShowNum = YES;
    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:self.loginTimeArr];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)showLastLoginTime {
    self.isShowNum = NO;
    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:self.loginTimeArr];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    self.seeTimeTypeLab.text = self.loginTimeArr[index];
    NSNumber *timeIndex = 0;
    if (index == 0) {
        timeIndex = @3;
    }
    else if (index == 1) {
        timeIndex = @2;
    }
    else if (index == 2) {
        timeIndex = @1;
    }
    else if (index == 3) {
        timeIndex = @-1;
    }
    NSString *key = [NSString string];
    if (self.isShowNum) {
        key = @"showTelephone";
    }else {
        key = @"showLastLoginTime";
    }
    [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:key value:[NSString stringWithFormat:@"%@",timeIndex] toView:self];
}

- (NSString *)getSeeLgoinLastTime:(NSNumber *)str {
    NSDictionary *type =@{@"-1":Localized(@"JX_SetAllNO"),@"1":Localized(@"JX_SetAllYES"),@"2":Localized(@"JX_SetAllFriendYES"),@"3":Localized(@"JX_SetContactYES")};
    return [type objectForKey:[NSString stringWithFormat:@"%@",str]];
}

- (NSString *)getaddMeTypeText:(NSString *)indexStr {
    NSArray *type = @[Localized(@"JXQR_QRImage"),Localized(@"JX_Card"),Localized(@"JX_ManyPerChat"),Localized(@"JX_MobileSearch"),Localized(@"JX_NicknameSearch"),Localized(@"OTHER")];
    NSMutableArray *indexArr = [NSMutableArray arrayWithArray:[indexStr componentsSeparatedByString:@","]];
    NSMutableArray *typeArr = [NSMutableArray array];
    [indexArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj intValue] == 0) {
            [indexArr removeObject:obj];
        }else {
            [typeArr addObject:[type objectAtIndex:[obj intValue]-1]];
        }
    }];
    
    if (indexArr.count <= 0) {
        return Localized(@"JX_SetAllNO");
    }else if (indexArr.count >= type.count){
        return Localized(@"JX_SetAllYES");
    }

    return [typeArr componentsJoinedByString:@","];
}

- (void)selectAddMeType {
    self.moreVC = [[WH_JXMoreSelect_WHVC alloc] initWithTitle:Localized(@"JX_AddMeToWay") dataArray:@[Localized(@"JXQR_QRImage"),Localized(@"JX_Card"),Localized(@"JX_ManyPerChat"),Localized(@"JX_MobileSearch"),Localized(@"JX_NicknameSearch"),Localized(@"OTHER")]];
    self.moreVC.wh_indexStr = self.indexStr.length > 0 ? self.indexStr : [NSString stringWithFormat:@"%@",[self.dataSorce objectForKey:@"friendFromList"]];
    self.moreVC.delegate = self;
    [self.view addSubview:self.moreVC.view];
}

- (void)didSureBtn:(WH_JXMoreSelect_WHVC *)moreSelectVC indexStr:(NSString *)indexStr {
    self.indexStr = indexStr; // 记录一下历史选项
    self.addMeTypeLab.text = [self getaddMeTypeText:indexStr];
    [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"friendFromList" value:indexStr toView:self];
}

- (NSString *)getPickerContentWithDay:(double)day{
    NSString *str;
    if (day == -2) {
        str = _pickerArr[0];
        
    }else if (day == 0 || day == -1) {
        str = _pickerArr[7];
        
    }else if (day == 0.04) {
        str = _pickerArr[1];
        
    }else if (day == 1) {
        str = _pickerArr[2];
        
    }else if (day == 7) {
        str = _pickerArr[3];
        
    }else if (day == 30) {
        str = _pickerArr[4];
        
    }else if (day == 90) {
        str = _pickerArr[5];
        
    }else{
        str = _pickerArr[6];
    }
    
    return str;
}

- (NSInteger)getPickerIndexWithDay:(double)day {
    NSInteger index;
    if (day == -2) {
        index = 0;
    }else if (day == 0 || day == -1) {
        index = 7;
    }else if (day == 0.04) {
        index = 1;
    }else if (day == 1) {
        index = 2;
    }else if (day == 7) {
        index = 3;
    }else if (day == 30) {
        index = 4;
    }else if (day == 90) {
        index = 5;
    }else{
        index = 6;
    }
    return index;
}

- (void)chatTimeOut:(WH_JXImageView *)imageView {
    self.selType = Type_chatRecordTimeOut;
    double outTime = [[self.dataSorce objectForKey:@"chatRecordTimeOut"] doubleValue];
    NSInteger index = [self getPickerIndexWithDay:outTime];
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

- (void)syncTimeLen:(WH_JXImageView *)imageView {
    self.selType = Type_chatSyncTimeLen;
    double chatSyncTimeLen = [[self.dataSorce objectForKey:@"chatSyncTimeLen"] doubleValue];
    NSInteger index = [self getPickerIndexWithDay:chatSyncTimeLen];
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

- (void)groupSyncTimeLen:(WH_JXImageView *)imageView {
    self.selType = Type_groupChatSyncTimeLen;
    double groupChatSyncTimeLen = [[self.dataSorce objectForKey:@"groupChatSyncTimeLen"] doubleValue];
    NSInteger index = [self getPickerIndexWithDay:groupChatSyncTimeLen];
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

- (void)btnAction:(UIButton *)btn {
    _selectView.hidden = YES;
    NSInteger row = [_pickerView selectedRowInComponent:0];
    
    NSString *str = [NSString stringWithFormat:@"%ld", row];
    switch (row) {
        case 0:
            str = @"-2";
            break;
        case 1:
            str = @"0.04";
            break;
        case 2:
            str = @"1";
            break;
        case 3:
            str = @"7";
            break;
        case 4:
            str = @"30";
            break;
        case 5:
            str = @"90";
            break;
        case 6:
            str = @"365";
            break;
        case 7:
            str = @"-1";
            break;
        default:
            break;
    }
    NSString *key;
    switch (self.selType) {
        case Type_chatRecordTimeOut: {
            key = @"chatRecordTimeOut";
            g_myself.chatRecordTimeOut = str;
            _timeOutLabel.text = _pickerArr[row];
        }
            break;
            
        case Type_chatSyncTimeLen: {
            key = @"chatSyncTimeLen";
            g_myself.chatSyncTimeLen = str;
            _syncTimeLenLabel.text = _pickerArr[row];
        }
            break;
            
        case Type_groupChatSyncTimeLen: {
            key = @"groupChatSyncTimeLen";
            g_myself.groupChatSyncTimeLen = str;
            _groupSyncTimeLenLabel.text = _pickerArr[row];
        }
            break;
            
        default:
            break;
    }
    
    [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:key value:str toView:self];
}

- (void)WH_cancelBtnAction:(UIButton *)btn {
    _selectView.hidden = YES;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"CurrentController = %@",[self class]);
//    UIView *view = g_window.subviews.lastObject;
//    //NSLog(@"lastObject = %@",g_window.subviews.lastObject);
//    [UIView animateWithDuration:0.3 animations:^{
//        view.frame = CGRectMake(-85, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
//    }];
    [self resetViewFrame];
    
}
-(void)createHeaderView{
    int wh_heightHeader = JX_SCREEN_TOP;
    
    UIView *  wh_tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, wh_heightHeader)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, wh_heightHeader)];
    iv.backgroundColor = g_factory.navigatorBgColor;
//    [g_theme setViewGradientWithView:iv gradientDirection:JXSkinGradientDirectionTopToBottom];
//    if (g_theme.themeIndex == 0) {
//        iv.image = [[UIImage imageNamed:@"navBarBackground"] imageWithTintColor:HEXCOLOR(0x00ceb3)];
//    }else {
//        iv.image = [g_theme themeTintImage:@"navBarBackground"];//[UIImage imageNamed:@"navBarBackground"];
//    }
    iv.userInteractionEnabled = YES;
    [wh_tableHeader addSubview:iv];
//    [iv release];
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, self_width-40*2, 16)];
    p.center = CGPointMake(wh_tableHeader.center.x, p.center.y);
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = g_factory.navigatorTitleColor;
    p.font = g_factory.navigatorTitleFont;
    p.text = Localized(@"JX_PrivacySettings");
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(WH_actionTitle:);
    p.wh_delegate = self;
    p.wh_changeAlpha = NO;
    [wh_tableHeader addSubview:p];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(NAV_INSETS-6, JX_SCREEN_TOP - 38-6, NAV_BTN_SIZE+12, NAV_BTN_SIZE+12)];
//    [btn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuitSet) forControlEvents:UIControlEventTouchUpInside];
//    btn.showsTouchWhenHighlighted = YES;
    [wh_tableHeader addSubview:btn];
    
    UIImageView *btnImg = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, NAV_BTN_SIZE, NAV_BTN_SIZE)];
    [btnImg setImage:[UIImage imageNamed:@"title_back"]];
    [btn addSubview:btnImg];

    [self.view addSubview:wh_tableHeader];
}

-(WH_JXImageView*)WH_create_WHButtonWithFrame:(CGRect)frame title:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click superView:(UIView *)superView{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.frame = frame;
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.wh_delegate = self;
    [superView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] init];
    p.text = title;
    p.font =  [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x3A404C);
    [btn addSubview:p];
    
    if(must){
        p.frame = CGRectMake(20, 0, 200, HEIGHT - 20);
    }else {
        p.frame = CGRectMake(20, 0, 200, HEIGHT);
    }

    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset,0.5)];
        line.backgroundColor = g_factory.globalBgColor;
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,frame.size.height-0.5,JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset,0.5)];
        line.backgroundColor = g_factory.globalBgColor;
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 19, (frame.size.height-12)/2, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [btn addSubview:iv];
    }
    return btn;
}

- (UIView *)createViewWithOrginY:(CGFloat)orginY height:(CGFloat)height superView:(UIView *)supView {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, height)];
    headView.backgroundColor = HEXCOLOR(0xffffff);
    [supView addSubview:headView];
    headView.layer.masksToBounds = YES;
    headView.layer.cornerRadius = g_factory.cardCornerRadius;
    headView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    headView.layer.borderWidth = g_factory.cardBorderWithd;
    
    return headView;
    
}

-(void)actionQuitSet{
    [_wait stop];
    [g_server stopConnection:self];
    
    [g_navigation WH_dismiss_WHViewController:self animated:YES];

}
-(void)actionQuit{
    [self.view removeFromSuperview];
    _pSelf = nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 点击switch开关
- (void)onSettings:(UISwitch *)switchButton{
    if (switchButton.tag == 0) {
        //消息加密传输
        self.isEncrypt = switchButton.isOn;
        g_myself.isEncrypt = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"isEncrypt" value:g_myself.isEncrypt toView:self];
        
        //需要好友验证
//        self.friends = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
//        g_myself.friendsVerify = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
//        [g_server WH_changeFriendSettingWithFriendsVerify:self.friends allowAtt:self.att allowGreet:self.greet key:nil value:nil toView:self];
    }
    if (switchButton.tag == 1) {
        //是否振动
        g_myself.isVibration = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"isVibration" value:g_myself.isVibration toView:self];
        // 允许手机号搜索我
//        g_myself.phoneSearch = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
//        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"phoneSearch" value:g_myself.phoneSearch toView:self];
    }
    if (switchButton.tag == 2) {// 允许昵称搜索我
        g_myself.nameSearch = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"nameSearch" value:g_myself.nameSearch toView:self];
    }

    if (switchButton.tag == 3) {
        //消息加密传输
        self.isEncrypt = switchButton.isOn;
        g_myself.isEncrypt = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"isEncrypt" value:g_myself.isEncrypt toView:self];
    }
    if (switchButton.tag == 4) {
        g_myself.isTyping = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"isTyping" value:g_myself.isTyping toView:self];
//        [g_default setBool:switchButton.isOn forKey:kStartEnteringStatus_WHNotification];
//        [g_default synchronize];
    }else if (switchButton.tag == 5) {//是否振动
        g_myself.isVibration = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"isVibration" value:g_myself.isVibration toView:self];
//        [g_default setBool:switchButton.isOn forKey:kMsgComeVibration_WHNotification];
//        [g_default synchronize];
    }else if (switchButton.tag == 6) {//是否多点登录
        g_myself.multipleDevices = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"multipleDevices" value:g_myself.multipleDevices toView:self];
        
//        [g_default setBool:switchButton.isOn forKey:kISMultipleLogin];
//        [g_default synchronize];
//        if (switchButton.isOn) {
//            g_myself.isMultipleLogin = [NSNumber numberWithLong:1];
//        }else {
//
//            g_myself.isMultipleLogin = [NSNumber numberWithLong:0];
//        }
    }else if (switchButton.tag == 7) {//是否使用Google地图
        
        g_myself.isUseGoogleMap = [NSString stringWithFormat:@"%@",switchButton.isOn ? @"1" : @"0"];
        [g_server WH_changeFriendSettingWithFriendsVerify:nil allowAtt:nil allowGreet:nil key:@"isUseGoogleMap" value:g_myself.isUseGoogleMap toView:self];
    }

    
}

#pragma mark － tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int number = 8;
    if ([g_config.isOpenPositionService intValue] == 1) {
        number = 8;
    }
    if (PrivacySetting_ShowOnlyTwoCell) {
        number = 3;
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WH_JXSettings_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:@"JXSC"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"WH_JXSettings_WHCell" owner:self options:nil][0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, HEIGHT);
        
        int number = 8;
        if ([g_config.isOpenPositionService intValue] == 1) {
            number = 8;
        }
        if (PrivacySetting_ShowOnlyTwoCell) {
            number = 3;
        }
        
        if (indexPath.row == 0) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, HEIGHT)];
            [imgView setImage:[UIImage imageNamed:@"kuai_shang"]];
            [cell addSubview:imgView];
        }else if(indexPath.row == number - 1){
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, HEIGHT)];
            [imgView setImage:[UIImage imageNamed:@"kuai_xia"]];
            [cell addSubview:imgView];
        }
        
        cell.myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, HEIGHT)];
        [cell.myLabel setTextColor:HEXCOLOR(0x3A404C)];
        [cell.myLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        [cell addSubview:cell.myLabel];
        
        cell.mySwitch = [[UISwitch alloc]initWithFrame:CGRectMake(self.myTableView.frame.size.width -70, 10, 0, 0)];
        
        [cell.mySwitch addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventValueChanged];

        cell.mySwitch.tag = indexPath.row;
        cell.mySwitch.onTintColor = THEMECOLOR;
        cell.inTableView = self;
        
        [cell addSubview:cell.mySwitch];
    }
    
    
//    cell.layer.masksToBounds = YES;
//    cell.layer.cornerRadius = g_factory.cardCornerRadius;
    

    
    int number = 8;
    if ([g_config.isOpenPositionService intValue] == 1) {
        number = 8;
    }
    if (PrivacySetting_ShowOnlyTwoCell) {
        number = 3;
    }
    
    if (indexPath.row > 0 && indexPath.row < number - 1) {
        cell.layer.borderColor = g_factory.cardBorderColor.CGColor;
        cell.layer.borderWidth = g_factory.cardBorderWithd;
        
        [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell setBackgroundColor:HEXCOLOR(0xffffff)];
    }else {
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
        
    cell.mySwitch.hidden = NO;
    if(indexPath.row == 0){
        if (PrivacySetting_ShowOnlyTwoCell) {
            //消息加密传输
            cell.myLabel.text = Localized(@"JXSettings_Encrypt");
            if([[self.dataSorce objectForKey:@"isEncrypt"] integerValue] == 1){
                
                cell.mySwitch.on = YES;
            }else{
                
                cell.mySwitch.on = NO;
            }
        } else {
            //需要好友验证
            cell.myLabel.text = Localized(@"JXSettings_FirendVerify");
            
            if([[self.dataSorce objectForKey:@"friendsVerify"] integerValue] == 1){
                
                cell.mySwitch.on = YES;
            }else{
                
                cell.mySwitch.on = NO;
            }
        }
    }
    else if(indexPath.row == 1){
        if (PrivacySetting_ShowOnlyTwoCell) {
            //是否振动
            cell.myLabel.text = Localized(@"JX_Vibration");
            if([[self.dataSorce objectForKey:@"isVibration"] integerValue] == 1){
                
                cell.mySwitch.on = YES;
            }else{
                
                cell.mySwitch.on = NO;
            }
        } else {
            //允许通过手机号搜索我
            cell.myLabel.text = Localized(@"JX_AllowMeToSearchByNO.");
            if([[self.dataSorce objectForKey:@"phoneSearch"] integerValue] == 1){
                
                cell.mySwitch.on = YES;
            }else{
                
                cell.mySwitch.on = NO;
            }
        }
    }
    else if(indexPath.row == 2){
        if (PrivacySetting_ShowOnlyTwoCell) {
            //黑名单
            cell.myLabel.text = Localized(@"JX_BlackList");
            cell.mySwitch.hidden = YES;
        } else {
            //通过昵称搜索好友
            cell.myLabel.text = Localized(@"JX_AllowMeToSearchByNickname");
            if([[self.dataSorce objectForKey:@"nameSearch"] integerValue] == 1){
                
                cell.mySwitch.on = YES;
            }else{
                
                cell.mySwitch.on = NO;
            }
        }
    }

    else if(indexPath.row == 3){
        cell.myLabel.text = Localized(@"JXSettings_Encrypt");
        if([[self.dataSorce objectForKey:@"isEncrypt"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    else if(indexPath.row == 4){
        cell.myLabel.text = Localized(@"JX_StartEntering");
        if([[self.dataSorce objectForKey:@"isTyping"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    else if(indexPath.row == 5){
        cell.myLabel.text = Localized(@"JX_Vibration");
        if([[self.dataSorce objectForKey:@"isVibration"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    else if(indexPath.row == 6){
        cell.myLabel.text = Localized(@"JX_OpenMultipointLogin");
        if([[self.dataSorce objectForKey:@"multipleDevices"] integerValue] == 1){
            
            cell.mySwitch.on = YES;
        }else{
            
            cell.mySwitch.on = NO;
        }
    }
    else if(indexPath.row == 7){
        if (!PrivacySetting_ShowOnlyTwoCell) {
            //黑名单
            cell.myLabel.text = Localized(@"JX_BlackList");
            cell.mySwitch.hidden = YES;
        } else {
            cell.myLabel.text = Localized(@"JX_UseGoogleMap");
            if([[self.dataSorce objectForKey:@"isUseGoogleMap"] integerValue] == 1){
                
                cell.mySwitch.on = YES;
            }else{
                
                cell.mySwitch.on = NO;
            }
        }
        
    }
    else if (indexPath.row == 8) {
        
    }
//
//    CGFloat rows = 8;
//    if ([g_config.isOpenPositionService intValue] == 1) {
//        rows = 7;
//    }
//    if (indexPath.row < rows - 1) {
//        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 10, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset , 10)];
//        [lView setBackgroundColor:HEXCOLOR(0xffffff)];
////
////        if (![view isKindOfClass:[NSClassFromString(@"_UITableViewCellSeparatorView") class]] && view)
////            [super addSubview:view];
//        [cell addSubview:lView];
//    }
//
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (PrivacySetting_ShowOnlyTwoCell) {
        return 12;
    }
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        if (PrivacySetting_ShowOnlyTwoCell) {
        //黑名单
        WH_BlackList_WHController *vc = [[WH_BlackList_WHController alloc] init];
        [g_navigation pushViewController:vc animated:YES];
        }
    } else if (indexPath.row == 7) {
        if (!PrivacySetting_ShowOnlyTwoCell) {
            //黑名单
            WH_BlackList_WHController *vc = [[WH_BlackList_WHController alloc] init];
            [g_navigation pushViewController:vc animated:YES];
        }
    }
}

- (void)changeSettingsNum{
    if([[self.dataSorce objectForKey:@"allowAtt"] integerValue] == 1){
        self.att = @"1";
    }else{
        self.att = @"0";
    }
    
    if([[self.dataSorce objectForKey:@"allowGreet"] integerValue] == 1){
        self.greet = @"1";
    }else{
        self.greet = @"0";
    }

    if([[self.dataSorce objectForKey:@"friendsVerify"] integerValue] == 1){
        self.friends = @"1";
    }else{
        self.friends = @"0";
    }
    if ([[self.dataSorce objectForKey:@"isEncrypt"] integerValue] == 1) {
        self.isEncrypt = YES;
    }else{
        self.isEncrypt = NO;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self doLogout];
    });
}

-(void)doLogout{
    [g_server logout:g_myself.areaCode toView:self];
}


-(void)relogin{
    
    g_server.access_token = nil;
    [g_default setBool:NO forKey:kIsAutoLogin];
    [g_notify postNotificationName:kSystemLogout_WHNotifaction object:nil];
    [[JXXMPP sharedInstance] logout];
    
    NSLog(@"XMPP --- jxsettingsVC");
    
     WH_LoginViewController* vc = [ WH_LoginViewController alloc];
    vc.isSwitchUser= NO;
    vc = [vc init];
    [g_mainVC.view removeFromSuperview];
    g_mainVC = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    vc.isPushEntering = YES;
    g_navigation.rootViewController = vc;
    [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
    [g_meeting WH_stopMeeting];
#endif
#endif
}

#pragma  mark - 返回数据

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if ([aDownload.action isEqualToString:wh_act_SettingsUpdate]) {//更改了好友验证
        
        self.dataSorce = [dict objectForKey:@"settings"];
        
        [self changeSettingsNum];
        
        
    }
    if ([aDownload.action isEqualToString:wh_act_UserUpdate]) {
        [g_App showAlert:Localized(@"JX_ModifiedMultipointLogonNeedsToBeLoggedIn") delegate:self tag:3333 onlyConfirm:YES];
    }
    
    if( [aDownload.action isEqualToString:wh_act_UserLogout] ){

        [self relogin];
    }
    
}



#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    if( [aDownload.action isEqualToString:wh_act_UserLogout] ){
        [self performSelector:@selector(doSwitch) withObject:nil afterDelay:1];
    }
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
//    [_myTableView release];
//    [_myView release];
//    [super dealloc];
}
//归位
- (void)resetViewFrame{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
    }];
}

- (void)sp_upload {
    NSLog(@"Get Info Failed");
}
@end
