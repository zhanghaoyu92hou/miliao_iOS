//
//  WH_JXredPacketDetail_WHVC.h
//  Tigase_imChatT
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXPacketObject.h"
#import "WH_JXGetPacketList.h"
@interface WH_JXredPacketDetail_WHVC : WH_JXTableViewController

@property (nonatomic,strong) NSString * wh_redPacketId;//红包id
@property (nonatomic,strong) NSDictionary * wh_dataDict;//数据源
@property (nonatomic,strong) NSArray * wh_OpenMember;//打开红包的人的列表
@property (nonatomic,strong) WH_JXPacketObject * wh_packetObj;//红包对象
@property (nonatomic, assign) BOOL isGroup;  // YES 群聊  NO 单聊



/**
 头部视图
 **/
@property (strong, nonatomic) UIImageView * wh_headImgV;
@property (strong, nonatomic) UIView *wh_contentView;


/**
 头像
 */
@property (strong, nonatomic) UIImageView *wh_headerImageView;

/**
 总金额
 */
@property (strong, nonatomic) UILabel *wh_totalMoneyLabel;

/**
 来自
 */
@property (strong, nonatomic) UILabel *wh_fromUserLabel;

/**
 红包标题
 */
@property (strong, nonatomic) UILabel *wh_greetLabel;

/**
 领取个数
 */
@property (strong, nonatomic) IBOutlet UILabel *wh_showNumLabel;

/**
 红包过时
 */
@property (strong, nonatomic) UILabel * wh_returnMoneyLabel;



- (void)sp_getUsersMostFollowerSuccess;
@end
