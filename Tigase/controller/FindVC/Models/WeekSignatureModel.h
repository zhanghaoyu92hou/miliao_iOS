//
//  7DaySignatureModel.h
//  WaHu
//
//  Created by Apple on 2019/3/6.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeekSignatureModel : NSObject
@property(strong,nonatomic) NSString *msg;
@property(assign,nonatomic) NSInteger seriesSignCount;
@property(assign,nonatomic) NSInteger sevenCount;
@property(assign,nonatomic) NSInteger signCount;
@property(assign,nonatomic) NSInteger signStatus;
@property(strong,nonatomic) NSString *signAward;
@property(assign,nonatomic) float  money;


NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostLikedSuccess;
@end
