//
//  WWEmotManagerCell.h
//  WaHu
//
//  Created by Apple on 2019/3/5.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WWEmotManagerCell : UICollectionViewCell


@property (nonatomic, strong) NSDictionary * dataDic;

@property (weak, nonatomic) IBOutlet UIButton *choseBtn;


@end

NS_ASSUME_NONNULL_END
