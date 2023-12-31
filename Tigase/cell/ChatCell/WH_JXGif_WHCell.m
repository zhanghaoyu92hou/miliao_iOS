//
//  WH_JXGif_WHCell.m
//  Tigase_imChatT
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXGif_WHCell.h"

@implementation WH_JXGif_WHCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    
}

-(void)setCellData{
    [super setCellData];
    
    NSString* path = [gifImageFilePath stringByAppendingPathComponent:[self.msg.content lastPathComponent]];
    //
    if (_gif) {
        [_gif removeFromSuperview];
        _gif = nil;
//        [_gif release];
    }
    //第三方库，必须有数据才能创建
    _gif = [[WH_SCGIFImageView alloc] initWithGIFFile:path];
    _gif.userInteractionEnabled = NO;
    [self.contentView addSubview:_gif];
//    [_gif release];
    
    CGFloat gifX = .0f;
    CGFloat gifY = .0f;
    CGFloat gifW = imageItemHeight;
    CGFloat gifH = imageItemHeight;
    if(self.msg.isMySend){
//        NSLog(@"%f %f %f %d",JX_SCREEN_WIDTH, HEAD_SIZE,imageItemHeight, INSETS);
        gifX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - gifW;
        gifY = 20;
    } else {
        gifX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON;
        gifY = 20;
    }
    _gif.frame = CGRectMake(gifX, gifY, gifW, gifH);//185
    
    if (self.msg.isShowTime) {
        CGRect frame = _gif.frame;
        frame.origin.y = _gif.frame.origin.y + 40;
        _gif.frame = frame;
    }
    
    
    self.bubbleBg.frame = _gif.frame;
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
            n = imageItemHeight+20*2;
        }
    }else {
        if (msg.isShowTime) {
            n = imageItemHeight+10*2 + 40;
        }else {
            n = imageItemHeight+10*2;
        }
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

-(void)didTouch:(UIButton*)button{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_getUserName {
    NSLog(@"Get Info Failed");
}
@end
