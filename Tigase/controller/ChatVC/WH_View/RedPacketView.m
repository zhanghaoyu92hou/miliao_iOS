//
//  RedPacketView.m
//  Tigase
//
//  Created by 齐科 on 2019/9/19.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "RedPacketView.h"
#import "WH_JXredPacketDetail_WHVC.h"

@interface RedPacketView () <UITextFieldDelegate>
{
    NSDictionary *packetDic;
    UIScrollView *packetScrollView;
    UIImageView *redPocketView; //!< 开红包背景
    UIImageView *secondBackView; //!< 特权开背景
    UILabel *checkDetailsLabel; //!< 查看红包明细
    UILabel *tintLabel; //!< 祝福语
    UIButton *closeButton; //!< 关闭
    int yuanString; //元
    int jiaoString; //!< 角
    int fenString; //!< 分
}
@end
@implementation RedPacketView
- (instancetype)initWithRedPacketInfo:(NSDictionary *)infoDic {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        packetDic = infoDic;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        [self loadSubViews];
        [self loadFirstViewContent];
    }
    return self;
}

- (void)loadSubViews {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self addGestureRecognizer:tap];
    
    CGFloat h = JX_SCREEN_HEIGHT - JX_SCREEN_TOP - JX_SCREEN_BOTTOM - 30-50;
    packetScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 30+JX_SCREEN_TOP, JX_SCREEN_WIDTH-25*2, h)];
    packetScrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH-25*2, h);
    packetScrollView.pagingEnabled = YES;
    packetScrollView.scrollEnabled = NO;
    [self addSubview:packetScrollView];
    
    redPocketView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, packetScrollView.width, h)];
    redPocketView.image = [UIImage imageNamed:@"WH_redPacket_open_bg"];
    redPocketView.userInteractionEnabled = YES;
    [packetScrollView addSubview:redPocketView];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(packetScrollView.left + 16, packetScrollView.top + 16, 28, 28)];
    [closeButton setImage:[UIImage imageNamed:@"WH_redPacket_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeRedPacket) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    
}
- (void)loadFirstViewContent {
    NSString *userName = packetDic[@"packet"][@"userName"];// [NSString stringWithFormat:@"%@",[[dict objectForKey:@"packet"] objectForKey:@"userName"]];
    NSString *greetings = packetDic[@"packet"][@"greetings"];//[NSString stringWithFormat:@"%@",[[dict objectForKey:@"packet"] objectForKey:@"greetings"]];
    NSString *userId = packetDic[@"packet"][@"userId"];//[NSString stringWithFormat:@"%@",[[dict objectForKey:@"packet"] objectForKey:@"userId"]];
//    CGSize size = [[NSString stringWithFormat:@"%@%@",userName,Localized(@"JX_FromRedPacket")] boundingRectWithSize:CGSizeMake(CGRectGetWidth(redPocketView.bounds) - 70, 50) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:sysFontWithSize(18)} context:nil].size;
    //头像
    CGFloat iconWH = 50.f;
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(redPocketView.frame) - iconWH) / 2.f, 40, iconWH, iconWH)];
    icon.layer.masksToBounds = YES;
    icon.layer.cornerRadius = icon.frame.size.width/2;
    [redPocketView addSubview:icon];
    [g_server WH_getHeadImageSmallWIthUserId:userId userName:userName imageView:icon];
    //昵称
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, icon.bottom + 8, redPocketView.width - 10 * 2, 25)];
    name.font = pingFangRegularFontWithSize(18);
    //    name.text = [NSString stringWithFormat:@"%@%@",userName,Localized(@"JX_FromRedPacket")];
    name.text = userName;
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = HEXCOLOR(0xFFE2B1);
    [redPocketView addSubview:name];
    
    
    //提示
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(name.frame), CGRectGetMaxY(name.frame)+8, CGRectGetWidth(name.frame), 20)];
    prompt.textColor = HEXCOLOR(0xFFE2B1);
    prompt.font = pingFangRegularFontWithSize(14);
    prompt.text = @"给你发了一个红包";
    [redPocketView addSubview:prompt];
    prompt.textAlignment = NSTextAlignmentCenter;
    
    //祝福语
    tintLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(name.frame), CGRectGetMaxY(prompt.frame)+24, CGRectGetWidth(name.frame), 31)];
    tintLabel.text = greetings;
    tintLabel.font = pingFangRegularFontWithSize(22);
    tintLabel.textAlignment = NSTextAlignmentCenter;
    tintLabel.textColor = HEXCOLOR(0xFFE2B1);
    [redPocketView addSubview:tintLabel];
    
    CGFloat b = (redPocketView.height / JX_SCREEN_HEIGHT) * (redPocketView.height-88);
    UIButton *openButton = [[UIButton alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-40-102)/2, b, 102, 102)];
    [openButton setImage:[UIImage imageNamed:@"WH_redPacket_open"] forState:UIControlStateNormal];
    [openButton addTarget:self action:@selector(openRedPacket:) forControlEvents:UIControlEventTouchUpInside];
    [redPocketView addSubview:openButton];
    
    checkDetailsLabel = [[UILabel alloc] initWithFrame:CGRectMake((redPocketView.width-140)/2, redPocketView.height-18-40, 140, 18)];
    checkDetailsLabel.textAlignment = NSTextAlignmentCenter;
    checkDetailsLabel.userInteractionEnabled = YES;
    checkDetailsLabel.textColor = HEXCOLOR(0xFFE2B1);
    checkDetailsLabel.font = sysFontWithSize(14);
    checkDetailsLabel.text = Localized(@"JX_CheckTheClaimDetails>");
    checkDetailsLabel.hidden = [userId intValue] != [MY_USER_ID intValue];
    [redPocketView addSubview:checkDetailsLabel];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkDetailsAction)];
    [checkDetailsLabel addGestureRecognizer:tap1];
    
    
//    CGFloat detailWH = 20;
//    UIImageView *detail = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(redPocketView.frame) - detailWH) / 2.f, CGRectGetMaxY(checkDetailsLabel.frame) + 8, detailWH, detailWH)];
//    detail.image = [UIImage imageNamed:@"WH_redPacket_detail"];
//    detail.userInteractionEnabled = YES;
//    [detail addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkDetailsAction)]];
//    [redPocketView addSubview:detail];
    
    //如果是拼手气红包并且用户有Vip权限，则显示特权
    //红包类型 1、普通红包 2、手气红包(只在群组里面才有) 3、口令红包
    if ([packetDic[@"packet"][@"type"] integerValue] == 2 && g_myself.redPacketVip.integerValue == 1 && IS_RedPacketVip_Open == 1) {
        UIButton *specialButton = [[UIButton alloc] initWithFrame:CGRectMake((packetScrollView.width-100)/2, openButton.bottom+10, 100, 30)];
        specialButton.backgroundColor = HEXCOLOR(0xFFE2B1);
        specialButton.layer.cornerRadius = 5;
        specialButton.clipsToBounds = YES;
        [specialButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        specialButton.titleLabel.font = pingFangRegularFontWithSize(14);
        [specialButton setTitle:Localized(@"PrivilegedOpen") forState:UIControlStateNormal];
        [specialButton addTarget:self action:@selector(goSpecialOpen) forControlEvents:UIControlEventTouchUpInside];
        [redPocketView addSubview:specialButton];
        
        packetScrollView.contentSize = CGSizeMake((JX_SCREEN_WIDTH-25*2)*2, redPocketView.height);
        packetScrollView.pagingEnabled = YES;
        
        secondBackView = [[UIImageView alloc] initWithFrame:CGRectMake(redPocketView.right, 0, packetScrollView.width, redPocketView.height)];
        secondBackView.image = [UIImage imageNamed:@"special_open_bg"];
        secondBackView.userInteractionEnabled = YES;
        [packetScrollView addSubview:secondBackView];
        [self loadSecondViewContent:secondBackView];
    }
}
- (void)loadSecondViewContent:(UIImageView *)view {
    UILabel *specialTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, view.width, 35)];
    specialTitleLabel.font = pingFangMediumFontWithSize(18);
    specialTitleLabel.textColor = HEXCOLOR(0xFFE2B1);
    specialTitleLabel.text = Localized(@"PrivilegedOpen");
    specialTitleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:specialTitleLabel];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, specialTitleLabel.bottom+35, view.width, 21)];
    tipLabel.font = pingFangRegularFontWithSize(15);
    tipLabel.textColor = HEXCOLOR(0xFFE2B1);
    tipLabel.text = Localized(@"PleaseSetAmount");
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:tipLabel];
    
    UITextField *yuanTextField = [[UITextField alloc] initWithFrame:CGRectMake((view.width - 3*40 - 12 - 20)/2, tipLabel.bottom+38, 40, 40)];
    yuanTextField.delegate = self;
    yuanTextField.tag = 22;
    yuanTextField.layer.borderWidth = 1;
    yuanTextField.layer.borderColor = HEXCOLOR(0xFFE2B1).CGColor;
    yuanTextField.textColor = HEXCOLOR(0xFFE2B1);
    yuanTextField.text = @"0";
    yuanTextField.font = pingFangMediumFontWithSize(40);
    yuanTextField.textAlignment = NSTextAlignmentCenter;
    yuanTextField.keyboardType = UIKeyboardTypeNumberPad;
    yuanTextField.tintColor = UIColor.clearColor;
    [view addSubview:yuanTextField];
    
    UIView *dianView = [[UIView alloc] initWithFrame:CGRectMake(yuanTextField.right + 8, tipLabel.bottom+38+38, 4, 4)];
    [dianView setBackgroundColor:HEXCOLOR(0xFFE2B1)];
    dianView.layer.cornerRadius = 2;
    [view addSubview:dianView];
    
    UITextField *jiaoTextField = [[UITextField alloc] initWithFrame:CGRectMake(yuanTextField.right + 20, tipLabel.bottom+38, 40, 40)];
    jiaoTextField.delegate = self;
    jiaoTextField.tag = 20;
    jiaoTextField.layer.borderWidth = 1;
    jiaoTextField.layer.borderColor = HEXCOLOR(0xFFE2B1).CGColor;
    jiaoTextField.textColor = HEXCOLOR(0xFFE2B1);
    jiaoTextField.text = @"0";
    jiaoTextField.font = pingFangMediumFontWithSize(40);
    jiaoTextField.textAlignment = NSTextAlignmentCenter;
    jiaoTextField.keyboardType = UIKeyboardTypeNumberPad;
    jiaoTextField.tintColor = UIColor.clearColor;
    [view addSubview:jiaoTextField];
    
    UITextField *fenTextField = [[UITextField alloc] initWithFrame:CGRectMake(jiaoTextField.right+12, tipLabel.bottom+38, 40, 40)];
    fenTextField.delegate = self;
    fenTextField.tag = 21;
    fenTextField.text = @"0";
    fenTextField.layer.borderWidth = 1;
    fenTextField.layer.borderColor = HEXCOLOR(0xFFE2B1).CGColor;
    fenTextField.textColor = HEXCOLOR(0xFFE2B1);
    fenTextField.font = pingFangMediumFontWithSize(40);
    fenTextField.textAlignment = NSTextAlignmentCenter;
    fenTextField.keyboardType = UIKeyboardTypeNumberPad;
    fenTextField.tintColor = UIColor.clearColor;
    [view addSubview:fenTextField];
    
    UIButton *specialOpenButton = [[UIButton alloc] initWithFrame:CGRectMake((view.width-160)/2, fenTextField.bottom+50, 160, 40)];
    specialOpenButton.layer.cornerRadius = 5;
    specialOpenButton.clipsToBounds = YES;
    specialOpenButton.backgroundColor = HEXCOLOR(0xFFE2B1);
    [specialOpenButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    specialOpenButton.titleLabel.font = pingFangRegularFontWithSize(14);
    [specialOpenButton setTitle:Localized(@"PrivilegedOpen") forState:UIControlStateNormal];
    [specialOpenButton addTarget:self action:@selector(specialOpen:) forControlEvents:UIControlEventTouchUpInside];
    specialOpenButton.tag = 0;
    [view addSubview:specialOpenButton];
    
    UIButton *generalOpenButton = [[UIButton alloc] initWithFrame:CGRectMake((view.width-160)/2, specialOpenButton.bottom+20, 160, 40)];
    generalOpenButton.layer.cornerRadius = 5;
    generalOpenButton.clipsToBounds = YES;
    generalOpenButton.backgroundColor = HEXCOLOR(0xFFE2B1);
    [generalOpenButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    generalOpenButton.titleLabel.font = pingFangRegularFontWithSize(14);
    [generalOpenButton setTitle:Localized(@"NormalOpen") forState:UIControlStateNormal];
    [generalOpenButton addTarget:self action:@selector(specialOpen:) forControlEvents:UIControlEventTouchUpInside];
    generalOpenButton.tag = 1;
    [view addSubview:generalOpenButton];
}

#pragma ---- Show Animation
- (void)showRedPacket{
    [g_window addSubview:self];
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [packetScrollView.layer addAnimation:animation forKey:nil];
    [closeButton.layer addAnimation:animation forKey:nil];
}

#pragma mark ---- Button Action
- (void)closeRedPacket {
    [self endEditing:YES];
    [self removeFromSuperview];
}
- (void)openRedPacket:(UIButton *)button {
    [self endEditing:YES];
    [button setUserInteractionEnabled:NO];
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (int i = 1; i < 12; i++) {
        NSString *imageName = [NSString stringWithFormat:@"icon_open_red_packet%d", i];
        UIImage  *image     = [UIImage imageNamed:imageName];
        [imagesArray addObject:image];
    }
    button.imageView.animationImages = imagesArray;
    button.imageView.animationDuration = 1.f;
    button.imageView.animationRepeatCount = 0;
    [button.imageView startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.9f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [redPocketView stopAnimating];
        [g_server WH_openRedPacketWithRedPacketId:packetDic[@"packet"][@"id"] money:nil toView:self];
    });
}
- (void)checkDetailsAction {
     [self endEditing:YES];
    [self removeFromSuperview];
    
    WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
    redPacketDetailVC.wh_dataDict = packetDic;
    redPacketDetailVC.isGroup = self.isGroup;
    [g_navigation pushViewController:redPacketDetailVC animated:YES];
}
- (void)goSpecialOpen {
     [self endEditing:YES];
    [packetScrollView setContentOffset:CGPointMake(packetScrollView.width, 0) animated:YES];
}
- (void)specialOpen:(UIButton *)button {
    [self endEditing:YES];
    [button setUserInteractionEnabled:NO];
    if (button.tag == 0) {//特权开
        NSString *moneyStr = [NSString stringWithFormat:@"%d.%d%d", yuanString ,jiaoString, fenString];
        [g_server WH_openRedPacketWithRedPacketId:packetDic[@"packet"][@"id"] money:moneyStr toView:self];
    }else {//普通开
        [packetScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}


- (void)WH_CheckTheDetails {
    [self removeFromSuperview];
    
    WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
    redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:packetDic];
    redPacketDetailVC.isGroup = self.isGroup;
    [g_navigation pushViewController:redPacketDetailVC animated:YES];
}
#pragma mark ----- Update RedPacket Status
////改变红包对应消息的不可获取
//-(void)changeMessageRedPacketStatus:(NSString*)redPacketId{
//    NSString* myUserId = MY_USER_ID;
//    if([myUserId length]<=0){
//        return;
//    }
//    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
//
//    NSString * sufStr = self.roomJid ? self.roomJid : self.chatPerson.userId;
//
//    NSString * sql = [NSString stringWithFormat:@"update msg_%@ set fileSize=2 where objectId=?",sufStr];
//
//    [db executeUpdate:sql,redPacketId];
//
//    db = nil;
//}
////改变红包消息不可获取
//- (void)changeMessageArrFileSize:(NSString *)redPackerId{
//    for (NSInteger i = _array.count - 1; i >= 0; i --) {
//        WH_JXMessageObject *msg = _array[i];
//        if ([msg.objectId isEqualToString:redPackerId]) {
//            msg.fileSize = [NSNumber numberWithInt:2];
//            [self.tableView WH_reloadRow:(int)i section:0];
//        }
//    }
//    for (WH_JXMessageObject * msg in _orderRedPacketArray) {
//        if ([msg.objectId isEqualToString:redPackerId]) {
//            msg.fileSize = [NSNumber numberWithInt:2];
//        }
//    }
//}
#pragma mark ------ UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 22) {
        yuanString = textField.text.intValue;
    }else if (textField.tag == 20) {
        jiaoString = textField.text.intValue;
    }else {
        fenString = textField.text.intValue;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        textField.text = @"0";
        return NO;
    }else if (textField.tag == 22 && textField.text.length == 1 && ![textField.text isEqualToString:@""]) {
        //角单位的输入框输入一次，跳转到下一个输入框
        textField.text = string;
        yuanString = string.intValue;
        UITextField *secTF = (UITextField *)[secondBackView viewWithTag:20];
        [secTF becomeFirstResponder];
        return NO;
    }else if (textField.tag == 20 && textField.text.length == 1 && ![textField.text isEqualToString:@""]) {
        //角单位的输入框输入一次，跳转到下一个输入框
        textField.text = string;
        jiaoString = string.intValue;
        UITextField *secTF = (UITextField *)[secondBackView viewWithTag:21];
        [secTF becomeFirstResponder];
        return NO;
    } else if(textField.text.length == 1) {
        textField.text = @"";
    }
    return YES;
}
- (void)dismissKeyboard:(UITapGestureRecognizer *)tap {
    [self endEditing:YES];
}
#pragma mark ---- NetWork
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //打开红包
    if ([aDownload.action isEqualToString:wh_act_openRedPacket]) {
        if (self.redPocketBlock) {
            self.redPocketBlock(dict, YES);
        }
        packetDic = dict;
        [UIView animateWithDuration:.3f animations:^{
            packetScrollView.top = -packetScrollView.height/2;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            
            WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
            redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:dict];
            redPacketDetailVC.isGroup = self.isGroup;
            [g_navigation pushViewController:redPacketDetailVC animated:NO];
        }];
    }
}
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [[ATMHud sharedInstance] stop];
    if ([aDownload.action isEqualToString:wh_act_openRedPacket]) {
        if (dict) {
            NSDictionary *resultMsg = [dict objectForKey:@"data"];
            if (resultMsg) {
                NSString *msg = [resultMsg objectForKey:@"resultMsg"];
                if (msg.length > 0) {
                    [GKMessageTool showText:msg];
                }
            }
        }
        
        packetDic = dict;
        redPocketView.hidden = YES;
        checkDetailsLabel.hidden = NO;
        tintLabel.text = Localized(@"SlowHand");
        if (self.redPocketBlock) {
            [self closeRedPacket];
            self.redPocketBlock(dict, NO);
        }
    }
    return WH_hide_error;
}
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [[ATMHud sharedInstance] stop];
    return WH_hide_error;
}
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [[ATMHud sharedInstance] start];
}

@end
