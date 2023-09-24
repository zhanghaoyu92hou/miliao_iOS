//
//  WH_JXAddDepart_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/5/16.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXAddDepart_WHViewController.h"
//#import "WH_selectTreeVC_WHVC.h"
//#import "WH_selectValue_WHVC.h"
//#import "WH_selectProvince_WHVC.h"
//#import "ImageResize.h"
//#import "WH_RoomData.h"
//#import "WH_JXUserInfo_WHVC.h"
//#import "WH_JXSelFriend_WHVC.h"
//#import "WH_JXRoomObject.h"
//#import "WH_JXChat_WHViewController.h"
//#import "WH_JXRoomPool.h"
//#import "DepartObject.h"

#define HEIGHT 50
#define IMGSIZE 170
static NSString *cellID = @"SearchCellID";

@interface WH_JXAddDepart_WHViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITextField* _desc;
    UILabel* _userName;
    UITextField* _roomName;
    UILabel* _size;
//    WH_JXRoomObject *_chatRoom;
    WH_RoomData* _room;
    UIView *seekBackView;
    UITextField* _searchCompany;
}
//@property (nonatomic,strong) WH_JXRoomObject* chatRoom;
@property (nonatomic,strong) NSString* userNickname;
@property (nonatomic,strong) JXTableView *searchTableView;
@property (nonatomic,strong) NSMutableArray *companyArr;
@property (nonatomic,strong) UIButton *creatBut;
@end

@implementation WH_JXAddDepart_WHViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
//        self.title = Localized(@"JXAddDepartVC_AddDepart");
        self.wh_tableBody.backgroundColor = THEMEBACKCOLOR;
        self.wh_isFreeOnClose = YES;
        self.wh_isGotoBack = YES;
    }
    return self;
}
// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    if (_type == OrganizAddDepartment) {
        [self createDepartmentView];
    }else if (_type == OrganizAddCompany) {
        [self createCompanyView];
    }else if (_type == OrganizUpdateDepartmentName) {
        [self updateDepartmentNameView];
    }else if (_type == OrganizSearchCompany){
        [self searchCompany];
    }else if (_type == OrganizUpdateCompanyName){
        [self updateCompanyNameView];
    }else if (_type == OrganizModifyEmployeePosition){
        [self modifyEmployeePosition];
    }
    
    
//    //iv = [self WH_createMiXinButton:Localized(@"JX_RoomExplain") drawTop:NO drawBottom:YES must:NO click:nil];
//    iv = [self WH_createMiXinButton:@"根部门名称" drawTop:NO drawBottom:YES must:NO click:nil];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    //_desc = [self WH_createMiXinTextField:iv default:_room.desc hint:Localized(@"WaHu_JXNewRoom_WHVC_InputExplain") type:0];
//    _desc = [self WH_createMiXinTextField:iv default:_room.desc hint:@"请输入根部门名称" type:0];
//    h+=iv.frame.size.height;
    
//    iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WHVC_CreatPer") drawTop:NO drawBottom:YES must:NO click:nil];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    _userName = [self WH_createLabel:iv default:g_myself.userNickname];
//    h+=iv.frame.size.height;
    
//    iv = [self WH_createMiXinButton:@"请选择部门成员" drawTop:NO drawBottom:YES must:NO click:@selector(hideKeyboard)];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    //_size = [self WH_createLabel:iv default:[NSString stringWithFormat:@"%d/%d",_room.curCount,_room.maxCount]];
//    h+=iv.frame.size.height;
    
//    iv = [self WH_createMiXinButton:@"请指定部门管理员" drawTop:NO drawBottom:YES must:NO click:@selector(hideKeyboard)];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    
//    h+=iv.frame.size.height;
    
    
    
}
- (void)searchCompany{
    self.title = Localized(@"JXAddDepart_search");
    //搜索输入框
    seekBackView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, self.wh_tableHeader.frame.size.width-10-10, 31)];
    seekBackView.backgroundColor = [UIColor lightGrayColor];
    seekBackView.layer.masksToBounds = YES;
    seekBackView.layer.cornerRadius = 16;
    [self.wh_tableBody addSubview:seekBackView];
    self.companyArr = [NSMutableArray array];
    
    _searchCompany = [[UITextField alloc] initWithFrame:CGRectMake(5, 1, seekBackView.frame.size.width-5-25-5, 29)];
    //_seekTextField.backgroundColor = [UIColor lightGrayColor];
    _searchCompany.placeholder = Localized(@"JX_EnterKeyword");
    _searchCompany.delegate = self;
    [_searchCompany setTextColor:[UIColor whiteColor]];
    [_searchCompany setFont:sysFontWithSize(14)];
    [_searchCompany setTintColor:[UIColor whiteColor]];
    _searchCompany.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _searchCompany.returnKeyType = UIReturnKeyGoogle;
    [seekBackView addSubview:_searchCompany];

    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(seekBackView.frame.size.width-30, 4, 25, 25);
    [but setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    //    [but setImage:[UIImage imageNamed:@"abc_ic_search_api_mtrl_alpha"] forState:UIControlStateHighlighted];
    [but addTarget:self action:@selector(onSearch) forControlEvents:UIControlEventTouchUpInside];
    [seekBackView addSubview:but];
    
    _creatBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _creatBut.frame = CGRectMake((JX_SCREEN_WIDTH-100)/2, 41, 100, 25);
    [_creatBut setTitle:Localized(@"OrgaVC_CreateCompany") forState:UIControlStateNormal];
    [_creatBut setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    _creatBut.titleLabel.font = sysFontWithSize(14);
    [_creatBut addTarget:self action:@selector(creatBut:) forControlEvents:UIControlEventTouchUpInside];
    //_creatBut.hidden = YES;
    [self.wh_tableBody addSubview:_creatBut];
    
    _searchTableView = [[JXTableView alloc]initWithFrame:CGRectMake(0, 71, JX_SCREEN_WIDTH, self.wh_tableBody.frame.size.height-71)];
    _searchTableView.backgroundColor = [UIColor whiteColor];
    _searchTableView.alpha = 0.97;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchTableView.hidden = YES;
    [self.wh_tableBody addSubview:_searchTableView];
}
- (void)onSearch{
    if ([self checkInput:_searchCompany.text]) {
        [g_server WH_seachCompanyWithKeywordId:_searchCompany.text toView:self];
    }
}
- (void)creatBut:(UIButton *)but{
    seekBackView.hidden = YES;
    but.hidden = YES;
    _searchTableView.hidden = YES;
    [self createCompanyView];
}
-(void)createDepartmentView{
    self.title = Localized(@"JXAddDepartVC_AddDepart");
    int h = 0;
    
    WH_JXImageView* iv;
    iv = [[WH_JXImageView alloc]init];
    iv.frame = self.wh_tableBody.bounds;
    iv.wh_delegate = self;
    iv.didTouch = @selector(hideKeyboard);
    [self.wh_tableBody addSubview:iv];
    
    iv = [self WH_createMiXinButton:Localized(@"JXAddDepartVC_DepartName") drawTop:YES drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _roomName = [self WH_createMiXinTextField:iv default:nil hint:Localized(@"JXAddDepartVC_DepartPlacehold") type:1];
    h+=iv.frame.size.height;
    
    h+=INSETS;
    
    UIButton* _btn;
    _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JXAddDepartVC_AddDepart") target:self action:@selector(onCreateDepartment)];
    _btn.layer.cornerRadius = 5;
    _btn.clipsToBounds = YES;
    _btn.frame = CGRectMake(INSETS,h,WIDTH,HEIGHT);
    [self.wh_tableBody addSubview:_btn];
}

-(void)createCompanyView{
    self.title = Localized(@"JXAddDepartVC_AddCompany");
    int h = 0;
    
    WH_JXImageView* iv;
    iv = [[WH_JXImageView alloc]init];
    iv.frame = self.wh_tableBody.bounds;
    iv.wh_delegate = self;
    iv.didTouch = @selector(hideKeyboard);
    [self.wh_tableBody addSubview:iv];
    
    iv = [self WH_createMiXinButton:Localized(@"JXAddDepartVC_CompName") drawTop:YES drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _roomName = [self WH_createMiXinTextField:iv default:nil hint:Localized(@"JXAddDepartVC_CompPlacehold") type:1];
    h+=iv.frame.size.height;
    
    h+=INSETS;
    
    UIButton* _btn;
    _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JXAddDepartVC_AddCompany") target:self action:@selector(onCreateCompany)];
    _btn.custom_acceptEventInterval = .25f;
    _btn.layer.cornerRadius = 5;
    _btn.clipsToBounds = YES;
    _btn.frame = CGRectMake(INSETS,h,WIDTH,HEIGHT);
    [self.wh_tableBody addSubview:_btn];
}

-(void)updateDepartmentNameView{
    self.title = _oldName;
    int h = 0;
    
    WH_JXImageView* iv;
    iv = [[WH_JXImageView alloc]init];
    iv.frame = self.wh_tableBody.bounds;
    iv.wh_delegate = self;
    iv.didTouch = @selector(hideKeyboard);
    [self.wh_tableBody addSubview:iv];
    
    iv = [self WH_createMiXinButton:Localized(@"JXAddDepartVC_UpdateDepart") drawTop:YES drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _roomName = [self WH_createMiXinTextField:iv default:_oldName hint:nil type:1];
    h+=iv.frame.size.height;
    
    h+=INSETS;
    
    UIButton* _btn;
    _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JXAddDepartVC_UpdateDepart") target:self action:@selector(onUpdateDepartmentName)];
    _btn.layer.cornerRadius = 5;
    _btn.clipsToBounds = YES;
    _btn.frame = CGRectMake(INSETS,h,WIDTH,HEIGHT);
    [self.wh_tableBody addSubview:_btn];
}

-(void)updateCompanyNameView{
    self.title = _oldName;
    int h = 0;
    
    WH_JXImageView* iv;
    iv = [[WH_JXImageView alloc]init];
    iv.frame = self.wh_tableBody.bounds;
    iv.wh_delegate = self;
    iv.didTouch = @selector(hideKeyboard);
    [self.wh_tableBody addSubview:iv];
    
    iv = [self WH_createMiXinButton:Localized(@"JXAddDepartVC_UpdateCompany") drawTop:YES drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _roomName = [self WH_createMiXinTextField:iv default:_oldName hint:nil type:1];
    h+=iv.frame.size.height;
    
    h+=INSETS;
    
    UIButton* _btn;
    _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JXAddDepartVC_UpdateCompany") target:self action:@selector(onUpdateCompanyName)];
    _btn.layer.cornerRadius = 5;
    _btn.clipsToBounds = YES;
    _btn.frame = CGRectMake(INSETS,h,WIDTH,HEIGHT);
    [self.wh_tableBody addSubview:_btn];
}
-(void)modifyEmployeePosition{
    self.title = _oldName;
    int h = 0;
    
    WH_JXImageView* iv;
    iv = [[WH_JXImageView alloc]init];
    iv.frame = self.wh_tableBody.bounds;
    iv.wh_delegate = self;
    iv.didTouch = @selector(hideKeyboard);
    [self.wh_tableBody addSubview:iv];
    
    iv = [self WH_createMiXinButton:Localized(@"OrgaVC_ModifyEmployeePosition") drawTop:YES drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _roomName = [self WH_createMiXinTextField:iv default:_oldName hint:nil type:1];
    h+=iv.frame.size.height;
    
    h+=INSETS;
    
    UIButton* _btn;
    _btn = [UIFactory WH_create_WHCommonButton:Localized(@"OrgaVC_ModifyEmployeePosition") target:self action:@selector(onUpdateCompanyName)];
    _btn.layer.cornerRadius = 5;
    _btn.clipsToBounds = YES;
    _btn.frame = CGRectMake(INSETS,h,WIDTH,HEIGHT);
    [self.wh_tableBody addSubview:_btn];
}


#pragma mark - action
-(BOOL)hideKeyboard{
    BOOL b = _roomName.editing || _desc.editing;
    [self.view endEditing:YES];
    return b;
}
-(void)onCreateDepartment{
    
    if ([_roomName.text isEqualToString:@""]) {
        [g_App showAlert:Localized(@"JX_InputRoomName")];
    }else if ([_desc.text isEqualToString:@""]){
        [g_App showAlert:Localized(@"WaHu_JXNewRoom_WaHuVC_InputExplain")];
    }else{
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(inputDelegateType:text:)])
            [self.delegate inputDelegateType:_type text:_roomName.text];
        [self actionQuit];
    }
    
}

-(void)onCreateCompany{
    if (_roomName.text.length <= 0) {
        [g_App showAlert:Localized(@"JXAddDepartVC_CompPlacehold")];
        return;
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(inputDelegateType:text:)])
        [self.delegate inputDelegateType:_type text:_roomName.text];
    [self actionQuit];
}

-(void)onUpdateDepartmentName{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(inputDelegateType:text:)])
        [self.delegate inputDelegateType:_type text:_roomName.text];
    [self actionQuit];
}
-(void)onUpdateCompanyName{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(inputDelegateType:text:)])
        [self.delegate inputDelegateType:_type text:_roomName.text];
    [self actionQuit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.wh_delegate = self;
    [self.wh_tableBody addSubview:btn];
    //    [btn release];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = sysFontWithSize(18);
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
        //        [p release];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, 130, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    
    [btn addSubview:p];
    //    [p release];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 13, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}

-(UITextField*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint type:(BOOL)name{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    if (s)
        p.text = s;
    if (hint)
        p.placeholder = hint;
    p.font = sysFontWithSize(14);
    
    if (name) {
        [p addTarget:self action:@selector(textLong12:) forControlEvents:UIControlEventEditingChanged];
    }else{
        [p addTarget:self action:@selector(textLong32:) forControlEvents:UIControlEventEditingChanged];
    }
    [parent addSubview:p];
    //    [p release];
    return p;
}

- (void)textLong12:(UITextField *)textField
{
    if (textField.text.length > 12) {
        textField.text = [textField.text substringToIndex:12];
    }
}

- (void)textLong32:(UITextField *)textField
{
    if (textField.text.length > 32) {
        textField.text = [textField.text substringToIndex:32];
    }
}

-(UILabel*)WH_createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 - INSETS,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = sysFontWithSize(14);
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
    //    [p release];
    return p;
}
#pragma mark----UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.companyArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary *dic = _companyArr[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"companyName"];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark----UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //键盘弹出
    self.searchTableView.hidden = YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[self hideKeBoard:nil];
    [textField resignFirstResponder];
    if (textField == _searchCompany) {
        [self onSearch];
    }
    return YES;
}
- (BOOL)checkInput:(NSString *)name{
    if ([name length] <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localized(@"JX_ContentEmpty") delegate:self cancelButtonTitle:Localized(@"OK") otherButtonTitles: nil];
        [alertView show];
        //        [alertView release];
        return NO;
    }
    return YES;
}
#pragma mark -数据请求
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_seachCompany]) {
        if (array1) {
            self.searchTableView.hidden = NO;
            [_companyArr addObjectsFromArray:array1];
            [_searchTableView reloadData];
        }else{
            [g_App showAlert:Localized(@"JXAddDepart_notFind")];
        }
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
@end
