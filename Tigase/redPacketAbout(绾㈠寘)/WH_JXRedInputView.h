//
//  WH_JXRedInputView.h
//  Tigase_imChatT
//
//  Created by 1 on 17/8/15.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXRedInputView : UIView<UITextFieldDelegate>

@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, assign) BOOL isRoom;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UIView * wh_countView;
@property (nonatomic, strong) UIView * wh_moneyView;
@property (nonatomic, strong) UIView * wh_greetView;

@property (nonatomic, strong) UIButton * wh_sendButton;
@property (nonatomic, strong) UILabel * wh_noticeTitle;


@property (nonatomic, strong) UITextField * wh_countTextField;
@property (nonatomic, strong) UITextField * wh_moneyTextField;
@property (nonatomic, strong) UITextField * wh_greetTextField;

@property (nonatomic, strong) UILabel * wh_countTitle;
@property (nonatomic, strong) UILabel * wh_moneyTitle;
@property (nonatomic, strong) UILabel * wh_greetTitle;
@property (nonatomic, strong) UILabel * wh_totalMoneyTitle;
@property (nonatomic, strong) UILabel * wh_promptTitle;

@property (nonatomic ,strong) UIView * wh_canClaimView; //谁可以领取
@property (nonatomic ,strong) UILabel *wh_canClaimTitle;
@property (nonatomic ,strong) UIButton *wh_canclaimBtn;
@property (nonatomic ,strong) UILabel *wh_canClaimPeoples;
@property (nonatomic ,strong) UIImageView *wh_canClaimMark;

@property (nonatomic ,strong) UILabel *receiveNoticeLabel;

@property (nonatomic, strong) UILabel * wh_countUnit;
@property (nonatomic, strong) UILabel * wh_moneyUnit;

@property (nonatomic ,copy) NSString *count; //群人数


-(instancetype)initWithFrame:(CGRect)frame type:(NSUInteger)type isRoom:(BOOL)isRoom delegate:(id)delegate;

-(instancetype)initWithFrame:(CGRect)frame type:(NSUInteger)type isRoom:(BOOL)isRoom roomMemebers:(NSString *)members delegate:(id)delegate;

-(void)stopEdit;


- (void)sp_checkNetWorking:(NSString *)mediaInfo;
@end
