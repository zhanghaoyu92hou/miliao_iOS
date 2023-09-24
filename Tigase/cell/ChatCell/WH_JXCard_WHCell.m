//
//  WH_JXCard_WHCell.m
//  Tigase_imChatT
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXCard_WHCell.h"
#import "WH_JXMessageObject.h"
#import "JXServer.h"
#import "AppDelegate.h"


@implementation WH_JXCard_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
//    [_imageBackground setBackgroundColor:[UIColor redColor]];
//    _imageBackground.layer.cornerRadius = 6;
//    _imageBackground.image = [UIImage imageNamed:@"white"];
    self.bubbleBg.layer.cornerRadius = g_factory.cardCornerRadius;
    self.bubbleBg.layer.masksToBounds = YES;
    self.bubbleBg.layer.borderColor = g_factory.cardBorderColor.CGColor;
    self.bubbleBg.layer.borderWidth = g_factory.cardBorderWithd;
    
    self.bubbleBg.backgroundColor = [UIColor whiteColor];
    
    [self.bubbleBg addSubview:_imageBackground];
//    [_imageBackground release];
    //
    
    _cardHeadImage = [[UIImageView alloc]init];
    _cardHeadImage.frame = CGRectMake(12,12, 45, 45);
    _cardHeadImage.userInteractionEnabled = NO;
    [_imageBackground addSubview:_cardHeadImage];
    [_cardHeadImage headRadiusWithAngle:CGRectGetWidth(_cardHeadImage.frame) / 2.f];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_cardHeadImage.frame) + 8,25, 100, 30);
    _nameLabel.center = CGPointMake(_nameLabel.center.x, _cardHeadImage.center.y);
    _nameLabel.font = sysFontWithSize(15);
    _nameLabel.textColor = HEXCOLOR(0x3A404C);
    _nameLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_nameLabel];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = HEXCOLOR(0xDBE0E7);
    [_imageBackground addSubview:_lineView];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
    _title.text = Localized(@"JX_BusinessCard");
    _title.font = sysFontWithSize(12);
    _title.textColor = HEXCOLOR(0x8C9AB8);
    [_imageBackground addSubview:_title];
}

-(void)setCellData{
    [super setCellData];
    CGFloat bubbleX = .0f;
    CGFloat bubbleY = .0f;
    CGFloat bubbleW = .0f;
    CGFloat bubbleH = .0f;
    if(self.msg.isMySend) {
        bubbleW = 235.0f;
        bubbleX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - bubbleW;
        bubbleY = INSETS;
        bubbleH = 94.0f;
    } else {
        bubbleX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON;
        bubbleY = INSETS2(self.msg.isGroup);
        bubbleW = 235.0f;
        bubbleH = 94.0f;
    }
    self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
    _imageBackground.frame = self.bubbleBg.bounds;
    
    CGFloat lineEdge = 12.0f;
    _lineView.frame = CGRectMake(lineEdge, CGRectGetMaxY(_cardHeadImage.frame) + lineEdge, _imageBackground.frame.size.width - lineEdge*2, 1.0f);
    _title.frame = CGRectMake(CGRectGetMinX(_lineView.frame), CGRectGetMaxY(_lineView.frame) + 2.f, 200, 17.f);
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    [g_server WH_getHeadImageSmallWIthUserId:self.msg.objectId userName:self.msg.content imageView:_cardHeadImage];
    _nameLabel.text = self.msg.content;
    
    if(!self.msg.isMySend)
        [self drawIsRead];
}

//未读红点
-(void)drawIsRead{
    if (self.msg.isMySend) {
        return;
    }
    if([self.msg.isRead boolValue]){
        self.readImage.hidden = YES;
    }
    else{
        if(self.readImage==nil){
            self.readImage=[[WH_JXImageView alloc]init];
            [self.contentView addSubview:self.readImage];
            //            [self.readImage release];
        }
        self.readImage.image = [UIImage imageNamed:@"new_tips"];
        self.readImage.hidden = NO;
        self.readImage.frame = CGRectMake(self.bubbleBg.frame.origin.x+self.bubbleBg.frame.size.width+2, self.bubbleBg.frame.origin.y+13, 8, 8);
        self.readImage.center = CGPointMake(self.readImage.center.x, self.bubbleBg.center.y);
    }
}

-(void)didTouch:(UIButton*)button{
    
    [self.msg WH_sendAlreadyRead_WHMsg];
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    if(!self.msg.isMySend){
        [self drawIsRead];
    }
    
    [g_notify postNotificationName:kCellShowCardNotifaction object:self.msg];
}

+ (float)getChatCellHeight:(WH_JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = imageItemHeight+20*2 + 40;
        }else {
            n = imageItemHeight+20*2+ 20;
        }
    }else {
        if (msg.isShowTime) {
            n = imageItemHeight+10*2 + 40;
        }else {
            n = imageItemHeight+10*2+ 20;
        }
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}


- (void)sp_getUserFollowSuccess {
    NSLog(@"Check your Network");
}
@end
