//
//  WH_JXTransferNotice_WHCell.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTransferNotice_WHCell.h"
#import "WH_JXTransferNoticeModel.h"
#import "WH_JXTransferModel.h"
#import "WH_BankCardTrans_WHModel.h"

@interface WH_JXTransferNotice_WHCell ()
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *moneyTit;
@property (nonatomic, strong) UILabel *moneyLab;
@property (nonatomic, strong) UILabel *payTit;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *noteTit;
@property (nonatomic, strong) UILabel *noteLab;


@property (nonatomic, strong) UILabel *backLab;
@property (nonatomic, strong) UILabel *backTime;
@property (nonatomic, strong) UILabel *sendLab;
@property (nonatomic, strong) UILabel *sendTime;

@end

@implementation WH_JXTransferNotice_WHCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        _baseView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200)];
        _baseView.backgroundColor = [UIColor whiteColor];
        _baseView.layer.masksToBounds = YES;
        _baseView.layer.cornerRadius = g_factory.cardCornerRadius;
        _baseView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        _baseView.layer.borderWidth = g_factory.cardBorderWithd;
        [self.contentView addSubview:_baseView];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
        _title.textColor = HEXCOLOR(0x8F9CBB);
        _title.font = [UIFont fontWithName:@"PingFangSC" size:16];
        [_baseView addSubview:_title];
        
        //收款金额
        _moneyTit = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame)+10, _baseView.frame.size.width, 18)];
        _moneyTit.text = Localized(@"JX_GetMoney");
        _moneyTit.textAlignment = NSTextAlignmentCenter;
        _moneyTit.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_moneyTit];
        
        _moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_moneyTit.frame)+10, _baseView.frame.size.width, 43)];
        _moneyLab.textAlignment = NSTextAlignmentCenter;
        _moneyLab.font = [UIFont boldSystemFontOfSize:40];
        [_baseView addSubview:_moneyLab];

        //第一行
        _payTit = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_moneyLab.frame)+20, 80, 18)];
        _payTit.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_payTit];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(90, _payTit.frame.origin.y, _baseView.frame.size.width-70, 18)];
        _nameLab.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_nameLab];
        
        //第二行
        _noteTit = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_payTit.frame)+10, 80, 18)];
        _noteTit.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_noteTit];
        
        _noteLab = [[UILabel alloc] initWithFrame:CGRectMake(90, CGRectGetMaxY(_payTit.frame)+10, _baseView.frame.size.width-70-30, 18)];
//        _noteLab.font = [UIFont fontWithName:@"PingFangSC" size:15];
        _noteLab.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_noteLab];
        
        
        //第三行
        _backLab = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_noteTit.frame)+10, 80, 18)];
        _backLab.text = Localized(@"JX_ReturnTheTime");
        _backLab.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_backLab];
        
        _backTime = [[UILabel alloc] initWithFrame:CGRectMake(90, _backLab.frame.origin.y, _baseView.frame.size.width-70, 18)];
        _backTime.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_backTime];
        
        //第四行
        _sendLab = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_backLab.frame)+10, 80, 18)];
        _sendLab.text = Localized(@"JX_TransferTime");
        _sendLab.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_sendLab];
        
        _sendTime = [[UILabel alloc] initWithFrame:CGRectMake(90, _sendLab.frame.origin.y, _baseView.frame.size.width-70, 18)];
        _sendTime.textColor = [UIColor lightGrayColor];
        [_baseView addSubview:_sendTime];
    }
    return self;
}


- (void)setDataWithMsg:(WH_JXMessageObject *)msg model:(id)tModel {
    if ([msg.type intValue] == kWCMessageTypeBankCardTrans || [msg.type intValue] == kWCMessageTypeH5PaymentReturn) {
        WH_BankCardTrans_WHModel *model = (WH_BankCardTrans_WHModel *)tModel;
        _moneyTit.text = @"到账金额";
        _payTit.text = @"当前状态:";
        if (model.payStatus == 0) {
            _nameLab.text = @"处理中";
        } else if (model.payStatus == 1){
            _nameLab.text = @"充值成功";
        } else if (model.payStatus == 6){
            _nameLab.text = @"订单超时";
        }
        [self hideTime:YES];
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.amount];
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200);
        _noteTit.text = @"备注内容:";
        
        _noteLab.numberOfLines = 0;
        _noteLab.lineBreakMode = NSLineBreakByWordWrapping;
        
        _noteLab.text = model.statusMsg;
        _noteLab.height = [self getHeightLineWithString:[NSString stringWithFormat:@"%@",model.statusMsg] withWidth:JX_SCREEN_WIDTH-120 withFont:_noteLab.font];
        _baseView.height = 200-18+_noteLab.height;
        
        _nameLab.textColor = model.payStatus == 0 ? HEXCOLOR(0x3EEB026) : model.payStatus == 1 ? HEXCOLOR(0x3F9E10) : HEXCOLOR(0xCB5858);
    } else if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        WH_JXTransferModel *model = (WH_JXTransferModel *)tModel;
        _moneyTit.text = Localized(@"JX_Refunds");
        _payTit.text = Localized(@"JX_TheRefundWay");
        _nameLab.text = Localized(@"JX_ReturnedToTheChange");
        _noteTit.text = Localized(@"JX_ReturnReason");
        [self hideTime:NO];
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.money];
        _backTime.text = model.outTime;
        _sendTime.text = model.createTime;
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200+56);
        _nameLab.textColor = [UIColor lightGrayColor];
    }else {
        WH_JXTransferNoticeModel *model = (WH_JXTransferNoticeModel *)tModel;
        _noteTit.text = Localized(@"JX_Note");
        if (model.type == 1 && [model.userId intValue] == [MY_USER_ID intValue]) {
            _payTit.text = Localized(@"JX_Payee");
            _nameLab.text = model.toUserName;
        }
        else if (model.type == 1 && [model.userId intValue] != [MY_USER_ID intValue]) {
            _payTit.text = Localized(@"JX_Drawee");
            _nameLab.text = model.userName;
        }
        else if (model.type == 2 && [model.userId intValue] == [MY_USER_ID intValue]) {
            _payTit.text = Localized(@"JX_Drawee");
            _nameLab.text = model.toUserName;
        }
        else if (model.type == 2 && [model.userId intValue] != [MY_USER_ID intValue]){
            _payTit.text = Localized(@"JX_Payee");
            _nameLab.text = model.userName;
        }
        [self hideTime:YES];
        _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",model.money];
        _baseView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 200);
        _nameLab.textColor = [UIColor lightGrayColor];
    }
    _title.text = [self getTitle:[msg.type intValue]];
    if ([msg.type intValue] != kWCMessageTypeBankCardTrans && [msg.type intValue] != kWCMessageTypeH5PaymentReturn){
        _noteLab.text = [self getNote:msg];
    }
}

#pragma mark - 根据字符串计算label高度
+ (CGFloat)getHeightLineWithString:(NSString *)string withWidth:(CGFloat)width withFont:(UIFont *)font {
    
    //1.1最大允许绘制的文本范围
    CGSize size = CGSizeMake(width, 2000);
    //1.2配置计算时的行截取方法,和contentLabel对应
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    [style setLineSpacing:10];
    //1.3配置计算时的字体的大小
    //1.4配置属性字典
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    //2.计算
    //如果想保留多个枚举值,则枚举值中间加按位或|即可,并不是所有的枚举类型都可以按位或,只有枚举值的赋值中有左移运算符时才可以
    CGFloat height = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size.height;
    
    return height;
}
- (CGFloat)getHeightLineWithString:(NSString *)string withWidth:(CGFloat)width withFont:(UIFont *)font {
    
    //1.1最大允许绘制的文本范围
    CGSize size = CGSizeMake(width, 2000);
    //1.2配置计算时的行截取方法,和contentLabel对应
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    [style setLineSpacing:10];
    //1.3配置计算时的字体的大小
    //1.4配置属性字典
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    //2.计算
    //如果想保留多个枚举值,则枚举值中间加按位或|即可,并不是所有的枚举类型都可以按位或,只有枚举值的赋值中有左移运算符时才可以
    CGFloat height = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size.height;
    
    return height;
}

- (void)hideTime:(BOOL)isHide {
    _backLab.hidden = isHide;
    _backTime.hidden = isHide;
    _sendLab.hidden = isHide;
    _sendTime.hidden = isHide;
}


- (NSString *)getTitle:(int)type {
    NSString *string;
    // 过期退还
    if (type == kWCMessageTypeTransferBack) {
        string = Localized(@"JX_RefundNoticeOfOverdueTransfer");
    }
    // 支付通知
    else if (type == kWCMessageTypePaymentOut || type == kWCMessageTypeReceiptOut) {
        string = Localized(@"JX_PaymentNo.");
    }
    // 收款通知
    else if (type == kWCMessageTypePaymentGet || type == kWCMessageTypeReceiptGet) {
        string = Localized(@"JX_ReceiptNotice");
    }
    //银行卡通知
    else if (type == kWCMessageTypeBankCardTrans){
        string = @"充值通知";
    }else if (type == kWCMessageTypeH5PaymentReturn) {
        string = @"充值通知";
    }

    return string;
}

- (NSString *)getNote:(WH_JXMessageObject *)msg {
    NSString *string;
    // 过期退还
    if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        string = Localized(@"JX_TransferIsOverdueAndTheChange");
    }
    // 支付通知
    else if ([msg.type intValue] == kWCMessageTypePaymentOut || [msg.type intValue] == kWCMessageTypeReceiptOut) {
        string = Localized(@"JX_PaymentToFriend");
    }
    // 收款通知
    else if ([msg.type intValue] == kWCMessageTypePaymentGet || [msg.type intValue] == kWCMessageTypeReceiptGet) {
        string = Localized(@"JX_PaymentReceived");
    }
    // 转账退款通知
    else if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        string = [NSString stringWithFormat:@"%@%@",msg.toUserName,Localized(@"JX_NotReceive24Hours")];
    }
    return string;
}

+ (float)getChatCellHeight:(WH_JXMessageObject *)msg {
    if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        return 215+56;
    }else if ([msg.type intValue] == kWCMessageTypeBankCardTrans || [msg.type intValue] == kWCMessageTypeH5PaymentReturn) {
        
        NSDictionary *dict = [self dictionaryWithJsonString:msg.content];
        WH_BankCardTrans_WHModel *model = [WH_BankCardTrans_WHModel mj_objectWithKeyValues:dict];
        
        return 215-18+[self getHeightLineWithString:[NSString stringWithFormat:@"%@",model.statusMsg] withWidth:JX_SCREEN_WIDTH-120 withFont:[UIFont systemFontOfSize:17]];
    }else {
        return 215;
    }
    return 0;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
