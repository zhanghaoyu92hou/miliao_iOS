//
//  WH_JXBaseChat_WHCell.h
//  wahu_im
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXConnection.h"
#import "WH_JXMessageObject.h"
#import "QBPopupMenuItem.h"
#import "QBPlasticPopupMenu.h"
#import "QCheckBox.h"
#import "WHProgress.h"

//#import "clockLayer.h"//时钟
@class JXEmoji;
@class WH_JXImageView;
@class JXLabel;
@class SCGIFImageView;
@class WH_JXBaseChat_WHCell;


#define kSystemImageCellWidth (kChatCellMaxWidth + INSETS * 2 + 50)

typedef enum : NSUInteger {
    CollectTypeDefult   = 0,// 默认
    CollectTypeEmoji    = 6,//表情
    CollectTypeImage    = 1,//图片
    CollectTypeVideo    = 2,//视频
    CollectTypeFile     = 3,//文件
    CollectTypeVoice    = 4,//语音
    CollectTypeText     = 5,//文本
} CollectType;

@protocol JXChatCellDelegate <NSObject>

// 长按回复
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell replyIndexNum:(int)indexNum;
// 长按删除
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell deleteIndexNum:(int)indexNum;
// 长按转发
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell RelayIndexNum:(int)indexNum;
// 长按收藏
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell favoritIndexNum:(int)indexNum type:(CollectType)collectType;
// 长按撤回
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell withdrawIndexNum:(int)indexNum;
// 开启、关闭多选
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell selectMoreIndexNum:(int)indexNum;
// 多选，选择
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell checkBoxSelectIndexNum:(int)indexNum isSelect:(BOOL)isSelect;

// 开始录制
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell startRecordIndexNum:(int)indexNum;
// 结束录制
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell stopRecordIndexNum:(int)indexNum;

// 重发消息
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell resendIndexNum:(int)indexNum;

// 获取录制状态
- (BOOL) getRecording;
// 获取开始录制num
- (NSInteger) getRecordStarNum;

@end


@interface WH_JXBaseChat_WHCell : UITableViewCell<LXActionSheetDelegate>

@property (nonatomic,strong) UIButton * bubbleBg;
@property (nonatomic,strong) WH_JXImageView * readImage;
@property (nonatomic,strong) WH_JXImageView * burnImage;
@property (nonatomic,strong) WH_JXImageView * sendFailed;
@property (nonatomic,strong) JXLabel * readView;
@property (nonatomic,strong) JXLabel * readNum;
@property (nonatomic,strong) UIActivityIndicatorView * wait;
@property (nonatomic,strong) WH_JXMessageObject * msg;
@property (nonatomic,strong) UIImageView * headImage;
@property (nonatomic,strong) UIImageView * cerImgView; // 认证图标
@property (nonatomic ,strong) UIImageView *gradeImgView; //等级图标
@property (nonatomic,strong) UILabel* timeLabel;
@property (nonatomic,strong) UILabel *nicknameLabel;
@property (nonatomic,assign) SEL didTouch;
@property (nonatomic,assign) int indexNum;
@property (nonatomic, strong) QBPlasticPopupMenu *plasticPopupMenu;
@property (nonatomic, strong) QBPopupMenu *popupMenu;
@property (nonatomic, weak) id<JXChatCellDelegate>chatCellDelegate;

@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL	  readDele;

@property (nonatomic, assign) BOOL isCourse;

@property (nonatomic, assign) BOOL isShowRecordCourse;

@property (nonatomic, assign) BOOL isShowHead;
@property (nonatomic, assign) BOOL isWithdraw;  // 是否显示撤回

@property (nonatomic, assign) BOOL isSelectMore;
@property (nonatomic, strong) QCheckBox *checkBox;

@property (nonatomic, strong) WH_RoomData *room;

@property (nonatomic,strong) WH_JXUserObject *chatPerson;
@property (nonatomic ,assign) Boolean isBanned; //是否被单人禁言
@property (nonatomic ,copy) NSString *bannedRemind; //单人禁言提示内容

@property (nonatomic, assign) double loadProgress;
@property (nonatomic, strong) NSString *fileDict;


/*******************************阅后即焚使用********************************/
@property (nonatomic, strong) NSTimer *readDelTimer;
@property (nonatomic, strong) WHProgress *whprogress;
//@property (nonatomic, strong) UILabel *bottomTitleLb;//显示多久后消息消失

//@property (nonatomic ,strong) clockLayer *clock;
//@property (nonatomic ,strong) void(^clickSettingBtnClick)();
-(void)startTimeer:(void(^)(WH_JXMessageObject *msg))block;
/*******************************阅后即焚使用********************************/


-(void)creatUI;
-(void)drawIsRead;
-(void)drawIsSend;
-(void)drawIsReceive;
- (void)drawReadPersons:(int)num;
- (void)setBackgroundImage;
- (void)setCellData;
-(void)setHeaderImage;
-(void)isShowSendTime;
//-(void)downloadFile:(WH_JXImageView*)iv;
- (void)setMaskLayer:(UIImageView *)imageView;
- (void)sendMessageToUser;
- (void)setAgreeRefuseBtnStatusAfterReply;  //回应交换电话后更新按钮状态（子类实现）
- (void)updateFileLoadProgress;
// 获取cell 高度
+ (float) getChatCellHeight:(WH_JXMessageObject *)msg;

//- (void)drawReadDelView:(BOOL)isSelected;

@end
