//
//  WH_JXShareFile_WHTableViewCell.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/6.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXShareFileObject;

@interface WH_JXShareFile_WHTableViewCell : UITableViewCell


@property (strong, nonatomic) UIImageView * typeView;
@property (strong, nonatomic) UILabel * fileTitleLabel;
@property (strong, nonatomic) UILabel * sizeLabel;
@property (strong, nonatomic) UILabel * fromLabel;
@property (strong, nonatomic) JXLabel * fromUserLabel;
@property (strong, nonatomic) UILabel * timeLabel;
@property (strong, nonatomic) UIImageView * didDownView;
@property (strong, nonatomic) UIProgressView * progressView;
@property (strong, nonatomic) UIButton * downloadStateBtn;

@property (strong, nonatomic) WH_JXShareFileObject *shareFile;

-(void)setShareWH_FileList_WHCellWith:(WH_JXShareFileObject *)shareFileObjcet indexPath:(NSIndexPath *) indexPath;


@end
