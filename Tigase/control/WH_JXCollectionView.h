//
//  WH_JXCollectionView.h
//  Tigase_imChatT
//
//  Created by MacZ on 2016/10/27.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXTableView.h"

@interface WH_JXCollectionView : UICollectionView

- (void)wh_showEmptyImage:(EmptyType)emptyType;
- (void)wh_hideEmptyImage;

@end
