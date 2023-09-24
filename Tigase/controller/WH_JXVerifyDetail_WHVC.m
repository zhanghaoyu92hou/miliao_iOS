//
//  WH_JXVerifyDetail_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/5/29.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXVerifyDetail_WHVC.h"

#define HEIGHT 50
@interface WH_JXVerifyDetail_WHVC ()
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) NSArray *userIds;
@property (nonatomic, strong) NSArray *userNames;
@end

@implementation WH_JXVerifyDetail_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.title = Localized(@"JX_InvitingDetails");
    [self createHeadAndFoot];
    
    [self customView];
}

- (void)customView {
    
    NSDictionary *resultObject = [self.msg.objectId mj_JSONObject];
    
    WH_JXImageView *imageView = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, 50, 80, 80)];
    imageView.center = CGPointMake(JX_SCREEN_WIDTH / 2, imageView.center.y);
    [imageView headRadiusWithAngle:imageView.frame.size.width * 0.5];
    [self.wh_tableBody addSubview:imageView];
    [g_server WH_getHeadImageLargeWithUserId:self.msg.fromUserId userName:self.msg.fromUserName imageView:imageView];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 10, JX_SCREEN_WIDTH, 20)];
    name.text = self.msg.fromUserName;
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = [UIColor lightGrayColor];
    name.font = [UIFont systemFontOfSize:15.0];
    [self.wh_tableBody addSubview:name];
    
    NSString *userIds = [resultObject objectForKey:@"userIds"];
    NSArray *array = [userIds componentsSeparatedByString:@","];
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(name.frame) + 10, JX_SCREEN_WIDTH, 20)];
    tip.text = [NSString stringWithFormat:Localized(@"JX_InviteFriendsJoinGroupChat"),array.count];
    tip.textAlignment = NSTextAlignmentCenter;
    tip.textColor = [UIColor lightGrayColor];
    tip.font = [UIFont systemFontOfSize:15.0];
    [self.wh_tableBody addSubview:tip];
    
    UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tip.frame) + 10, JX_SCREEN_WIDTH, 20)];
    detail.text = [resultObject objectForKey:@"reason"];
    detail.textAlignment = NSTextAlignmentCenter;
    detail.textColor = [UIColor lightGrayColor];
    detail.font = [UIFont systemFontOfSize:15.0];
    [self.wh_tableBody addSubview:detail];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(detail.frame) + 20, JX_SCREEN_WIDTH - 40, 1)];
    line.backgroundColor = [UIColor grayColor];
    [self.wh_tableBody addSubview:line];
    
    UIView *view = [self createImages];
    view.frame = CGRectMake(0, CGRectGetMaxY(line.frame) + 20, JX_SCREEN_WIDTH, view.frame.size.height);
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame) + 20, WIDTH, 50)];
    _confirmBtn.center = CGPointMake(JX_SCREEN_WIDTH / 2, _confirmBtn.center.y);
    if ([self.msg.fileName isEqualToString:@"1"]) {
        self.confirmBtn.enabled = NO;
        self.confirmBtn.backgroundColor = [UIColor grayColor];
    }else {
        _confirmBtn.enabled = YES;
        _confirmBtn.backgroundColor = THEMECOLOR;
    }
    [_confirmBtn setTitle:Localized(@"JX_ConfirmationInvitations") forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(WH_confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableBody addSubview:_confirmBtn];
    
    [self.wh_tableBody setContentSize:CGSizeMake(0, CGRectGetMaxY(_confirmBtn.frame) + 20)];
}

- (UIView *) createImages {
    NSDictionary *resultObject = [self.msg.objectId mj_JSONObject];
    NSString *userIdStr = [resultObject objectForKey:@"userIds"];
    NSString *userNameStr = [resultObject objectForKey:@"userNames"];
    self.userIds = [userIdStr componentsSeparatedByString:@","];
    self.userNames = [userNameStr componentsSeparatedByString:@","];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 0)];
    [self.wh_tableBody addSubview:contentView];
    
    //动态分配行数，且居中
    int screenWidth = JX_SCREEN_WIDTH;
    //+52让间隙变大，更美观
//    float widthInset = (screenWidth%52 +52)/(screenWidth/52.0);
    int num = screenWidth / 52;
    while ((screenWidth - num * 52) < 15 * (num + 1)) {
        num = num - 1;
    }
    
    float widthInset = (screenWidth - num * 52) / 6;
    
    float x = widthInset;
    int y = 10;
    for (NSInteger i = 0; i < self.userIds.count; i ++) {
        NSString *userId = self.userIds[i];
        NSString *userName = self.userNames[i];
        WH_JXImageView* headImageView = [[WH_JXImageView alloc] init];
        [g_server WH_getHeadImageLargeWithUserId:userId userName:userName imageView:headImageView];
        [contentView addSubview:headImageView];
        if(headImageView){
            
            if(x +52 >= screenWidth){
                y += 77;
                x = widthInset;
            }
            
            headImageView.frame = CGRectMake(x, y, 52, 52);
            [headImageView headRadiusWithAngle:headImageView.frame.size.width * 0.5];
            x = x+52+widthInset;
            
            JXLabel* b = [[JXLabel alloc]initWithFrame:CGRectMake( headImageView.frame.origin.x, headImageView.frame.origin.y+headImageView.frame.size.height + 5, 52, 10)];
            b.text = userName;
            b.font = sysFontWithSize(9);
            b.textAlignment = NSTextAlignmentCenter;
            [contentView addSubview:b];
        }
    }
    
    contentView.frame = CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, contentView.frame.size.width, y + 77);
    return contentView;
}

- (void)WH_confirmBtnAction:(UIButton *)btn {
    [g_server WH_addRoomMemberWithRoomId:self.room.roomId userArray:self.userIds toView:self];//用接口即可
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_roomMemberSet] ){
        for (int i=0;i<[_userIds count];i++) {
            NSString *userId=[_userIds objectAtIndex:i];
            
            memberData* p = [[memberData alloc] init];
            p.userId = [userId intValue];
            p.userNickName = [_userNames objectAtIndex:i];
            [self.room.members addObject:p];
        }
        self.msg.fileName = @"1";
        self.msg.content = [self.msg.content stringByReplacingOccurrencesOfString:Localized(@"JX_ToConfirm") withString:Localized(@"JX_VerifyConfirmed")];
        [self.msg updateNeedVerifyFileName];
        [self.msg update];
        self.confirmBtn.enabled = NO;
        self.confirmBtn.backgroundColor = [UIColor grayColor];
        
        for(NSInteger i=[self.chatVC.array count]-1;i>=0;i--){
            WH_JXMessageObject *p=[self.chatVC.array objectAtIndex:i];
            if([p.messageId isEqualToString:self.msg.messageId]){//如果找到被撤回的那条消息
                [self.chatVC.tableView WH_reloadRow:(int)i section:0];
                break;
            }
            p =nil;
        }
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


- (void)sp_getUserName {
    NSLog(@"Continue");
}
@end
