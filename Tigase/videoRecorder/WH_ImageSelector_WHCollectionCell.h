//
//  WH_ImageSelector_WHCollectionCell.h
//  Tigase_imChatT
//
//  Created by 1 on 17/1/20.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_ImageSelector_WHCollectionCell : UICollectionViewCell{
    NSInteger indexpath;
    WH_JXImageView* _yellow;
}
@property (nonatomic,assign,setter=setIndex:) long index;
@property (nonatomic,assign,setter=setIsSelected:) BOOL isSelected;
@property (nonatomic,assign,setter=setDelegate:) id        delegate;
@property (nonatomic,strong) WH_JXImageView * wh_imageView;
@property (nonatomic,strong) WH_JXImageView * wh_selectView;
@property (nonatomic, assign) SEL		didImageView;
@property (nonatomic, assign) SEL		didSelectView;

-(void)refreshCellWithImagePath:(NSString *)imagePath;




@end
