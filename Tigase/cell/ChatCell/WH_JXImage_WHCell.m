//
//  MiXin_JXImage_MiXinCell.m
//  wahu_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXImage_WHCell.h"
#import "WH_ImageBrowser_WHViewController.h"
#import "WH_SCGIFImageView.h"


@implementation WH_JXImage_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dealloc{
    //[g_notify removeObserver:self name:kCellReadDelNotification object:self.msg];
}
-(void)creatUI{
    _chatImage=[[FLAnimatedImageView alloc]initWithFrame:CGRectZero];
    [_chatImage setBackgroundColor:[UIColor clearColor]];
//    _chatImage.layer.cornerRadius = 6;
//    _chatImage.layer.masksToBounds = YES;
    self.bubbleBg.backgroundColor = [UIColor clearColor];
    [self.bubbleBg addSubview:_chatImage];
    
    self.bubbleBg.layer.cornerRadius = 2;
//    [_chatImage release];
    
    _imageProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    _imageProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    _imageProgress.layer.masksToBounds = YES;
    _imageProgress.layer.borderWidth = 2.f;
    _imageProgress.layer.borderColor = [UIColor whiteColor].CGColor;
    _imageProgress.layer.cornerRadius = _imageProgress.frame.size.width/2;
    _imageProgress.text = @"0%";
    _imageProgress.hidden = YES;
    _imageProgress.font = sysFontWithSize(13);
    _imageProgress.textAlignment = NSTextAlignmentCenter;
    _imageProgress.textColor = [UIColor whiteColor];
    [_chatImage addSubview:_imageProgress];

}

- (void)updateFileLoadProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        // UI更新代码
            if ([self.fileDict isEqualToString:self.msg.messageId]) {
                _imageProgress.hidden = NO;
                if (self.loadProgress >= 1) {
                    _imageProgress.text = [NSString stringWithFormat:@"99%@",@"%"];
                }else {
                    _imageProgress.text = [NSString stringWithFormat:@"%d%@",(int)(self.loadProgress*100),@"%"];
                }
            }
//            if (self.loadProgress >= 1) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    _imageProgress.hidden = YES;
//                });
//            }
    });
    
}

- (void)sendMessageToUser {
    _imageProgress.text = [NSString stringWithFormat:@"100%@",@"%"];
    _imageProgress.hidden = YES;
}


-(void)setCellData{
    [super setCellData];
    [self setUIFrame];
    [g_notify addObserver:self selector:@selector(imageDidDismiss:) name:kImageDidTouchEndNotification object:nil];
}

- (void)setUIFrame{
    
    NSURL* url;
    if(self.msg.isMySend && isFileExist(self.msg.fileName)){
        NSString *imageUrl = [self.msg.fileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];//编码
        url = [NSURL fileURLWithPath:imageUrl];
    } else {
        NSString *imageUrl = [self.msg.content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];//编码
        url = [NSURL URLWithString:imageUrl];
    }
        
    
    [self setCellSubViewFrame:CGSizeMake(200, imageItemHeight)];
    
    self.chatImage.image = [UIImage imageNamed:@"Default_Gray"];
    if ([url.absoluteString rangeOfString:@".gif"].location != NSNotFound) {
        
        [self loadAnimatedImageWithURL:url completion:^(FLAnimatedImage *animatedImage) {
            self.chatImage.animatedImage = animatedImage;
            [self setCellSubViewFrame:_chatImage.image.size];
            [self setBackgroundImage];
            //self.wait.hidden = YES;
            //[self.wait stopAnimating];
        }];
        
    }else {
        
        [_chatImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Default_Gray"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //_chatImage.image = image;
            
            [self setCellSubViewFrame:_chatImage.image.size];
            [self setBackgroundImage];

        }];
        
    }

    if ([self.msg.isReadDel boolValue]) {

//        _chatImage.alpha = 0.1;
   
    }else {
        _chatImage.alpha = 1;
    }
    
    
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {

    if ([self.msg.isReadDel boolValue]) {
        if (!self.msg.isMySend) {
            if([self.msg.isRead intValue] == transfer_status_yes){
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [self deleteReadMsg];
                }];
            }
        }else {
            if([self.msg.isSend intValue] == transfer_status_yes){
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [self deleteReadMsg];
                }];
            }
        }
    }
    }
//#else
//#endif
}

- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [dataFilePath stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}

- (void) setCellSubViewFrame:(CGSize)size {
    
    int n = imageItemHeight;
    //后设置imageview大小
    float w = size.width * kScreenWidthScale;
    float h = size.height;
    
    if (w <= 0 || h <= 0){
        w = n;
        h = n;
    }
    
    float k = w/(h/n);
    if(k+INSETS > JX_SCREEN_WIDTH - 80)//如果超出屏幕宽度
        k = JX_SCREEN_WIDTH-n-INSETS;
    
    CGFloat bubbleX = .0f;
    CGFloat bubbleY = .0f;
    CGFloat bubbleW = .0f;
    CGFloat bubbleH = .0f;
    if(self.msg.isMySend)
    {
        if(w != 0 && h != 0){
            bubbleW = INSETS + k;
            bubbleX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - bubbleW;
            bubbleY = INSETS;
            bubbleH = n + INSETS - 4;
            self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
            //                _chatImage.frame = CGRectMake(INSETS*0.2 , INSETS*0.3, k, n);
            _chatImage.frame = self.bubbleBg.bounds;
        }
    } else {
        bubbleX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON;
        bubbleY = INSETS2(self.msg.isGroup);
        bubbleW = k + INSETS - 5;
        bubbleH = n + INSETS;
        self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
        //            self.chatImage.frame = CGRectMake(INSETS*0.5, INSETS*0.3, k, n);
        _chatImage.frame = self.bubbleBg.bounds;
        //            _chatImage.contentMode = UIViewContentModeScaleAspectFit;
        
        /*
         //            如果超出屏幕宽度
         if(self.bubbleBg.frame.size.width > (JX_SCREEN_WIDTH - 80)){
         self.bubbleBg.frame = CGRectMake(self.bubbleBg.frame.origin.x, self.bubbleBg.frame.origin.y, JX_SCREEN_WIDTH - n, self.bubbleBg.frame.size.height);
         _chatImage.frame = CGRectMake(_chatImage.frame.origin.x, _chatImage.frame.origin.y, JX_SCREEN_WIDTH - n, _chatImage.frame.size.height);
         }
         */
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    _imageProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    self.readImage.right = _chatImage.left - 10;
    [self setMaskLayer:_chatImage];
}

-(void)didTouch:(UIButton*)button{
    NSLog(@"imageCell ------");
    [g_notify postNotificationName:kCellImageNotifaction object:@(self.indexNum)];
    
    if ([self.msg.isReadDel boolValue] && !self.msg.isMySend) {
        
        [self.msg WH_sendAlreadyRead_WHMsg];
      
        
    
        _chatImage.alpha = 1;
        //[self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
    }
//    MiXin_ImageBrowser_MiXinViewController *imageVC = [MiXin_ImageBrowser_MiXinViewController sharedInstance];
//    imageVC.delegate = self;
//    imageVC.seeOK = @selector(imageDidDismiss);
    
}

//- (void)timeGo:(WH_JXMessageObject *)msg {
//    if ([self.msg.isReadDel boolValue]) {
//        [self startTimeer:^(WH_JXMessageObject *msg) {
//            [self deleteReadMsg];
//        }];
//    }
//}


- (void)drawIsSend {
    [super drawIsSend];
    if (self.msg.isMySend) {
        
//#ifdef IS_SHOW_NEWReadDelete
        if ([g_config.isDelAfterReading isEqualToString:@"0"]) {

        if ([self.msg.isReadDel boolValue]) {
            if([self.msg.isSend intValue] == transfer_status_yes){
                self.msg.timeSend = [NSDate date];
            [self startTimeer:^(WH_JXMessageObject *msg) {
                [self deleteReadMsg];
            }];
            }
        }
        }
//#else
//#endif
    }
}

- (void)drawIsRead {
    [super drawIsRead];
    if (!self.msg.isMySend) {
        
//#ifdef IS_SHOW_NEWReadDelete
         if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
        if ([self.msg.isReadDel boolValue]) {
            if([self.msg.isRead intValue] == transfer_status_yes){
                self.msg.readTime = [NSDate date];
            [self startTimeer:^(WH_JXMessageObject *msg) {
                [self deleteReadMsg];
            }];
            }
        }
         }
//#else
//#endif
    }
}

- (void)deleteReadMsg {
    if (![self.msg.isReadDel boolValue]) {
        return;
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
        [UIView animateWithDuration:0.5f animations:^{
            _chatImage.alpha = 0.0f;
            self.readImage.alpha = 0.f;
            self.burnImage.alpha = 0;
        } completion:^(BOOL finished) {
            [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
            _chatImage.alpha = 1.0f;
            self.readImage.alpha = 1.f;
            self.burnImage.alpha = 1.f;
            //阅后即焚图片通知
            [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
        }];
    }
}



- (void)imageDidDismiss:(NSNotification *)notification{
    
    WH_JXMessageObject *msg = notification.object;
    
    if ([msg.messageId isEqualToString:self.msg.messageId]) {
        if (![self.msg.isReadDel boolValue]) {
            return;
        }
        if (self.msg.isMySend) {
            if (!self.isRemove) {
                return;
            }
        }
//        if ([self.msg.isReadDel boolValue] && !self.msg.isMySend && self.isRemove) {
            if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
                //删除动画
                
            }
        }
//    }
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(int)getImageWidth{
    return [self.msg.location_x intValue];
}

-(int)getImageHeight{
    return [self.msg.location_y intValue];
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
            n = imageItemHeight+20*2+20;
        }
    }else {
        if (msg.isShowTime) {
            n = imageItemHeight+10*2 + 40;
        }else {
            n = imageItemHeight+10*2+20;
        }
    }
    
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([msg.isReadDel integerValue] >= 1) {
        n+=30;
//        if ([msg.isShowDel integerValue]>=1) {
//            
//            if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
//                n += 70;
//            }else {
//                n+=40;
//            }
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

@end
