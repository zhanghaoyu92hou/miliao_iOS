//
//  WH_JXUserObject+jsonModel.h
//  Tigase
//
//  Created by 齐科 on 2019/9/23.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXUserObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXUserObject (jsonModel)
- (void)objectFromDocumentDictionary:(NSDictionary *)userInfo;
- (void)objectFromServerDictionary:(NSDictionary *)userInfo;
- (NSDictionary *)objectToDictionary;
@end

NS_ASSUME_NONNULL_END
