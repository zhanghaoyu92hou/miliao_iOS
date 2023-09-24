//
//  WH_JXTransfer_WHCell.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTransfer_WHCell.h"

@interface WH_JXTransfer_WHCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation WH_JXTransfer_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    self.bubbleBg.custom_acceptEventInterval = 1.0;
    
    _imageBackground =[[WH_JXImageView alloc]initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.image = [[UIImage imageNamed:@"WH_hongbao_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];
    
    _headImageView = [[UIImageView alloc]init];
    _headImageView.frame = CGRectMake(12,11, 36, 36);
    _headImageView.image = [UIImage imageNamed:@"ic_transfer_money"];
    _headImageView.userInteractionEnabled = NO;
    [_imageBackground addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 8,8, 160, 23);
    _nameLabel.font = sysFontWithSize(16);
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.numberOfLines = 0;
    _nameLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_nameLabel];
    
    _moneyLabel = [[UILabel alloc]init];
    _moneyLabel.frame = CGRectMake(CGRectGetMinX(_nameLabel.frame),CGRectGetMaxY(_nameLabel.frame) + 3, CGRectGetWidth(_nameLabel.frame), 20);
    _moneyLabel.font = sysFontWithSize(15);
    _moneyLabel.textColor = [UIColor whiteColor];
    _moneyLabel.numberOfLines = 0;
    _moneyLabel.userInteractionEnabled = NO;
    [_imageBackground addSubview:_moneyLabel];

    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 30)];
    _title.text = Localized(@"JX_Transfer");
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
        bubbleW = 220;
        bubbleX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - bubbleW;
        bubbleY = INSETS;
        bubbleH = 87.f;
    } else {
        bubbleX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON;
        bubbleY = INSETS2(self.msg.isGroup);
        bubbleW = 220;
        bubbleH = 87.f;
    }
    self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
    _imageBackground.frame = self.bubbleBg.bounds;
    
    _title.frame = CGRectMake(13, _imageBackground.frame.size.height - 4 - 17, bubbleW - 13*2, 17);
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
//    [self setMaskLayer:_imageBackground];
    WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
    user = [user getUserById:self.msg.toUserId];
    _nameLabel.text = self.msg.fileName.length > 0 ? self.msg.fileName : self.msg.isMySend ? [NSString stringWithFormat:@"%@%@",Localized(@"JX_TransferTo"),user.remarkName.length > 0 ? user.remarkName : user.userNickname] : Localized(@"JX_TransferToYou");
    _moneyLabel.text = [NSString stringWithFormat:@"¥%@",self.msg.content];
    
    if ([self.msg.fileSize integerValue] == 2) {
        _imageBackground.alpha = 0.7;
    }else{
        _imageBackground.alpha = 1;
    }
    
}

-(void)didTouch:(UIButton*)button{
    self.msg.index = self.indexNum;
    [g_notify postNotificationName:kcellTransferDidTouchNotifaction object:self.msg];
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



- (void)sp_checkNetWorking:(NSString *)string {
    NSLog(@"Get Info Success");
}
@end
