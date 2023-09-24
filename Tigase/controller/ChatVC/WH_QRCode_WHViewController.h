//
//  WH_QRCode_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/7/3.
//  Copyright © 2019 Reese. All rights reserved.
//  群二维码

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, QRType) {
    QR_UserType  =   1,
    QR_GroupType =   2,
};

@interface WH_QRCode_WHViewController : UIViewController

@property (nonatomic ,strong) UIView *wh_baseView;
@property (nonatomic ,strong) UIView *wh_contentView;

@property (nonatomic, copy) NSString * wh_userId;
@property (nonatomic, assign) QRType type;

@property (nonatomic, copy) NSString * wh_nickName;
@property (nonatomic, copy) NSString * wh_roomJId;

@property (nonatomic ,strong) UIImageView *wh_qrImageView;

@property (nonatomic,copy) NSString *wh_groupNum; 

@property (nonatomic ,strong) WH_RoomData *groupRoom;

NS_ASSUME_NONNULL_END

@end
