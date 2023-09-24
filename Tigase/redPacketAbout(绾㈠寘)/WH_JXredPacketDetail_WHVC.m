//
//  WH_JXredPacketDetail_WHVC.m
//  Tigase_imChatT
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXredPacketDetail_WHVC.h"
#import "WH_JXRPacketList_WHCell.h"
#import "WH_JXRedPacketList_WHVC.h"

@interface WH_JXredPacketDetail_WHVC () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *replyLab;

@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *replayTitle;
@property (nonatomic, strong) UITextView *replayTextView;
@property (nonatomic, assign) int replayNum;

@property (nonatomic, strong) NSString *replyContent;
@property (nonatomic, strong) NSString *money;

@property (nonatomic, strong) UIColor *watermarkColor;

@end

@implementation WH_JXredPacketDetail_WHVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = 0;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack   = YES;
       
        
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xf0eff4);
    [self WH_createHeadAndFoot];
    
    self.watermarkColor = [UIColor lightGrayColor];
    
    //获取数据
    _wh_packetObj = [WH_JXPacketObject getPacketObject:_wh_dataDict];
    _wh_OpenMember = [self arraySortDESC:[WH_JXGetPacketList getPackList:_wh_dataDict]];
    
    NSNumber * typeNum = _wh_dataDict[@"packet"][@"type"];
    switch ([typeNum intValue]) {
        case 1:
            self.title = Localized(@"JX_UsualGift");
            break;
        case 2:
            self.title = Localized(@"JX_LuckGift");
            break;
        case 3:
            self.title = Localized(@"JX_MesGift");
            break;
        default:
            break;
    }
    
    self.replyContent = [NSString string];
    for (WH_JXGetPacketList * memberObj in _wh_OpenMember) {
        if ([memberObj.userId intValue] == [MY_USER_ID intValue]) {
            self.replyContent = memberObj.reply;
//            self.money = [NSString stringWithFormat:@"%.2f %@",memberObj.money,Localized(@"JX_ChinaMoney")];
            self.money = [NSString stringWithFormat:@"¥%.2f ",memberObj.money];
        }
    }

    _table.backgroundColor = g_factory.globalBgColor;
    _table.allowsSelection = NO;
    self.wh_isShowFooterPull = NO;
    
    self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
    [self WH_createCustomView];
    _table.frame = CGRectMake(0, CGRectGetMaxY(_wh_contentView.frame), JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - CGRectGetMaxY(_wh_contentView.frame));
    
//    _getPacketListTBV.delegate = self;
//    _getPacketListTBV.dataSource = self;
//    _getPacketListTBV.separatorStyle = UITableViewCellSeparatorStyleNone;
//    //设置tableview不可被点击
//    _getPacketListTBV.allowsSelection = NO;
//    _wait = [ATMHud sharedInstance];
    
    [self WH_setViewSize];
    [self WH_setViewData];
}


-(void)WH_createCustomView{
    _wh_headImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 150)];
    _wh_headImgV.image = [UIImage imageNamed:@"WH_redPacket_top_bg"];
    _wh_headImgV.userInteractionEnabled = YES;
    _wh_headImgV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_wh_headImgV];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, JX_SCREEN_TOP - 32, 28, 28)];
    [closeBtn setImage:[UIImage imageNamed:@"WH_redPacket_back"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(WH_closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_wh_headImgV addSubview:closeBtn];
    
    UIButton *listBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 10 - 70, JX_SCREEN_TOP - 32, 70, 28)];
    [listBtn setTitle:Localized(@"JX_RedPacketRecord") forState:UIControlStateNormal];
    [listBtn setTitleColor:HEXCOLOR(0xFFE2B1) forState:UIControlStateNormal];
    listBtn.titleLabel.font = sysFontWithSize(14);
    [listBtn addTarget:self action:@selector(listBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    listBtn.layer.borderColor = HEXCOLOR(0xFFE2B1).CGColor;
    listBtn.layer.borderWidth = g_factory.cardBorderWithd;
    listBtn.layer.cornerRadius = CGRectGetHeight(listBtn.frame) / 2.f;
    listBtn.layer.masksToBounds = YES;
    [_wh_headImgV addSubview:listBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH, 20)];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = Localized(@"JX_ShikuRedPacket");
    title.textColor = HEXCOLOR(0xFFE2B1);
    title.font = sysFontWithSize(18);
    [_wh_headImgV addSubview:title];
    
    
    _wh_contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_wh_headImgV.frame), JX_SCREEN_WIDTH, self.money.length > 0 ? 210 : 150)];
    _wh_contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_wh_contentView];
    
    _wh_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -25, 50, 50)];
    _wh_headerImageView.center = CGPointMake(_wh_headImgV.frame.size.width / 2, _wh_headerImageView.center.y);
    _wh_headerImageView.image = [UIImage imageNamed:@"avatar_normal"];
    _wh_headerImageView.userInteractionEnabled = YES;
    [_wh_contentView addSubview:_wh_headerImageView];
    
//    _totalMoneyLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(_headerImageView.frame) +8, CGRectGetMinY(_headerImageView.frame), 130, 27) text:@"共100.01元"];
//    _totalMoneyLabel.textColor = [UIColor yellowColor];
//    _totalMoneyLabel.font = sysFontWithSize(20);
//    [_headImgV addSubview:_totalMoneyLabel];
    
    _wh_fromUserLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(_wh_headerImageView.frame) + 12, _wh_contentView.frame.size.width, 21) text:Localized(@"JX_IsRedEnvelopes")];
    _wh_fromUserLabel.textColor = HEXCOLOR(0x3A404C);
    _wh_fromUserLabel.textAlignment = NSTextAlignmentCenter;
    _wh_fromUserLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    [_wh_contentView addSubview:_wh_fromUserLabel];
    
    _wh_greetLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(_wh_fromUserLabel.frame) + 8, _wh_contentView.frame.size.width, 17) text:Localized(@"JX_KungHeiFatChoi")];
    _wh_greetLabel.textColor = HEXCOLOR(0x3A404C);
    _wh_greetLabel.textAlignment = NSTextAlignmentCenter;
    _wh_greetLabel.font = sysFontWithSize(12);
    [_wh_contentView addSubview:_wh_greetLabel];
    
    if (self.money.length > 0) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.money attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size: 40],NSForegroundColorAttributeName:HEXCOLOR(0x3A404C)}];
//        [attStr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size: 40],NSForegroundColorAttributeName:HEXCOLOR(0x3A404C)} range:NSMakeRange(0, self.money.length-1)];
        UILabel *moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_wh_greetLabel.frame) + 10, JX_SCREEN_WIDTH, 60)];
        moneyLab.attributedText = attStr;
        moneyLab.textAlignment = NSTextAlignmentCenter;
        [_wh_contentView addSubview:moneyLab];
                
        _replyLab = [UIFactory WH_create_WHLabelWith:CGRectMake((JX_SCREEN_WIDTH-200)/2, CGRectGetMaxY(moneyLab.frame) + 10, 200, 20) text:self.replyContent.length > 0 ? self.replyContent : @"回复一句话表示感谢！"];
        _replyLab.textColor = HEXCOLOR(0x8C9AB8);
        _replyLab.textAlignment = NSTextAlignmentCenter;
        _replyLab.userInteractionEnabled = YES;
        _replyLab.font = sysFontWithSize(11);
        [_wh_contentView addSubview:_replyLab];
    }

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyToTheRedPacket)];
    [_replyLab addGestureRecognizer:tap];


    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 41)];
    headView.backgroundColor = g_factory.globalBgColor;
    _wh_showNumLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(10, 12, JX_SCREEN_WIDTH - 10, 17) text:Localized(@"JX_ ReceiveRed")];
    _wh_showNumLabel.textColor = HEXCOLOR(0x969696);
    _wh_showNumLabel.font = sysFontWithSize(12);
    [headView addSubview:_wh_showNumLabel];
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 30 - 1, JX_SCREEN_WIDTH, 1)];
//    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [headView addSubview:lineView];
    
    self.tableView.tableHeaderView = headView;
    
    [self WH_setupReplayView];
}

- (void)WH_setupReplayView {
    int height = 44;
    self.bigView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.bigView.hidden = YES;
    [g_App.window addSubview:self.bigView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.bigView addGestureRecognizer:tap];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self. baseView.layer.cornerRadius = 4.0f;
    [self.bigView addSubview:self.baseView];
    int n = 20;
    _replayTitle = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, n, self.baseView.frame.size.width - INSETS*2, 20)];
    _replayTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _replayTitle.textColor = HEXCOLOR(0x595959);
    _replayTitle.font = sysFontWithSize(16);
    [self.baseView addSubview:_replayTitle];
    
    n = n + height;
    self.replayTextView = [self WH_createMiXinTextField:self.baseView default:nil hint:nil];
    self.replayTextView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    self.replayTextView.frame = CGRectMake(10, n, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.replayTextView.delegate = self;
    self.replayTextView.textColor = HEXCOLOR(0x595959);
    n = n + INSETS + height;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, n, self.baseView.frame.size.width, 44)];
    [self.baseView addSubview:self.topView];
    
    // 两条线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 0.5)];
    topLine.backgroundColor = HEXCOLOR(0xD6D6D6);
    [self.topView addSubview:topLine];
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, 0, 0.5, self.topView.frame.size.height)];
    botLine.backgroundColor = HEXCOLOR(0xD6D6D6);
    [self.topView addSubview:botLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:sysFontWithSize(15)];
    [cancelBtn addTarget:self action:@selector(hideBigView) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancelBtn];
    // 发送
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [sureBtn setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0x383893) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:sysFontWithSize(15)];
    [sureBtn addTarget:self action:@selector(onRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:sureBtn];
    
}

- (void)hideBigView {
    [self resignKeyBoard];
}

- (void)onRelease {
    if (self.replayTextView.textColor != self.watermarkColor && self.replayTextView.text.length > 0) {
        [g_server WH_redPacketReplyWithRedPacketid:self.wh_packetObj.packetId content:self.replayTextView.text toView:self];
        [self hideBigView];
    }
}

- (void)replyToTheRedPacket {
    if (self.replayTextView.text.length > 0) {
        self.replayTextView.text = nil;
    }
    self.bigView.hidden = NO;
    [self.replayTextView becomeFirstResponder];
    
    self.replayTitle.text = @"回复一句话表示感谢！";
    
    self.replayTextView.textColor = self.watermarkColor;
    self.replayTextView.text = self.replyContent.length > 0 ? self.replyContent : @"回复一句话表示感谢！";
    self.replayTextView.selectedRange = NSMakeRange(0, 0);
    // 加载水印时调用textViewDidChange 高度自适应
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    //如果是提示内容，光标放置开始位置
    if (textView.textColor == self.watermarkColor) {
        NSRange range;
        range.location = 0;
        range.length = 0;
        textView.selectedRange = range;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //如果不是delete响应,当前是提示信息，修改其属性
    if (![text isEqualToString:@""] && textView.textColor == self.watermarkColor) {
        textView.text = @"";//置空
        textView.textColor = HEXCOLOR(0x595959);
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.text.length > 10) {
        textView.text = [textView.text substringToIndex:10];
    }
    
    static CGFloat maxHeight =66.0f;
    
    
    //防止输入时在中文后输入英文过长直接中文和英文换行
    if ([textView.text isEqualToString:@""]) {
        textView.textColor = self.watermarkColor;
        textView.text = self.replyContent.length > 0 ? self.replyContent : @"回复一句话表示感谢！";
    }
    
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
    NSLog(@"--------%@",NSStringFromCGRect(self.baseView.frame));
    
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4+35-size.height, JX_SCREEN_WIDTH-80, 162-35+size.height);
    self.topView.frame = CGRectMake(0, 118-35+size.height, self.baseView.frame.size.width, 40);
}


- (void)WH_closeBtnAction:(UIButton *)btn {
    [self actionQuit];
}

- (void)listBtnAction:(UIButton *)btn {
    WH_JXRedPacketList_WHVC *vc = [[WH_JXRedPacketList_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    }];
}

-(void)WH_quitOutAnimate{
    [self actionQuit];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
//    }];
}

- (void)WH_setViewSize{
    [_wh_headerImageView headRadiusWithAngle:CGRectGetHeight(_wh_headerImageView.frame) / 2.f];
}

- (void)WH_creatTBHeaderView{
    //红包过时，提示
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 30)];
    _table.tableHeaderView = headerView;
    _wh_returnMoneyLabel = [[UILabel alloc]initWithFrame:headerView.frame];
    
    _wh_returnMoneyLabel.font = pingFangRegularFontWithSize(12);
    _wh_returnMoneyLabel.text = [NSString stringWithFormat:@"%@(%.2f%@)%@",Localized(@"WaHu_JXredPacketDetail_WaHuVC_ReturnMoney1"),_wh_packetObj.over,Localized(@"JX_ChinaMoney"),Localized(@"WaHu_JXredPacketDetail_WaHuVC_ReturnMoney2")];
    _wh_returnMoneyLabel.textAlignment = NSTextAlignmentCenter;
    _wh_returnMoneyLabel.center = headerView.center;
    [headerView addSubview:_wh_returnMoneyLabel];
}
//填写界面上的数据
- (void)WH_setViewData{
    [g_server WH_getHeadImageSmallWIthUserId:_wh_packetObj.userId userName:_wh_packetObj.userName imageView:_wh_headerImageView];
    _wh_totalMoneyLabel.text = [NSString stringWithFormat:@"%@%.2f%@",Localized(@"WaHu_JXredPacketDetail_WaHuVC_All"),_wh_packetObj.money,Localized(@"JX_ChinaMoney")];
    _wh_fromUserLabel.text = [NSString stringWithFormat:@"%@%@", _wh_packetObj.userName,Localized(@"JX_WhoIsRedEnvelopes")];
    _wh_greetLabel.text = _wh_packetObj.greetings;
    NSString * isCanOpen = nil;
    NSString *over = [NSString stringWithFormat:@"%.2f",_wh_packetObj.over];
    //[over doubleValue] < 0.01
    if([_wh_OpenMember count] == _wh_packetObj.count){
        if (IS_SHOW_EXCLUSIVEREDPACKET) {
            isCanOpen = @"已领完！";
        }else{
            isCanOpen = Localized(@"WaHu_JXredPacketDetail_WaHuVC_DrawOver");
        }
        
    }else if(_wh_dataDict[@"resultMsg"]){
        if (IS_SHOW_EXCLUSIVEREDPACKET) {
            isCanOpen = _wh_dataDict[@"resultMsg"];
        }else{
//            isCanOpen = Localized(@"WaHu_JXredPacketDetail_WaHuVC_Overdue");
//            [self WH_creatTBHeaderView];
            
            if (![_wh_dataDict[@"resultMsg"] containsString:@"未领完"]) {
                isCanOpen = Localized(@"WaHu_JXredPacketDetail_WaHuVC_Overdue");
                [self WH_creatTBHeaderView];
            }else{
                isCanOpen = _wh_dataDict[@"resultMsg"];
            }
        }
        
    }else if ([_wh_OpenMember count] < _wh_packetObj.count && _wh_dataDict[@"resultMsg"] == nil) {
        if (IS_SHOW_EXCLUSIVEREDPACKET) {
            isCanOpen = @"未领完！";
        }else{
             isCanOpen = Localized(@"WaHu_JXredPacketDetail_WaHuVC_DrawOK");
        }
       
    }
    
    if (IS_SHOW_EXCLUSIVEREDPACKET) {
        _wh_showNumLabel.text = [NSString stringWithFormat:@"已领取%lu/%ld个，共%.2f/%.2f元，%@" ,(unsigned long)[_wh_OpenMember count] ,_wh_packetObj.count ,(_isGroup)?_wh_packetObj.over:_wh_packetObj.money ,_wh_packetObj.money ,isCanOpen];
    }else{
        if (_wh_packetObj.over < 0.01) {
            _wh_showNumLabel.text = [NSString stringWithFormat:@"%@%ld/%ld,%@",Localized(@"WaHu_JXredPacketDetail_WaHuVC_Drawed"),[_wh_OpenMember count],_wh_packetObj.count,isCanOpen];
        }else{
            _wh_showNumLabel.text = [NSString stringWithFormat:@"%@%ld/%ld, %@%.2f%@,%@",Localized(@"WaHu_JXredPacketDetail_WaHuVC_Drawed"),[_wh_OpenMember count],_wh_packetObj.count,Localized(@"WaHu_JXredPacketDetail_WaHuVC_Rest"),_wh_packetObj.over,Localized(@"JX_ChinaMoney"),isCanOpen];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)back:(id)sender {
    [self WH_quitOutAnimate];
}

#pragma mark  --------------------TableView-------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_wh_OpenMember count];
}

-(WH_JXRPacketList_WHCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //领取过红包的用户，使用WH_JXRPacketList_WHCell展示
    NSString * cellName = @"RPacketListCell";
    WH_JXRPacketList_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){

        cell = [[NSBundle mainBundle] loadNibNamed:@"WH_JXRPacketList_WHCell" owner:self options:nil][0];
    }
    WH_JXGetPacketList * memberObj = _wh_OpenMember[indexPath.row];
    [g_server WH_getHeadImageSmallWIthUserId:memberObj.userId userName:memberObj.userName imageView:cell.headerImage];
    //用户名
    cell.nameLabel.text = memberObj.userName;
    //回复内容
    cell.contentLab.text = memberObj.reply;
    //日期
    NSTimeInterval  getTime = memberObj.time;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:getTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*60*60]];//中国专用
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    //金额
    cell.moneyLabel.text = [NSString stringWithFormat:@"%.2f %@",memberObj.money,Localized(@"JX_ChinaMoney")];
    
    
    
    NSString *over = [NSString stringWithFormat:@"%.2f",_wh_packetObj.over];
    
    if (_wh_packetObj.status == 2 && [over doubleValue] < 0.01 && indexPath.row == [self getMaxMoney] && self.isGroup) {
        cell.kingImgV.hidden = NO;
        cell.bestLab.hidden = NO;
    }else {
        cell.kingImgV.hidden = YES;
        cell.bestLab.hidden = YES;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}



//#pragma mark - 请求成功回调
//-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
//
//    if ([aDownload.action isEqualToString:wh_act_getRedPacket]) {
//        self.dataDict = [[NSDictionary alloc]initWithDictionary:dict];
//    }
//    
//    
//}
//
//#pragma mark - 请求失败回调
//-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
//
//    //自己查看红包
//    if ([aDownload.action isEqualToString:wh_act_getRedPacket]) {
//        self.dataDict = [[NSDictionary alloc]initWithDictionary:dict];
//    }
//    return WH_hide_error;
//}

- (void)resignKeyBoard {
    self.bigView.hidden = YES;
    [self hideKeyBoard];
    [self resetBigView];
}

- (void)resetBigView {
    self.replayTextView.frame = CGRectMake(10, 64, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5);
    self.topView.frame = CGRectMake(0, 118, self.baseView.frame.size.width, 40);
}

- (void)hideKeyBoard {
    if (self.replayTextView.isFirstResponder) {
        [self.replayTextView resignFirstResponder];
    }
}
-(UITextView*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextView* p = [[UITextView alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,54)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = sysFontWithSize(16);
    [parent addSubview:p];
    return p;
}


- (void)dealloc {
//    [_headerImageView release];
//    [_totalMoneyLabel release];
//    [_fromUserLabel release];
//    [_greetLabel release];
//    [_showNumLabel release];
//    [_getPacketListTBV release];
//    [super dealloc];
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if([aDownload.action isEqualToString:wh_act_redPacketReply]){
        for (WH_JXGetPacketList * memberObj in _wh_OpenMember) {
            if ([memberObj.userId intValue] == [MY_USER_ID intValue]) {
                memberObj.reply = self.replayTextView.text;
            }
        }
        self.replyContent = self.replayTextView.text;
        self.replyLab.text = self.replayTextView.text;
        
        [_table reloadData];
    }
}



#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    if([aDownload.action isEqualToString:wh_act_redPacketReply]){
        [g_server showMsg:@"回复失败"];
    }
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    if([aDownload.action isEqualToString:wh_act_redPacketReply]){
        [g_server showMsg:@"回复失败"];
    }
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


- (NSArray *)arraySortDESC:(NSArray *)dataDict {
    //对数组按领取时间time  进行降序排序
    
    // 排序key, 某个对象的属性名称，是否升序, YES-升序, NO-降序
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    // 排序结果
    return [dataDict sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}


- (NSUInteger)getMaxMoney {
    // 获取手气最佳用户的index
    NSArray *tempArr = [NSArray array];
    
    NSMutableArray *list = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"money" ascending:NO];
    // 排序结果
    tempArr = [_wh_OpenMember sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
    WH_JXGetPacketList *tempPacket = (WH_JXGetPacketList *)tempArr.firstObject;
    NSString *tempMoney = [NSString stringWithFormat:@"%.2f",tempPacket.money];
    for (WH_JXGetPacketList *packet in _wh_OpenMember) {
        NSString *money = [NSString stringWithFormat:@"%.2f",packet.money];
        if ([money doubleValue] == [tempMoney doubleValue]) {
            [list addObject:packet];
        }
    }
    if (list.count > 1) {
        NSArray *sortArr = list.copy;
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
        sortArr = [sortArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
        WH_JXGetPacketList *sortPacket = (WH_JXGetPacketList *)sortArr.firstObject;
        for (WH_JXGetPacketList *packet in _wh_OpenMember) {
            if ([packet.userId intValue] == [sortPacket.userId intValue]) {
                return [_wh_OpenMember indexOfObject:packet];
            }
        }
    }else {
        return [_wh_OpenMember indexOfObject:[list firstObject]];
    }
    return 0;
}


- (void)sp_getUsersMostFollowerSuccess {
    NSLog(@"Get User Succrss");
}
@end
