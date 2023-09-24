//
//  ContactSelectViewController.h
//  Tigase
//
//  Created by 政委 on 2020/6/4.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddressBookFriendModel;
NS_ASSUME_NONNULL_BEGIN
typedef void (^ChooseContact)(AddressBookFriendModel *friendModel);
@interface ContactSelectViewController : UIViewController

@property (nonatomic, copy) ChooseContact contactInfo;

@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)chooseContactWihtContact:(ChooseContact)contactInfo;

@end

NS_ASSUME_NONNULL_END
