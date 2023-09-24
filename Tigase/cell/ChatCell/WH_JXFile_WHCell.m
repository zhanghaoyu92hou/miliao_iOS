//
//  WH_JXFile_WHCell.m
//  Tigase_imChatT
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXFile_WHCell.h"
#import "WH_JXMyFile.h"

@interface WH_JXFile_WHCell ()

@property (nonatomic, strong) UIImageView *fileImage;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation WH_JXFile_WHCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
//    [_imageBackground setBackgroundColor:[UIColor clearColor]];
//    _imageBackground.layer.cornerRadius = 6;
//    _imageBackground.image = [UIImage imageNamed:@"white"];
//    _imageBackground.layer.masksToBounds = YES;
    
    self.bubbleBg.layer.cornerRadius = g_factory.cardCornerRadius;
    self.bubbleBg.layer.masksToBounds = YES;
    self.bubbleBg.layer.borderColor = g_factory.cardBorderColor.CGColor;
    self.bubbleBg.layer.borderWidth = g_factory.cardBorderWithd;
    self.bubbleBg.backgroundColor = [UIColor whiteColor];
    
    [self.bubbleBg addSubview:_imageBackground];
//    [_imageBackground release];
    
    UIView *fileImageBgView = [UIView new];
    [_imageBackground addSubview:fileImageBgView];
    fileImageBgView.frame = CGRectMake(12, 12, 60, 60);
    fileImageBgView.layer.cornerRadius = 5.f;
    fileImageBgView.layer.masksToBounds = YES;
    fileImageBgView.backgroundColor = HEXCOLOR(0xECF0F5);
    
    _fileImage = [[UIImageView alloc]init];
    _fileImage.frame = CGRectMake(12,12, 40, 40);
    _fileImage.center = CGPointMake(CGRectGetWidth(fileImageBgView.frame) / 2.f, CGRectGetHeight(fileImageBgView.frame) / 2.f);
    _fileImage.userInteractionEnabled = NO;
    _fileImage.image = [UIImage imageNamed:@"WH_file_dir"];
    [fileImageBgView addSubview:_fileImage];

    _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(fileImageBgView.frame) + 12,CGRectGetMinY(fileImageBgView.frame), 130, 21)];
    _fileNameLabel.numberOfLines = 0;
    _fileNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _fileNameLabel.backgroundColor = [UIColor clearColor];
    _fileNameLabel.font = sysFontWithSize(15);
    _fileNameLabel.textColor = HEXCOLOR(0x3A404C);
    [_imageBackground addSubview:_fileNameLabel];
    
//    _lineView = [[UIView alloc] init];
//    _lineView.backgroundColor = HEXCOLOR(0xe3e3e3);
//    [_imageBackground addSubview:_lineView];
    
    _progressView = [[UIProgressView alloc] init];
    _progressView.progressTintColor = [UIColor greenColor];
    _progressView.progressViewStyle = UIProgressViewStyleDefault;
    _progressView.hidden = YES;
    [_imageBackground addSubview:_progressView];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_fileNameLabel.frame), CGRectGetMaxY(_fileNameLabel.frame) + 4.f, CGRectGetWidth(_fileNameLabel.frame), 19.f)];
    _title.text = Localized(@"JX_File");
    _title.font = sysFontWithSize(13);
    _title.textColor = HEXCOLOR(0x969696);
    [_imageBackground addSubview:_title];
    
    
//    [_fileNameLabel release];
}

-(void)setCellData{
    [super setCellData];

    CGFloat bubbleX = .0f;
    CGFloat bubbleY = .0f;
    CGFloat bubbleW = .0f;
    CGFloat bubbleH = .0f;
    if(self.msg.isMySend) {
        bubbleW = 235;
        bubbleX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - bubbleW;
        bubbleY = INSETS;
        bubbleH = 82;
    } else {
        bubbleX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON;
        bubbleY = INSETS2(self.msg.isGroup);
        bubbleW = 235;
        bubbleH = 82;
    }
    self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
    _imageBackground.frame = self.bubbleBg.bounds;
    
//    _lineView.frame = CGRectMake(0, _imageBackground.frame.size.height - 30, _imageBackground.frame.size.width, .5);
    _progressView.frame = CGRectMake(2, _imageBackground.frame.size.height - 30, _imageBackground.frame.size.width-2, .5);
//    _title.frame = CGRectMake(15, _imageBackground.frame.size.height - 30, 200, 30);
//    _fileNameLabel.frame = CGRectMake(_fileNameLabel.frame.origin.x, _fileNameLabel.frame.origin.y, _fileNameLabel.frame.size.width, _lineView.frame.origin.y - _fileNameLabel.frame.origin.y - 10);
    
    
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    [self setMaskLayer:_imageBackground];
    
    if (self.msg.fileName.length > 0) {
        _fileNameLabel.text = [NSString stringWithFormat:@"%@",[self.msg.fileName lastPathComponent]];
    }
    
//    if (JX_SCREEN_WIDTH >320) {
//        if (self.msg.content.length > 0) {
//           _fileNameLabel.text = [NSString stringWithFormat:@"  %@:%@...",Localized(@"JX_File"),[[self.msg.content lastPathComponent] substringToIndex:15]];
//        }
//    }else{
//        if (self.msg.content.length > 0) {
//            _fileNameLabel.text = [NSString stringWithFormat:@"  %@:%@...",Localized(@"JX_File"),[[self.msg.content lastPathComponent] substringToIndex:9]];
//        }
//    }
    
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

- (void)updateFileLoadProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fileDict isEqualToString:self.msg.messageId]) {
            _progressView.hidden = NO;
            // UI更新代码
            if (self.loadProgress >= 1) {
                [_progressView setProgress:0.99 animated:YES];
            }
            else {
                [_progressView setProgress:self.loadProgress animated:YES];
            }
//            _progressView.hidden = self.loadProgress >= 1;
        }
    });
}

- (void)sendMessageToUser {
    [_progressView setProgress:1 animated:YES];
    _progressView.hidden = YES;
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

-(void)didTouch:(UIButton*)button{

//    WH_JXMyFile* vc = [[WH_JXMyFile alloc]init];
//    [g_window addSubview:vc.view];
    
    
    [self.msg WH_sendAlreadyRead_WHMsg];
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    if(!self.msg.isMySend){
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self drawIsRead];
    }
    
    [g_notify postNotificationName:kCellSystemFileNotifaction object:self.msg];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_didUserInfoFailed {
    NSLog(@"Get Info Failed");
}
@end
