//
//  WH_JXAddressBook_WHCell.m
//  Tigase_imChatT
//
//  Created by p on 2018/8/30.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXAddressBook_WHCell.h"

@implementation WH_JXAddressBook_WHCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _headImage = [[WH_JXImageView alloc]init];
        _headImage.userInteractionEnabled = NO;
        _headImage.tag = self.index;
        _headImage.wh_delegate = self;
        _headImage.didTouch = @selector(WH_headImageDidTouch);
        _headImage.frame = CGRectMake(13,14,HEAD_SIZE,HEAD_SIZE);
        [_headImage headRadiusWithAngle:_headImage.frame.size.width * 0.5];
        //        _headImageView.layer.borderWidth = 0.5;
        _headImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:self.headImage];
        
        CGFloat lineW = g_factory.cardBorderWithd;
        UIColor *lineColor = g_factory.cardBorderColor;
        
        _topLine = [UIView new];
        [self.contentView addSubview:_topLine];
        [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.offset(0);
            make.height.offset(lineW);
        }];
        _topLine.backgroundColor = lineColor;
        _topLine.hidden = YES;
        
        _verticalLine = [UIView new];
        [self.contentView addSubview:_verticalLine];
        [_verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headImage.mas_right).offset(10);
            make.top.bottom.offset(0);
            make.width.offset(lineW);
        }];
        _verticalLine.backgroundColor = lineColor;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 64 - .5, JX_SCREEN_WIDTH, lineW)];
        line.backgroundColor = lineColor;
        [self.contentView addSubview:line];
        
        _nickName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_verticalLine.frame) + 12, 10, 300, 23)];
        _nickName.textColor = HEXCOLOR(0x323232);
        _nickName.userInteractionEnabled = NO;
        _nickName.text = @"张辉";
        _nickName.backgroundColor = [UIColor clearColor];
        _nickName.font = [UIFont systemFontOfSize:16];
        _nickName.tag = self.index;
        [self.contentView addSubview:_nickName];
        [_nickName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_verticalLine.mas_right).offset(12);
            make.top.offset(10);
            make.size.mas_equalTo(CGSizeMake(300, 23));
        }];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nickName.frame), CGRectGetMaxY(_nickName.frame) + 4, 300, 17)];
        _name.textColor = [UIColor lightGrayColor];
        _name.userInteractionEnabled = NO;
        _name.text = @"张辉";
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont systemFontOfSize:14];
        _name.tag = self.index;
        [self.contentView addSubview:_name];
        [_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nickName);
            make.top.equalTo(_nickName.mas_bottom).offset(4);
            make.size.mas_equalTo(CGSizeMake(300, 17));
            
        }];
        
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-10-56, 18, 56, 28)];
        [_addBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateDisabled];
        _addBtn.titleLabel.font = sysFontWithSize(12);
        [_addBtn setTitle:Localized(@"JX_Add") forState:UIControlStateNormal];
        [_addBtn setTitle:Localized(@"JX_AlreadyAdded") forState:UIControlStateDisabled];
        [_addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _addBtn.layer.cornerRadius = 14.f;
        _addBtn.layer.masksToBounds = YES;
        [self.contentView addSubview:_addBtn];
        
        _checkBox = [[QCheckBox alloc] initWithDelegate:self];
        _checkBox.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - 20, 22, 20, 20);
        _checkBox.delegate = self;
        [self.contentView addSubview:_checkBox];
    }
    return self;
}

- (void)setAddressBook:(JXAddressBook *)addressBook {
    _addressBook = addressBook;
    WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:addressBook.toUserId];
    if ([user.status intValue] == 2 || [user.status intValue] == -1) {
        _addBtn.enabled = NO;
        _addBtn.backgroundColor = [UIColor clearColor];
    }else {
        _addBtn.enabled = YES;
        _addBtn.backgroundColor = HEXCOLOR(0x0093FF);
    }
    if (self.isShowSelect) {
        if (_addBtn.enabled) {
            self.checkBox.hidden = NO;
        }else {
            self.checkBox.hidden = YES;
        }
        self.addBtn.hidden = YES;
//        _headImage.frame = CGRectMake(CGRectGetMaxX(self.checkBox.frame) + 10, _headImage.frame.origin.y, _headImage.frame.size.width, _headImage.frame.size.height);
//        _nickName.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame) + 10, _nickName.frame.origin.y, _nickName.frame.size.width, _nickName.frame.size.height);
//        _name.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame) + 10, _name.frame.origin.y, _name.frame.size.width, _name.frame.size.height);
    }else {
        self.checkBox.hidden = YES;
        self.addBtn.hidden = NO;
//        _headImage.frame = CGRectMake(13, _headImage.frame.origin.y, _headImage.frame.size.width, _headImage.frame.size.height);
//        _nickName.frame = CGRectMake(CGRectGetMaxX(self.verticalLine.frame) + 12, _nickName.frame.origin.y, _nickName.frame.size.width, _nickName.frame.size.height);
//        _name.frame = CGRectMake(CGRectGetMinX(_nickName.frame), _name.frame.origin.y, _name.frame.size.width, _name.frame.size.height);
    }
    [g_server WH_getHeadImageSmallWIthUserId:addressBook.toUserId userName:addressBook.addressBookName imageView:_headImage];
    _name.text = [NSString stringWithFormat:@"%@:%@",APP_NAME,addressBook.toUserName];
    _nickName.text = addressBook.addressBookName;
    
    if (self.isInvite) {
        _addBtn.enabled = YES;
        [_addBtn setTitle:Localized(@"JX_TheInvitation") forState:UIControlStateNormal];
        [g_server WH_getHeadImageSmallWIthUserId:nil userName:addressBook.addressBookName imageView:_headImage];
        _nickName.text = addressBook.addressBookName;
        _name.text = addressBook.toTelephone;
    }
    
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    if ([self.delegate respondsToSelector:@selector(addressBookCell:checkBoxSelectIndexNum:isSelect:)]) {
        [self.delegate addressBookCell:self checkBoxSelectIndexNum:self.index isSelect:checked];
    }
}

- (void)addBtnAction:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(addressBookCell:addBtnAction:)]) {
        [self.delegate addressBookCell:self addBtnAction:self.addressBook];
    }
}

/**
 设置分割线显示或者隐藏
 
 @param indexPath 当前cell所在索引
 */
- (void)setLineDisplayOrHidden:(NSIndexPath *)indexPath{
    _topLine.hidden = indexPath.row != 0;
}

- (void)WH_headImageDidTouch {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_getMediaData {
    NSLog(@"Get Info Failed");
}
@end
