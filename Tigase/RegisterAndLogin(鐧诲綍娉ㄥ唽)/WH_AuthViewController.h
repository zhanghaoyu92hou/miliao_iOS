//
//  WH_AuthViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_AuthViewController : WH_admob_WHViewController
@property (nonatomic, strong) UIImage *sdkImage;
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSString *fromSchema;
@end

NS_ASSUME_NONNULL_END
