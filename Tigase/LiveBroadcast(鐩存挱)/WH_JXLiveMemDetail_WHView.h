//
//  WH_JXLiveMemDetail_WHView.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/30.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXLiveMem_WHObject;


typedef NS_OPTIONS(NSInteger, JXLiveMemDetailActionType) {
    JXLiveMemDetailActionTypeClose      = 0,
    JXLiveMemDetailActionTypeHisPage    = 1,
    JXLiveMemDetailActionTypeSetManager = 2,
    JXLiveMemDetailActionTypeKick       = 3,
    JXLiveMemDetailActionTypeShutUp     = 4,
    JXLiveMemDetailActionTypeUpdateRoom = 5,
};

@protocol JXLiveMemDetailDelegate <NSObject>

-(void)memDetailViewDelegate:(WH_JXLiveMem_WHObject *)memData actionType:(JXLiveMemDetailActionType)type;

-(void)memDetailViewUpdateRoom:(NSString *)roomName notice:(NSString *)notice;

@end

@interface WH_JXLiveMemDetail_WHView : UIView

@property (nonatomic, weak) id<JXLiveMemDetailDelegate> delegate;
@property (nonatomic, strong) WH_JXLiveMem_WHObject * memData;
//禁言
@property (nonatomic, strong) UIButton * wh_shutUpButton;
//踢出
@property (nonatomic, strong) UIButton * wh_kickButton;
//设为管理员
@property (nonatomic, strong) UIButton * wh_managerButton;

+(instancetype)memDetailView:(WH_JXLiveMem_WHObject *)memData myType:(NSInteger)myType garyBg:(BOOL)isShowBg frame:(CGRect)frame;

-(void)updateShow;

-(void)setRoomName:(NSString *)roomName;
-(void)setNotice:(NSString *)notice;

@end
