//
//  AddressBookFriendModel.h
//  Tigase
//
//  Created by 政委 on 2020/6/3.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddressBookFriendModel : NSObject

@property(nonatomic, copy) NSString *remarkName;
@property(nonatomic, copy) NSString *toNickname;
@property(nonatomic, copy) NSString *toUserId;
@property(nonatomic, copy) NSString *userNickname;


@end

NS_ASSUME_NONNULL_END
