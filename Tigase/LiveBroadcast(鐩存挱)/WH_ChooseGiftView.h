//
//  WH_ChooseGiftView.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/28.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXLiveGift_WHObject;

@protocol WH_ChooseGiftViewDelegate <NSObject>

-(void)WH_ChooseGiftViewDelegateGift:(WH_JXLiveGift_WHObject *)giftDict count:(NSUInteger)count;

@optional
-(void)rechargeButtonAction;

@end

@interface WH_ChooseGiftView : UIView

@property (nonatomic, strong) NSArray * wh_giftArray;

-(instancetype)initWithGiftData:(NSArray *)giftArray delegate:(id<WH_ChooseGiftViewDelegate>)delegate frame:(CGRect)frame;

-(void)setWh_giftArray:(NSArray *)giftArray;

@end
