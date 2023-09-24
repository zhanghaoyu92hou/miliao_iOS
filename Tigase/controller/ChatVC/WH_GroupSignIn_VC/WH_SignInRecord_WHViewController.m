//
//  WH_SignInRecord_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/9/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SignInRecord_WHViewController.h"

#import "BMChineseSort.h"
#import "QCheckBox.h"

#import "WH_ContentModification_WHView.h"
#import "UIView+CustomAlertView.h"

@interface WH_SignInRecord_WHViewController ()

@end

@implementation WH_SignInRecord_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.title = @"签到记录";
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    [self.view setBackgroundColor:g_factory.globalBgColor];
    
    self.listArray = [[NSMutableArray alloc] init];
    self.indexArray = [[NSMutableArray alloc] init];
    self.letterResultArr = [[NSMutableArray alloc] init];
    self.checkBoxArr = [NSMutableArray array];
    self.searchArray = [[NSMutableArray alloc] init];
    self.selectDataArray = [[NSMutableArray alloc] init];
    
    self.listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP - 45 - 44 - JX_SCREEN_BOTTOM) style:UITableViewStylePlain];
    [self.listTable setDelegate:self];
    [self.listTable setDataSource:self];
    [self.listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.listTable];
    [self.listTable setBackgroundColor:g_factory.globalBgColor];
    
    UIView *bottmView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 45 - 44 - JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, 45 + 44)];
    [bottmView setBackgroundColor:self.wh_tableBody.backgroundColor];
    [self.view addSubview:bottmView];
    
    UIButton *sBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottmView addSubview:sBtn];
    [sBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottmView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(147, 44));
        make.center.equalTo(bottmView);
    }];
    [sBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    [sBtn setTitle:@"奖品兑换" forState:UIControlStateNormal];
    [sBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [sBtn.titleLabel setFont:sysFontWithSize(16)];
    sBtn.layer.masksToBounds = YES;
    sBtn.layer.cornerRadius = 22;
    [sBtn addTarget:self action:@selector(redeemGiftMethod) forControlEvents:UIControlEventTouchUpInside];
    
    [self customView];
    
    [g_server requestSignInDetailsListWithRoomId:self.roomId toView:self];
    
}

- (void)customView {
    CGFloat headerViewH = 44.f;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, headerViewH)];
    header.backgroundColor = [UIColor whiteColor];
    [self createSeekTextField:header];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.offset(JX_SCREEN_TOP+headerViewH);
    }];
    self.seekTextField.placeholder = [NSString stringWithFormat:@"%@",Localized(@"JX_EnterKeyword")];
    self.listTable.tableHeaderView = header;
    
}

- (void)nickNameSortMethod {
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    [BMChineseSort sortAndGroup:self.listArray key:@"nickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        self.indexArray = sectionTitleArr;
        self.letterResultArr = sortedObjArr;
        [self.listTable reloadData];
    }];
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.seekTextField.text.length > 0) {
        return 1;
    }
    return [self.indexArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 31;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [UIView new];
    UILabel *titleLbl = [UILabel new];
    [header addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.centerY.offset(0);
    }];
    titleLbl.textColor = HEXCOLOR(0x8C9AB8);
    titleLbl.font = pingFangMediumFontWithSize(16);
    
    NSString *title = nil;
    if (self.seekTextField.text.length > 0) {
        title = Localized(@"JXFriend_searchTitle");
    } else {
        title = [self.indexArray objectAtIndex:section];
    }
    titleLbl.text = title;
    
    return header;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.seekTextField.text.length > 0) {
        return self.searchArray.count;
    }
    return [[self.letterResultArr objectAtIndex:section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.seekTextField.text.length > 0) {
        return nil;
    }
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat btnW = 20.0f;
    CGRect btnF = CGRectMake(JX_SCREEN_WIDTH - 10 - btnW, 20, btnW, btnW);
    NSString *cellStr = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
    }
    [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
    [cell setBackgroundColor:HEXCOLOR(0xffffff)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dataDict;
    if (self.seekTextField.text.length > 0) {
        dataDict = [self.searchArray objectAtIndex:indexPath.row];
    }else{
        NSArray *array = [self.letterResultArr objectAtIndex:indexPath.section];
        dataDict = [array objectAtIndex:indexPath.row];
    }
    
    
    UIImageView *headImageView = [[WH_JXImageView alloc]init];
    headImageView.frame = CGRectMake(16,(60 - 36)/2,36,36);
    [headImageView headRadiusWithAngle:headImageView.frame.size.width *0.5];
    [cell addSubview:headImageView];
    
    [g_server WH_getHeadImageSmallWIthUserId:[NSString stringWithFormat:@"%@" ,[dataDict objectForKey:@"userId"]] userName:[dataDict objectForKey:@"nickName"] imageView:headImageView];
    
    //    [g_server getRoomHeadImageSmall:[NSString stringWithFormat:@"%@" ,[dataDict objectForKey:@"userId"]] roomId:[NSString stringWithFormat:@"%@" ,[dataDict objectForKey:@"roomId"]] imageView:headImageView];
    
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - g_factory.cardBorderWithd, CGRectGetWidth(self.listTable.frame), g_factory.cardBorderWithd)];
    [lView setBackgroundColor:g_factory.cardBorderColor];
    [cell addSubview:lView];
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(60, 0, g_factory.cardBorderWithd, 60)];
    [hView setBackgroundColor:g_factory.globalBgColor];
    [cell addSubview:hView];
    
    //姓名
    UILabel *nickNameLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(hView.frame) + 10, 10, CGRectGetWidth(self.listTable.frame) - CGRectGetMaxX(hView.frame) - 30 - btnW , 20) text:[dataDict objectForKey:@"nickName"]?:@"" font:sysFontWithSize(15) textColor:HEXCOLOR(0x3A404C) backgroundColor:cell.backgroundColor];
    [cell addSubview:nickNameLabel];
    
    //连续签到时间
    UILabel *tLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(hView.frame) + 10, CGRectGetMaxY(nickNameLabel.frame), CGRectGetWidth(nickNameLabel.frame), 20) text:[NSString stringWithFormat:@"连续签到%@天" ,[NSString stringWithFormat:@"%@" ,[dataDict objectForKey:@"serialCount"]]?:@"0"] font:sysFontWithSize(14) textColor:HEXCOLOR(0x8F9CBB) backgroundColor:cell.backgroundColor];
    [cell addSubview:tLabel];
    
    QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
    btn.frame = btnF;
    btn.tag = indexPath.section * 1000 + indexPath.row;
    
    if (self.disableSet) {
        btn.enabled = ![_disableSet containsObject:[NSString stringWithFormat:@"%@" ,[dataDict objectForKey:@"userId"]]];
    }else{
        btn.enabled = YES;
    }
    [_checkBoxArr addObject:btn];
    [self didSelectedCheckBox:btn checked:btn.selected];
    [cell addSubview:btn];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [self.letterResultArr objectAtIndex:indexPath.section];
    NSDictionary *dataDict = [array objectAtIndex:indexPath.row];
    
    if (![_existSet containsObject:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@" ,[dataDict objectForKey:@"userId"]]]]) {
        QCheckBox *checkBox = nil;
        for (NSInteger i = 0; i < _checkBoxArr.count; i ++) {
            QCheckBox *btn = _checkBoxArr[i];
            if (btn.tag / 1000 == indexPath.section && btn.tag % 1000 == indexPath.row) {
                checkBox = btn;
                break;
            }
        }
        checkBox.selected = !checkBox.selected;
        [self didSelectedCheckBox:checkBox checked:checkBox.selected];
    }
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    NSLog(@"checked:%d" ,checked);
    
    NSDictionary *data ;
    if (self.seekTextField.text.length > 0) {
        data = self.searchArray[checkbox.tag % 1000];
    }else{
        data = [[self.letterResultArr objectAtIndex:checkbox.tag / 1000] objectAtIndex:checkbox.tag % 1000];
    }
    
    NSString *userIdStr = [NSString stringWithFormat:@"%@" ,[data objectForKey:@"userId"]];
    
    NSLog(@"userIdStr:%@" ,userIdStr);
    //    NSString *selectUserIdStr = @"";
    
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    //    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < self.selectDataArray.count; i++) {
        NSDictionary *sDict = [self.selectDataArray objectAtIndex:i];
        //        selectUserIdStr = [sDict objectForKey:@"userId"];
        [userIds addObject:[NSString stringWithFormat:@"%@" ,[sDict objectForKey:@"userId"]]];
        
        //        [userData setValue:sDict forKey:[NSString stringWithFormat:@"%@" ,[sDict objectForKey:@"userId"]]];
    }
    
    if (checked) {
        //选中
        if (![userIds containsObject:userIdStr]) {
            [self.selectDataArray addObject:data];
        }
    }else{
        //取消
        if ([userIds containsObject:userIdStr]) {
            [self.selectDataArray removeObject:data];
        }
    }
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_ExchangeGift]) {
        [GKMessageTool showText:@"兑换成功"];
        
        [g_server requestSignInDetailsListWithRoomId:self.roomId toView:self];
    }
    
    if ([aDownload.action isEqualToString:act_SignInDetailsRoom]) {
        [self.listArray removeAllObjects];
        [self.indexArray removeAllObjects];
        if (array1.count > 0) {
            [self.listArray addObjectsFromArray:array1];
            
            [self nickNameSortMethod];
        }else{
            [self.indexArray removeAllObjects];
            [self.listTable reloadData];
        }
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_MiXinError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        [_wait stop];
        return;
    }
    [_wait start];
}

#pragma mark 兑换礼物
- (void)redeemGiftMethod {
    NSLog(@"=======selectArray:%@" ,self.selectDataArray);
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.selectDataArray.count > 0) {
        WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:@"确认奖品兑换" content:@"确认奖品兑换，用户联系签到时间将清零" isEdit:NO isLimit:NO];
        [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
        
        __weak typeof(cmView) weakShare = cmView;
        //        __weak typeof(self) weakSelf = self;
        [cmView setCloseBlock:^{
            [weakShare hideView];
        }];
        [cmView setSelectActionBlock:^(NSInteger buttonTag, NSString * _Nonnull content) {
            if (buttonTag == 0) {
                [weakShare hideView];
            }else{
                [weakShare hideView];
                
                NSDictionary *selectDataDict = [self.selectDataArray objectAtIndex:0];
                [dict setObject:[NSString stringWithFormat:@"%@" ,[selectDataDict objectForKey:@"roomId"]] forKey:@"roomId"];
                [dict setObject:[NSString stringWithFormat:@"%@" ,[selectDataDict objectForKey:@"roomJid"]] forKey:@"roomJid"];
                
                NSArray *array = [NSArray array];
                for (int i = 0; i < self.selectDataArray.count; i++) {
                    NSDictionary *iDict = [self.selectDataArray objectAtIndex:i];
                    array = @[@{@"userId":[NSString stringWithFormat:@"%@" ,[iDict objectForKey:@"userId"]] ,@"serialCount":[NSString stringWithFormat:@"%@" ,[iDict objectForKey:@"serialCount"]] ,@"nickName":[iDict objectForKey:@"nickName"]}];
                }
                [dict setObject:array forKey:@"data"];
                
                NSError *err;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                [g_server requestExchangeGiftWithData:jsonStr toView:self];
            }
        }];
    }else{
        [GKMessageTool showText:@"还未选择需要兑换礼物的人员!"];
        return;
    }
}

- (void)createSeekTextField:(UIView *)superView {
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, JX_SCREEN_WIDTH - 10*2, 30.f)];
    _seekTextField.placeholder = [NSString stringWithFormat:@"%@", @"搜索联系人"];
    _seekTextField.backgroundColor = g_factory.inputBackgroundColor;
    if (@available(iOS 10, *)) {
        _seekTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", @"搜索联系人"] attributes:@{NSForegroundColorAttributeName:g_factory.inputDefaultTextColor}];
    } else {
        [_seekTextField setValue:g_factory.inputDefaultTextColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    [_seekTextField setFont:g_factory.inputDefaultTextFont];
    _seekTextField.textColor = HEXCOLOR(0x333333);
    _seekTextField.layer.borderWidth = 0.5;
    _seekTextField.layer.borderColor = g_factory.inputBorderColor.CGColor;
    _seekTextField.layer.cornerRadius = CGRectGetHeight(_seekTextField.frame) / 2.f;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [superView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [superView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_seekTextField.mas_right).offset(10);
        make.top.bottom.equalTo(_seekTextField);
        make.width.offset(52.f);
    }];
    cancelBtn.layer.borderColor = g_factory.cancelBtnBorderColor.CGColor;
    cancelBtn.layer.borderWidth = g_factory.cardBorderWithd;
    cancelBtn.titleLabel.font = g_factory.cancelBtnFont;
    [cancelBtn setTitleColor:g_factory.cancelBtnTextColor forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius = CGRectGetHeight(_seekTextField.frame) / 2.f;
    cancelBtn.layer.masksToBounds = YES;
    
    //上下分割线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(superView.frame), g_factory.cardBorderWithd)];
    topLine.backgroundColor = g_factory.inputBorderColor;
    [superView addSubview:topLine];
    UIView *btmLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_seekTextField.frame) + 7.f, CGRectGetWidth(superView.frame), g_factory.cardBorderWithd)];
    btmLine.backgroundColor = g_factory.inputBorderColor;
    [superView addSubview:btmLine];
    
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btmLine.frame), CGRectGetWidth(superView.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(btmLine.frame))];
    [self.view addSubview:_coverView];
    _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _coverView.alpha = 0;
    [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverView)]];
}

- (void)clickCancelBtn{
    [self dismissCoverWithIsResignKeyboard:YES];
}

- (void)tapCoverView{
    [self dismissCoverWithIsResignKeyboard:YES];
}

- (void)showCover{
    if (_coverView.alpha == 1) {
        return;
    }
    _coverView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        _coverView.alpha = 1;
        
        CGRect frame = _seekTextField.frame;
        frame.size.width = JX_SCREEN_WIDTH - 10 - 72;
        _seekTextField.frame = frame;
    }];
}

- (void)dismissCoverWithIsResignKeyboard:(BOOL)isResignKeyboard{
    //    if (_coverView.alpha == 0) {
    //        return;
    //    }
    //    _coverView.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        _coverView.alpha = 0;
        
        if (isResignKeyboard) {
            CGRect frame = _seekTextField.frame;
            frame.size.width = JX_SCREEN_WIDTH - 10*2;
            _seekTextField.frame = frame;
        }
    }];
    if (isResignKeyboard) {
        [_seekTextField resignFirstResponder];
    }
}

- (void)textFieldDidChange:(UITextField *)textField{
    if (_seekTextField.text.length > 0) {
        //隐藏蒙版
        [self dismissCoverWithIsResignKeyboard:NO];
    } else {
        //显示蒙版
        [self showCover];
    }
    
    [self.searchArray removeAllObjects];
    
    for (int i = 0; i < self.listArray.count; i++) {
        NSDictionary *dict = [self.listArray objectAtIndex:i];
        
        NSString *userStr = [[dict objectForKey:@"nickName"] lowercaseString];
        NSString *textStr = [textField.text lowercaseString];
        
        NSLog(@"dict:%@  userStr:%@  textStr:%@" ,dict ,userStr ,textStr);
        if ([userStr rangeOfString:textStr].location != NSNotFound) {
            [self.searchArray addObject:dict];
        }
    }
    NSLog(@"self.searchArray:%@" ,self.searchArray);
    [self.listTable reloadData];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //显示蒙版
    [self showCover];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //隐藏蒙版
    [self dismissCoverWithIsResignKeyboard:YES];
}

@end
