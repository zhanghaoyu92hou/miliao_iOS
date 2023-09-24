//
//  WH_JXRedPacket_WHCell.m
//  Tigase_imChatT
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXRedPacket_WHCell.h"

@interface WH_JXRedPacket_WHCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *checkLabel;

@property (nonatomic, strong) UILabel *title;

@end

@implementation WH_JXRedPacket_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    self.bubbleBg.custom_acceptEventInterval = 1.0;
    
    self.bubbleBg.layer.masksToBounds = NO;
    
    _imageBackground =[[WH_JXImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.image = [[UIImage imageNamed:@"WH_hongbao_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];
    
    _headImageView = [[UIImageView alloc]init];
    _headImageView.frame = CGRectMake(12,11, 35, 41);
    _headImageView.image = [UIImage imageNamed:@"WH_hongbao_top"];
    _headImageView.userInteractionEnabled = NO;
    [_imageBackground addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10,8, 160, 23);
    _nameLabel.font = sysFontWithSize(16);
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.numberOfLines = 0;
    _nameLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_nameLabel];

    _checkLabel = [[UILabel alloc] init];
    [_imageBackground addSubview:_checkLabel];
    _checkLabel.frame = CGRectMake(CGRectGetMinX(_nameLabel.frame), CGRectGetMaxY(_nameLabel.frame) + 4.0f, CGRectGetWidth(_nameLabel.frame), 20);
    _checkLabel.text = Localized(@"WH_Check_RedPacket");
    _checkLabel.textColor = [UIColor whiteColor];
    _checkLabel.font = sysFontWithSize(14);
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_headImageView.frame)+1.0f, 10, 200, 30)];
    _title.text = Localized(@"JX_BusinessCard");
    _title.font = sysFontWithSize(12);
    _title.textColor = HEXCOLOR(0x8C9AB8);
    [_imageBackground addSubview:_title];
    
    //
//    _redPacketGreet = [[JXEmoji alloc]initWithFrame:CGRectMake(5, 25, 80, 16)];
//    _redPacketGreet.textAlignment = NSTextAlignmentCenter;
//    _redPacketGreet.font = [UIFont systemFontOfSize:12];
//    _redPacketGreet.textColor = [UIColor whiteColor];
//    _redPacketGreet.userInteractionEnabled = NO;
//    [_imageBackground addSubview:_redPacketGreet];
}

-(void)setCellData{
    [super setCellData];
    
    CGFloat bubbleX = .0f;
    CGFloat bubbleY = .0f;
    CGFloat bubbleW = .0f;
    CGFloat bubbleH = .0f;
    if(self.msg.isMySend) {
        bubbleW = 220.0f;
        bubbleX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - bubbleW;
        bubbleY = INSETS;
        bubbleH = 87.0f;
    } else {
        bubbleW = 220.0f;
        bubbleX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON;
        bubbleY = INSETS2(self.msg.isGroup);
        bubbleH = 87.0f;
    }
    self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
    _imageBackground.frame = self.bubbleBg.bounds;
    _title.frame = CGRectMake(CGRectGetMinX(_headImageView.frame) + 1.0f, _imageBackground.frame.size.height - (4+17), 200, 17);
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
//    [self setMaskLayer:_imageBackground];
    
    //服务端返回的数据类型错乱，强行改
    self.msg.fileName = [NSString stringWithFormat:@"%@",self.msg.fileName];
    if ([self.msg.fileName isEqualToString:@"3"]) {
        _nameLabel.text = [NSString stringWithFormat:@"%@%@",Localized(@"JX_Message"),self.msg.content];
        _title.text = ([self.msg.type intValue] == kWCMessageTypeRedPacketExclusive)?@"专属红包":Localized(@"JX_MesGift");
    }else{
        _nameLabel.text = self.msg.content;
        _title.text = ([self.msg.type intValue] == kWCMessageTypeRedPacketExclusive)?@"专属红包":Localized(@"JXredPacket");
    }
    
    if ([self.msg.fileSize intValue] == 2) {
        
        _imageBackground.alpha = 0.7;
    }else {
        
        _imageBackground.alpha = 1;
    }

}

-(void)didTouch:(UIButton*)button{
    if ([self.msg.fileName isEqualToString:@"3"]) {
//        //如果可以打开
//        if([self.msg.fileSize intValue] != 2){
//            [g_App showAlert:Localized(@"JX_WantOpenGift")];
//            return;
//        }
        
        [g_notify postNotificationName:kcellRedPacketDidTouchNotifaction object:self.msg];
    }
    
    if ([self.msg.fileName isEqualToString:@"1"] || [self.msg.fileName isEqualToString:@"2"]) {
    
            [g_notify postNotificationName:kcellRedPacketDidTouchNotifaction object:self.msg];
            return;

    }
    

}

+ (float)getChatCellHeight:(WH_JXMessageObject *)msg {
    if ([g_App.isShowRedPacket intValue] == 1){
        if ([msg.chatMsgHeight floatValue] > 1) {
            return [msg.chatMsgHeight floatValue];
        }
        
        float n = 0;
        if (msg.isGroup && !msg.isMySend) {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 + 10 + 40;
            }else {
                n = JX_SCREEN_WIDTH/3 + 10;
            }
        }else {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 + 40;
            }else {
                n = JX_SCREEN_WIDTH/3;
            }
        }
        
        msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
        if (!msg.isNotUpdateHeight) {
            [msg updateChatMsgHeight];
        }
        return n;
        
    }else{
        
        msg.chatMsgHeight = [NSString stringWithFormat:@"0"];
        if (!msg.isNotUpdateHeight) {
            [msg updateChatMsgHeight];
        }
        return 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_getMediaData {
    NSLog(@"Continue");
}
@end
