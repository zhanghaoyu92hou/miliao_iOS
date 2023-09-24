//
//  WH_JXAnnounce_WHCell.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/8/17.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXAnnounce_WHCell.h"

#define HEIGHT 40

@interface WH_JXAnnounce_WHCell ()
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *line;

@end

@implementation WH_JXAnnounce_WHCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = g_factory.globalBgColor;
        self.backgroundColor = g_factory.globalBgColor;
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 16, JX_SCREEN_WIDTH - g_factory.globelEdgeInset*2, MAXFLOAT)];
        self.baseView.backgroundColor = [UIColor whiteColor];
        self.baseView.layer.masksToBounds = YES;
        self.baseView.layer.cornerRadius = g_factory.cardCornerRadius;
        self.baseView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        self.baseView.layer.borderWidth = g_factory.cardBorderWithd;
        [self.contentView addSubview:self.baseView];
        
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(15 , 15, HEIGHT, HEIGHT)];
        [self.baseView addSubview:self.icon];
        self.icon.layer.masksToBounds = YES;
        self.icon.layer.cornerRadius = (MainHeadType)?(HEIGHT/2):(g_factory.headViewCornerRadius);
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.icon.frame)+8, 16, 200, CGRectGetHeight(self.icon.frame))];
        [self.name setTextColor:HEXCOLOR(0x3A404C)];
        [self.name setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        [self.baseView addSubview:self.name];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width-15-100, 0, 100, 72)];
        self.time.textAlignment = NSTextAlignmentRight;
        self.time.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
        [self.time setTextColor:HEXCOLOR(0x969696)];
        [self.baseView addSubview:self.time];
        
//        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.icon.frame)+INSETS, self.baseView.frame.size.width, 0.5)];
//        self.line.backgroundColor = HEXCOLOR(0xD6D6D6);
//        [self.baseView addSubview:self.line];
        
        self.content = [[UILabel alloc] initWithFrame:CGRectMake(self.icon.frame.origin.x, 72, self.baseView.frame.size.width-(self.icon.frame.origin.x)*2, MAXFLOAT)];
        self.content.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 16];
        [self.content setTextColor:HEXCOLOR(0x3A404C)];
        self.content.numberOfLines = 0;
        [self.content sizeToFit];
        [self.baseView addSubview:self.content];
    }
    return self;
}

- (void)setCellHeightWithText:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - (self.icon.frame.origin.x)*2 - 2*g_factory.globelEdgeInset, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]} context:nil].size;
    self.content.frame = CGRectMake(self.icon.frame.origin.x, 72,size.width, size.height);
    self.baseView.frame = CGRectMake(g_factory.globelEdgeInset, 15, JX_SCREEN_WIDTH - (g_factory.globelEdgeInset)*2, 73+size.height);
}


- (void)sp_getUsersMostFollowerSuccess {
    NSLog(@"Continue");
}
@end
