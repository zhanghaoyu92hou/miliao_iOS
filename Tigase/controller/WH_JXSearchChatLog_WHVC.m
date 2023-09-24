//
//  WH_JXSearchChatLog_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/6/25.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXSearchChatLog_WHVC.h"
#import "WH_JX_WHCell.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXRoomPool.h"
#import "WH_JXSearchFileLog_WHVC.h"
#import "WH_JXSearchImageLog_WHVC.h"

@interface WH_JXSearchChatLog_WHVC () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic,strong) UIView *selectView;

@end

@implementation WH_JXSearchChatLog_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = NO;
    [self WH_createHeadAndFoot];
    
    self.title = Localized(@"JX_FindChatContent");
    
    _array = [NSMutableArray array];
    self.tableView.backgroundColor = g_factory.globalBgColor;
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 50)];
    [self.view addSubview:backView];
    UIView *bgView = [UIView new];
    [backView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.offset(0.5);
        make.height.offset(44);
    }];
    bgView.backgroundColor = [UIColor whiteColor];
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 8, backView.frame.size.width - 20, 30)];
    _seekTextField.placeholder = [NSString stringWithFormat:@"%@", Localized(@"JX_SearchChatLog")];
    _seekTextField.backgroundColor = g_factory.inputBackgroundColor;
    if (@available(iOS 10, *)) {
        _seekTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", Localized(@"JX_SearchChatLog")] attributes:@{NSForegroundColorAttributeName:g_factory.inputDefaultTextColor}];
    } else {
        [_seekTextField setValue:g_factory.inputDefaultTextColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    [_seekTextField setFont:g_factory.inputDefaultTextFont];
    _seekTextField.textColor = HEXCOLOR(0x333333);
    _seekTextField.layer.borderWidth = 0.5;
    _seekTextField.layer.borderColor = g_factory.inputBorderColor.CGColor;
    
    _seekTextField.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:251/255.0 blue:252/255.0 alpha:1.0].CGColor;
    _seekTextField.layer.cornerRadius = 15;
    //    _seekTextField.layer.masksToBounds = YES;
    //    _seekTextField.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, JX_SCREEN_WIDTH, .5)];
//    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [backView addSubview:lineView];
    
    self.tableView.tableHeaderView = backView;
    
    [self createSelectView];
    
}


- (void)createSelectView {
    
    if (!_selectView) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height - 50)];
        [self.tableView addSubview:_selectView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectViewTap:)];
        [_selectView addGestureRecognizer:tap];
        
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, _selectView.frame.size.width, 30)];
        tip.textAlignment = NSTextAlignmentCenter;
        tip.textColor = [UIColor lightGrayColor];
        tip.text = Localized(@"JX_SearchChatContentQuickly");
        tip.font = [UIFont systemFontOfSize:14.0];
        [_selectView addSubview:tip];
        
        NSArray *items = @[Localized(@"JX_Image"), Localized(@"JX_Video"), Localized(@"JX_File"), Localized(@"JXLink"), Localized(@"JX_Trading")];
        CGFloat itemW = 100;
        CGFloat itemH = 60;
        CGFloat marginX = (JX_SCREEN_WIDTH - (itemW * 3)) / 2;
        CGFloat itemX = marginX;
        CGFloat itemY = CGRectGetMaxY(tip.frame) + 10;
        
        UIButton *lastItem= nil;
        for (NSInteger i = 0; i < items.count; i ++) {
            
            if (i % 3 == 0) {
                itemX = marginX;
                if (lastItem) {
                    itemY = CGRectGetMaxY(lastItem.frame);
                }else {
                    itemY = CGRectGetMaxY(tip.frame) + 10;
                }
            }else {
                itemX = CGRectGetMaxX(lastItem.frame);
                itemY = lastItem.frame.origin.y;
                
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(itemX, ((itemH - 20) / 2) + itemY, 0.5, 20)];
                lineView.backgroundColor = [UIColor lightGrayColor];
                [_selectView addSubview:lineView];
            }
            
            NSString *itemTitle = items[i];
            
            UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(itemX, itemY, itemW, itemH)];
            [item setTitle:itemTitle forState:UIControlStateNormal];
            [item setTitleColor:HEXCOLOR(0x576b95) forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont systemFontOfSize:16.0];
            item.tag = i;
            [item addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
            [_selectView addSubview:item];
            
            lastItem = item;
        }
    }
}

- (void)itemAction:(UIButton *)btn {
    
    NSInteger type = 0;
    switch (btn.tag) {
        case 0:{
            WH_JXSearchImageLog_WHVC *vc = [[WH_JXSearchImageLog_WHVC alloc] init];
            vc.isImage = YES;
            vc.user = self.user;
            [g_navigation pushViewController:vc animated:YES];
            return;
        }
            break;
        case 1:{
            WH_JXSearchImageLog_WHVC *vc = [[WH_JXSearchImageLog_WHVC alloc] init];
            vc.isImage = NO;
            vc.user = self.user;
            [g_navigation pushViewController:vc animated:YES];
            return;
        }
            break;
        case 2:
            type = FileLogType_file;
            break;
        case 3:
            type = FileLogType_Link;
            break;
        case 4:
            type = FileLogType_transact;
            break;
            
        default:
            break;
    }
    WH_JXSearchFileLog_WHVC *vc = [[WH_JXSearchFileLog_WHVC alloc] init];
    vc.type = type;
    vc.user = self.user;
    vc.isGroup = YES;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectViewTap:(UITapGestureRecognizer *)tap {
 
    [self.view endEditing:YES];
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    [_array removeAllObjects];
    if (textField.text.length <= 0) {
        _selectView.hidden = NO;
        [self.tableView reloadData];
        return;
    }
    
    _selectView.hidden = YES;
    NSArray * resultArray = [[WH_JXMessageObject sharedInstance] fetchSearchMessageWithUserId:self.user.userId String:textField.text];
    
    for (WH_JXMessageObject *msg in resultArray) {
        if(msg.content.length > 0) {
            WH_JXMsgAndUserObject *searchObj = [[WH_JXMsgAndUserObject alloc] init];
            searchObj.user = self.user;
            searchObj.message = msg;
            [_array addObject:searchObj];
        }
    }

    [self.tableView reloadData];
}


#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellName = [NSString stringWithFormat:@"msg"];
    
    WH_JX_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];

    WH_JXMsgAndUserObject * dict = (WH_JXMsgAndUserObject*) [_array objectAtIndex:indexPath.row];
    
    if(cell==nil){
        cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
        [_table WH_addToPool:cell];
    }
    cell.delegate = self;
    cell.didTouch = @selector(WH_on_WHHeadImage:);
    cell.didDragout=@selector(onDrag:);
    //    [cell msgCellDataSet:dict indexPath:indexPath];
    cell.title = dict.user.userNickname;
    
    cell.userId = dict.user.userId;
    cell.bage = [NSString stringWithFormat:@"%d",[dict.user.msgsNew intValue]];
    cell.index = (int)indexPath.row;
    cell.bottomTitle  = [TimeUtil getTimeStrStyle1:[dict.message.timeSend timeIntervalSince1970]];
    
    cell.headImageView.tag = (int)indexPath.row;
    cell.headImageView.wh_delegate = cell.delegate;
    cell.headImageView.didTouch = cell.didTouch;
    
    [cell.lbTitle setText:cell.title];
    cell.lbTitle.tag = cell.index;
    
    if(dict.user.lastInput.length > 0) {
        NSString *str = Localized(@"JX_Draft");
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str, dict.user.lastInput]];
        NSRange range = [[NSString stringWithFormat:@"%@%@",str, dict.user.lastInput] rangeOfString:str];
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        cell.lbSubTitle.attributedText = attr;
        
    }else {
        cell.searchContent = _seekTextField.text?:@"";
        [cell setSubtitle:[dict.message getLastContent]];
    }
    
    [cell.timeLabel setText:cell.bottomTitle];
    cell.bageNumber.wh_delegate = cell.delegate;
    cell.bageNumber.wh_didDragout = cell.didDragout;
    cell.bage = cell.bage;
    if ([dict.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        cell.bageNumber.wh_lb.hidden = YES;
        CGRect frame = cell.bageNumber.frame;
        frame.size = CGSizeMake(10, 10);
        cell.bageNumber.frame = frame;
    }else {
        cell.bageNumber.wh_lb.hidden = NO;
        CGRect frame = cell.bageNumber.frame;
        frame.size = CGSizeMake(18, 18);
        cell.bageNumber.frame = frame;
    }
    NSString * roomIdStr = dict.user.roomId;
    cell.roomId = roomIdStr;
    cell.isSmall = NO;
    [cell WH_headImageViewImageWithUserId:dict.user.userId roomId:roomIdStr];
    [self WH_doAutoScroll:indexPath];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (dict.user.topTime) {
        cell.contentView.backgroundColor = HEXCOLOR(0xF0F1F2);
    }else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    WH_JXMsgAndUserObject *p=[_array objectAtIndex:indexPath.row];
    
    int lineNum = 0;
    if (_seekTextField.text.length > 0) {
        lineNum = [p.message getLineNumWithUserId:p.user.userId];
    }

    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    
    sendView.scrollLine = lineNum;
    sendView.title = p.user.userNickname;
    if([p.user.roomFlag intValue] > 0 || p.user.roomId.length > 0){
        if(g_xmpp.isLogined != 1){
            // 掉线后点击title重连
            [g_xmpp showXmppOfflineAlert];
            return;
        }
        sendView.roomJid = p.user.userId;
        sendView.roomId   = p.user.roomId;
        sendView.groupStatus = p.user.groupStatus;
        if ([p.user.groupStatus intValue] == 0) {
            
            sendView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:p.user.userId title:p.user.userNickname isNew:NO];
        }
        
        if (p.user.roomFlag) {
            NSDictionary * groupDict = [p.user toDictionary];
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:groupDict];
            
            sendView.room = roomdata;
        }
        
    }
    sendView.lastMsg = p.message;
    sendView.chatPerson = p.user;
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.view.hidden = NO;

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


- (void)sp_getUserFollowSuccess {
    NSLog(@"Get User Succrss");
}
@end
