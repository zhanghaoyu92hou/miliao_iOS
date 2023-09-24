//
//  JXExpertCell.h
//  Tigase_imChatT
//
//  Created by MacZ on 2016/10/20.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXLive_WHCell : UICollectionViewCell

@property(nonatomic,assign) int wh_fnId;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL didTouch;

@property (nonatomic,strong) UIButton *wh_btnDelete;

- (void)doRefreshNearExpert:(NSDictionary *)dict;

@end
