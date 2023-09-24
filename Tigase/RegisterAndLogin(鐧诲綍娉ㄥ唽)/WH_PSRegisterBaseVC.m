//
//  WH_PSRegisterBaseVC.m
//  wahu_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WH_PSRegisterBaseVC.h"
//#import "WH_selectTreeVC_WHVC.h"
#import "WH_selectValue_WHVC.h"
#import "WH_selectProvince_WHVC.h"
#import "ImageResize.h"
#import "WH_ResumeData.h"
#import "WH_JXActionSheet_WHVC.h"
#import "WH_JXCamera_WHVC.h"
#import "WH_SettingHeadImgViewController.h"
#import "WH_SetGroupHeads_WHView.h"
#import "UIView+CustomAlertView.h"
#import "OBSHanderTool.h"
#import "WH_PwsSecSettingViewController.h"
#import "WH_RoundCornerCell.h"
#import "WH_JXUserObject+GetCurrentUser.h"



@interface WH_PSRegisterBaseVC ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,WH_JXActionSheet_WHVCDelegate,WH_JXCamera_WHVCDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView *basicInfoTable;
    BOOL isMale; //!< YES 男,NO 女
    __block UIImage* selectedHeadImage;
    BOOL hasSetPassSec;//!<密保设置状态
    NSString *passSecurityString; //!< 设置好的密保字符串
    WH_ResumeBaseData* resume;
    NSString *cityStr;
}
@end
static NSString *HeadImgCellIdentifier = @"HeadImgCellIdentifier";
static NSString *NameCellIdentifier = @"NameCellIdentifier";
static NSString *ButtonCellIdentifier = @"ButtonCellIdentifier";
//static NSString *InviteCodeCellIdentifier = @"InviteCodeCellIdentifier";
static NSString *PassCellIdentifier = @"PassCellIdentifier";

@implementation WH_PSRegisterBaseVC
- (id)init
{
    self = [super init];
    if (self) {
//        self.wh_isGotoBack   = !self.isRegister;
//        self.wh_isGotoBack   = YES;
        
//        if(self.isRegister){
//            resume.telephone   = user.telephone;
//            self.title = [NSString stringWithFormat:@"3.%@",Localized(@"JX_BaseInfo")];
//        }
//        else
//            self.title = Localized(@"JX_BaseInfo");
        
//        self.wh_heightFooter = 0;
//        self.wh_heightHeader = JX_SCREEN_TOP;
//        [self createHeadAndFoot];
//        self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
//        self.wh_tableBody.scrollEnabled = YES;
//        int h = 0;
//        NSString* s;
//
//        WH_JXImageView* iv;
//        iv = [[WH_JXImageView alloc]init];
//        iv.frame = self.wh_tableBody.bounds;
//        iv.delegate = self;
//        iv.didTouch = @selector(hideKeyboard);
//        [self.wh_tableBody addSubview:iv];
//
//        UIButton *headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [headBtn setFrame:CGRectMake(g_factory.globelEdgeInset, 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 75)];
//        [headBtn setBackgroundColor:HEXCOLOR(0xffffff)];
//        [self.wh_tableBody addSubview:headBtn];
//        headBtn.layer.masksToBounds = YES;
//        headBtn.layer.cornerRadius = g_factory.cardCornerRadius;
//        headBtn.layer.borderColor = g_factory.cardBorderColor.CGColor;
//        headBtn.layer.borderWidth = g_factory.cardBorderWithd;
//
//        _head = [[WH_JXImageView alloc]initWithFrame:CGRectMake(16, 20, IMGSIZE, IMGSIZE)];
//        _head.layer.cornerRadius = IMGSIZE/2;
//        _head.layer.masksToBounds = YES;
////        _head.didTouch = @selector(pickImage);
//        _head.delegate = self;
//        _head.image = [UIImage imageNamed:@"avatar_normal"];
//        if(self.isRegister)
//            s = user.userId;
//        else
//            s = g_myself.userId;
//        [g_server getHeadImageSmall:s userName:resume.name imageView:_head];
//        [headBtn addSubview:_head];
//
//        UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(headBtn.frame) - 19, (75 - 12)/2, 7, 12)];
//        [markImg setImage:[UIImage imageNamed:@"WH_Back"]];
//        [headBtn addSubview:markImg];
//
//        UILabel *setHeadLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(headBtn.frame) - 19 - 8 - 70, 0, 70, CGRectGetHeight(headBtn.frame))];
//        [setHeadLabel setText:@"设置头像"];
//        [headBtn addSubview:setHeadLabel];
//        [setHeadLabel setTextAlignment:NSTextAlignmentRight];
//        [setHeadLabel setTextColor:HEXCOLOR(0x969696)];
//        [setHeadLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
//
//        [headBtn addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventTouchUpInside];
//        CGFloat cViewH = 55*3;
//        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(headBtn.frame) + 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, cViewH)];
//        [cView setBackgroundColor:HEXCOLOR(0xffffff)];
//        [self.wh_tableBody addSubview:cView];
//        cView.layer.masksToBounds = YES;
//        cView.layer.cornerRadius = g_factory.cardCornerRadius;
//        cView.layer.borderWidth = g_factory.cardBorderWithd;
//        cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
//
//        NSString* workExp = [g_constant.workexp objectForKey:[NSNumber numberWithInt:resume.workexpId]];
//        NSString* diploma = [g_constant.diploma objectForKey:[NSNumber numberWithInt:resume.diplomaId]];
//        NSString* city = [g_constant getAddressForInt:resume.provinceId cityId:resume.cityId areaId:resume.areaId];
//
//        iv = [self WH_createMiXinButton:Localized(@"JX_Name") drawTop:YES drawBottom:YES must:NO click:nil superView:cView];
//        iv.frame = CGRectMake(0, 0, CGRectGetWidth(cView.frame), HEIGHT);
//        _name = [self WH_createMiXinTextField:iv default:resume.name hint:Localized(@"JX_InputName")];
//        [_name addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
//        h+=iv.frame.size.height;
//
//        iv = [self WH_createMiXinButton:Localized(@"JX_Sex") drawTop:NO drawBottom:YES must:NO click:nil superView:cView];
//        iv.frame = CGRectMake(0, HEIGHT, CGRectGetWidth(cView.frame), HEIGHT);
//        _sex = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:Localized(@"JX_Wuman"),Localized(@"JX_Man"),nil]];
//        _sex.frame = CGRectMake(CGRectGetWidth(cView.frame) - 80 - g_factory.globelEdgeInset,INSETS+3,80,30);
//        _sex.selectedSegmentIndex = resume.sex;
//        //样式
////        _sex.segmentedControlStyle= UISegmentedControlStyleBar;
//        _sex.tintColor = THEMECOLOR;
//        _sex.layer.cornerRadius = 5;
//        _sex.layer.borderWidth = 1.5;
//        _sex.layer.borderColor = [THEMECOLOR CGColor];
//        _sex.clipsToBounds = YES;
//        //设置文字属性
//        _sex.selectedSegmentIndex = [user.sex boolValue];
//        _sex.apportionsSegmentWidthsByContent = NO;
//        [iv addSubview:_sex];
//        [_sex release];
//        h+=iv.frame.size.height;
        
//        if (!resume.birthday) {
//            resume.birthday = [[NSDate date] timeIntervalSince1970];
//        }
        
//        iv = [self WH_createMiXinButton:Localized(@"JX_BirthDay") drawTop:NO drawBottom:YES must:NO click:nil superView:cView];
//        iv.frame = CGRectMake(0, HEIGHT*2, CGRectGetWidth(cView.frame), HEIGHT);
//        _birthday = [self WH_createMiXinTextField:iv default:[TimeUtil getDateStr:resume.birthday] hint:Localized(@"JX_BirthDay")];
        
//        g_config.isQestionOpen = @1;
//        UIView *cView2 = nil;
//        CGFloat viewHeight = CGRectGetMaxY(cView.frame);;
//        if ([g_config.isQestionOpen intValue] == 1) {
//
//            cView2 = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(cView.frame) + 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 55)];
//            [cView2 setBackgroundColor:HEXCOLOR(0xffffff)];
//            [self.wh_tableBody addSubview:cView2];
//            cView2.layer.masksToBounds = YES;
//            cView2.layer.cornerRadius = g_factory.cardCornerRadius;
//            cView2.layer.borderWidth = g_factory.cardBorderWithd;
//            cView2.layer.borderColor = g_factory.cardBorderColor.CGColor;
//            UITapGestureRecognizer *pwsSecTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(WH_pwsSecSetting:)];
//            [cView2 addGestureRecognizer:pwsSecTapGes];
//
//            iv = [self WH_createMiXinButton:@"密保问题" drawTop:NO drawBottom:YES must:NO click:nil superView:cView2];
//            iv.frame = CGRectMake(0, 0, CGRectGetWidth(cView2.frame), HEIGHT);
//
//            UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cView2.frame) - 19, (55 - 12)/2, 7, 12)];
//            [markImg setImage:[UIImage imageNamed:@"WH_Back"]];
//            [cView2 addSubview:markImg];
//
//            UILabel *setHeadLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(cView2.frame) - 19 - 8 - 100, 0, 100, CGRectGetHeight(cView2.frame))];
//            [setHeadLabel setText:@"设置密保问题"];
//            [cView2 addSubview:setHeadLabel];
//            [setHeadLabel setTextAlignment:NSTextAlignmentRight];
//            [setHeadLabel setTextColor:HEXCOLOR(0x969696)];
//            [setHeadLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
//
//            viewHeight = CGRectGetMaxY(cView2.frame);
//        }

        

//        if(!self.isRegister){
//            iv = [self WH_createMiXinButton:Localized(@"JX_WorkingYear") drawTop:NO drawBottom:YES must:YES click:@selector(WH_onWorkexp) superView:self.wh_tableBody];
//            iv.frame = CGRectMake(0, CGRectGetMaxY(cView.frame) + 12, CGRectGetWidth(cView.frame), HEIGHT);
//            _workexp = [self WH_createLabel:iv default:workExp];
//            h+=iv.frame.size.height;
//
//            iv = [self WH_createMiXinButton:Localized(@"JX_HighSchool") drawTop:NO drawBottom:YES must:YES click:@selector(WH_onDiploma) superView:self.wh_tableBody];
//            iv.frame = CGRectMake(0, CGRectGetMaxY(cView.frame) + 12 + HEIGHT + 12, CGRectGetWidth(cView.frame), HEIGHT);
//            _dip = [self WH_createLabel:iv default:diploma];
//            h+=iv.frame.size.height;
//
//            iv = [self WH_createMiXinButton:Localized(@"JX_Address") drawTop:NO drawBottom:YES must:YES click:@selector(onCity) superView:self.wh_tableBody];
//            iv.frame = CGRectMake(0, CGRectGetMaxY(cView.frame) + 12 + HEIGHT + 12 + 12, CGRectGetWidth(cView.frame), HEIGHT);
//            _city = [self WH_createLabel:iv default:city];
//            h+=iv.frame.size.height;
//
//            viewHeight = CGRectGetMaxY(cView.frame) + 12 + HEIGHT + 12 + 12;
//        }
//
//        UIButton* _btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_btn setTitle:@"确定" forState:UIControlStateNormal];
//        [_btn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
//        [_btn addTarget:self action:@selector(onInsert) forControlEvents:UIControlEventTouchUpInside];
//        _btn.layer.cornerRadius = g_factory.cardCornerRadius;
//        _btn.custom_acceptEventInterval = .25f;
//        _btn.clipsToBounds = YES;
//        _btn.frame = CGRectMake(g_factory.globelEdgeInset, viewHeight + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44);
//        [_btn setBackgroundColor:HEXCOLOR(0x0093FF)];
//        [self.wh_tableBody addSubview:_btn];
//
//        self.logView = [[UIView alloc] initWithFrame:_btn.frame];
//        [self.logView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]];
//        self.logView.layer.cornerRadius = g_factory.cardCornerRadius;
//        self.logView.layer.masksToBounds = YES;
//        [self.wh_tableBody addSubview:self.logView];
//
//        _date = [[JXDatePicker alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-200, JX_SCREEN_WIDTH, 200)];
//        _date.date = [NSDate dateWithTimeIntervalSince1970:resume.birthday];
//        _date.datePicker.datePickerMode = UIDatePickerModeDate;
//        _date.delegate = self;
//        _date.didChange = @selector(onDate:);
//        _date.didSelect = @selector(onDate:);
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customHeader];
    [self loadTableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    tap.numberOfTapsRequired = 1;
    tap.cancelsTouchesInView = NO;
    [basicInfoTable addGestureRecognizer:tap];
}
- (void)customHeader {
    resume.telephone   = _user.telephone;
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_isGotoBack = YES;
    self.wh_isNotCreatewh_tableBody = NO;
    self.title = Localized(@"JX_BaseInfo");
    _user.sex = @(1);
    [self createHeadAndFoot];
    NSArray *maleImages = @[@(3), @(4), @(5), @(10), @(11), @(12), @(14), @(16)];
    int headImageIndex = arc4random() % 8;
    NSString *defaultImageString = [NSString stringWithFormat:@"headimage_%@",maleImages[headImageIndex]];
    selectedHeadImage = [UIImage imageNamed:defaultImageString];
        
}
- (void)loadTableView {
    basicInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP) style:UITableViewStylePlain];
    basicInfoTable.delegate = self;
    basicInfoTable.dataSource = self;
    basicInfoTable.backgroundColor = g_factory.globalBgColor;
    basicInfoTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    basicInfoTable.tableFooterView = [UIView new];
    basicInfoTable.separatorColor = HEXCOLOR(0xF8F8F7);
    [self.view addSubview:basicInfoTable];
}

#pragma mark --- UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger number = 3;
    if (self.registType == 1 && [g_config.isQestionOpen boolValue]) {
        number += 1;
    }
    
    return number;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 1;
    if (section == 1) {
        number += 1;
        if (g_config.isOpenPositionService) {
            //number += 1;//现在不论位置服务是否开启,注册时的居住地全部不显示
        }
    }
    return number;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 55;
    if (indexPath.section == 0) {
        cellHeight = 75;
    }
    NSInteger sections = [tableView numberOfSections];
    if (indexPath.section == sections-1) {
        cellHeight = 44;
    }
    return cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [self getHeadImageCell:indexPath];
    }else if (indexPath.section == 1) {
        cell = [self getInfoCell:indexPath];
    }else if (indexPath.section == 2) {
        if (self.registType == 1 && [g_config.isQestionOpen boolValue]) {
            cell = [self getPasswordSecCell:indexPath];
        }else {
            cell = [self getButtonCell:indexPath];
        }
    }else {
        cell = [self getButtonCell:indexPath];
    }
//    if (g_config.registerInviteCode != 0) {
//        if (self.registType == 1 && indexPath.section == 3) {
//            cell = [self getInviteCodeCell:indexPath];
//        }else if(indexPath.section == 2) {
//            cell = [self getInviteCodeCell:indexPath];
//        }
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }else {
        cell.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    }
    
    cell.cellIndexPath = indexPath;
    return cell;
}
- (WH_RoundCornerCell *)getHeadImageCell:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [basicInfoTable dequeueReusableCellWithIdentifier:HeadImgCellIdentifier];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:HeadImgCellIdentifier tableView:basicInfoTable indexPath:indexPath];
        WH_JXImageView *headImgView = [[WH_JXImageView alloc]initWithFrame:CGRectMake(16+g_factory.globelEdgeInset, (75-36)/2, 36, 36)];
        headImgView.layer.cornerRadius = 36/2;
        headImgView.layer.masksToBounds = YES;
        headImgView.wh_delegate = self;
        headImgView.image = [UIImage imageNamed:@"avatar_normal"];
        headImgView.tag = 100;
        [cell.contentView addSubview:headImgView];
        
        UILabel *setHeadLabel = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 20 - 70 - 12-7, 0, 70, 75)];
        [setHeadLabel setText:@"设置头像"];
        [setHeadLabel setTextAlignment:NSTextAlignmentRight];
        [setHeadLabel setTextColor:HEXCOLOR(0x969696)];
        [setHeadLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        [cell.contentView addSubview:setHeadLabel];
        
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emarrow"]];
        arrowImage.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - 10 - 12, (75-7)/2, 7, 12);
        arrowImage.centerY = setHeadLabel.centerY;
        [cell.contentView addSubview:arrowImage];
    }
    WH_JXImageView *headImgView = [cell.contentView viewWithTag:100];
    if (selectedHeadImage) {
        headImgView.image = selectedHeadImage;
    }else if (!IsStringNull(_user.userId)) {
        [g_server WH_getHeadImageSmallWIthUserId:_user.userId userName:_user.userNickname imageView:headImgView];
    }
    return cell;
}
- (WH_RoundCornerCell *)getInfoCell:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [basicInfoTable dequeueReusableCellWithIdentifier:NameCellIdentifier];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:NameCellIdentifier tableView:basicInfoTable indexPath:indexPath];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+g_factory.globelEdgeInset, 0, 50, 55)];
        titleLabel.textColor = HEXCOLOR(0x3A404C);
        titleLabel.font = pingFangRegularFontWithSize(15);
        titleLabel.backgroundColor = UIColor.whiteColor;
        titleLabel.tag = 101;
        [cell.contentView addSubview:titleLabel];
        
        if (indexPath.row == 0) {
            UITextField *nickTextField = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-g_factory.globelEdgeInset-12-150, 0, 150, 55)];
            nickTextField.textAlignment = NSTextAlignmentRight;
            nickTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_NickName") attributes:@{NSFontAttributeName:pingFangRegularFontWithSize(15), NSForegroundColorAttributeName:HEXCOLOR(0x969696)}];
            nickTextField.delegate = self;
            nickTextField.tag = 10;
            [cell.contentView addSubview:nickTextField];
        }else if (indexPath.row == 1){
            UISegmentedControl *sexSegment = [[UISegmentedControl alloc] initWithItems:@[Localized(@"JX_Man"), Localized(@"JX_Wuman")]];
            [sexSegment addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
            sexSegment.frame = CGRectMake(JX_SCREEN_WIDTH - 80 - 12 - g_factory.globelEdgeInset,INSETS+3, 80, 55-2*13);
            sexSegment.selectedSegmentIndex = 0;
            sexSegment.tintColor = THEMECOLOR;
            sexSegment.layer.cornerRadius = 5;
            sexSegment.layer.borderWidth = 1.5;
            sexSegment.layer.borderColor = [THEMECOLOR CGColor];
            sexSegment.clipsToBounds = YES;
            //设置文字属性
            sexSegment.selectedSegmentIndex = [_user.sex boolValue];
            sexSegment.apportionsSegmentWidthsByContent = NO;
            sexSegment.tag = 103;
            [cell.contentView addSubview:sexSegment];
        }else {
            titleLabel.text = Localized(@"JX_Address");
            UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emarrow"]];
            arrowImage.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - 10 - 12, (55-7)/2, 7, 12);
            [cell.contentView addSubview:arrowImage];
            
            UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 32 - 10 - 80, 0, 80, 55)];
            [cityLabel setTextAlignment:NSTextAlignmentRight];
            [cityLabel setTextColor:HEXCOLOR(0x969696)];
            [cityLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
            cityLabel.tag = 102;
            [cell.contentView addSubview:cityLabel];
        }
    }
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    if (indexPath.row == 0) {//手机号注册
        titleLabel.text = Localized(@"JX_NickName");
    }else  if (indexPath.row == 1){
        titleLabel.text = Localized(@"JX_Sex");
    }
    UISegmentedControl *sexSegment = [cell.contentView viewWithTag:103];
    sexSegment.selectedSegmentIndex = isMale;
    UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:102];
    CGSize citySize = [cityStr sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]}];
    cityLabel.left = JX_SCREEN_WIDTH - 32-10-citySize.width;
    cityLabel.width = citySize.width;
    cityLabel.text = cityStr;
    
    return cell;
}
- (WH_RoundCornerCell *)getPasswordSecCell:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [basicInfoTable dequeueReusableCellWithIdentifier:PassCellIdentifier];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:PassCellIdentifier tableView:basicInfoTable indexPath:indexPath];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+g_factory.globelEdgeInset, 0, 100, 55)];
        titleLabel.textColor = HEXCOLOR(0x3A404C);
        titleLabel.font = pingFangRegularFontWithSize(15);
        titleLabel.backgroundColor = UIColor.whiteColor;
        titleLabel.text = @"密保问题";
        [cell.contentView addSubview:titleLabel];
        
        UILabel *passSecStatus = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-12-100-10, 0, 100, 55)];
        passSecStatus.textColor = HEXCOLOR(0x969696);
        passSecStatus.font = pingFangRegularFontWithSize(15);
        passSecStatus.textAlignment = NSTextAlignmentRight;
        passSecStatus.tag = 102;
        [cell.contentView addSubview:passSecStatus];
        
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emarrow"]];
        arrowImage.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - 10 - 12, (55-7)/2, 7, 12);
        arrowImage.centerY = passSecStatus.centerY;
        [cell.contentView addSubview:arrowImage];
    }
    UILabel *passSecStatus = (UILabel *)[cell.contentView viewWithTag:102];
    passSecStatus.text = hasSetPassSec ? Localized(@"PassHasSet") : Localized(@"SetPassSecurity");
    return cell;
}
//- (WH_RoundCornerCell *)getInviteCodeCell:(NSIndexPath *)indexPath {
//    WH_RoundCornerCell *cell = [basicInfoTable dequeueReusableCellWithIdentifier:InviteCodeCellIdentifier];
//    if (!cell) {
//        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:InviteCodeCellIdentifier tableView:basicInfoTable indexPath:indexPath];
//
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+g_factory.globelEdgeInset, 0, 50, 55)];
//        titleLabel.textColor = HEXCOLOR(0x3A404C);
//        titleLabel.font = pingFangRegularFontWithSize(15);
//        titleLabel.backgroundColor = UIColor.whiteColor;
//        titleLabel.text = Localized(@"JX_InvitationCode");
//        [cell.contentView addSubview:titleLabel];
//
//        if (indexPath.row == 0) {
//            UITextField *inviteCodeField = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-g_factory.globelEdgeInset-12-150, 0, 150, 55)];
//            inviteCodeField.textAlignment = NSTextAlignmentRight;
//            inviteCodeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_NickName") attributes:@{NSFontAttributeName:pingFangRegularFontWithSize(15), NSForegroundColorAttributeName:HEXCOLOR(0x969696)}];
//            inviteCodeField.delegate = self;
//            inviteCodeField.tag = 11;
//            [cell.contentView addSubview:inviteCodeField];
//        }
//    }
//    return cell;
//}
- (WH_RoundCornerCell *)getButtonCell:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [basicInfoTable dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:ButtonCellIdentifier tableView:basicInfoTable indexPath:indexPath];
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
        [button setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = g_factory.cardCornerRadius;
        button.custom_acceptEventInterval = 1.5f;
        button.clipsToBounds = YES;
        button.enabled = NO;
        button.tag = 202;
        button.frame = CGRectMake(g_factory.globelEdgeInset,  0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44);
        [button setBackgroundColor:HEXCOLOR(0x0093FF)];
        [cell.contentView addSubview:button];
    }
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:202];
    button.enabled = [self shouldConfirm];
    button.backgroundColor = button.enabled ? HEXCOLOR(0x0093FF) : UIColor.lightGrayColor;
    return cell;
}
#pragma mark ----- UITapGesture
- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}


/**
 检查必要信息是否填写完整，刷新确定按钮的状态
 */
- (BOOL)shouldConfirm {
    if (self.registType == 0) {
        if (IsStringNull(_user.password)) {
            return NO;
        }
    }else {
        if (!hasSetPassSec && [g_config.isQestionOpen boolValue]) {
            return NO;
        }
    }
    if (selectedHeadImage && !IsStringNull(_user.userNickname)) {
        return YES;
    }
    return NO;
}
#pragma mark ---- UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        [self pickImage];
    }else if (indexPath.section == 2 && [tableView numberOfSections] == 4) {
        [self setUpPasswordSecurity];
    }else if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            [self selectAddress];
        }
    }
}

#pragma mark ----- UITableView HeaderView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSInteger lastSection = (self.registType == 0 && [g_config.isQestionOpen boolValue]) ? 2 : 3;
    return (section == lastSection) ? 20 : 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark ---- UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 10) {
//        nickName = textField.text;
        _user.userNickname = textField.text;
    }else {
        self.inviteCode = textField.text;
    }
    [basicInfoTable reloadData];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
- (void)textFieldEditChanged:(UITextField *)textField {
    [g_factory setTextFieldInputLengthLimit:textField maxLength:NAME_INPUT_MAX_LENGTH];
}
#pragma mark ---------- 设置密保问题
- (void)setUpPasswordSecurity {
    WH_PwsSecSettingViewController* vc = [[WH_PwsSecSettingViewController alloc] init];
    vc.isRegist = YES;
    vc.questionBlock = ^(NSString * _Nonnull questions) {
        passSecurityString = questions;
        if (!IsStringNull(passSecurityString)) {
            hasSetPassSec = YES;
            [basicInfoTable reloadData];
        }
    };
    [g_navigation pushViewController:vc animated:YES];
}

-(void)dealloc{
//    NSLog(@"WH_PSRegisterBaseVC.dealloc");
//    [_image release];
    self.user = nil;
//    resume = nil;
    
//    [_date removeFromSuperview];
//    [_date release];
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if(textField == _birthday){
//        [self hideKeyboard];
//        [g_window addSubview:_date];
//        _date.hidden = NO;
//        return NO;
//    }else{
//        _date.hidden = YES;
//        [self.logView setHidden:YES];
//        return YES;
//    }
//}

//- (IBAction)onDate:(id)sender {
//    NSDate *selected = [_date date];
//    _birthday.text = [TimeUtil formatDate:selected format:@"yyyy-MM-dd"];
    //    _date.hidden = YES;
//}

- (void)segmentClicked:(UISegmentedControl *)segment {
    isMale = segment.selectedSegmentIndex == 0;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
//    [_wait stop];
    
    if( [aDownload.action isEqualToString:wh_act_Config]){
        
        [g_config didReceive:dict];
        [_wait start];
        [g_server registerUser:_user inviteCode:self.inviteCode  isSmsRegister:self.isSmsRegister registType:self.registType passSecurity:passSecurityString smsCode:self.smsCode  toView:self];
    }else if( [aDownload.action isEqualToString:wh_act_Register] ){
        [g_default setBool:NO forKey:kTHIRD_LOGIN_AUTO];
        
        //注册成功杀死程序重新进程序不会自动登录问题
        [g_default setBool:YES forKey:kIsAutoLogin];
        
        g_config.lastLoginType = [NSNumber numberWithInteger:self.registType];
        [g_server doLoginOK:dict user:_user];
//        self.user = g_myself;

        self.resumeId   = [[dict objectForKey:@"cv"] objectForKey:@"resumeId"];
//        [g_server autoLogin:self];
        [_wait start];
//        [g_server getUser:[[dict objectForKey:@"userId"] stringValue] toView:self];
        [[WH_JXUserObject sharedUserInstance] getCurrentUser];
        
        //注册完成头像没有BUG
        __block NSString *userId = [[dict objectForKey:@"userId"] stringValue];
        _user.userId = userId;
        
        [WH_JXUserObject sharedUserInstance].complete = ^(HttpRequestStatus status, NSDictionary * _Nullable userInfo, NSError * _Nullable error) {
            /*直接上传服务器,改为上传obs*/
            [OBSHanderTool WH_handleUploadOBSHeadImage:userId image:selectedHeadImage toView:self success:^(int code) {
                if (code == 1) {
                    [self postRegistSuccessNotification];
                } else {
                    [self postRegistSuccessNotification];
                }
            } failed:^(NSError * _Nonnull error) {
                [self postRegistSuccessNotification];
            }];
        };
        
        
    }else if([aDownload.action isEqualToString:wh_act_UserGet]){
        g_config.lastLoginType = [NSNumber numberWithInteger:self.registType];
        [g_default setBool:NO forKey:WH_ThirdPartyLogins];
         [g_server doLoginOK:dict user:_user];
        
        /*直接上传服务器,改为上传obs*/
        [OBSHanderTool WH_handleUploadOBSHeadImage:_user.userId image:selectedHeadImage toView:self success:^(int code) {
            if (code == 1) {
                [self postRegistSuccessNotification];
            }
        } failed:^(NSError * _Nonnull error) {
            [self postRegistSuccessNotification];
        }];
        
    }else if( [aDownload.action isEqualToString:wh_act_UploadHeadImage] ){
        selectedHeadImage = nil;
       [self postRegistSuccessNotification];
    }else if( [aDownload.action isEqualToString:wh_act_resumeUpdate] ){
        if(selectedHeadImage) {
            /*直接上传服务器,改为上传obs*/
//            [g_server uploadHeadImage:g_myself.userId image:_image toView:self];
            [OBSHanderTool WH_handleUploadOBSHeadImage:_user.userId image:selectedHeadImage toView:self success:^(int code) {
                if (code == 1) {
                    [basicInfoTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self postRegistSuccessNotification];
                }
            } failed:^(NSError * _Nonnull error) {

            }];
        } else{
//            g_myself.userNickname = nickName;
//            g_myself.sex = isMale ? @(1) : @(0);
//            g_myself.birthday = _date.date;
//            g_myself.cityId = [NSNumber numberWithInt:[_city.text intValue]];
            [GKMessageTool showSuccess:Localized(@"JXAlert_UpdateOK")];
            [g_notify postNotificationName:kUpdateUser_WHNotifaction object:self userInfo:nil];
            [self actionQuit];
        }
    }else if ([aDownload.action isEqualToString:wh_act_RegisterSDK]) {
        [g_default setBool:YES forKey:kTHIRD_LOGIN_AUTO];
//        g_server.openId = nil;
        g_config.lastLoginType = [NSNumber numberWithInteger:self.registType];
        [g_server doLoginOK:dict user:_user];
        self.user = g_myself;
        
        self.resumeId   = [[dict objectForKey:@"cv"] objectForKey:@"resumeId"];
        [_wait start];
        [g_server getUser:[[dict objectForKey:@"userId"] stringValue] toView:self];
       
//        //绑定账号
//        if (self.iswWxinLogin) {
//              [g_server thirdLogin:user type:[self.iswWxinLogin integerValue] openId:g_server.openId isLogin:NO toView:self];
//        }
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_resumeUpdate] ){
        if(selectedHeadImage) {
            /*直接上传服务器,改为上传obs*/
            [OBSHanderTool WH_handleUploadOBSHeadImage:_user.userId image:selectedHeadImage toView:self success:^(int code) {
                if (code == 1) {
                    [basicInfoTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self postRegistSuccessNotification];
                }
            } failed:^(NSError * _Nonnull error) {
                
            }];
        }
    }else if( [aDownload.action isEqualToString:wh_act_Config] ){
        
    }else if( [aDownload.action isEqualToString:wh_act_UploadHeadImage] ){
        selectedHeadImage = nil;
        [self postRegistSuccessNotification];
    }
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_UploadHeadImage] ){
        [self postRegistSuccessNotification];
    }
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}




//-(void)WH_onWorkexp{
//    if([self hideKeyboard])
//        return;
//
//    WH_selectValue_WHVC* vc = [WH_selectValue_WHVC alloc];
//    vc.values = g_constant.workexp_name;
//    vc.selNumber = resume.workexpId;
//    vc.numbers   = g_constant.workexp_value;
//    vc.delegate  = self;
//    vc.didSelect = @selector(WH_onSelWorkExp:);
//    vc.quickSelect = YES;
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
//}

//-(void)WH_onDiploma{
//    if([self hideKeyboard])
//        return;
//
//    WH_selectValue_WHVC* vc = [WH_selectValue_WHVC alloc];
//    vc.values = g_constant.diploma_name;
//    vc.selNumber = resume.diplomaId;
//    vc.numbers   = g_constant.diploma_value;
//    vc.delegate  = self;
//    vc.didSelect = @selector(WH_onSelDiploma:);
//    vc.quickSelect = YES;
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
//}
//

//
//-(void)WH_onSelDiploma:(WH_selectValue_WHVC*)sender{
//    resume.diplomaId = sender.selNumber;
//    _dip.text = sender.selValue;
//}
//
//-(void)WH_onSelWorkExp:(WH_selectValue_WHVC*)sender{
//    resume.workexpId = sender.selNumber;
//    _workexp.text = sender.selValue;
//}

#pragma mark ----- 图片选择
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    selectedHeadImage = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
    [basicInfoTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) pickImage
{
    [self.view endEditing:YES];
    WH_SettingHeadImgViewController *settingHeadVC = [[WH_SettingHeadImgViewController alloc] init];
    settingHeadVC.defaultImage = selectedHeadImage;
    settingHeadVC.user = self.user;
    settingHeadVC.isNeedRegistFirst = YES;
    settingHeadVC.changeHeadImageBlock = ^(UIImage * _Nonnull headImage) {
        selectedHeadImage = headImage;
        [basicInfoTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [g_navigation pushViewController:settingHeadVC animated:YES];
    return;
//    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
//    actionVC.delegate = self;
//    [self presentViewController:actionVC animated:NO completion:nil];
//
//    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
//    ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
//    ipc.delegate = self;
//    ipc.allowsEditing = YES;
//    ipc.modalPresentationStyle = UIModalPresentationFullScreen;
////    [g_window addSubview:ipc.view];
//    if (IS_PAD) {
//        UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
//        [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }else {
//        [self presentViewController:ipc animated:YES completion:nil];
//    }
    
    CGFloat viewH = 191;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 191+24;
    }
    
    WH_SetGroupHeads_WHView *setGroupHeadsview = [[WH_SetGroupHeads_WHView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH)];
    [setGroupHeadsview showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(setGroupHeadsview) weakShare = setGroupHeadsview;
    __weak typeof(self) weakSelf = self;
    [setGroupHeadsview setWh_selectActionBlock:^(NSInteger buttonTag) {
        if (buttonTag == 2) {
            //取消
            [weakShare hideView];
        }else if (buttonTag == 0) {
            //拍摄照片
            WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
            vc.cameraDelegate = weakSelf;
            vc.isPhoto = YES;
            vc = [vc init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [weakSelf presentViewController:vc animated:YES completion:nil];
            [weakShare hideView];
        }else {
            //选择照片
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            ipc.delegate = weakSelf;
            ipc.allowsEditing = YES;
            //选择图片模式
            ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
            //    [g_window addSubview:ipc.view];
            if (IS_PAD) {
                UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
                [pop presentPopoverFromRect:CGRectMake((weakSelf.view.frame.size.width - 320) / 2, 0, 300, 300) inView:weakSelf.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }else {
                [weakSelf presentViewController:ipc animated:YES completion:nil];
            }
            
            [weakShare hideView];
            
        }
    }];
}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        //选择图片模式
        ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
        //    [g_window addSubview:ipc.view];
        if (IS_PAD) {
            UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
            [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else {
            [self presentViewController:ipc animated:YES completion:nil];
        }
        
    }else {
        WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
        vc.cameraDelegate = self;
        vc.isPhoto = YES;
        vc = [vc init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    selectedHeadImage = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    [basicInfoTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    [picker.view removeFromSuperview];
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [picker release];
    //	[self dismissModalViewControllerAnimated:YES];
}

-(void)onUpdate{
    if(![self getInputValue])
        return;
    NSString* s = [[resume setDataToDict] mj_JSONString];
    [g_server updateResume:self.resumeId nodeName:@"p" text:s toView:self];
}
#pragma mark ----- 城市选择
-(void)selectAddress {
    [self.view endEditing:YES];
    
    WH_selectProvince_WHVC* vc = [WH_selectProvince_WHVC alloc];
    vc.delegate = self;
    vc.didSelect = @selector(WH_onSelCity:);
    vc.showCity = YES;
    vc.showArea = NO;
    vc.parentId = 1;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)WH_onSelCity:(WH_selectProvince_WHVC*)sender{
    //    resume.cityId = sender.cityId;
    //    resume.provinceId = sender.provinceId;
    //    resume.areaId = sender.areaId;
    //    resume.countryId = 1;
    
    _user.areaId = [NSNumber numberWithInt:sender.areaId];
    _user.provinceId = [NSNumber numberWithInt:sender.provinceId];
    _user.provinceId = [NSNumber numberWithInt:sender.provinceId];
    _user.cityId = [NSNumber numberWithInt:sender.cityId];
    cityStr = sender.selValue;
    [basicInfoTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
#pragma mark ----- 注册
-(void)confirmButtonAction {
    if(![self getInputValue])
        return;
    [_wait start];
    [g_server getSetting:self];
}

-(BOOL)getInputValue{
    if(selectedHeadImage==nil){
        [GKMessageTool showTips:Localized(@"JX_SetHead")];
        return NO;
    }
    if(IsStringNull(_user.userNickname)){
        [GKMessageTool showTips:Localized(@"JX_InputName")];
        return NO;
    }
//    if(!self.isRegister){
//        if(resume.workexpId<=0){
//            [GKMessageTool showTips:Localized(@"JX_InputWorking")];
//            return NO;
//        }
//        if(resume.diplomaId<=0){
//            [GKMessageTool showTips:Localized(@"JX_School")];
//            return NO;
//        }
//        if(resume.cityId<=0){
//            [GKMessageTool showTips:Localized(@"JX_Live")];
//            return NO;
//        }
//    }else {
//        if ([g_config.registerInviteCode intValue] == 1) {
//            if (IsStringNull(self.inviteCode)) {
//                [GKMessageTool showTips:Localized(@"JX_EnterInvitationCode")];
//                return NO;
//            }
//        }
//    }
//    resume.name = _user.userNickname;
//    resume.birthday = [_date.date timeIntervalSince1970];
//    resume.sex = isMale;
    return  YES;
}
- (void)postRegistSuccessNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [g_server WH_delHeadImageWithUserId:_user.userId];
        [GKMessageTool showSuccess:Localized(@"JX_RegOK")];
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:self userInfo:nil];
        [g_notify postNotificationName:kRegistSuccessNotifaction object:self userInfo:nil];

        [g_App showMainUI];
    });
}

@end
