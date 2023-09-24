//
//  WH_JXLiveRoom_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/8/5.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXLiveRoom_WHViewController.h"


@implementation WH_JXLiveRoom_WHViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        
        self.wh_heightHeader = 0;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = NO;
        self.wh_isFreeOnClose = NO;
        _membersArray = [[NSMutableArray alloc] init];
        _membersSet = [[NSMutableSet alloc] init];
        _chatMsgArray = [[NSMutableArray alloc] init];
        _giftArray = [[NSArray alloc] init];
        _giftNameDict = [[NSMutableDictionary alloc] init];
        
        [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsg_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(receiveRoomNotification:) name:kXMPPRoom_WHNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [g_notify removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self settingLive];
    
    [self customUI];
    
    [self joinChatRoom];
    
    [g_server liveRoomGiftList:_wh_liveRoomId toView:self];
    [g_server liveRoomMembers:_wh_liveRoomId toView:self];
    [g_server WH_getUserMoenyToView:self];
}

-(void)settingLive{

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.closeButton];
//    [self createDemoBarrage];
    [_barrageView startBullet];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(void)createDemoBarrage{
    //w为弹幕添加测试数据
    _barrageView.dataSource = @[@"我去",@"路见不平",@"66666",@"demo",@"66666",@"额，就是负伤啊",@"错66666，那是勇猛无敌",@"哈66666！英雄救美呢！！！！！",@"拔刀相助",@"额，66666就是负伤啊",@"错了，那是勇猛无敌",@"哈？66666！英雄救美呢！！！！！",@"哈哈哈哈。。。",@"你们说错啦，那个坑货！",@"这是一个故事啊！",@"不懂不要乱说",@"额。。。",@"什么情况",@"hel66666lo meizi",@"天理难容啊～",@"放开它，让我来",@"nb",@"这样都可以？！",@"看不懂",@"不错不错，有大酱风范～",@"如果66666有一天。。。",@"我去66666，天掉下来了",@"都挺好的",@"你们看到后面了吗，貌似有背景呢，哈哈哈哈哈。。。",@"真是，额，强",@"可以可以"];
}

#pragma mark - 创建View

-(void)customUI{
    
    [self.view addSubview:self.bgScrollView];
    
    //顶部
    [_bgScrollView addSubview:self.topBar];
    
    //弹幕
    [_bgScrollView addSubview:self.barrageView];
    
    //聊天
    [_bgScrollView addSubview:self.chatTableView];
    
    //爱心
    [_bgScrollView addSubview:self.heartView];
    //礼物
//    [self createGiftView];
    //底部按钮
    [_bgScrollView addSubview:self.toolBar];
    
     // 返回
    [self.view addSubview:self.closeButton];
    
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(JX_SCREEN_WIDTH-33-5, JX_SCREEN_TOP - 64 + 10, 33, 33);
        [_closeButton setImage:[UIImage imageNamed:@"closeicon"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(quitLiveRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(UIScrollView *)bgScrollView{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _bgScrollView.backgroundColor = [UIColor clearColor];
        _bgScrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH*2, JX_SCREEN_HEIGHT);
        _bgScrollView.contentOffset = CGPointMake(JX_SCREEN_WIDTH, 0);
        _bgScrollView.pagingEnabled = YES;
        _bgScrollView.bounces = NO;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
//        _bgScrollView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgSCrollViewTapAction:)];
        tapGes.delegate = self;
        [_bgScrollView addGestureRecognizer:tapGes];
    }
    
    return _bgScrollView;
}

-(UIView *)topBar{
    if (!_topBar) {
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0+JX_SCREEN_WIDTH, JX_SCREEN_TOP - 64, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
        
        [_topBar addSubview:self.anchorHead];
        
        [_topBar addSubview:self.membListCollection];
    }
    
    return _topBar;
}

-(UIView *)anchorHead{
    if (!_anchorHead) {
        _anchorHead = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 100, 39)];
        _anchorHead.layer.cornerRadius = 39/2;
        _anchorHead.layer.masksToBounds = YES;
        _anchorHead.backgroundColor = [UIColor darkGrayColor];
        
        //head
        _anchorHeadImgView = [[WH_JXImageView alloc] init];
        _anchorHeadImgView.frame = CGRectMake(3, 3, 33, 33);
        _anchorHeadImgView.layer.cornerRadius = 33/2;
        _anchorHeadImgView.layer.masksToBounds = YES;
        //        _headImageView.layer.borderWidth = 0.5;
        _anchorHeadImgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        
        _anchorHeadImgView.wh_delegate = self;
        _anchorHeadImgView.didTouch = @selector(anchorDidTouchAction);
        
        [g_server WH_getHeadImageSmallWIthUserId:_userId userName:_name imageView:_anchorHeadImgView];
        [_anchorHead addSubview:_anchorHeadImgView];
        
        //title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_anchorHeadImgView.frame)+5, 3, 80, 18)];
        //    _titleLabel.center = CGPointMake(_titleLabel.center.x, _anchorHeadImgView.center.y);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = _name;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = sysFontWithSize(12);
        [_anchorHead addSubview:_titleLabel];
        
        //count
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_anchorHeadImgView.frame)+5, CGRectGetMaxY(_titleLabel.frame), 80, 18)];
        _countLabel.text = [NSString stringWithFormat:@"%ld%@",_count,Localized(@"JXLiveVC_countPeople")];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = sysFontWithSize(12);
        [_anchorHead addSubview:_countLabel];
    }
    return _anchorHead;
}

-(UICollectionView *)membListCollection{
    if (!_membListCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _membListCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(110, 5, 300, CGRectGetHeight(_anchorHead.frame)) collectionViewLayout:layout];
        _membListCollection.backgroundColor = [UIColor clearColor];
        _membListCollection.alwaysBounceHorizontal = YES;
        _membListCollection.alwaysBounceVertical = NO;
        _membListCollection.delegate = self;
        _membListCollection.dataSource = self;
        [_membListCollection registerClass:[WH_JXLiveMember_WHCell class] forCellWithReuseIdentifier:NSStringFromClass([WH_JXLiveMember_WHCell class])];
    }
    return _membListCollection;
}

-(WH_BulletGroupView *)barrageView{
    if (!_barrageView) {
        _barrageView = [[WH_BulletGroupView alloc] initWithFrame:CGRectMake(0+JX_SCREEN_WIDTH, CGRectGetMaxY(_topBar.frame) +5, JX_SCREEN_WIDTH, 160) rowHeight:30 rowNum:5];
        
        BulletSettingDic *barrageSetting = [[BulletSettingDic alloc] init];
        [barrageSetting setBulletTextColor:[UIColor whiteColor]];
        [barrageSetting setBulletAnimationDuration:5.0];
        [_barrageView setBulletDic:barrageSetting];
        [_bgScrollView addSubview:_barrageView];
    }
    return _barrageView;
}

-(UITableView *)chatTableView{
    if (!_chatTableView) {
        _chatTableView = [[JXTableView alloc] initWithFrame:CGRectMake(0+JX_SCREEN_WIDTH, CGRectGetMaxY(_barrageView.frame), JX_SCREEN_WIDTH-110, JX_SCREEN_HEIGHT-CGRectGetMaxY(_barrageView.frame)-JX_SCREEN_BOTTOM-20) style:UITableViewStylePlain];
        _chatTableView.delegate = self;
        _chatTableView.dataSource = self;
        _chatTableView.backgroundColor = [UIColor clearColor];
        _chatTableView.rowHeight = 30;
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_chatTableView registerClass:[WH_JXLiveChat_WHCell class] forCellReuseIdentifier:NSStringFromClass([WH_JXLiveChat_WHCell class])];
    }
    return _chatTableView;
}

-(UIView *)heartView{
    if (!_heartView) {
        _heartView = [[UIView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-110+JX_SCREEN_WIDTH, CGRectGetMaxY(_barrageView.frame), 110, JX_SCREEN_HEIGHT - CGRectGetMaxY(_barrageView.frame)-49)];
    }
    return _heartView;
}

-(UIView *)toolBar{
    if (!_toolBar) {
        _toolBar = [[UIView alloc] init];
        _toolBar.frame = CGRectMake(0 +JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM);
        
        [_toolBar addSubview:self.commentBtn];
    }
    return _toolBar;
}
-(UIButton *)commentBtn{
    if (!_commentBtn) {
        //输入按钮
        _commentBtn = [UIFactory WH_create_WHButtonWithImage:@"livecomment" highlight:@"livecomment" target:self selector:@selector(commentButtonAction:)];
        _commentBtn.frame = CGRectMake(10, 0, 40, 40);
    }
    return _commentBtn;
}

-(UIView *)inputView{
    //输入条,副键盘
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
//        _inputView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        _inputView.frame = CGRectMake(0, JX_SCREEN_HEIGHT+10, JX_SCREEN_WIDTH, 44);
        
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = CGRectMake(0, 0, _inputView.frame.size.width, _inputView.frame.size.height);
        [_inputView addSubview:effectView];
        
        _chatTextView = [[UITextView alloc] initWithFrame:CGRectMake(70, 5, JX_SCREEN_WIDTH-70-15, 44-5)];
        _chatTextView.backgroundColor = [UIColor clearColor];
//        _chatTextView.placeHolder = @"和大家说点什么";
//        _chatTextView.placeHolder = @"开启大喇叭,1钻石/条";
        _chatTextView.font = sysFontWithSize(14);
        _chatTextView.textColor = [UIColor whiteColor];
        _chatTextView.clearsOnInsertion = YES;
        
        _chatTextView.delegate = self;
        _chatTextView.returnKeyType = UIReturnKeySend;
        [_inputView addSubview:_chatTextView];
        
        _chatTextView.inputAccessoryView = _inputView;
        
        _placeHolder = [[UILabel alloc] init];
        _placeHolder.frame = CGRectMake(4, 4, CGRectGetWidth(_chatTextView.frame), 22);
        _placeHolder.textColor = [UIColor colorWithWhite:0.7 alpha:1];
        _placeHolder.textAlignment = NSTextAlignmentLeft;
        
        [_chatTextView addSubview:_placeHolder];
        _placeHolder.text = Localized(@"JXLiveVC_ChatPlaceHolder");
        
        
        
        _barrageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _barrageButton.frame = CGRectMake(5, 5, 50, 34);
//        _barrageButton.layer.cornerRadius = 17;
//        _barrageButton.layer.masksToBounds = YES;
        [_barrageButton setBackgroundColor:[UIColor clearColor]];
        [_barrageButton setTintColor:[UIColor whiteColor]];
        [_barrageButton setTitle:Localized(@"JXLiveVC_Barrage") forState:UIControlStateNormal];
        [_barrageButton addTarget:self action:@selector(barrageSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        [_inputView addSubview:_barrageButton];
        
//        _barrageSwitch = [[UISwitch alloc] init];
//        _barrageSwitch.frame = CGRectMake(0, 5, 0, 0);
////        _barrageSwitch.thumbTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ddddddd"]];
//        [_barrageSwitch addTarget:self action:@selector(barrageSwitchAction:) forControlEvents:UIControlEventValueChanged];
//        [_inputView addSubview:_barrageSwitch];
    }
    return _inputView;
}





#pragma mark - userId查找成员
-(WH_JXLiveMem_WHObject *)memArrayObjectWithUserId:(NSString *)userID{
    for (WH_JXLiveMem_WHObject * mem in _membersArray) {
        if ([mem.userId integerValue] == [userID integerValue]) {
            return mem;
        }
    }
    return nil;
}

#pragma mark - UICollectionView delegate
#pragma 多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma 多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _membersArray.count;
}
#pragma 每一个的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(35, 35);
}
#pragma 每一个边缘留白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
#pragma 最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}
#pragma 最小竖间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}
#pragma 返回每个单元格是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma 创建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    WH_JXLiveMember_WHCell *cell;
    
    if (collectionView == _membListCollection) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WH_JXLiveMember_WHCell class]) forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        [cell setLiveMemberCelldata:_membersArray[indexPath.item]];
        
        return cell;
    }
    return cell;
}
#pragma 点击单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_selected == false) {   //防多次快速点击cell
        _selected = true;
        //点击过一次之后。5秒再让cell点击可以响应
        [self performSelector:@selector(changeDidSelect) withObject:nil afterDelay:0.5];
        
        [self showMemDetail:_membersArray[indexPath.item]];
    }
}



#pragma mark - 聊天tableView delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _chatMsgArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WH_JXLiveChat_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WH_JXLiveChat_WHCell class]) forIndexPath:indexPath];
    [cell setLiveChatCellData:_chatMsgArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JXMessageObject *obj = _chatMsgArray[indexPath.row];
    NSString * nameStr = [NSString stringWithFormat:@"%@ :",obj.fromUserName];
    CGSize size = [nameStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: sysFontWithSize(13)} context:nil].size;
    
    size = [obj.content boundingRectWithSize:CGSizeMake((JX_SCREEN_WIDTH - size.width - 15 - 110), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: sysFontWithSize(13)} context:nil].size;
    
    return size.height + 10;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    tableView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tableView.userInteractionEnabled = YES;
    });
    WH_JXMessageObject* p = _chatMsgArray[indexPath.row];
    if (![p isRoomControlMsg]) {
        WH_JXLiveMem_WHObject * mem = [[WH_JXLiveMem_WHObject alloc] init];
        mem.userId = p.fromUserId;
        [self showMemDetail:mem];
    }
    
}


#pragma mark - textView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _editing = YES;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    _editing = NO;
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        BOOL finish = NO;
        if (textView.text.length > 0) {
            finish = [self sendIt:textView.text];
        }
        if (finish) {
            _chatTextView.text = @"";
            [textView resignFirstResponder];
        }
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length <= 0) {
//        self.placeHolder = _placeHolderStr;
        _placeHolder.hidden = NO;
    }else {
//        self.placeHolder = nil;
        _placeHolder.hidden = YES;
    }
}

#pragma mark - 详情页 Delegate
-(void)memDetailViewDelegate:(WH_JXLiveMem_WHObject *)memData actionType:(JXLiveMemDetailActionType)type{
    _currentMember = memData;
    
    switch (type) {
        case JXLiveMemDetailActionTypeClose:
            [_memDetailView removeFromSuperview];
            break;
        case JXLiveMemDetailActionTypeHisPage:{
            WH_JXUserInfo_WHVC* userVC = [WH_JXUserInfo_WHVC alloc];
            userVC.wh_userId = memData.userId;
            userVC.wh_fromAddType = 6;
            userVC = [userVC init];
            //        [g_window addSubview:userVC.view];
            [g_navigation pushViewController:userVC animated:YES];
        }
            
//            [g_server getUser:memData.userId toView:self];
//            [_memDetailView removeFromSuperview];
            break;
            
        case JXLiveMemDetailActionTypeSetManager:{
            int type = [memData.type intValue] == 3 ? 2 : 3;
            [g_server liveRoomSetManager:memData.userId liveRoomId:_wh_liveRoomId type:type toView:self];
        }
            break;
            
        case JXLiveMemDetailActionTypeKick:
            [g_server liveRoomKickMember:memData.userId liveRoomId:_wh_liveRoomId toView:self];
            break;
            
        case JXLiveMemDetailActionTypeShutUp:{
            NSInteger shutUpState = [memData.state integerValue];
            shutUpState = shutUpState == 1 ? 0 : 1;
            
            [g_server liveRoomShutUPMember:memData.userId liveRoomId:_wh_liveRoomId state:shutUpState toView:self];
            break;
        }
        default:
            break;
    }
}

-(void)memDetailViewUpdateRoom:(NSString *)roomName notice:(NSString *)notice{
    __weak typeof(self) weakSelf = self;
    self.actionAfterRequestBlock = ^(id sender) {
        weakSelf.name = roomName;
        weakSelf.notice = notice;
        weakSelf.titleLabel.text = roomName;
    };
    [g_server updateLiveRoom:_wh_liveRoomId nickName:nil name:roomName notice:notice toView:self];
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2000){
        if (buttonIndex == 1) {
            [self rechargeButtonAction];
        }
    }
}
#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2457) {
        [self quitLiveRoom];
    }
}


#pragma mark - RechargeDelegate
-(void)rechargeSuccessed{
    
}
#pragma mark - UIGestureRecognizer Delegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.view == _bgScrollView  && !_editing && !_isGiftViewShow) {
        CGPoint touchPoint = [gestureRecognizer locationInView:_bgScrollView];
        BOOL isContaint = CGRectContainsPoint(_topBar.frame, touchPoint);
        if (isContaint) {return NO;}
        isContaint = CGRectContainsPoint(_chatTableView.frame, touchPoint);
        if (isContaint) {return NO;}
    }
    return YES;
}

#pragma mark - 数据请求代理
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_liveRoomMemberList] ){
        [_membersSet removeAllObjects];
        NSMutableArray * tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dataDict in array1) {
            WH_JXLiveMem_WHObject * mem = [WH_JXLiveMem_WHObject liveMemObjectWith:dataDict];
            if ([mem.userId intValue] == [self.userId intValue]) {
                _anchorMember = mem;
                if ([mem.userId isEqualToString:g_myself.userId]){
                    _myMember = mem;
                }
            }else{
                if ([mem.userId isEqualToString:g_myself.userId]) {
                    _myMember = mem;
                }
                [tempArray addObject:mem];
            }
            [_membersSet addObject:mem.userId];
        }
        _membersArray = tempArray;
        [_membListCollection reloadData];
        [self refreshCountLabel];
    }else if ([aDownload.action isEqualToString:act_liveRoomGiftList]){
        
        NSMutableDictionary * giftNameDict = [[NSMutableDictionary alloc] init];
        NSMutableArray * giftArray = [[NSMutableArray alloc] init];
        for (NSDictionary * giftDict in array1) {
            if (giftDict[@"name"] != nil && giftDict[@"giftId"] != nil) {
//                [giftNameDict setObject:giftDict[@"name"] forKey:giftDict[@"giftId"]];
                WH_JXLiveGift_WHObject * giftObj = [WH_JXLiveGift_WHObject liveGiftObjectWith:giftDict];
                [giftNameDict setObject:giftObj forKey:giftDict[@"giftId"]];
                [giftArray addObject:giftObj];
            }
        }
        _giftNameDict = giftNameDict;
        _giftArray = (NSArray *)giftArray;
        
    }else if ([aDownload.action isEqualToString:act_liveRoomGetMember]) {
        //收到加入消息
        if (dict == nil)
            return;
        WH_JXLiveMem_WHObject * mem = [WH_JXLiveMem_WHObject liveMemObjectWith:dict];
        if ([mem.userId intValue] == [self.userId intValue]) {
            _anchorMember = mem;
            [_membersSet addObject:mem.userId];
            NSLog(@"主播来了");
        }else{
            NSUInteger index = [_membersArray indexOfObject:_currentMember];
            if (index != NSNotFound) {
                [_membersArray replaceObjectAtIndex:index withObject:mem];
            }
        }
        
        if (_memDetailView) {
//            [_memDetailView updateShow];
            [_memDetailView removeFromSuperview];
            [self showMemDetail:mem];
        }
    }else if ([aDownload.action isEqualToString:act_liveRoomBarrage]){
        g_App.myMoney -= BARRAGE_PRICE;
        //        [g_server WH_getUserMoenyToView:self];
    }else if ([aDownload.action isEqualToString:wh_act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
    }
    
    else if ([aDownload.action isEqualToString:act_liveRoomGive]){
        NSString * giftIdStr = dict[@"giftId"];
        if(giftIdStr){
            WH_JXLiveGift_WHObject * giftObj = _giftNameDict[giftIdStr];
            g_App.myMoney -= [giftObj.price doubleValue];
             [self showGiftAnimate:g_myself.userId giftId:giftIdStr fromUserName:g_myself.userNickname];
        }
        
    }else if ([aDownload.action isEqualToString:act_liveRoomSetManager]) {
        NSInteger shutUpState = [_currentMember.type integerValue];
        shutUpState = shutUpState == 3 ? 2 : 3;
        _currentMember.type = [NSNumber numberWithInteger:shutUpState];
        
        if ([_currentMember.type intValue] == 2) {
            [g_server showMsg:Localized(@"WaHu_JXRoomMember_WaHuVC_SetAdministratorSuccess")];
            _memDetailView.wh_managerButton.selected = YES;
        }else {
            [g_server showMsg:Localized(@"WaHu_JXRoomMember_WaHuVC_CancelAdministratorSuccess")];
            _memDetailView.wh_managerButton.selected = NO;
        }
        NSInteger index;
        for (WH_JXLiveMem_WHObject *mem in _membersArray) {
            if ([mem.userId isEqualToString:_currentMember.userId]) {
                index = [_membersArray indexOfObject:mem];
            }
        }
        [_membersArray replaceObjectAtIndex:index withObject:_currentMember];
        _memDetailView.memData = _currentMember;
//        [_memDetailView updateShow];
    }else if ([aDownload.action isEqualToString:act_liveRoomShutUP]) {
        NSInteger shutUpState = [_currentMember.state integerValue];
        shutUpState = shutUpState == 1 ? 0 : 1;
        _currentMember.state = [NSNumber numberWithInteger:shutUpState];
        [_memDetailView updateShow];
    }else if ([aDownload.action isEqualToString:act_liveRoomKick]) {
        [_memDetailView removeFromSuperview];
        [g_server showMsg:Localized(@"JXLiveVC_KickSuccess")];
    }else if ([aDownload.action isEqualToString:act_liveRoomPraise]) {
        
    }else if ([aDownload.action isEqualToString:act_liveRoomUpdate]) {
        if (self.actionAfterRequestBlock) {
            self.actionAfterRequestBlock(nil);
        }
    }
    else if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* userVC = [WH_JXUserInfo_WHVC alloc];
        userVC.wh_user = user;
        userVC.wh_fromAddType = 6;
        userVC = [userVC init];
//        [g_window addSubview:userVC.view];
        [g_navigation pushViewController:userVC animated:YES];
    }
    
    if ([aDownload.action isEqualToString:act_liveRoomQuit]) {
        
        [g_notify postNotificationName:kLiveListRefresh_WHNotification object:nil];
    }
}
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_liveRoomBarrage]){
        [g_server WH_getUserMoenyToView:self];
    }else if ([aDownload.action isEqualToString:act_liveRoomGive]){
        [g_server WH_getUserMoenyToView:self];
    }else if ([aDownload.action isEqualToString:act_liveRoomUpdate]) {
        self.actionAfterRequestBlock = nil;
    }
    
    return WH_show_error;
}
#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}
#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    if ([aDownload.action isEqualToString:act_liveRoomBarrage]){
    }else if ([aDownload.action isEqualToString:act_liveRoomPraise]) {
    }else if ([aDownload.action isEqualToString:act_liveRoomGive]){
    }else{
        [_wait start];
    }
}




#pragma mark - button事件

-(void)commentButtonAction:(UIButton *)button{
    [g_window addSubview:self.inputView];
    [_chatTextView becomeFirstResponder];
}

-(void)barrageSwitchAction:(UIButton *)barrButton{
    barrButton.selected = !barrButton.selected;
    if (barrButton.selected) {
//        _placeHolder.text = @"开启大喇叭,1钻石/条";
        _placeHolder.text = Localized(@"JXLiveVC_BarragePlaceHolder");
    }else{
        _placeHolder.text = Localized(@"JXLiveVC_ChatPlaceHolder");
    }
    
}
-(void)bgSCrollViewTapAction:(UIGestureRecognizer *)ges{
    if (_editing){
        [self endChatEdit];
    }
    
    else if (!_editing && !_isGiftViewShow) {
//        [self sendPraise];
    }else if (_isGiftViewShow){
//        [self hiddenSelGiftView];
    }
}
-(void)anchorDidTouchAction{
    if(!_anchorMember){
        _anchorMember = [[WH_JXLiveMem_WHObject alloc] init];
        _anchorMember.userId = self.userId;
    }
    [self showMemDetail:_anchorMember];
}

-(void)endChatEdit{
    [_chatTextView resignFirstResponder];
}



#pragma mark - Actions
-(void)quitLiveRoom{
    [g_server quitLiveRoom:_wh_liveRoomId toView:self];
    _chatRoom.delegate = self;
    [_chatRoom.xmppRoom leaveRoom];
    memberData * member = [[memberData alloc] init];
    member.userId = [g_myself.userId integerValue];
    [_chatRoom removeUser:member];
    _chatRoom.delegate = nil;
    [_chatTextView resignFirstResponder];
    [self performSelector:@selector(afterDelaySetLiveJidNil:) withObject:_wh_jid afterDelay:30.0f];
    [self actionQuit];
}

-(void)afterDelaySetLiveJidNil:(NSString *)liveJid{
    if (_wh_jid) {
        [[WH_JXLiveJid_WHManager shareArray] remove:_wh_jid];
    }
    [self actionQuit];
//    _pSelf = nil;
}

-(void)changeDidSelect{
    _selected = false;
}
-(void)setWh_jid:(NSString *)jid{
    _wh_jid = jid;
    if (_wh_jid) {
        [[WH_JXLiveJid_WHManager shareArray] add:_wh_jid];
    }
}
-(void)joinChatRoom{
    if(g_xmpp.isLogined != 1){
        // 掉线后点击title重连
        // 判断XMPP是否在线  不在线重连
        [g_xmpp showXmppOfflineAlert];
        return;
    }
//    if (_jid) {
//        [[WH_JXLiveJid_WHManager shareArray] add:_jid];
//    }
    
    WH_JXRoomObject* room = [[JXXMPP sharedInstance].roomPool getRoom:_wh_jid];
    BOOL isNewRoom = NO;
    if (!room) {
        isNewRoom = YES;
    }else{
        isNewRoom = NO;
    }
    _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:_wh_jid title:@"" isNew:isNewRoom];
    
    if(_chatRoom.isConnected){
        [self showWelcomeMsg];
//        NSLog(@"showWelcomeMsg_isconnect");
        _chatRoom.delegate = self;
        [_chatRoom joinRoom:YES];
    }else{
        _chatRoom.delegate = self;
        [_chatRoom joinRoom:YES];
    }
}
-(void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    [self showWelcomeMsg];
//    NSLog(@"showWelcomeMsg_xmppRoomDidJoin");
}

-(void)WH_show_WHOneMsg:(WH_JXMessageObject*)msg{
    for(int i=0;i<[_chatMsgArray count];i++){
        WH_JXMessageObject* p = (WH_JXMessageObject*)[_chatMsgArray objectAtIndex:i];
        if([p.messageId isEqualToString:msg.messageId])
            return;
        p = nil;
    }
    
    [_chatMsgArray addObject:msg];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_chatMsgArray count]-1 inSection:0];
    [indexPaths addObject:indexPath];
    
    
    [_chatTableView beginUpdates];
    [_chatTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_chatTableView endUpdates];
    [self gotoLatestRow];
}
-(void)gotoLatestRow{
    if (!_stopSlide) {
        [_chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatMsgArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
-(void)showWelcomeMsg{
    WH_JXMessageObject * welcome = [[WH_JXMessageObject alloc]init];
    welcome.timeSend     = [NSDate date];
//    welcome.fromUserId   = ROOM_CENTER_USERID;
    welcome.fromUserName = Localized(@"JXLiveVC_SystemMessage");
    welcome.toUserId = _wh_jid;
    welcome.isGroup = YES;
    welcome.content      = Localized(@"JXLiveVC_Welcome");
    welcome.type         = [NSNumber numberWithInt:kWCMessageTypeText];
    [welcome setMsgId];
    [self WH_show_WHOneMsg:welcome];
    
}
-(void)refreshCountLabel{
    _count = _membersArray.count;
    _countLabel.text = [NSString stringWithFormat:@"%ld%@",_count,Localized(@"JXLiveVC_countPeople")];
}
-(BOOL)sendIt:(NSString *)textStr{
    if (_barrageButton.selected) {
        //发弹幕
        [self sendBarrage:textStr];
    }else{
        if ([_myMember.state integerValue] == 1) {
            [g_App showAlert:Localized(@"JXLiveVC_GagToBarrage")];
            return NO;
        }
        
        //发普通聊天
        WH_JXMessageObject * msg = [[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        msg.fromUserName = g_myself.userNickname;
        msg.toUserId = _wh_jid;
        msg.isGroup = YES;
        msg.content      = textStr;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeText];
        [msg setMsgId];
        [self WH_show_WHOneMsg:msg];
        [g_xmpp sendMessage:msg roomName:_wh_jid];
    }
    return YES;
}

-(void)sendBarrage:(NSString *)textStr{
    if (g_App.myMoney >= BARRAGE_PRICE){
        [g_server liveRoomBarrage:textStr roomId:_wh_liveRoomId toView:self];
    }else{
        [g_App showAlert:Localized(@"JX_NotEnough") delegate:self tag:2000 onlyConfirm:NO];
    }
}

-(void)showMemDetail:(WH_JXLiveMem_WHObject *)memData{
    if (!memData) {
        return;
    }
    if (memData.userId.length <= 5) {
        return;
    }
    _currentMember = memData;
    if (!memData.roomId) {
        [g_server getLiveRoomMember:memData.userId liveRoomId:_wh_liveRoomId toView:self];
    }
    
    _memDetailView = [WH_JXLiveMemDetail_WHView memDetailView:memData myType:[_myMember.type integerValue] garyBg:YES frame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    _memDetailView.delegate = self;
    if ([memData.type integerValue] == 1) {//点了主播头像显示直播间公告
        [_memDetailView setRoomName:_name];
        [_memDetailView setNotice:_notice];
    }
    [self.view addSubview:_memDetailView];
}

-(void)rechargeButtonAction{
    WH_JXRecharge_WHViewController * rechargeVC = [[WH_JXRecharge_WHViewController alloc]init];
    rechargeVC.rechargeDelegate = self;
//    [g_window addSubview:rechargeVC.view];
    [g_navigation pushViewController:rechargeVC animated:YES];
}

#pragma mark - 通知事件

-(void)keyboardWillHidden:(NSNotification *)notification
{
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _inputView.frame = CGRectMake(0, frame.origin.y+10, JX_SCREEN_WIDTH, 50);
    
}

#pragma 接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    WH_JXMessageObject *msg = (WH_JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    if(!msg.isVisible)
        return;
    if ([msg.toUserId isEqualToString:self.wh_jid]) {
        if ([msg.type intValue] == kWCMessageTypeText) {//是普通消息
            [self WH_show_WHOneMsg:msg];
        }else if ([msg.type intValue] == kWCMessageTypeRemind) {//是提醒
            if ([msg.content isKindOfClass:[NSString class]] && msg.content.length >0) {
                if([msg.fromUserId intValue]<10100 && [msg.fromUserId intValue]>=10000){
                    msg.fromUserName = Localized(@"JXLiveVC_SystemMessage");
                }
                [self WH_show_WHOneMsg:msg];
            }
        }
    }
}

-(void)receiveRoomNotification:(NSNotification *)notifacation{
    WH_JXRoomRemind *remind = (WH_JXRoomRemind *)notifacation.object;
    //直播间通知消息
    if ([remind.objectId isEqualToString:self.wh_jid]) {
        switch ([remind.type intValue]) {
            case kRoomRemind_LiveBarrage:{
                //显示到聊天列表里
                //[self WH_show_WHOneMsg:remind];
                //弹幕区滚动
                [_barrageView showNewBarrage:remind.content];
                break;
            }
            case kRoomRemind_LiveGift:{
                [self showGiftRemind:remind];
                break;
            }
            case kRoomRemind_LivePraise:{
                [self showLove];
                break;
            }
            case kRoomRemind_AddMember:{
                break;
            }
            case kRoomRemind_EnterLiveRoom:{
                [self newUserComeInRemind:remind];
                break;
            }
            case kLiveRemind_ExitRoom:{
                [self userQuitRemind:remind];
                break;
            }
            case kLiveRemind_SetManager:{
                [self setManageRemind:remind];
                break;
            }
            case kLiveRemind_ShatUp:{
                [self disableSayRemind:remind];
                break;
            }
            default:
                break;
        }
        
    }
}

#pragma mark - 消息处理
-(void)showLove{
    //显示一个爱心
    int heartSize = 36;
    DMHeartFlyView* heart = [[DMHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, heartSize, heartSize)];
    [_heartView addSubview:heart];
    CGPoint fountainSource = CGPointMake(40, CGRectGetHeight(_heartView.frame));
    heart.center = fountainSource;
    [heart animateInView:_heartView];
    
}
-(void)showGiftRemind:(WH_JXRoomRemind *)remind{
    if ([remind.userId integerValue] != [g_myself.userId integerValue]) {
        [self showGiftAnimate:remind.userId giftId:remind.content fromUserName:remind.fromUserName];
    }
}
-(void)showGiftAnimate:(NSString *)userId giftId:(NSString *)giftId fromUserName:(NSString *)fromUserName{

    WH_JXLiveGift_WHObject * giftObj = _giftNameDict[giftId];
    GiftModel *giftModel = [[GiftModel alloc] init];
    giftModel.headImage = [UIImage imageNamed:@"avatar_normal"];
    giftModel.name = fromUserName;
//    giftModel.giftImage = image;
    giftModel.giftName = giftObj.wh_name;
    giftModel.giftCount = 1;
    
    NSString * giftViewIdentfy = [NSString stringWithFormat:@"%@_%@",userId,giftId];

    WH_AnimOperationManager *manager = [WH_AnimOperationManager sharedManager];
    manager.parentView = self.view;
    
    
    SDWebImageManager *shareManager = [SDWebImageManager sharedManager];
    NSString* dir  = [NSString stringWithFormat:@"%d",[userId intValue] % 10000];
    NSString* headUrl  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,userId];
    
    [shareManager cachedImageExistsForURL:[NSURL URLWithString:headUrl] completion:^(BOOL isInCache) {
        if (!isInCache) {//没有缓存
            giftModel.headImage = [UIImage imageNamed:@"avatar_normal"];
            [shareManager loadImageWithURL:[NSURL URLWithString:headUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (image != nil){
                    giftModel.headImage = image;
                }
            }];
        }else{
            giftModel.headImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:headUrl];
        }

    }];
    [shareManager cachedImageExistsForURL:[NSURL URLWithString:giftObj.wh_photo] completion:^(BOOL isInCache) {
        if (!isInCache) {//没有缓存
            giftModel.headImage = [UIImage imageNamed:@"avatar_normal"];
            [shareManager loadImageWithURL:[NSURL URLWithString:giftObj.wh_photo] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (image != nil){
                    giftModel.giftImage = image;
                    [manager animWithUserID:giftViewIdentfy model:giftModel finishedBlock:^(BOOL result) {}];
                }
            }];
        }else{
            giftModel.giftImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:giftObj.wh_photo];
            [manager animWithUserID:giftViewIdentfy model:giftModel finishedBlock:^(BOOL result) {}];
        }
        
    }];

    
    [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
}

-(void)newUserComeInRemind:(WH_JXRoomRemind *)remind{
    if ([remind.toUserId integerValue] != [g_myself.userId integerValue] ) {
        WH_JXLiveMem_WHObject * mem = [[WH_JXLiveMem_WHObject alloc] init];
        mem.userId = remind.toUserId;
        if ([mem.userId intValue] == [self.userId intValue]) {
            _anchorMember = mem;
            [_membersSet addObject:mem.userId];
            NSLog(@"主播来了");
            return;
        }
        if ([mem.userId isEqualToString:g_myself.userId]){
            //            _myMember = mem;
            return;
        }
        if (![_membersSet containsObject:mem.userId]) {
            [_membersSet addObject:mem.userId];
            [_membersArray addObject:mem];
            if (_membersArray.count > 1) {
                NSIndexPath *indePath = [NSIndexPath indexPathForItem:_membersArray.count-1 inSection:0];
                [_membListCollection insertItemsAtIndexPaths:@[indePath]];
            }else {
                [_membListCollection reloadData];
            }
            [self refreshCountLabel];
        }
    }
}
-(void)userQuitRemind:(WH_JXRoomRemind *)remind{
    
    if ([remind.toUserId intValue] == [self.userId intValue]) {
        NSLog(@"主播走了");
        [g_App showAlert:Localized(@"JX_TheAnchorHasStoppedBroadcasting") delegate:self tag:2457 onlyConfirm:YES];
        return;
    }
    if([remind.toUserId intValue] == [_myMember.userId intValue]){
        //        //自己被踢出房间
        [g_App showAlert:Localized(@"JXLiveVC_AlreadyKickOutRoom")];
        [self performSelector:@selector(quitLiveRoom) withObject:nil afterDelay:1.5f];
        return;
    }
    
    [_membersSet removeObject:remind.toUserId];
    WH_JXLiveMem_WHObject * mem = [self memArrayObjectWithUserId:remind.toUserId];
    if (mem == nil)
        return;
    NSUInteger index = [_membersArray indexOfObject:mem];
    if (index == NSNotFound)
        return;
    
    [_membersArray removeObject:mem];
    NSIndexPath * indexpath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [_membListCollection deleteItemsAtIndexPaths:@[indexpath]];
    [self refreshCountLabel];
}
-(void)setManageRemind:(WH_JXRoomRemind *)remind{
    //    "content":1,"fromUserId":"10005","fromUserName":"10005","objectId":"44b7c6c507f94980ae3cff976cb29741","timeSend":1501899401,"toUserId":"10007882","toUserName":"acup","type":913
    WH_JXLiveMem_WHObject * mem = [self memArrayObjectWithUserId:remind.toUserId];
    if (mem == nil)
        return;
    if ([mem.userId isEqualToString:MY_USER_ID]) {
        mem.type = [NSNumber numberWithInteger:[mem.type intValue] == 3 ? 2 : 3];
        _myMember.type = mem.type;
    }
}
-(void)disableSayRemind:(WH_JXRoomRemind *)remind{
    WH_JXLiveMem_WHObject * mem = [self memArrayObjectWithUserId:remind.toUserId];
    if (mem == nil)
        return;
    if ([remind.content longLongValue] > 0) {
        mem.state = [NSNumber numberWithInteger:1];
    }else{
        mem.state = [NSNumber numberWithInteger:0];
    }
    //    if ([mem.userId integerValue] == [g_myself.userId integerValue]) {
    //
    //    }
}



@end
