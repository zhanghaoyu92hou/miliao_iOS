//
//  MiXin_CompanyCell.h
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiXin_CompanyModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MiXin_CompanyCell : UITableViewCell

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIImageView *icon;

- (void)refresh:(MiXin_CompanyModel *)model;


@end

NS_ASSUME_NONNULL_END
