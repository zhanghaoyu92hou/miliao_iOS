//
//  MiXin_inputPwd_MiXinVC.h
//  wahu_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_InputPwdViewController : WH_admob_WHViewController
@property (nonatomic,strong) NSString *area;
@property (nonatomic,strong) NSString* telephone;
@property (nonatomic,assign) BOOL isCompany;
@property (nonatomic, assign) BOOL resetPass; //!< 是否是重新设置
@property (nonatomic, assign) NSInteger registTYpe;

@end
