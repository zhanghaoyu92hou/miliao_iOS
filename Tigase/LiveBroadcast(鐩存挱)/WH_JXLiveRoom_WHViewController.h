//
//  WH_JXLiveRoom_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/8/5.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

//#import <IJKMediaFramework/IJKMediaFramework.h>
#import "WH_JXLiveJid_WHManager.h"
#import "WH_JXLiveMember_WHCell.h"
#import "WH_JXLiveChat_WHCell.h"
#import "WH_BulletGroupView.h"
#import "DMHeartFlyView.h"

#import "WH_JXLiveMemDetail_WHView.h"
#import "WH_JXLiveMem_WHObject.h"
#import "WH_JXLiveGift_WHObject.h"

#import "WH_JXRoomObject.h"
#import "WH_JXRoomPool.h"
#import "WH_JXRoomRemind.h"

#import "PresentView.h"
#import "GiftModel.h"
#import "WH_AnimOperationManager.h"

#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXRecharge_WHViewController.h"

#define BARRAGE_PRICE 1.0

@interface WH_JXLiveRoom_WHViewController : WH_admob_WHViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate,JXLiveMemDetailDelegate,UIGestureRecognizerDelegate,RechargeDelegate>{
    BOOL _selected; //cell点击延时,防止多次快速点击
    BOOL _stopSlide; //是否停止自动刷新到最后一行
    BOOL _editing;  //是否正在输入,键盘弹出
    BOOL _isGiftViewShow;  //是否正在显示选择礼物界面
    WH_JXRoomObject *_chatRoom;
    WH_JXLiveMem_WHObject * _anchorMember;//主播
    WH_JXLiveMem_WHObject * _myMember;//我
    WH_JXLiveMem_WHObject * _currentMember;//操作的成员
    NSMutableSet * _membersSet;
}



@property (nonatomic, strong)NSString * wh_liveUrl;
@property (nonatomic, strong)NSString * wh_imageUrl;
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * nickName;
@property (nonatomic, copy) NSString * notice;
@property (nonatomic, copy) NSString * wh_jid;
@property (nonatomic, copy) NSString * wh_liveRoomId;
@property (nonatomic, assign) long count;

@property (nonatomic, copy) void (^actionAfterRequestBlock)(id sender);

/**
 直播间成员列表
 */
@property (nonatomic, strong) NSMutableArray * membersArray;
/**
 聊天消息列表
 */
@property (nonatomic, strong) NSMutableArray * chatMsgArray;

///**
// 弹幕列表
// */
//@property (nonatomic, strong) NSMutableArray * barrageArray;
/**
 礼物列表
 */
@property (nonatomic, strong) NSArray * giftArray;
@property (nonatomic, strong) NSMutableDictionary * giftNameDict;

//@property (atomic, retain) id <IJKMediaPlayback> player;
//@property (weak, nonatomic) UIView *displayView;
//@property (atomic, strong) NSURL *url;

/**
 顶部bar
 */
@property (nonatomic, strong) UIView * topBar;

/**
 中下可滑隐藏bg
 */
//@property (nonatomic, strong) UIControl * bgControl;
@property (nonatomic, strong) UIScrollView * bgScrollView;

/**
 房间主播简要信息bg
 */
@property (nonatomic, strong) UIView * anchorHead;

/**
 左上角房间简要信息
 */
@property (nonatomic, strong) WH_JXImageView * anchorHeadImgView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * countLabel;

/**
 右侧直播间成员列表
 */
@property (nonatomic, strong) UICollectionView * membListCollection;

/**
 关闭button
 */
@property (nonatomic, strong) UIButton * closeButton;
/**
 弹幕区
 */
@property (nonatomic, strong) WH_BulletGroupView * barrageView;

///**
// 聊天区
// */
//@property (nonatomic, strong) UIView * chatView;

/**
 聊天列表
 */
@property (nonatomic, strong) UITableView * chatTableView;

///**
// 礼物展示区
// */
//@property (nonatomic, strong) UIView * giftView;

/**
 爱心展示区
 */
@property (nonatomic, strong) UIView * heartView;

/**
 下方按钮工具条
 */
@property (nonatomic, strong) UIView * toolBar;

@property (nonatomic, strong)  UIButton *commentBtn;
//@property (nonatomic, strong)  UIButton *giftBtn;
//@property (nonatomic, strong)  UIButton *heartBtn;

///**
// 礼物选择
// */
//@property (nonatomic, strong) WH_ChooseGiftView * selGiftView;

/**
 输入条
 */
@property (nonatomic, strong) UIView * inputView;
@property (nonatomic, strong) UIButton * barrageButton;
@property (nonatomic, strong) UISwitch * barrageSwitch;
@property (nonatomic, strong) UITextView * chatTextView;
@property (nonatomic, strong) UILabel * placeHolder;
/**
 点头像出来的成员管理view
 */
@property (nonatomic, strong) WH_JXLiveMemDetail_WHView *memDetailView;





/**
 设置直播视频,子类重写
 */
-(void)settingLive;

-(void)quitLiveRoom;

-(void)bgSCrollViewTapAction:(UIGestureRecognizer *)ges;

@end
