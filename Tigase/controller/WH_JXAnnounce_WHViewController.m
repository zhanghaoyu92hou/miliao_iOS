//
//  WH_JXAnnounce_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/8/17.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXAnnounce_WHViewController.h"
#import "WH_selectProvince_WHVC.h"
#import "WH_selectValue_WHVC.h"
#import "ImageResize.h"
#import "WH_SearchData.h"
#import "WH_JXAnnounce_WHCell.h"
#import "WH_JXInputValue_WHVC.h"

#define HEIGHT 54
#define STARTTIME_TAG 1
#define IMGSIZE 100

@interface WH_JXAnnounce_WHViewController ()<UITextViewDelegate>
@property(nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) JXLabel* relLabel;

@end

@implementation WH_JXAnnounce_WHViewController
@synthesize delegate,didSelect,value;

- (id)init
{
    self = [super init];
    if (self) {
        self.wh_isGotoBack   = YES;
        self.wh_heightFooter = 0;
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.title = @"群公告";
        [self WH_createHeadAndFoot];
        self.wh_isShowHeaderPull = NO;
        self.wh_isShowFooterPull = NO;
        
        [self createHeadNavigationView];
        [self.view setBackgroundColor:g_factory.globalBgColor];
        self.tableView.backgroundColor = g_factory.globalBgColor;
        
        [self createGongGaoContent];
        
    }
    return self;
}

- (void)createHeadNavigationView {
    // 发布
    self.relLabel = [self WH_createLabel:self.wh_tableHeader default:Localized(@"JX_Publish") selector:@selector(onSave)];
    self.relLabel.textColor = [UIColor whiteColor];
    self.relLabel.textAlignment = NSTextAlignmentCenter;
    [self.relLabel setBackgroundColor:HEXCOLOR(0x0093FF)];
    self.relLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 53, JX_SCREEN_TOP - 36, 43, 28);
    self.relLabel.layer.masksToBounds = YES;
    self.relLabel.layer.cornerRadius = 14;
    
//    UIButton *relBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [relBtn setFrame:CGRectMake(JX_SCREEN_WIDTH - 53, JX_SCREEN_TOP - 36, 43, 28)];
//    [relBtn setTitle:Localized(@"JX_Publish") forState:UIControlStateNormal];
//    [relBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
//    [relBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
//    [relBtn.titleLabel setTextColor:HEXCOLOR(0xffffff)];
//    relBtn.layer.masksToBounds = YES;
//    relBtn.layer.cornerRadius = 14;
//    [self.wh_tableHeader addSubview:relBtn];
//    [relBtn addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)createGongGaoContent {
//    int height = 44;
    self.bigView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.bigView.hidden = YES;
    [self.tableView addSubview:self.bigView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.bigView addGestureRecognizer:tap];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(20, JX_SCREEN_HEIGHT/4 +.5, JX_SCREEN_WIDTH-40, 228)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self. baseView.layer.cornerRadius = g_factory.cardCornerRadius;
    self.baseView.layer.borderWidth = g_factory.cardBorderWithd;
    self.baseView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    [self.bigView addSubview:self.baseView];
//    int n = 0;
    UILabel *titLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.baseView.frame.size.width - 30, 54)];
    titLabel.textColor = HEXCOLOR(0x8C9AB8);
    titLabel.text = Localized(@"JX_Announcement");
    titLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 18];
    titLabel.textAlignment = NSTextAlignmentCenter;
    [self.baseView addSubview:titLabel];
    
    //关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(12, 14, 28, 28)];
    [closeBtn setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateNormal];
    [self.baseView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeMethod) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 54, self.baseView.frame.size.width, 1)];
    topLine.backgroundColor = HEXCOLOR(0xE8E8E8);
    [self.baseView addSubview:topLine];
    
//    n = n + height;
    self.name = [self WH_createMiXinTextField:self.baseView default:self.value hint:nil];
    self.name.backgroundColor = HEXCOLOR(0xF6F7FB);
    //        _name.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    //        CGRect frame = self.name.frame;
    //        CGSize constraintSize = CGSizeMake(frame.size.width - 20, MAXFLOAT);
    //        CGSize size = [self.name sizeThatFits:constraintSize];
    self.name.textColor = HEXCOLOR(0x3A404C);
    self.name.frame = CGRectMake(12, topLine.frame.origin.y + topLine.frame.size.height + 20, self.baseView.frame.size.width - 24, 60);
    self.name.layer.masksToBounds = YES;
    self.name.layer.cornerRadius = g_factory.cardCornerRadius;
    self.name.delegate = self;
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, self.baseView.frame.size.height - 74, self.baseView.frame.size.width, 74)];
    [self.baseView addSubview:self.topView];
    
    // 两条线
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.topView.frame.size.width , 1)];
    botLine.backgroundColor = topLine.backgroundColor;
    [self.topView addSubview:botLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(12, 14, (self.topView.frame.size.width - 24 - 17)/2, 44)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [cancelBtn setBackgroundColor:HEXCOLOR(0xffffff)];
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    cancelBtn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cancelBtn.layer.borderWidth = g_factory.cardBorderWithd;
    [cancelBtn addTarget:self action:@selector(hideBigView) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancelBtn];
    // 确定
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(cancelBtn.frame.size.width + 12 + 17, cancelBtn.frame.origin.y, cancelBtn.frame.size.width, cancelBtn.frame.size.height)];
    [sureBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [sureBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    sureBtn.layer.masksToBounds = YES;
    sureBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    [sureBtn addTarget:self action:@selector(onRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:sureBtn];
    
    
    
    
    
    [g_server getRoom:self.room.roomId toView:self];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - tableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict = self.dataArray[indexPath.row];
    NSString *tempStr = [NSString stringWithFormat:@"%@",dict[@"text"]];
    NSString *messageR = [tempStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];  //去掉回车键
    CGSize size = [messageR boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]} context:nil].size;
    
    return 72 + size.height + 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"WH_JXAnnounce_WHCell";
    WH_JXAnnounce_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXAnnounce_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataArray.count > 0) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict = self.dataArray[indexPath.row];
        [g_server WH_getHeadImageSmallWIthUserId:[NSString stringWithFormat:@"%@",dict[@"userId"]] userName:dict[@"nickname"] imageView:cell.icon];
        cell.name.text = [NSString stringWithFormat:@"%@",dict[@"nickname"]];
        NSTimeInterval startTime = [dict[@"time"] longLongValue];
        cell.time.text = [TimeUtil getTimeStrStyle1:startTime];
        NSString *tempStr = [NSString stringWithFormat:@"%@",dict[@"text"]];
        NSString *messageR = [tempStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];  //去掉回车键
        cell.content.text = messageR;
        [cell setCellHeightWithText:messageR];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    // delete action
    if (self.isAdmin) { // 是群主或管理员添加删除功能
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:Localized(@"JX_Delete")  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
            {
                [tableView setEditing:NO animated:YES];  // 退出编辑模式，隐藏左滑菜单
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                dict = self.dataArray[indexPath.row];
                NSString *roomId = [NSString stringWithFormat:@"%@",dict[@"roomId"]];
                NSString *noticeId = [NSString stringWithFormat:@"%@",dict[@"id"]];
                self.index = indexPath.row;
                [g_server WH_roomDeleteNoticeWithRoomId:roomId noticeId:noticeId ToView:self];
            }];
        deleteAction.backgroundColor = [UIColor redColor];   // 删除按钮颜色

    return @[deleteAction];
    }
    return @[];
}


- (void)hideBigView {
    [self hideKeyBoard];
    self.bigView.hidden = YES;
    self.relLabel.userInteractionEnabled = YES;
    [self resetBigView];
}

- (void)hideKeyBoard {
    if ([self.name isFirstResponder]) {
        [self.name resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.isLimit) {
        if (self.limitLen <= 0) {
            self.limitLen = NAME_INPUT_MAX_LENGTH;
        }
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length > self.limitLen && ![text isEqualToString:@""]){
            if (!self.isShow) {
                self.isShow = YES;
                [g_App showAlert:Localized(@"JX_InputLimit")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isShow = NO;
                });
            }
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    
    int maxHeight = 66.f;
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-80-INSETS*2, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    self.baseView.frame = CGRectMake(20, JX_SCREEN_HEIGHT/4+35-size.height, JX_SCREEN_WIDTH-40, 228-35+size.height);
    self.topView.frame = CGRectMake(0, 118-35+size.height, self.baseView.frame.size.width, 40);

}

-(UITextView*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextView* p = [[UITextView alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,HEIGHT)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    //    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    //    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    //    p.placeholder = hint;
    //    p.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, HEIGHT-INSETS*2)];
    //    p.leftViewMode = UITextFieldViewModeAlways;
    p.font = sysFontWithSize(16);
    [parent addSubview:p];
    return p;
}

-(JXLabel*)WH_createLabel:(UIView*)parent default:(NSString*)s selector:(SEL)selector{
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 -20,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    p.textAlignment = NSTextAlignmentLeft;
    p.didTouch = selector;
    p.wh_delegate = self;
    [parent addSubview:p];
    return p;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void)closeMethod {
    [self hideKeyBoard];
    self.bigView.hidden = YES;
    self.relLabel.userInteractionEnabled = YES;
    [self resetBigView];
}

- (void)onRelease {
    if([_name.text isEqualToString:@""]){
        [g_App showAlert:Localized(@"JX_AnnouncementNoNull")];
        return;
    }
    [self hideBigView];
//    self.value = _name.text;
    self.room.note = _name.text;
    [g_server WH_updateRoomNotifyWithRoom:self.room toView:self];
}


-(void)onSave{
    if (!self.isAdmin) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotAdminCannotDoThis")];
        return;
    }
//    self.name.text = nil;
//    self.bigView.hidden = NO;
//    self.relLabel.userInteractionEnabled = NO;
//    [self.name becomeFirstResponder];
    
    WH_JXInputValue_WHVC* vc = [WH_JXInputValue_WHVC alloc];
//    vc.value = self.room.note;
    vc.title = Localized(@"WaHu_JXRoomMember_WaHuVC_UpdateExplain");
    vc.delegate  = self;
    vc.didSelect = @selector(onPublishRoomNote:);
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onPublishRoomNote:(WH_JXInputValue_WHVC*)vc{
    self.room.note = vc.value;
    self.value = vc.value;
    self.room.allowForceNotice = vc.allowForceNotice;
    [g_server WH_updateRoomNotifyWithRoom:self.room toView:self];
}

- (void)resetBigView {
    self.name.frame = CGRectMake(10, 64, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.baseView.frame = CGRectMake(20, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-40, 228);
    self.topView.frame = CGRectMake(0, 118, self.baseView.frame.size.width, 40);
}

-(void)WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if( [aDownload.action isEqualToString:wh_act_roomDeleteNotice]){
        [_wait stop];
        [self.dataArray removeObjectAtIndex:self.index];
        [self.tableView reloadData];
        self.value = [self.dataArray.firstObject objectForKey:@"text"];
        if (delegate && [self.delegate respondsToSelector:didSelect]) {
            [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
        }
    }
    if( [aDownload.action isEqualToString:wh_act_roomSet]){
        [_wait stop];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSNumber *time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [dict setObject:self.room.roomId forKey:@"roomId"];
        [dict setObject:self.room.roomId forKey:@"id"];
        [dict setObject:MY_USER_ID forKey:@"userId"];
        [dict setObject:self.name.text forKey:@"text"];
        [dict setObject:time forKey:@"time"];
        [dict setObject:MY_USER_NAME forKey:@"nickname"];
//        [self.dataArray insertObject:dict atIndex:0];
//        [self.tableView reloadData];
        [g_server getRoom:self.room.roomId toView:self];
        if (delegate && [self.delegate respondsToSelector:didSelect]) {
            [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
        }
    }
    if( [aDownload.action isEqualToString:wh_act_roomGet]){
        [_wait stop];
        [self.dataArray removeAllObjects];
        NSArray *arr = [dict objectForKey:@"notices"];
        [self.dataArray addObjectsFromArray:arr];
        [self.tableView reloadData];
    }

}

-(int)WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

-(int)WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{
    [_wait stop];
    return WH_show_error;
}

-(void)WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}



- (void)sp_getUsersMostLiked {
    NSLog(@"Get Info Success");
}
@end
