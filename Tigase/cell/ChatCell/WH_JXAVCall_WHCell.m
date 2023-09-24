//
//  WH_JXAVCall_WHCell.m
//  Tigase_imChatT
//
//  Created by p on 2017/8/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXAVCall_WHCell.h"

@interface WH_JXAVCall_WHCell ()

@property (nonatomic, strong) UILabel *avLabel;
@property (nonatomic, strong) UIImageView *avImageView;

@end

@implementation WH_JXAVCall_WHCell

-(void)creatUI{
    
    _avLabel = [[UILabel alloc] init];
    _avLabel.textColor = HEXCOLOR(0x4776C6);
    _avLabel.font = [UIFont systemFontOfSize:g_constant.chatFont];
    [self.bubbleBg addSubview:_avLabel];
    
    _avImageView = [[UIImageView alloc] init];
    [self.bubbleBg addSubview:_avImageView];
    
}

-(void)setCellData{
    [super setCellData];
    
    if (self.msg.isMySend) {
        _avLabel.textColor = HEXCOLOR(0x4776C6);
    } else {
        _avLabel.textColor = HEXCOLOR(0x3A404C);
    }
    
    _avLabel.text = self.msg.content;
    int type = 0;
    switch ([self.msg.type intValue]) {
        case kWCMessageTypeAudioChatCancel:
        case kWCMessageTypeAudioChatEnd:
        case kWCMessageTypeAudioMeetingInvite:
            type = 1;
            break;
        case kWCMessageTypeVideoMeetingInvite:
        case kWCMessageTypeVideoChatCancel:
        case kWCMessageTypeVideoChatEnd:
            type = 2;
            break;
            
        default:
            break;
    }
    if (type == 1) {
        if (self.msg.isMySend) {
            
            _avImageView.image = [UIImage imageNamed:@"WH_phone_myself"];
        }else {
            
            _avImageView.image = [UIImage imageNamed:@"WH_phone_other"];
        }
    } else {
        if (self.msg.isMySend) {
            
            _avImageView.image = [UIImage imageNamed:@"WH_video_myself"];
        }else {
            
            _avImageView.image = [UIImage imageNamed:@"WH_video_other"];
        }
    }
    
    [self creatBubbleBg];
}
-(void)creatBubbleBg{
    CGSize textSize = [self.msg.content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_avLabel.font} context:nil].size;
    int n = textSize.width;

    CGFloat bubbleX = .0f;
    CGFloat bubbleY = .0f;
    CGFloat bubbleW = .0f;
    CGFloat bubbleH = .0f;
    CGFloat imgWH = 20.f;
    if(self.msg.isMySend){
        bubbleW = n + imgWH + 12 + 18; // n+INSETS*2 + 25
        bubbleH = textSize.height + INSETS*2; //textSize.height+INSETS*2
        bubbleX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - bubbleW; //JX_SCREEN_WIDTH-INSETS*4-HEAD_SIZE-n - 2 - 25+CHAT_WIDTH_ICON
        bubbleY = INSETS; //INSETS
        self.bubbleBg.frame=CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
        [_avImageView setFrame:CGRectMake(INSETS*0.4 + 3, (self.bubbleBg.frame.size.height - imgWH) / 2, imgWH, imgWH)];
        [_avLabel setFrame:CGRectMake(CGRectGetMaxX(_avImageView.frame) + 3, INSETS, n + 5, textSize.height)];
//        [_avLabel setFrame:CGRectMake(INSETS*0.4 + 3, INSETS, n + 5, textSize.height)];
//        [_avImageView setFrame:CGRectMake(CGRectGetMaxX(_avLabel.frame) + 3, (self.bubbleBg.frame.size.height - 20) / 2, 20, 20)];
    } else {
        bubbleX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON; //JX_SCREEN_WIDTH-INSETS*4-HEAD_SIZE-n - 2 - 25+CHAT_WIDTH_ICON
        bubbleY = INSETS2(self.msg.isGroup); //INSETS
        bubbleW = n + imgWH + 12 + 18; // n+INSETS*2 + 25
        bubbleH = textSize.height + INSETS*2; //textSize.height+INSETS*2
        self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
        [_avImageView setFrame:CGRectMake(INSETS + 3, (self.bubbleBg.frame.size.height - 20) / 2, 20, 20)];
        [_avLabel setFrame:CGRectMake(CGRectGetMaxX(_avImageView.frame) + 5, INSETS, n + 5, textSize.height)];
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
}


+ (float)getChatCellHeight:(WH_JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n;
    if (msg.isShowTime) {
        n = 95;
    }else {
        n = 55;
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

-(void)didTouch:(UIButton*)button{
    [g_notify postNotificationName:kCellSystemAVCallNotifaction object:self.msg];
}


@end
