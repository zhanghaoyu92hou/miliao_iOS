//
//  AddressBookFriendCell.h
//  Tigase
//
//  Created by 政委 on 2020/6/3.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddressBookFriendCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *remarkLabel;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

NS_ASSUME_NONNULL_END
