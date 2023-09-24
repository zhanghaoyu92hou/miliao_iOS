//
//  WH_JXNewRoom_WHVC.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXNewRoom_WHVC.h"
//#import "WH_selectTreeVC_WHVC.h"
#import "WH_selectValue_WHVC.h"
#import "WH_selectProvince_WHVC.h"
#import "ImageResize.h"
#import "WH_RoomData.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXRoomObject.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXRoomObject.h"
#import "WH_JXRoomPool.h"
#import "WH_JXSelectFriends_WHVC.h"

#define HEIGHT 50
#define IMGSIZE 170


@interface WH_JXNewRoom_WHVC ()<UITextFieldDelegate>

//@property (nonatomic, assign) NSInteger roomNameLength;
@property (nonatomic, assign) NSInteger descLength;
@property (nonatomic, strong) WH_JXImageView *GroupValidationBtn;
@property (nonatomic, strong) UISwitch *GroupValidationSwitch;
@property (nonatomic, strong) UISwitch *showGroupMembersSwitch;
@property (nonatomic, strong) UISwitch *sendCardSwitch;

@end

@implementation WH_JXNewRoom_WHVC
@synthesize chatRoom;


- (id)init
{
    self = [super init];
    if (self) {
        self.wh_isGotoBack   = YES;
        self.title = Localized(@"WaHu_JXNewRoom_WaHuVC_CreatRoom");
        self.wh_heightFooter = 0;
        self.wh_heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.wh_tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
        self.wh_tableBody.scrollEnabled = YES;
        self.wh_tableBody.showsVerticalScrollIndicator = YES;
        int h = 0;
        
        _room = [[WH_RoomData alloc] init];
        _room.maxCount = 10000;
        WH_JXImageView* iv;
        iv = [[WH_JXImageView alloc]init];
        iv.frame = self.wh_tableBody.bounds;
        iv.wh_delegate = self;
        iv.didTouch = @selector(hideKeyboard);
        [self.wh_tableBody addSubview:iv];
//        [iv release];
        
        iv = [self WH_createMiXinButton:Localized(@"JX_RoomName") drawTop:YES drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _roomName = [self WH_createMiXinTextField:iv default:_room.name hint:Localized(@"JX_InputRoomName") type:1];
        h+=iv.frame.size.height;
        
        iv = [self WH_createMiXinButton:Localized(@"JX_RoomExplain") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _desc = [self WH_createMiXinTextField:iv default:_room.desc hint:Localized(@"WaHu_JXNewRoom_WaHuVC_InputExplain") type:0];
        h+=iv.frame.size.height;
        
        iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WaHuVC_CreatPer") drawTop:NO drawBottom:YES must:NO click:nil];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        _userName = [self WH_createLabel:iv default:g_myself.userNickname];
        h+=iv.frame.size.height;
        
//        iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WHVC_PerCount") drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _size = [self WH_createLabel:iv default:[NSString stringWithFormat:@"%ld/%d",_room.curCount,_room.maxCount]];
//        h+=iv.frame.size.height;
        
//        iv = [self WH_createMiXinButton:Localized(@"JX_DisplayGroupMemberList") drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _showGroupMembersSwitch = [[UISwitch alloc] init];
//        _showGroupMembersSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        _showGroupMembersSwitch.center = CGPointMake(_showGroupMembersSwitch.center.x, iv.frame.size.height/2);
//        [_showGroupMembersSwitch setOn:YES];
//        [iv addSubview:_showGroupMembersSwitch];
//        h+=iv.frame.size.height;
        
//        iv = [self WH_createMiXinButton:@"允许群成员在群组内发送名片" drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _sendCardSwitch = [[UISwitch alloc] init];
//        _sendCardSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        _sendCardSwitch.center = CGPointMake(_sendCardSwitch.center.x, iv.frame.size.height/2);
//        [_sendCardSwitch setOn:YES];
//        [iv addSubview:_sendCardSwitch];
//        h+=iv.frame.size.height;
        
//        iv = [self WH_createMiXinButton:Localized(@"JX_RoomShowRead") drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _readSwitch = [[UISwitch alloc] init];
//        _readSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        _readSwitch.center = CGPointMake(_readSwitch.center.x, iv.frame.size.height/2);
//        [iv addSubview:_readSwitch];
//        h+=iv.frame.size.height;
        
//        iv = [self WH_createMiXinButton:Localized(@"JX_PrivateGroups") drawTop:NO drawBottom:YES must:NO click:nil];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        _publicSwitch = [[UISwitch alloc] init];
//        _publicSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        _publicSwitch.onTintColor = THEMECOLOR;
//        _publicSwitch.center = CGPointMake(_publicSwitch.center.x, iv.frame.size.height/2);
//        [_publicSwitch setOn:YES];
////        _publicSwitch.userInteractionEnabled = NO;
//        [_publicSwitch addTarget:self action:@selector(publicSwitchAction:) forControlEvents:UIControlEventValueChanged];
//        [iv addSubview:_publicSwitch];
//        h+=iv.frame.size.height;
        
//        self.GroupValidationBtn = [self WH_createMiXinButton:Localized(@"JX_OpenGroupValidation") drawTop:NO drawBottom:YES must:NO click:nil];
//        self.GroupValidationBtn.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        self.GroupValidationSwitch = [[UISwitch alloc] init];
//        self.GroupValidationSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-5-51,0,0,0);
//        self.GroupValidationSwitch.center = CGPointMake(self.GroupValidationSwitch.center.x, self.GroupValidationBtn.frame.size.height/2);
//        [self.GroupValidationBtn addSubview:self.GroupValidationSwitch];
//        h+=self.GroupValidationBtn.frame.size.height;
        
        h+=INSETS;
        UIButton* _btn;
        _btn = [UIFactory WH_create_WHCommonButton:Localized(@"WaHu_JXNewRoom_WaHuVC_CreatRoom") target:self action:@selector(onInsert)];
        _btn.custom_acceptEventInterval = .25f;
        _btn.layer.cornerRadius = 5;
        _btn.clipsToBounds = YES;
        _btn.frame = CGRectMake(INSETS,h,WIDTH,HEIGHT);
        [self.wh_tableBody addSubview:_btn];
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"WH_JXNewRoom_WHVC.dealloc");
//    [_room release];
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
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, 230, HEIGHT)];
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
    p.text = s;
    p.placeholder = hint;
    p.font = sysFontWithSize(16);
    
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
//    NSInteger length = [self getTextLength:textField.text];
    
    if (textField.text.length > NAME_INPUT_MAX_LENGTH) {
        textField.text = [textField.text substringToIndex:NAME_INPUT_MAX_LENGTH];
        [JXMyTools showTipView:Localized(@"JX_CannotEnterMore")];
    }
//    _roomNameLength = textField.text.length;
}

- (void)textLong32:(UITextField *)textField
{
    NSInteger length = [self getTextLength:textField.text];
    if (length > 100) {
        textField.text = [textField.text substringToIndex:_descLength];
        [JXMyTools showTipView:Localized(@"JX_CannotEnterMore")];
    }
    _descLength = textField.text.length;
}

- (NSInteger) getTextLength:(NSString *)text {
    NSInteger length = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSInteger num = (length - text.length) / 2;
    length = length - num;
    
    return length;
}

-(UILabel*)WH_createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 - INSETS,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = sysFontWithSize(16);
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
//    [p release];
    return p;
}

- (void)publicSwitchAction:(UISwitch *)publicSwitch {
    
//    if (publicSwitch.on) {
//        self.GroupValidationBtn.hidden = YES;
//        self.GroupValidationSwitch.on = NO;
//    }else {
//        self.GroupValidationBtn.hidden = NO;
//    }
}

-(void)onUpdate{
    if(![self getInputValue])
        return;
}

-(BOOL)getInputValue{
    if([_roomName.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputName")];
        return NO;
    }
    return  YES;
}

-(BOOL)hideKeyboard{
    BOOL b = _roomName.editing || _desc.editing;
    [self.view endEditing:YES];
    return b;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)onInsert{
    NSString* s = [XMPPStream generateUUID];
    s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    
    _room.roomJid= s;
    _room.name   = _roomName.text;
    _room.desc   = _desc.text;
    _room.userId = [g_myself.userId longLongValue];
    _room.userNickName = _userName.text;
    _room.showRead = NO;
    _room.showMember = YES;
    _room.allowSendCard = YES;
    _room.isNeedVerify = NO;
    _room.allowInviteFriend = YES;
    _room.allowUploadFile = YES;
    _room.allowConference = YES;
    _room.allowSpeakCourse = YES;
    
    
    _chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:s title:_roomName.text];
    _chatRoom.delegate = self;
    
    [_wait start:Localized(@"JXAlert_CreatRoomIng") delay:30];
    
    
//    if ([_roomName.text isEqualToString:@""]) {
//        [g_App showAlert:Localized(@"JX_InputRoomName")];
//    }
////    else if ([_desc.text isEqualToString:@""]){
////        [g_App showAlert:Localized(@"WaHu_JXNewRoom_WHVC_InputExplain")];
////    }
//    else{
//        NSString* s = [XMPPStream generateUUID];
//        s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
//
//        _room.roomJid= s;
//        _room.name   = _roomName.text;
//        _room.desc   = _desc.text;
//        _room.userId = [g_myself.userId longLongValue];
//        _room.userNickName = _userName.text;
//        _room.showRead = NO;
//        _room.showMember = YES;
//        _room.allowSendCard = YES;
//        _room.isNeedVerify = NO;
//        _room.allowInviteFriend = YES;
//        _room.allowUploadFile = YES;
//        _room.allowConference = YES;
//        _room.allowSpeakCourse = YES;
//
//
//        _chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:s title:_roomName.text];
//        _chatRoom.delegate = self;
//
//        [_wait start:Localized(@"JXAlert_CreatRoomIng") delay:30];
//    }
    
}

-(void)xmppRoomDidCreate:(XMPPRoom *)sender{
    
    NSInteger category = 0;
    if (self.isAddressBook) {
        category = 510;
    }
    
    [g_server addRoom:_room isPublic:_publicSwitch.on isNeedVerify:self.GroupValidationSwitch.on category:category toView:self];
    _chatRoom.delegate = nil;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_roomAdd] ){
        _room.roomId = [dict objectForKey:@"id"];
//        _room.call = [NSString stringWithFormat:@"%@",[dict objectForKey:@"call"]];
        [self insertRoom];
        
        memberData *member = [[memberData alloc] init];
        member.userId = [g_myself.userId longLongValue];
        member.userNickName = MY_USER_NAME;
        member.role = @1;
        [_room.members addObject:member];
        
        WH_JXSelectFriends_WHVC *vc = [WH_JXSelectFriends_WHVC alloc];
        vc.chatRoom = _chatRoom;
        vc.room = _room;
        vc.isNewRoom = YES;
        if (self.isAddressBook) {
            NSMutableArray *arr = [NSMutableArray array];
            NSMutableSet *existSet = [NSMutableSet set];
            for (NSInteger i = 0; i < self.addressBookArr.count; i ++) {
                JXAddressBook *ab = self.addressBookArr[i];
                WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
                user.userId = ab.toUserId;
                user.userNickname = ab.toUserName;
                [arr addObject:user];
                [existSet addObject:ab.toUserId];
            }
            vc.existSet = [existSet copy];
            vc.addressBookArr = arr;
        }
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        
//        WH_JXSelFriend_WHVC* vc = [WH_JXSelFriend_WHVC alloc];
//        vc.chatRoom = _chatRoom;
//        vc.room = _room;
//        vc.isNewRoom = YES;
//        vc = [vc init];
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
        [self actionQuit];
//        _pSelf = nil;
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

-(void)insertRoom{
    WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
    user.userNickname = _room.name;
    user.userId = _room.roomJid;
    user.userDescription = _room.desc;
    user.roomId = _room.roomId;
    user.content = Localized(@"JX_WelcomeGroupChat");
    user.showRead =  [NSNumber numberWithBool:_room.showRead];
    user.showMember = [NSNumber numberWithBool:_room.showMember];
    user.allowSendCard = [NSNumber numberWithBool:_room.allowSendCard];
    user.allowInviteFriend = [NSNumber numberWithBool:_room.allowInviteFriend];
    user.allowUploadFile = [NSNumber numberWithBool:_room.allowUploadFile];
    user.allowSpeakCourse = [NSNumber numberWithBool:_room.allowSpeakCourse];
    user.createUserId = [NSString stringWithFormat:@"%ld",_room.userId];
    if (self.isAddressBook) {
        user.category = [NSNumber numberWithInteger:510];
    }
    [user insertRoom];
}


- (void)sp_getMediaFailed {
    NSLog(@"Get Info Success");
}
@end
