//
//  WhoCanSeeViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/11/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@protocol VisibelDelegate <NSObject>

-(void)seeVisibel:(int)visibel userArray:(NSArray *)userArray selLabelsArray:(NSMutableArray *)selLabelsArray mailListArray:(NSMutableArray *)mailListArray;

@end

@interface WhoCanSeeViewController : WH_admob_WHViewController

@property (nonatomic,weak) id<VisibelDelegate> wh_visibelDelegate;
@property (nonatomic,assign) int type;
@property (nonatomic, strong) NSMutableArray *wh_selLabelsArray;
@property (nonatomic, strong) NSMutableArray *wh_mailListUserArray;


- (void)sp_getUsersMostLikedSuccess:(NSString *)mediaCount;
@end
