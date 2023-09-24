//
//  WH_JXTelArea_WHCell.h
//  Tigase_imChatT
//
//  Created by YZK on 19/4/24.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXTelArea_WHCell : UITableViewCell{
    UILabel *_countryName;
    UILabel *_areaNum;
}

@property (nonatomic,strong) UIView *bottomLine;

- (void)doRefreshWith:(NSDictionary *)dict language:(NSString *)language;


- (void)sp_checkUserInfo;
@end
