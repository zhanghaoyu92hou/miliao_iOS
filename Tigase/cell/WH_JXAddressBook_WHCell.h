//
//  WH_JXAddressBook_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2018/8/30.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCheckBox.h"
#import "JXAddressBook.h"

@class WH_JXAddressBook_WHCell;
@protocol WH_JXAddressBook_WHCellDelegate <NSObject>

- (void)addressBookCell:(WH_JXAddressBook_WHCell *)abCell checkBoxSelectIndexNum:(NSInteger)indexNum isSelect:(BOOL)isSelect;
- (void)addressBookCell:(WH_JXAddressBook_WHCell *)abCell addBtnAction:(JXAddressBook *)addressBook;

@end

@interface WH_JXAddressBook_WHCell : UITableViewCell <QCheckBoxDelegate>

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) WH_JXImageView *headImage;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *nickName;
@property (nonatomic, strong) QCheckBox *checkBox;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isShowSelect;
@property (nonatomic, weak) id<WH_JXAddressBook_WHCellDelegate>delegate;

@property (nonatomic, strong) JXAddressBook *addressBook;

@property (nonatomic, assign) BOOL isInvite;

/**
 设置分割线显示或者隐藏
 
 @param indexPath 当前cell所在索引
 */
- (void)setLineDisplayOrHidden:(NSIndexPath *)indexPath;


- (void)sp_getMediaData;
@end
