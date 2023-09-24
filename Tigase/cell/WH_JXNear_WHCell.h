//
//  JXExpertCell.h
//  Tigase_imChatT
//
//  Created by MacZ on 2016/10/20.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXNear_WHCell : UICollectionViewCell

@property(nonatomic,assign) int fnId;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL didTouch;

- (void)doRefreshNearExpert:(NSDictionary *)dict;


- (void)sp_checkNetWorking;
@end
