//
//  WH_JXChatSetting_WHVC.m
//  wahu_im
//
//  Created by p on 2018/5/19.
//  Copyright © 2018年 Reese. All rights reserved.
//  单人聊天进入的 --> 设置界面

#import "WH_JXChatSetting_WHVC.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXSetChatBackground_WHVC.h"
#import "WH_JXInputValue_WHVC.h"
#import "WH_JXSearchChatLog_WHVC.h"
#import "WH_JXLabelObject.h"
#import "WH_JXSetLabel_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "WH_JXTransferRecordTableVC.h"
#import "WH_JXSetNoteAndLabel_WHVC.h"


@interface WH_JXChatSetting_WHVC () <UIPickerViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) WH_JXImageView *head;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UILabel *userDesc;

@property (nonatomic, strong) JXLabel *remarksLabel;
@property (nonatomic, strong) JXLabel *chatRecordTimeOutLabel;
@property (nonatomic, strong) JXLabel *labelLabel;
@property (nonatomic, strong) UISwitch *messageFreeSwitch;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerArr;

@property (nonatomic, strong) UILabel *describe;
@property (nonatomic, assign) CGFloat insertH;
@end

#define HEIGHT 55
@implementation WH_JXChatSetting_WHVC
{
    
    UIView *insertView;
    
    UIView *_syzxView;
    
    //置顶聊天
    UIView *_chatTopView;
    //消息免打扰
    UIView *_messageAvoidanceView;
    //聊天背景
    UIView *_ltbjView;
    UIView *_xqView;
    
    //时间进度条
    UISlider *_timeSlider;
    UILabel *_sliderTitleLb;
    
    //时间数组
    NSArray *_timeArr;
    //选择的时间
    NSInteger _selectedIndex;
    
    //当前的选择  //防止多次 修改数据库
    NSInteger currentIndex;
}
// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
    self.title = Localized(@"JX_ChatSettings");
    
    
    _pickerArr = @[Localized(@"JX_Forever"), Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear")];
    
    int hhh = 12;
    int w = JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset;
    
    [g_notify addObserver:self selector:@selector(actionQuitChatVC:) name:kActionRelayQuitVC_WHNotification object:nil];
    
    float marginHei = 12;
    
    WH_JXImageView* iv;
    iv = [self MiXin_createHeadButtonclick:nil];
    iv.frame = CGRectMake(g_factory.globelEdgeInset, hhh, w, 90);
    
    hhh+=iv.frame.size.height + marginHei;
    
    if ([self.user.userId intValue]>10100 || [self.user.userId intValue]<10000) {
        //JX_MemoName 备注名  JX_UserInfoDescribe:描述
//        iv = [self MiXin_createMiXinButton:_user.describe.length > 0 ? Localized(@"JX_UserInfoDescribe") : Localized(@"JX_MemoName") superView:mbView drawTop:YES drawBottom:NO icon:nil click:@selector(setLabel)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
        CGFloat mHeight = HEIGHT;
        mHeight = 111;
        UIView *mbView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, hhh, w, mHeight)];
        [mbView setBackgroundColor:[UIColor whiteColor]];
        [self.wh_tableBody addSubview:mbView];
        mbView.layer.cornerRadius = g_factory.cardCornerRadius;
        mbView.layer.masksToBounds = YES;
        mbView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        mbView.layer.borderWidth = g_factory.cardBorderWithd;
        
        iv = [self MiXin_createMiXinButton:_user.describe.length > 0 ? Localized(@"JX_UserInfoDescribe") : Localized(@"JX_MemoName") superView:mbView orginY:0 drawTop:NO drawBottom:NO icon:nil click:@selector(setLabel)];
//        [mbView addSubview:iv];
        
        hhh+=iv.frame.size.height;
        _remarksLabel = [self MiXin_createLabel:mbView default:_user.describe.length > 0 ? _user.describe : _user.remarkName isClick:YES];
        
        
        //标签
        iv = [self MiXin_createMiXinButton:Localized(@"JX_Label") superView:mbView orginY:(mHeight == HEIGHT)?0:(mHeight - HEIGHT) drawTop:YES drawBottom:NO icon:nil click:@selector(setLabel)];
        
        hhh+=iv.frame.size.height + marginHei;
        NSMutableArray *array = [[WH_JXLabelObject sharedInstance] fetchLabelsWithUserId:self.user.userId];
        NSMutableString *labelsName = [NSMutableString string];
        for (NSInteger i = 0; i < array.count; i ++) {
            WH_JXLabelObject *labelObj = array[i];
            if (i == 0) {
                [labelsName appendString:labelObj.groupName];
            }else {
                [labelsName appendFormat:@",%@",labelObj.groupName];
            }
        }
        
        _labelLabel = [self MiXin_createLabel:iv default:labelsName isClick:YES];
        _labelLabel.textColor = HEXCOLOR(0x969696);
    }
    
    
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_Label") superView:mbView drawTop:YES drawBottom:YES icon:nil click:@selector(setLabel)];
//    iv.frame = CGRectMake(0,h, w, HEIGHT);
//    [mbView addSubview:iv];
    
    
    
//    UIView *zhView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, h, w, HEIGHT)];
//    [zhView setBackgroundColor:[UIColor whiteColor]];
//    zhView.layer.masksToBounds = YES;
//    zhView.layer.cornerRadius = g_factory.cardCornerRadius;
//    zhView.layer.borderColor = g_factory.cardBorderColor.CGColor;
//    zhView.layer.borderWidth = 1;
//    [self.wh_tableBody addSubview:zhView];
    
    UIView *zhView = [self createSubViewWithFrame:CGRectMake(g_factory.globelEdgeInset, hhh, w, 0)];
    [self.wh_tableBody addSubview:zhView];
    
    //查看转账记录
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_ViewTransferRecords") superView:self.wh_tableBody drawTop:YES drawBottom:YES icon:nil click:@selector(checkTransfer)];
    iv = [self MiXin_createMiXinButton:Localized(@"JX_ViewTransferRecords") superView:zhView orginY:0 drawTop:NO drawBottom:NO icon:nil click:@selector(checkTransfer)];
//    [zhView addSubview:iv];
//    iv.frame = CGRectMake(0,h, w, HEIGHT);
//
//    h += zhView.frame.size.height + marginHei + iv.frame.origin.y;
//
    //查找聊天记录
    UIView *ltView = [self createSubViewWithFrame:CGRectMake(g_factory.globelEdgeInset, zhView.frame.origin.y + zhView.frame.size.height + marginHei , w, HEIGHT)];
    [self.wh_tableBody addSubview:ltView];
    iv = [self MiXin_createMiXinButton:Localized(@"JX_LookupChatRecords") superView:ltView orginY:0 drawTop:NO drawBottom:NO icon:nil click:@selector(searchChatLog)];
    
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_LookupChatRecords")  superView:self.wh_tableBody drawTop:YES drawBottom:YES icon:nil click:@selector(searchChatLog)];
//    [ltView addSubview:iv];
//    iv.frame = CGRectMake(0,h, w, HEIGHT);
//    h+=iv.frame.size.height + marginHei;
    
    UIView *syzxView = [self createSubViewWithFrame:CGRectMake(g_factory.globelEdgeInset, ltView.frame.size.height + ltView.frame.origin.y + marginHei, w, HEIGHT * 3)];
    _syzxView = syzxView;
    [self.wh_tableBody addSubview:syzxView];
    //双向撤回
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_DelMsgTwoSides") superView:self.wh_tableBody drawTop:YES drawBottom:YES icon:nil click:@selector(cleanTwoSidesMessageLog)];
////    iv.frame = CGRectMake(0,h, w, HEIGHT);
//    [syzxView addSubview:iv];
//    h+=iv.frame.size.height;
    
    iv = [self MiXin_createMiXinButton:Localized(@"JX_DelMsgTwoSides") superView:syzxView orginY:0 drawTop:NO drawBottom:YES icon:nil click:@selector(cleanTwoSidesMessageLog)];

    //阅后即焚
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    iv = [self MiXin_createMiXinButton:Localized(@"JX_ReadDelete") superView:syzxView orginY:iv.bottom drawTop:NO drawBottom:YES icon:nil click:nil];
    BOOL readDelSwitchIsOn = self.user.isOpenReadDel.integerValue == 0 ? NO : YES;
    [self MiXin_create_MiXinSwitch:iv defaule:readDelSwitchIsOn  click:@selector(readDelAction:)];
    
    insertView = [[UIView alloc] initWithFrame:CGRectMake(0, iv.bottom, iv.bounds.size.width, _insertH)];
    //insertView.backgroundColor = [UIColor redColor];
    [syzxView addSubview:insertView];
    } else {
//#else
    self.user.isOpenReadDel = [NSNumber numberWithBool:NO];
    [self.user WH_updateIsOpenReadDel];
    [g_notify postNotificationName:kOpenReadDelNotif object:self.user.isOpenReadDel];
    }
//#endif
    
    
    //置顶聊天
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_ChatAtTheTop") superView:self.wh_tableBody drawTop:NO drawBottom:YES icon:nil click:nil];
//    iv.frame = CGRectMake(0,h, w, HEIGHT);
//    h+=iv.frame.size.height;
    iv = [self MiXin_createMiXinButton:Localized(@"JX_ChatAtTheTop") superView:syzxView orginY:iv.bottom drawTop:NO drawBottom:YES icon:nil click:nil];
    _chatTopView = iv;
    [self MiXin_create_MiXinSwitch:iv defaule:self.user.topTime click:@selector(topChatAction:)];
    
    //消息免打扰

    iv = [self MiXin_createMiXinButton:Localized(@"JX_MessageFree") superView:syzxView orginY:iv.bottom drawTop:NO drawBottom:NO icon:nil click:nil];
    _messageAvoidanceView = iv;
    _messageFreeSwitch = [self MiXin_create_MiXinSwitch:iv defaule:[self.user.offlineNoPushMsg intValue] == 1 click:@selector(messageFreeAction:)];
    syzxView.height = iv.bottom;
    
    //聊天背景
    UIView *ltbjView = [self createSubViewWithFrame:CGRectMake(g_factory.globelEdgeInset, syzxView.frame.origin.y + syzxView.frame.size.height + marginHei, w, HEIGHT)];
    _ltbjView = ltbjView;
    [self.wh_tableBody addSubview:ltbjView];
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_ChatBackground") superView:self.wh_tableBody drawTop:YES drawBottom:YES icon:nil click:@selector(chatBackGroundImage)];
//    iv.frame = CGRectMake(0,h, w, HEIGHT);
//    h+=iv.frame.size.height + marginHei;
    iv = [self MiXin_createMiXinButton:Localized(@"JX_ChatBackground") superView:ltbjView orginY:0 drawTop:NO drawBottom:NO icon:nil click:@selector(chatBackGroundImage)];
    
    UIView *xqView = [self createSubViewWithFrame:CGRectMake(g_factory.globelEdgeInset, ltbjView.frame.origin.y + ltbjView.frame.size.height +marginHei, w, HEIGHT)];
    _xqView = xqView;
    [self.wh_tableBody addSubview:xqView];
    //消息过期自动销毁
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_MessageAutoDestroyed") superView:self.wh_tableBody drawTop:YES drawBottom:YES icon:nil click:@selector(chatRecordTimeOutAction)];
//    iv.frame = CGRectMake(0,h, w, HEIGHT);
//    h+=iv.frame.size.height;
    /** 消息过期自动销毁功能隐藏 19.09.26 hanf
    iv = [self MiXin_createMiXinButton:Localized(@"JX_MessageAutoDestroyed") superView:xqView orginY:0 drawTop:NO drawBottom:YES icon:nil click:@selector(chatRecordTimeOutAction)];
    
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSString *str;
    if (outTime <= 0) {
        str = _pickerArr[0];
    }else if (outTime == 0.04) {
        str = _pickerArr[1];
    }else if (outTime == 1) {
        str = _pickerArr[2];
    }else if (outTime == 7) {
        str = _pickerArr[3];
    }else if (outTime == 30) {
        str = _pickerArr[4];
    }else if (outTime == 90) {
        str = _pickerArr[5];
    }else{
        str = _pickerArr[6];
    }
    _chatRecordTimeOutLabel = [self MiXin_createLabel:iv default:str isClick:YES];*/
    
    //清空聊天记录
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_EmptyChatRecords") superView:self.wh_tableBody drawTop:NO drawBottom:YES icon:nil click:@selector(cleanMessageLog)];
//    iv.frame = CGRectMake(0,h, w, HEIGHT);
//    h+=iv.frame.size.height;
    iv = [self MiXin_createMiXinButton:Localized(@"JX_EmptyChatRecords")  superView:xqView orginY:0 drawTop:NO drawBottom:NO icon:nil click:@selector(cleanMessageLog)];
    
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {

    self.insertH = [self.user.isOpenReadDel boolValue] ? 82 : 0;
    insertView.hidden = ![self.user.isOpenReadDel boolValue];
//#else
    } else {
    self.insertH = 0;
    insertView.hidden = YES;
    }
//#endif
    if ((xqView.frame.origin.y + xqView.frame.size.height + HEIGHT + 20) > self.wh_tableBody.frame.size.height) {
        self.wh_tableBody.contentSize = CGSizeMake(self_width, xqView.frame.origin.y + xqView.frame.size.height + HEIGHT + 20);
    }
    
    [g_server getUser:self.user.userId toView:self];
    
    [self createPickerView];
    //阅后即焚
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {

    [self addSliderView];
    }
//#else
//#endif
    
}

- (void)setInsertH:(CGFloat)insertH{
    _syzxView.height = _syzxView.height + insertH;
    _insertH = insertH;
    insertView.height = insertH;
    insertView.top = 2 * HEIGHT;
//    insertView.top = insertView.top + insertH;
    _ltbjView.top = _ltbjView.top + insertH;
    _xqView.top = _xqView.top + insertH;
    _chatTopView.top = _chatTopView.top + insertH;
    _messageAvoidanceView.top = _messageAvoidanceView.top + insertH;
    if ((_xqView.frame.origin.y + _xqView.frame.size.height + HEIGHT + 20) > self.wh_tableBody.frame.size.height) {
        self.wh_tableBody.contentSize = CGSizeMake(self_width, _xqView.frame.origin.y + _xqView.frame.size.height + HEIGHT + 20);
    }
}


//添加月后既焚进度条
- (void) addSliderView{
    
    _timeArr = @[@"5秒", @"10秒", @"30秒", @"1分钟", @"5分钟", @"30分钟", @"1小时", @"6小时", @"12小时", @"1天", @"一星期"];
    _selectedIndex = [self.user.isOpenReadDel integerValue];

    _timeSlider =               [UISlider new];
    UILabel *sliderTitleLb =    [UILabel new];
//    UILabel *bzLb =             [UILabel new];
    
    [insertView addSubview:sliderTitleLb];
    [insertView addSubview:_timeSlider];
//    [insertView addSubview:bzLb];
    
    
    _timeSlider.maximumValue = _timeArr.count;
    _timeSlider.minimumValue = 1;
//    _timeSlider.continuous = NO;
    _timeSlider.minimumTrackTintColor = RGB(0, 147, 255);
    [_timeSlider addTarget:self action:@selector(sliderValurChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    
//    UIImage *sliderImage = [self createImageWithColor:[UIColor whiteColor]];
//    UIImage *sliderImage = [self originImage:_timeSlider.currentThumbImage scaleToSize:CGSizeMake(22, 22)];
//    [_timeSlider setThumbImage:sliderImage forState:UIControlStateNormal];
    
    _sliderTitleLb = sliderTitleLb;
    sliderTitleLb.textColor = RGB(58, 64, 76);
    sliderTitleLb.font = [UIFont systemFontOfSize:12];
    sliderTitleLb.text = [NSString stringWithFormat:@"消息在 %@ 后消失", _timeArr[_selectedIndex >= 1 ? _selectedIndex-1 :0]];
    _timeSlider.value = _selectedIndex;
//    bzLb.textColor = RGB(254, 0, 0);
//    bzLb.font = [UIFont systemFontOfSize:9];
//    bzLb.textAlignment = NSTextAlignmentCenter;
//    bzLb.numberOfLines = 2;
//    bzLb.text = @"(时间选项备注：\n5秒 10秒 30秒 1分钟 5分钟 30分钟 1小时 6小时 12小时 1天 一星期)";

    
    [sliderTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->insertView.mas_left).offset(21);
        make.top.mas_equalTo(self->insertView.mas_top).offset(18);
        make.height.mas_equalTo(12);
    }];
    [_timeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->insertView.mas_left).offset(20);
        make.right.mas_equalTo(self->insertView.mas_right).offset(-11);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self->_sliderTitleLb.mas_bottom).offset(20);
    }];
//    [bzLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self->_sliderTitleLb.mas_left);
//        make.top.mas_equalTo(self->_timeSlider.mas_bottom);
//
//        make.right.mas_equalTo(self->insertView.mas_right);
//    }];
}
#pragma mark - 阅后即焚时间设置
- (void)sliderValurChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch*touchEvent = [[event allTouches] anyObject];
    switch(touchEvent.phase)
    {
        case UITouchPhaseBegan:

            break;
        case UITouchPhaseMoved:
        {
            NSInteger index = floor(slider.value);
            _selectedIndex = index;
            _sliderTitleLb.text = [NSString stringWithFormat:@"消息在 %@ 后消失", _timeArr[_selectedIndex >=1 ? _selectedIndex - 1 : 0]];
        }
            break;
        case UITouchPhaseEnded:

            //存储数据
        {
            NSInteger index = floor(slider.value);
            _selectedIndex = index;
            self.user.isOpenReadDel = @(index);
            [self.user WH_updateIsOpenReadDel];
            
            _sliderTitleLb.text = [NSString stringWithFormat:@"消息在 %@ 后消失", _timeArr[_selectedIndex >=1 ? _selectedIndex - 1 : 0]];
            if (currentIndex != _selectedIndex) {
                
//                [g_notify postNotificationName:kReadDelRefreshNotif object:self.user.isOpenReadDel]
            }
            
            currentIndex = _selectedIndex;
            
        }
            break;
        default:
            break;
    }

}




- (void)createPickerView {
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
    [btn addTarget:self action:@selector(MiXin_cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:btn];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, _selectView.frame.size.width, _selectView.frame.size.height - 40)];
    _pickerView.delegate = self;
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSInteger index = 0;
    if (outTime <= 0) {
        index = 0;
    }else if (outTime == 0.04) {
        index = 1;
    }else if (outTime == 1) {
        index = 2;
    }else if (outTime == 7) {
        index = 3;
    }else if (outTime == 30) {
        index = 4;
    }else if (outTime == 90) {
        index = 5;
    }else{
        index = 6;
    }
    
    [_pickerView selectRow:index inComponent:0 animated:NO];
    [_selectView addSubview:_pickerView];
}

- (void)btnAction:(UIButton *)btn {
    _selectView.hidden = YES;
    NSInteger row = [_pickerView selectedRowInComponent:0];
    _chatRecordTimeOutLabel.text = _pickerArr[row];
    
    NSString *str = [NSString stringWithFormat:@"%ld",row];
    switch (row) {
        case 0:
            str = @"-1";
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
            
        default:
            break;
    }
    self.user.chatRecordTimeOut = str;
    [self.user WH_updateUserChatRecordTimeOut];
    [g_server friendsUpdate:self.user.userId chatRecordTimeOut:str toView:self];
}

- (void)MiXin_cancelBtnAction:(UIButton *)btn {
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

- (void)dealloc {
    [g_notify removeObserver:self];
}

- (void)checkTransfer {
    WH_JXTransferRecordTableVC *vc = [[WH_JXTransferRecordTableVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 发起群聊
- (WH_JXImageView *)createRoomButtonClick:(SEL)click {
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [self.wh_tableBody addSubview:btn];
    
    WH_JXImageView *add = [[WH_JXImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
    add.image = [UIImage imageNamed:@"person_add"];
    [btn addSubview:add];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(add.frame) + 20, 0, 200, HEIGHT)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = HEXCOLOR(0xff3db4ff);
    label.text = Localized(@"JX_LaunchGroupChat");
    [btn addSubview:label];
    
    return btn;
}

- (void)remarkAction {
    WH_JXInputValue_WHVC* vc = [WH_JXInputValue_WHVC alloc];
    vc.value = self.user.remarkName.length > 0  ? self.user.remarkName : self.user.userNickname;
    vc.title = Localized(@"WH_JXUserInfo_WHVC_SetName");
    vc.delegate  = self;
    vc.isLimit = YES;
    vc.didSelect = @selector(onSaveNickName:);
    vc = [vc init];
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
-(void)onSaveNickName:(WH_JXInputValue_WHVC*)vc{
    _remarksLabel.text = vc.value;
    self.user.remarkName = vc.value;
    [g_server WH_setFriendNameWithToUserId:self.user.userId noteName:vc.value describe:nil toView:self];
}

// 标签
- (void)setLabel {
    
    WH_JXSetNoteAndLabel_WHVC *vc = [[WH_JXSetNoteAndLabel_WHVC alloc] init];
    vc.title = Localized(@"JX_SetNotesAndLabels");
    vc.delegate = self;
    vc.didSelect = @selector(MiXin_refreshLabel:);
    vc.user = self.user;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)MiXin_refreshLabel:(WH_JXUserObject *)user {
    
    NSMutableArray *array = [[WH_JXLabelObject sharedInstance] fetchLabelsWithUserId:self.user.userId];
    NSMutableString *labelsName = [NSMutableString string];
    for (NSInteger i = 0; i < array.count; i ++) {
        WH_JXLabelObject *labelObj = array[i];
        if (i == 0) {
            [labelsName appendString:labelObj.groupName];
        }else {
            [labelsName appendFormat:@",%@",labelObj.groupName];
        }
    }
    _labelLabel.text = labelsName;
    
    if (user.describe.length > 0) {
        _describe.text = Localized(@"JX_UserInfoDescribe");
        _remarksLabel.text = user.describe;
    }else {
        _describe.text = Localized(@"JX_MemoName");
        _remarksLabel.text = user.remarkName;
    }
    self.user.remarkName = user.remarkName;
    self.user.describe = user.describe;
    [g_server WH_setFriendNameWithToUserId:self.user.userId noteName:user.remarkName describe:user.describe toView:self];

}

// 查找聊天内容
- (void)searchChatLog {
    
    WH_JXSearchChatLog_WHVC *vc = [[WH_JXSearchChatLog_WHVC alloc] init];
    vc.user = self.user;
    [g_navigation pushViewController:vc animated:YES];
}

#pragma mark - 阅后即焚开关
- (void)readDelAction:(UISwitch *)switchView {
    
    self.user.isOpenReadDel = [NSNumber numberWithBool:switchView.isOn];
    [self.user WH_updateIsOpenReadDel];
    if (switchView.isOn) {
        //[g_App showAlert:Localized(@"JX_ReadDeleteTip")];
    }
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {

    self.insertH = switchView.isOn ? 82 : -82;
    insertView.hidden = !switchView.isOn;
    }
//#else
//#endif
    [g_notify postNotificationName:kOpenReadDelNotif object:self.user.isOpenReadDel];
}

// 置顶聊天
- (void)topChatAction:(UISwitch *)switchView {
    if (switchView.isOn) {
        self.user.topTime = [NSDate date];
    }else {
        self.user.topTime = nil;
    }
    
    [self.user WH_updateTopTime];
    [g_notify postNotificationName:kFriendListRefresh_WHNotification object:nil];
}

// 消息免打扰
- (void)messageFreeAction:(UISwitch *)switchView {
    int offlineNoPushMsg = switchView.isOn;
    [g_server WH_friendsUpdateOfflineNoPushMsgUserId:g_myself.userId toUserId:self.user.userId offlineNoPushMsg:offlineNoPushMsg toView:self];
}

- (void)chatRecordTimeOutAction {
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSInteger index = 0;
    if (outTime <= 0) {
        index = 0;
    }else if (outTime == 0.04) {
        index = 1;
    }else if (outTime == 1) {
        index = 2;
    }else if (outTime == 7) {
        index = 3;
    }else if (outTime == 30) {
        index = 4;
    }else if (outTime == 90) {
        index = 5;
    }else{
        index = 6;
    }
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

// 清除聊天记录
- (void)cleanMessageLog {
    [g_App showAlert:Localized(@"JX_ConfirmDeleteChat") delegate:self tag:1111 onlyConfirm:NO];

}

//清空双方的聊天记录
- (void)cleanTwoSidesMessageLog {
    [g_App showAlert:Localized(@"JX_ConfirmDelMsgTwoSides?") delegate:self tag:2222 onlyConfirm:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1 && (alertView.tag == 1111 || alertView.tag == 2222)) {
        if (alertView.tag == 2222) {
            WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
            msg.timeSend = [NSDate date];
            msg.type = [NSNumber numberWithInt:kWCMessageTypeDelMsgTwoSides];
            msg.fromUserId = MY_USER_ID;
            msg.toUserId = self.user.userId;
            [g_xmpp sendMessage:msg roomName:nil];
        }
        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
        msg.toUserId = self.user.userId;
        [msg deleteAll];
        msg.type = [NSNumber numberWithInt:1];
        msg.content = @" ";
        [msg updateLastSend:UpdateLastSendType_None];
        [msg notifyMyLastSend];
        [g_server WH_emptyMsgWithTouserId:self.user.userId type:[NSNumber numberWithInt:0] toView:self];
        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];

    }
}

-(WH_JXImageView*)MiXin_createHeadButtonclick:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [self.wh_tableBody addSubview:btn];
    btn.layer.cornerRadius = g_factory.cardCornerRadius;
    btn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    btn.layer.borderWidth = g_factory.cardBorderWithd ;
    
    _head = [[WH_JXImageView alloc]initWithFrame:CGRectMake(20, 17, 35, 35)];
    if (MainHeadType) {
        [_head headRadiusWithAngle:_head.frame.size.width * 0.5];
    }else{
        [_head headRadiusWithAngle:g_factory.headViewCornerRadius];
    }
    
    _head.wh_delegate = self;
    _head.didTouch = @selector(onResume);
    [g_server WH_getHeadImageLargeWithUserId:self.user.userId userName:self.user.userNickname imageView:_head];
    [btn addSubview:_head];
    
    WH_JXImageView *add = [[WH_JXImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_head.frame) + 20, _head.frame.origin.y, _head.frame.size.width, _head.frame.size.height)];
    add.wh_delegate = self;
    add.didTouch = @selector(createRoom);
    add.image = [UIImage imageNamed:@"WH_Add"];
    [btn addSubview:add];
    
    
    //名字Label
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(_head.frame.origin.x, CGRectGetMaxY(_head.frame) + 4, _head.frame.size.width, 20)];
    p.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 12];
    p.text = g_myself.userNickname;
    p.textColor = HEXCOLOR(0x969696);
    p.textAlignment = NSTextAlignmentCenter;
    p.backgroundColor = [UIColor clearColor];
    [btn addSubview:p];
    _userName = p;
    _userName.text = self.user.remarkName.length > 0  ? self.user.remarkName : self.user.userNickname;
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 0, 20, 20)];
        iv.center = CGPointMake(iv.center.x, CGRectGetMidY(_head.frame));
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
    }
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,90-0.5,JX_SCREEN_WIDTH,0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [btn addSubview:line];

    return btn;
}

-(WH_JXImageView*)MiXin_createMiXinButton:(NSString*)title superView:(UIView *)view orginY:(CGFloat)orginY drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click {
    WH_JXImageView* btn = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, orginY, CGRectGetWidth(view.frame), 55)];
    btn.backgroundColor = [UIColor clearColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [view addSubview:btn];
    //    [btn release];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH-100, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.wh_delegate = self;
    p.didTouch = click;
    [btn addSubview:p];
    if ([title isEqualToString:Localized(@"JX_UserInfoDescribe")] || [title isEqualToString:Localized(@"JX_MemoName")]) {
        _describe = p;
    }
    //    [p release];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, (HEIGHT-20)/2, 20, 20)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
        //        [iv release];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,g_factory.cardBorderWithd)];
        line.backgroundColor = g_factory.globalBgColor;
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,g_factory.cardBorderWithd)];
        line.backgroundColor = g_factory.globalBgColor;
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame) - 19, (HEIGHT-12)/2, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [btn addSubview:iv];
    }
    
    return btn;
}
    

-(WH_JXImageView*)MiXin_createMiXinButton:(NSString*)title superView:(UIView *)view drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor clearColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [view addSubview:btn];
    //    [btn release];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH-100, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.wh_delegate = self;
    p.didTouch = click;
    [btn addSubview:p];
    if ([title isEqualToString:Localized(@"JX_UserInfoDescribe")] || [title isEqualToString:Localized(@"JX_MemoName")]) {
        _describe = p;
    }
    //    [p release];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, (HEIGHT-20)/2, 20, 20)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
        //        [iv release];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, (HEIGHT-20)/2, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        //        [iv release];
    }
    
    return btn;
}


-(JXLabel*)MiXin_createLabel:(UIView*)parent default:(NSString*)s isClick:(BOOL) boo{
    JXLabel * p;
    if (boo) {
        p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 23 -INSETS,INSETS,JX_SCREEN_WIDTH/2 - INSETS,HEIGHT-INSETS*2)];
    }else{
        p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 ,INSETS,JX_SCREEN_WIDTH/2 - INSETS,HEIGHT-INSETS*2)];
    }
    
    p.userInteractionEnabled = NO;
    p.text = s;
    p.textColor = [UIColor lightGrayColor];
    p.font = sysFontWithSize(15);
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
    //    [p release];
    return p;
}

- (UISwitch *)MiXin_create_MiXinSwitch:(UIView *)parent defaule:(BOOL)isOn click:(SEL)click {
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.frame = CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 61 - 12, 6, 0, 0);
    [switchView addTarget:self action:click forControlEvents:UIControlEventTouchUpInside];
    switchView.onTintColor = THEMECOLOR;
    [switchView setOn:isOn];
    [parent addSubview:switchView];
    return switchView;
}

#pragma mark 点击头像事件
- (void)onResume {
    
//    [g_server getUser:self.user.userId toView:self];
    
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.isAddFriend = self.user.isAddFirend;
    vc.wh_userId       = self.user.userId;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)createRoom {
    if ([g_config.isCommonCreateGroup intValue] == 1) {
        [g_App showAlert:Localized(@"JX_NotCreateNewRoom")];
        return;
    }
    memberData *member = [[memberData alloc] init];
    member.userId = [g_myself.userId longLongValue];
    member.userNickName = MY_USER_NAME;
    member.role = @1;
    [_room.members addObject:member];

    WH_JXSelectFriends_WHVC* vc = [WH_JXSelectFriends_WHVC alloc];
//    vc.chatRoom = _chatRoom;
    vc.room = _room;
    vc.isNewRoom = YES;
    vc.isForRoom = YES;
    vc.forRoomUser = self.user;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)actionQuitChatVC:(NSNotification *)notif {
    [self actionQuit];
}

- (void)chatBackGroundImage {
    WH_JXSetChatBackground_WHVC *vc = [[WH_JXSetChatBackground_WHVC alloc] init];
    vc.userId = self.user.userId;
    [g_navigation pushViewController:vc animated:YES];
}


//服务端返回数据
#pragma mark - 请求成功回调
-(void)WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
//    if( [aDownload.action isEqualToString:act_UserGet] ){
//        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
//        [user MiXin_getDataFromDict:dict];
//
//        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
//        vc.user       = user;
//        vc = [vc init];
//        //        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//    }
    if( [aDownload.action isEqualToString:wh_act_UploadFile] ){
        NSDictionary* p = nil;
        if([[dict objectForKey:@"audios"] count]>0)
            p = [[dict objectForKey:@"audios"] objectAtIndex:0];
        if([[dict objectForKey:@"images"] count]>0)
            p = [[dict objectForKey:@"images"] objectAtIndex:0];
        if([[dict objectForKey:@"videos"] count]>0)
            p = [[dict objectForKey:@"videos"] objectAtIndex:0];
        if(p==nil)
            p = [[dict objectForKey:@"others"] objectAtIndex:0];
        
        NSString* url = [p objectForKey:@"oUrl"];
        [g_constant.userBackGroundImage setObject:url forKey:self.user.userId];
        BOOL isSuccess = [g_constant.userBackGroundImage writeToFile:backImage atomically:YES];
        if (isSuccess) {
            [g_App showAlert:Localized(@"JX_SetUpSuccess")];
        }else {
            [g_App showAlert:Localized(@"JX_SettingFailure")];
        }
    }
    
    if([aDownload.action isEqualToString:wh_act_FriendRemark]){
        [_wait stop];
        _userName.text = self.user.remarkName.length > 0  ? self.user.remarkName : self.user.userNickname;

        WH_JXUserObject* user1 = [[WH_JXUserObject sharedUserInstance] getUserById:self.user.userId];
        user1.remarkName = self.user.remarkName;
        user1.describe = self.user.describe;
        // 修改备注后实时刷新
        [g_notify postNotificationName:kFriendRemark object:user1];
        [user1 update];
//        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if([aDownload.action isEqualToString:wh_act_FriendsUpdateOfflineNoPushMsg]){
        [_wait stop];
        
        self.user.offlineNoPushMsg = [NSNumber numberWithBool:_messageFreeSwitch.isOn];
        [self.user updateOfflineNoPushMsg];
//        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        [_messageFreeSwitch setOn:[user.offlineNoPushMsg intValue] == 1];
    }
    
    
    if( [aDownload.action isEqualToString:wh_act_EmptyMsg] ){
        [g_App showAlert:Localized(@"JXAlert_DeleteOK")];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return WH_show_error;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)createSubViewWithFrame:(CGRect)frame {
    
    UIView *zhView = [[UIView alloc] initWithFrame:frame];
    [zhView setBackgroundColor:[UIColor whiteColor]];
    zhView.layer.masksToBounds = YES;
    zhView.layer.cornerRadius = g_factory.cardCornerRadius;
    zhView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    zhView.layer.borderWidth = g_factory.cardBorderWithd;
//    [self.wh_tableBody addSubview:zhView];
    return zhView;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/





-(UIImage*) originImage:(UIImage*)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    //size为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
//颜色图片反转
- (UIImage*)createImageWithColor: (UIColor*) color{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}



@end
