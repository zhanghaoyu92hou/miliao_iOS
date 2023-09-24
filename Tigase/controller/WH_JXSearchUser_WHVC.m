//
//  WH_JXSearchUser_WHVC.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXSearchUser_WHVC.h"
//#import "WH_selectTreeVC_WHVC.h"
#import "WH_selectProvince_WHVC.h"
#import "WH_selectValue_WHVC.h"
#import "ImageResize.h"
#import "WH_SearchData.h"
#import "WH_JXSearchUserList_WHVC.h"
#import "WH_SearchFriendResult_WHController.h"

#define HEIGHT 44
#define STARTTIME_TAG 1
#define IMGSIZE 100

@interface WH_JXSearchUser_WHVC ()<UITextFieldDelegate>

@end

@implementation WH_JXSearchUser_WHVC
@synthesize job,delegate,didSelect;

- (id)init
{
    self = [super init];
    if (self) {
        job = [[WH_SearchData alloc] init];
        self.wh_isGotoBack   = YES;
        if (self.type == JXSearchTypeUser) {
            self.title = Localized(@"WaHu_JXNear_WaHuVC_AddFriends");
        }else {
            self.title = Localized(@"JX_SearchPublicNumber");
        }
        self.wh_heightFooter = 0;
        self.wh_heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        
        int h = 0;
        _values = [[NSMutableArray alloc]initWithObjects:Localized(@"WaHu_JXSearchUser_WaHuVC_AllDate"),Localized(@"WaHu_JXSearchUser_WaHuVC_OneDay"),Localized(@"WaHu_JXSearchUser_WaHuVC_TwoDay"),Localized(@"WaHu_JXSearchUser_WaHuVC_ThereDay"),Localized(@"WaHu_JXSearchUser_WaHuVC_OneWeek"),Localized(@"WaHu_JXSearchUser_WaHuVC_TwoWeek"),Localized(@"WaHu_JXSearchUser_WaHuVC_OneMonth"),Localized(@"WaHu_JXSearchUser_WaHuVC_SixWeek"),Localized(@"WaHu_JXSearchUser_WaHuVC_TwoMonth"),nil];
        _numbers = [[NSMutableArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"7",@"14",@"30",@"42",@"60",nil];
        
//        NSString* city = [g_constant getAddressForNumber:g_myself.provinceId cityId:g_myself.cityId areaId:g_myself.areaId];
        job.sex    = -1;
        
        WH_JXImageView* iv;
        
        NSString *name;
        NSString *phoneN;
        NSString *input;
        if (self.type == JXSearchTypeUser) {
            if ([g_config.nicknameSearchUser intValue] != 0 && [g_config.regeditPhoneOrName intValue] == 0) {
                name = Localized(@"JX_NickName");
                phoneN = Localized(@"JX_OrPhoneNumber");
                input = Localized(@"JX_InputNickName");
            }else if([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 0) {
                name = Localized(@"JX_SearchPhoneNumber");
                phoneN = @"";
                input = Localized(@"JX_InputPhone");
            }else if ([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 1) {
                name = Localized(@"JX_UserName");
                phoneN = @"";
                input = Localized(@"JX_InputUserAccount");
            }else {
                name = Localized(@"JX_NickName");
                phoneN = Localized(@"JX_SearchOrUserName");
                input = Localized(@"JX_InputNickName");
            }
        }else {
            name = @"";
            phoneN = Localized(@"JX_PublicNumber");
            input = Localized(@"JX_PleaseEnterThe");
        }
        
        iv = [self WH_createMiXinButton:[NSString stringWithFormat:@"%@%@",name,phoneN] drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _name = [self WH_createMiXinTextField:iv default:job.name hint:[NSString stringWithFormat:@"%@%@",input,phoneN]];
        [_name becomeFirstResponder];
        h+=iv.frame.size.height;
        
        /*
        iv = [self WH_createMiXinButton:Localized(@"JX_Sex") drawTop:NO drawBottom:YES must:NO click:@selector(onSex)];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _sex = [self WH_createLabel:iv default:Localized(@"WaHu_JXSearchUser_WHVC_All")];
        h+=iv.frame.size.height;
        
        iv = [self WH_createMiXinButton:Localized(@"WaHu_JXSearchUser_WHVC_MinAge") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _minAge = [self WH_createMiXinTextField:iv default:@"0" hint:Localized(@"WaHu_JXSearchUser_WHVC_MinAge")];
        h+=iv.frame.size.height;
        
        iv = [self WH_createMiXinButton:Localized(@"WaHu_JXSearchUser_WHVC_MaxAge") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _maxAge = [self WH_createMiXinTextField:iv default:@"200" hint:Localized(@"WaHu_JXSearchUser_WHVC_MaxAge")];
        h+=iv.frame.size.height;
        
        iv = [self WH_createMiXinButton:Localized(@"WaHu_JXSearchUser_WHVC_AppearTime") drawTop:NO drawBottom:YES must:NO click:@selector(onDate)];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _date = [self WH_createLabel:iv default:[_values objectAtIndex:0]];
        h+=iv.frame.size.height;
        */
        h+=30;
        UIButton* _btn;
        _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JX_Seach") target:self action:@selector(onSearch)];
        _btn.custom_acceptEventInterval = .25f;
        _btn.frame = CGRectMake(INSETS, h, WIDTH, HEIGHT);
        [self.wh_tableBody addSubview:_btn];
        
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"WH_JXSearchUser_WHVC.dealloc");
    self.job = nil;
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.wh_delegate = self;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
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
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH/2-40, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(16);
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

-(UITextField*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 + 10,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = sysFontWithSize(16);
    [parent addSubview:p];
//    [p release];
    return p;
}

-(UILabel*)WH_createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 - 30,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = sysFontWithSize(14);
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
//    [p release];
    return p;
}

-(void)onSex{
    if([self hideKeyboard])
        return;
    
    WH_selectValue_WHVC* vc = [WH_selectValue_WHVC alloc];
    vc.values = [NSMutableArray arrayWithObjects:Localized(@"WaHu_JXSearchUser_WaHuVC_All"),Localized(@"JX_Man"),Localized(@"JX_Wuman"),nil];
    vc.selNumber = 0;
    vc.numbers   = [NSMutableArray arrayWithObjects:@"-1",@"1",@"0",nil];
    vc.delegate  = self;
    vc.didSelect = @selector(onSelSex:);
    vc.quickSelect = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSelSex:(WH_selectValue_WHVC*)sender{
    if([self hideKeyboard])
        return;
    
    _sex.text  = sender.selValue;
    job.sex    = sender.selNumber;
}

-(void)onDate{
    if([self hideKeyboard])
        return;
    
    WH_selectValue_WHVC* vc = [WH_selectValue_WHVC alloc];
    vc.values = _values;
    vc.selNumber = 0;
    vc.numbers   = _numbers;
    vc.delegate  = self;
    vc.didSelect = @selector(onSelDate:);
    vc.quickSelect = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSelDate:(WH_selectValue_WHVC*)sender{
    job.showTime = sender.selNumber;
    _date.text = sender.selValue;
}

-(void)onSearch{
    if ([_name.text isEqualToString:@""]) {
        if (self.type == JXSearchTypeUser) {
            if ([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 0) {
                [g_App showAlert:Localized(@"JX_InputPhone")];
            }else if ([g_config.nicknameSearchUser intValue] == 0 && [g_config.regeditPhoneOrName intValue] == 1){
                [g_App showAlert:Localized(@"JX_InputUserAccount")];
            }else {
                [g_App showAlert:Localized(@"JX_InputNickName")];
            }
        }else {
            [g_App showAlert:Localized(@"JX_PleaseEnterTheServerNo.")];
        }
    }else{
        job.name = _name.text;
        job.minAge = [_minAge.text intValue];
        job.maxAge = [_maxAge.text intValue];
        [self actionQuit];
        
        if (self.type == JXSearchTypeUser) {
            [self searchFriend:job];
            return;
        }else {
            WH_JXSearchUserList_WHVC *vc = [[WH_JXSearchUserList_WHVC alloc] init];
            vc.isUserSearch = NO;
            vc.keyWorld = _name.text;
            vc.search = job;
            [g_navigation pushViewController:vc animated:YES];
        }
    }
}

//搜索好友
- (void)searchFriend:(WH_SearchData *)job{
    WH_SearchFriendResult_WHController *vc = [WH_SearchFriendResult_WHController alloc];
    vc.search = job;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

-(BOOL)hideKeyboard{
    BOOL b = _name.editing;
    [self.view endEditing:YES];
    return b;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}



@end
