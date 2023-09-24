//
//  WH_JXQRCode_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/9/14.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

typedef NS_OPTIONS(NSUInteger, QRViewControllerType) {
    QRUserType  =   1,
    QRGroupType =   2,
};

@interface WH_JXQRCode_WHViewController : WH_admob_WHViewController

@property (nonatomic, copy) NSString * userId;
@property (nonatomic, assign) QRViewControllerType type;

@property (nonatomic, copy) NSString * nickName;
@property (nonatomic, copy) NSString * roomJId;



@end
