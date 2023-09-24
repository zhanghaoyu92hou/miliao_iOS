//
//  WH_JXLiveChat_WHCell.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/26.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXLiveChat_WHCell.h"
#import "WH_JXMessageObject.h"

@interface WH_JXLiveChat_WHCell()

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * contentLabel;

@end

@implementation WH_JXLiveChat_WHCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customSubViews];
    }
    return self;
}

-(void)customSubViews{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!_nameLabel) {
        _nameLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(5, 0, 50, 21) text:@"" font:sysFontWithSize(13) textColor:[UIColor purpleColor] backgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:_nameLabel];
    }
    
    if (!_contentLabel) {
        _contentLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+5, 0, CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(_nameLabel.frame)-10, 21) text:@"" font:sysFontWithSize(13) textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor]];
        _contentLabel.numberOfLines = 0;
        [self.contentView addSubview:_contentLabel];
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setLiveChatCellData:(WH_JXMessageObject *)msg{
    NSString * nameStr = [NSString stringWithFormat:@"%@ :",msg.fromUserName];
    
    CGSize size = [nameStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: sysFontWithSize(13)} context:nil].size;
    CGRect nframe = _nameLabel.frame;
    nframe.size.width = size.width;
    _nameLabel.frame = nframe;
    _nameLabel.text = nameStr;

    _contentLabel.text = msg.content;
    size = [msg.content boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - CGRectGetMaxX(_nameLabel.frame)-10 - 110, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: sysFontWithSize(13)} context:nil].size;
    _contentLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame)+5, 0, JX_SCREEN_WIDTH - CGRectGetMaxX(_nameLabel.frame)-10 - 110, size.height + 5);
}

@end
