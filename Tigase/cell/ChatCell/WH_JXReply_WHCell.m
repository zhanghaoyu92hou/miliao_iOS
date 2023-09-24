//
//  MiXin_JXReply_MiXinCell.m
//  wahu_im
//
//  Created by 1 on 2019/3/30.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXReply_WHCell.h"

#define lineInset 5 // 加大 可增加与line的间隙

@interface WH_JXReply_WHCell ()
@property (nonatomic, strong)UIView *line;

@end


@implementation WH_JXReply_WHCell


- (void)dealloc {
    
}

-(void)creatUI{
    _replyConent = [[WH_JXEmoji alloc] init];
    _replyConent.lineBreakMode = NSLineBreakByWordWrapping;
    _replyConent.numberOfLines = 0;
    _replyConent.backgroundColor = [UIColor clearColor];
    _replyConent.font = [UIFont systemFontOfSize:g_constant.chatFont];
    _replyConent.userInteractionEnabled = YES;
    [self.bubbleBg addSubview:_replyConent];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReplyContent)];
    [_replyConent addGestureRecognizer:tap];

    
    _line = [[UIView alloc] init];
    _line.backgroundColor = [UIColor grayColor];
    [self.bubbleBg addSubview:_line];

    _messageConent=[[WH_JXEmoji alloc] init];
    _messageConent.lineBreakMode = NSLineBreakByWordWrapping;
    _messageConent.numberOfLines = 0;
    _messageConent.backgroundColor = [UIColor clearColor];
    _messageConent.font = [UIFont systemFontOfSize:g_constant.chatFont];
    [self.bubbleBg addSubview:_messageConent];
    
    _timeIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _timeIndexLabel.layer.cornerRadius = _timeIndexLabel.frame.size.width / 2;
    _timeIndexLabel.layer.masksToBounds = YES;
    _timeIndexLabel.textColor = [UIColor whiteColor];
    _timeIndexLabel.backgroundColor = HEXCOLOR(0x02d8c9);
    _timeIndexLabel.textAlignment = NSTextAlignmentCenter;
    _timeIndexLabel.text = @"0";
    _timeIndexLabel.font = [UIFont systemFontOfSize:12.0];
    _timeIndexLabel.hidden = YES;
    [self.contentView addSubview:_timeIndexLabel];
}

-(void)setCellData{
    [super setCellData];
    WH_JXMessageObject *msgObj = [[WH_JXMessageObject alloc] init];
    _messageConent.font = [UIFont systemFontOfSize:g_constant.chatFont];
    _messageConent.frame = CGRectMake(0, 0, 200, 20);
    NSString *objectId = self.msg.objectId;
    NSDictionary *tempDic = [objectId mj_JSONObject];
    if ([self.msg.objectId isKindOfClass:[NSDictionary class]]) {
        //objectId是字典类型
        [msgObj fromDictionary:(NSDictionary *)self.msg.objectId];
    }
    else if (tempDic != nil && [tempDic isKindOfClass:[NSDictionary class]]){
        //objectId是字典类型
        [msgObj fromDictionary:tempDic];
    }
    else if ([self.msg.objectId isKindOfClass:[NSString class]]){
        //objectid是字符串类型
        if (self.msg.objectId.length > 0) {
            if ([self.msg.type intValue] != kWCMessageTypeReply) {
                _messageConent.atUserIdS = self.msg.objectId;
            }else {
                
                NSDictionary *dict = [self.msg.objectId mj_JSONObject];
                [msgObj fromDictionary:dict];
            }
        }
    }
    
//    if (self.msg.objectId.length > 0) {
//        if ([self.msg.type intValue] != kWCMessageTypeReply) {
//            _messageConent.atUserIdS = self.msg.objectId;
//        }else {
//            NSDictionary *dict = [self.msg.objectId mj_JSONObject];
//            [msgObj fromDictionary:dict];
//        }
//    }
    
    
    
//    if ([self.msg.isReadDel boolValue] && [self.msg.fileName length] <= 0 && !self.msg.isMySend) {
//        _messageConent.userInteractionEnabled = NO;
//        _messageConent.text = [NSString stringWithFormat:@"%@ T", Localized(@"JX_ClickAndView")];
//        _messageConent.textColor = HEXCOLOR(0x0079FF);
//        _timeIndexLabel.hidden = YES;
//    }else {
    _messageConent.userInteractionEnabled = YES;
    _messageConent.textColor = [UIColor blackColor];
    _replyConent.textColor = [UIColor grayColor];
    
//    _replyConent.text = [NSString stringWithFormat:@"%@:%@",msgObj.fromUserName,[msgObj getTypeName]];
    if (msgObj.fromUserName.length) {
        _replyConent.text = [NSString stringWithFormat:@"%@:%@",msgObj.fromUserName,[msgObj getTypeName]];
    } else {
        _replyConent.text = [NSString stringWithFormat:@"%@:%@",self.msg.fromUserName,[self.msg getTypeName]];
    }
    
    _messageConent.text = self.msg.content;
    
    _timeIndexLabel.hidden = YES;
    //        if (!self.msg.isMySend && [self.msg.fileName isKindOfClass:[NSString class]] && [self.msg.fileName length] > 0 && [self.msg.fileName intValue] >= 0) {
//            self.timeIndexLabel.hidden = NO;
//
//            NSString *messageR = [self.msg.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];  //去掉回车键
//            NSString *messageN = [messageR stringByReplacingOccurrencesOfString:@"\n" withString:@""];  //去掉回车键
//            NSString *messageText = [messageN stringByReplacingOccurrencesOfString:@" " withString:@""];  //去掉空格
//            CGSize size = [messageText boundingRectWithSize:CGSizeMake(_messageConent.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(g_constant.chatFont)} context:nil].size;
//            NSInteger count = size.height / _messageConent.font.lineHeight;
//            NSLog(@"countcount ===  %ld-----%f-----%@",count,[[NSDate date] timeIntervalSince1970],self.msg.fileName);
//            //            NSLog(@"countcount === %ld,,,,%f,,,,%@",count,[[NSDate date] timeIntervalSince1970], self.msg.fileName);
//            count = count * 10 - ([[NSDate date] timeIntervalSince1970] - [self.msg.fileName longLongValue]);
//            self.timerIndex = count;
//
//            NSLog(@"countcount1 ===  %ld",count);
//            if (count > 0) {
//                self.timeIndexLabel.text = [NSString stringWithFormat:@"%ld",count];
//                if (!self.readDelTimer) {
//                    self.readDelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
//                }
//            }else {
//
//                self.msg.fileName = @"0";
//
//                //阅后即焚通知
//                [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
//                [self deleteMsg:self.msg];
//            }
//
//
//        }
//    }
    
    [self creatBubbleBg];
    [self sendReadDel];
}
- (void)drawIsRead {
    [self drawIsSend];
    if (!self.msg.isMySend) {
        
//#ifdef IS_SHOW_NEWReadDelete
        if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
        if ([self.msg.isReadDel boolValue]) {
            self.msg.readTime = [NSDate date];
            if([self.msg.isRead intValue] == transfer_status_yes){
                
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [self deleteMsg:self.msg];
                }];
            }
        }
        }
//#else
//#endif
    }
}
- (void)drawIsSend {
    [super drawIsSend];
    if (self.msg.isMySend) {
        
//#ifdef IS_SHOW_NEWReadDelete
        if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
        if ([self.msg.isReadDel boolValue]) {
            if([self.msg.isSend intValue] == transfer_status_yes){
            [self startTimeer:^(WH_JXMessageObject *msg) {
                [self deleteMsg:self.msg];
            }];
            }
        }
        }
//#else
//#endif
    }
}

-(void)creatBubbleBg{
    CGSize textSize = _messageConent.frame.size;
    CGSize replySize = _replyConent.frame.size;
    int n = textSize.width > replySize.width ? textSize.width : replySize.width;
    //聊天长度反正就是算错了，强行改
    if(n){
        //        n -= 10;
    }
    if(self.msg.isMySend){
        self.bubbleBg.frame=CGRectMake(JX_SCREEN_WIDTH-INSETS*4-HEAD_SIZE-n - 2+CHAT_WIDTH_ICON, INSETS, n+INSETS*2, textSize.height+replySize.height+INSETS*2+lineInset*2+.5);
        [_replyConent setFrame:CGRectMake(INSETS*0.4 + 3, INSETS, n + 5, replySize.height)];
        [_line setFrame:CGRectMake(INSETS*0.4 + 3, CGRectGetMaxY(_replyConent.frame)+lineInset, n + 5, .5)];
        [_messageConent setFrame:CGRectMake(INSETS*0.4 + 3, CGRectGetMaxY(_line.frame)+lineInset, n + 5, textSize.height)];
        _timeIndexLabel.frame = CGRectMake(self.bubbleBg.frame.origin.x - 30, self.bubbleBg.frame.origin.y, 20, 20);
        
        //            _messageConent.textAlignment = NSTextAlignmentRight;
    }else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + INSETS-CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), n+INSETS*2, textSize.height+replySize.height+INSETS*2+lineInset*2+.5);
        [_replyConent setFrame:CGRectMake(INSETS + 3, INSETS, n + 5, replySize.height)];
        [_line setFrame:CGRectMake(INSETS + 3, CGRectGetMaxY(_replyConent.frame)+lineInset, n + 5, .5)];
        [_messageConent setFrame:CGRectMake(INSETS + 3, CGRectGetMaxY(_line.frame)+lineInset, n + 5, textSize.height)];
        _timeIndexLabel.frame = CGRectMake(CGRectGetMaxX(self.bubbleBg.frame) + 10, self.bubbleBg.frame.origin.y, 20, 20);
        //            _messageConent.textAlignment = NSTextAlignmentLeft;
    }
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
        
        _timeIndexLabel.frame = CGRectMake(_timeIndexLabel.frame.origin.x, self.bubbleBg.frame.origin.y, 20, 20);
    }
    
}

- (void)setBackgroundImage {
    [super setBackgroundImage];
    if (!self.msg.isMySend && [self.msg.fileName isKindOfClass:[NSString class]] && [self.msg.fileName length] > 0 && [self.msg.fileName intValue] >= 0 && [self.msg.type intValue] == kWCMessageTypeText) {
        self.isDidMsgCell = YES;
    }
    if ([self.msg.isReadDel boolValue] && !self.msg.isMySend && self.isDidMsgCell) {
        //[self drawReadDelView:YES];
        self.isDidMsgCell = NO;
    }
    
}

//复制信息到剪贴板
- (void)myCopy{
//    if ([self.chatPerson.talkTime longLongValue] > 0) {
//        //禁言情况下
//        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
//        return;
//    }
    
    if(self.isBanned) {
        [GKMessageTool showText:self.bannedRemind];
        return;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.msg.content];
}

+ (float)getChatCellHeight:(WH_JXMessageObject *)msg {
    WH_JXMessageObject *msgObj = [[WH_JXMessageObject alloc] init];
    if ([msg.type intValue] == kWCMessageTypeReply) {
        NSDictionary *dict = [msg.objectId mj_JSONObject];
        [msgObj fromDictionary:dict];
    }
    NSString *fromStr = [NSString stringWithFormat:@"%@:%@",msgObj.fromUserName,[msgObj getTypeName]];
    NSString *toStr = [NSString stringWithFormat:@"%@\n%@",fromStr,msg.content];

    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    float n;
    WH_JXEmoji *messageConent=[[WH_JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    messageConent.backgroundColor = [UIColor clearColor];
    //    messageConent.userInteractionEnabled = NO;
    messageConent.numberOfLines = 0;
    messageConent.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
    messageConent.font = [UIFont systemFontOfSize:g_constant.chatFont];
    messageConent.offset = -12;
    
    messageConent.frame = CGRectMake(0, 0, 200, 20);
    if ([msg.isReadDel boolValue] && [msg.fileName intValue] <= 0 && !msg.isMySend) {
        messageConent.text = [NSString stringWithFormat:@"%@ T", Localized(@"JX_ClickAndView")];
    }else {
        messageConent.text = toStr;
    }
    
    if (msg.isGroup && !msg.isMySend) {
        n = messageConent.frame.size.height+10*3 + 20;
        if (msg.isShowTime) {
            n=messageConent.frame.size.height+10*3 + 40 + 20;
        }
    }else {
        n= messageConent.frame.size.height+10*3 + 10;
        if (msg.isShowTime) {
            n=messageConent.frame.size.height+10*3 + 40 + 10;
        }
    }
    
    //NSLog(@"heightForRowAtIndexPath_%d,%d:=%@",indexPath.row,n,_messageConent.text);
    if(n<55)
        n = 55;
    if (msg.isShowTime) {
        if(n<95)
            n = 95;
    }
    //lineInset*2+.5 为中间和line 的间隙
    n += lineInset*2+.5;
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([msg.isReadDel integerValue] >= 1) {
        NSLog(@"阅后即焚消息");
        n+=30;
//        if ([msg.isShowDel integerValue]>=1) {
//
//        if (msg.isMySend) {
//            n += 70;
//        }else {
//            n+=40;
//        }
//        }
    }
    }
//#else
//#endif
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    
    return n;
}

- (void)didReplyContent {
    [g_notify postNotificationName:kCellReplyNotifaction object:[NSNumber numberWithInt:self.indexNum]];
}

-(void)didTouch:(UIButton*)button{
}


- (void)sendReadDel {

    if ([self.msg.isReadDel boolValue] && [self.msg.fileName intValue] <= 0 && !self.msg.isMySend) {
        [self.msg WH_sendAlreadyRead_WHMsg];
        
        self.msg.fileName = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        [self.msg updateFileName];
        
        self.timeIndexLabel.hidden = NO;
  
        self.isDidMsgCell = YES;
        self.msg.chatMsgHeight = [NSString stringWithFormat:@"0"];
        [self.msg updateChatMsgHeight];
        //[g_notify postNotificationName:kCellMessageReadDelNotifaction object:[NSNumber numberWithInt:self.indexNum]];
    }

//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([self.msg.isReadDel boolValue]) {
        if (!self.msg.isMySend) {
            if([self.msg.isRead intValue] == transfer_status_yes){
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [self deleteMsg:self.msg];
                }];
            }
        }else {
            if([self.msg.isSend intValue] == transfer_status_yes){
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [self deleteMsg:self.msg];
                }];
            }
        }
    }
    }
//#else
//#endif
}



- (void)deleteMsg:(WH_JXMessageObject *)msg{
    
    if ([self.msg.isReadDel boolValue]) {
        
        if ([self.msg.fileName intValue] > 0) {
            return;
        }
        
        //渐变隐藏
        [UIView animateWithDuration:0.5f animations:^{
            self.bubbleBg.alpha = 0;
            self.timeIndexLabel.alpha = 0;
            self.readImage.alpha = 0;
            self.burnImage.alpha = 0;
        } completion:^(BOOL finished) {
            //动画结束后删除UI
            [self.delegate performSelectorOnMainThread:self.readDele withObject:msg waitUntilDone:NO];
            self.bubbleBg.alpha = 1;
            self.timeIndexLabel.alpha = 1;
            self.readImage.alpha = 1;
            self.burnImage.alpha = 1;
            //阅后即焚图片通知
            [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
        }];
    }
    
}

@end
