//
//  WH_JXSetNoteAndLabel_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/5/7.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXSetNoteAndLabel_WHVC.h"
#import "WH_JXLabelObject.h"
#import "WH_JXSetLabel_WHVC.h"
#import "UIImage+WH_Color.h"

#define HEIGHT 54
#define FONT [UIFont fontWithName:@"PingFangSC-Regular" size: 15]
#define TEXT_COLOR HEXCOLOR(0x333333)

@interface WH_JXSetNoteAndLabel_WHVC () <UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *name; //备注
@property (nonatomic, strong) UITextField *textField; //标签
@property (nonatomic, strong) UITextView *detail; //描述

@property (nonatomic, strong) UILabel *labT;
@property (nonatomic, strong) UILabel *labContLab;
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UIColor *textVColor;

@property (nonatomic, strong) NSMutableArray *array;    // 已选择标签
@property (nonatomic, strong) NSMutableArray *allArray; // 所有标签

@property (nonatomic, strong) UILabel *watermarkLab;// 水印

@end

@implementation WH_JXSetNoteAndLabel_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    self.wh_tableBody.delegate = self;
    
    self.textVColor = HEXCOLOR(0xBAC3D5);
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
    
    
//    _array = [NSMutableArray array];
//    _allArray = [NSMutableArray array];

    [self customView];

}

- (void)customView {
    JXLabel *p = [self WH_createLabel:self.wh_tableHeader default:Localized(@"JX_Confirm") selector:@selector(onSave)];
    p.textColor = [UIColor whiteColor];
    p.backgroundColor = HEXCOLOR(0x0093FF);
    p.textAlignment = NSTextAlignmentCenter;
    p.layer.masksToBounds = YES;
    p.layer.cornerRadius = 14;
//    p.frame = THE_DEVICE_HAVE_HEAD ? CGRectMake(JX_SCREEN_WIDTH -45, 20+10+23, 35, 25) : CGRectMake(JX_SCREEN_WIDTH -g_factory.globelEdgeInset - 43, JX_SCREEN_TOP - 36, 43, 28);
    p.frame = CGRectMake(JX_SCREEN_WIDTH -g_factory.globelEdgeInset - 43, JX_SCREEN_TOP - 36, 43, 28);
    
    CGFloat marginY = 16;
//    CGFloat viewWidth = JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset;

    // 备注
//    UIView *markView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, marginY, viewWidth, 55)];
//    [markView setBackgroundColor:HEXCOLOR(0xffffff)];
//    markView.layer.masksToBounds = YES;
//    markView.layer.cornerRadius = g_factory.cardCornerRadius;
//    markView.layer.borderColor = g_factory.cardBorderColor.CGColor;
//    markView.layer.borderWidth = 1;
//    [self.wh_tableBody addSubview:markView];
//
//    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 60, CGRectGetHeight(markView.frame))];
//    nameLab.text = Localized(@"JX_MemoName");
//    nameLab.textColor = HEXCOLOR(0x3A404C);
//    nameLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
//    [markView addSubview:nameLab];

    UIView *markView = [self createCommonViewWithOrginY:marginY viewHeight:HEIGHT labelText:Localized(@"JX_MemoName")];
    _name = [[UITextField alloc] initWithFrame:CGRectMake(90 ,(CGRectGetHeight(markView.frame) - 40)/2 ,CGRectGetWidth(markView.frame) - 12 - 90 ,40)];
    _name.placeholder = Localized(@"JX_AddRemarkName");
    _name.font = FONT;
    _name.delegate = self;
    _name.textColor = TEXT_COLOR;
    _name.textAlignment = NSTextAlignmentRight;
    _name.returnKeyType = UIReturnKeyDone;
    _name.backgroundColor = [UIColor whiteColor];
    _name.text = _user.remarkName;
    [_name addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    [markView addSubview:_name];

    // 标签
    UIView *labelView = [self createCommonViewWithOrginY:markView.frame.origin.y + markView.frame.size.height + marginY  viewHeight:HEIGHT labelText:Localized(@"JX_Label")];
    
//    _labT = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_name.frame)+20, 40, 18)];
//    _labT.text = Localized(@"JX_Label");
//    _labT.textColor = HEXCOLOR(0x3A404C);
//    _labT.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
//    [labelView addSubview:_labT];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(90, (CGRectGetHeight(labelView.frame) - 40)/2, CGRectGetWidth(labelView.frame) - 12 - 90, 40)];
//    btn.backgroundColor = [UIColor redColor];
//    btn.layer.borderWidth = .5f;
//    btn.layer.borderColor = self.textVColor.CGColor;
    
//    [btn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage createImageWithColor:self.textVColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onLabel) forControlEvents:UIControlEventTouchUpInside];
    [labelView addSubview:btn];
    
    _labContLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(btn.frame) - 24, 40)];
    _labContLab.backgroundColor = [UIColor clearColor];
    _labContLab.textColor = TEXT_COLOR;
    _labContLab.font = FONT;
    [_labContLab setTextAlignment:NSTextAlignmentRight];
//    _labContLab.userInteractionEnabled = YES;
    [btn addSubview:_labContLab];
    [self getLab];

//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLabel)];
//    [_labContLab addGestureRecognizer:tap];
    
    UIImageView *imgV =[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(btn.frame) - 19, (CGRectGetHeight(btn.frame) - 12)/2, 7, 12)];
    imgV.image = [UIImage imageNamed:@"WH_Back"];
    [btn addSubview:imgV];
    

    // 描述
    self.describeView = [self createCommonViewWithOrginY:labelView.frame.origin.y + labelView.frame.size.height + marginY viewHeight:135 labelText:Localized(@"JX_UserInfoDescribe")];
    
    _baseView = [[UIView alloc] initWithFrame:CGRectMake(20, 50, CGRectGetWidth(self.describeView.frame) - 32, CGRectGetHeight(self.describeView.frame) - 50 - 8)];
    [self.describeView addSubview:_baseView];

    _detail = [self WH_createMiXinTextField:_baseView default:_user.remarkName];
    _detail.frame = CGRectMake(0, 0, CGRectGetWidth(_baseView.frame), CGRectGetHeight(_baseView.frame));
//    CGSize sizeD = [_detail sizeThatFits:CGSizeMake(_detail.frame.size.width, MAXFLOAT)];
//    _detail.frame = CGRectMake(_detail.frame.origin.x, _detail.frame.origin.y, _detail.frame.size.width, sizeD.height);
    _detail.text = _user.describe.length > 0 ? _user.describe : @"";
    
    //水印
    _watermarkLab = [[UILabel alloc] initWithFrame:CGRectMake(3,6, _detail.frame.size.width, 20)];
    _watermarkLab.text = Localized(@"JX_AddMoreComments");
    _watermarkLab.textColor = HEXCOLOR(0xBAC3D5);
    _watermarkLab.font = FONT;
    [_detail addSubview:_watermarkLab];
    
    if (_user.describe.length > 0) {
        [self textViewDidChange:_detail];
    }

    if ([self WH_validateCellPhoneNumber:[self getNumber:_detail.text]]) {
        NSMutableAttributedString *atbs =[[NSMutableAttributedString alloc] initWithAttributedString: _detail.attributedText];
        NSRange range = [[atbs string] rangeOfString:[self getNumber:_detail.text]];
        [atbs addAttributes:@{NSLinkAttributeName:[self getNumber:_detail.text],NSForegroundColorAttributeName:[UIColor redColor]} range:range];
        _detail.attributedText= atbs;
        _detail.selectable=YES;
    }
}

- (void)getLab {
    NSMutableArray *array = [[WH_JXLabelObject sharedInstance] fetchLabelsWithUserId:self.user.userId];
    NSMutableString *labelsName = [NSMutableString string];
    for (NSInteger i = 0; i < array.count; i ++) {
        WH_JXLabelObject *labelObj = array[i];
        if (i == 0) {
            [labelsName appendString:labelObj.groupName];
        }else {
            [labelsName appendFormat:@",%@",labelObj.groupName];
        }
    }
    if (labelsName.length > 0) {
        _labContLab.text = labelsName;
        _labContLab.textColor = TEXT_COLOR;
    }else {
        _labContLab.text = @"通过标签给联系人进行分类";
        _labContLab.textColor = self.textVColor;
    }

}
- (void)onLabel {
    WH_JXSetLabel_WHVC *vc = [[WH_JXSetLabel_WHVC alloc] init];
    vc.title = Localized(@"JX_SettingLabel");
    vc.delegate = self;
    vc.didSelect = @selector(WH_refreshLabel:);
    vc.array = _array;
    vc.allArray = _allArray;
    vc.user = self.user;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)WH_refreshLabel:(WH_JXSetLabel_WHVC *)vc {
    [self getLab];
    _array = [vc.array mutableCopy];
    _allArray = [vc.allArray mutableCopy];
    
    NSMutableString *labelsName = [NSMutableString string];
    for (NSInteger i = 0; i < _array.count; i ++) {
        WH_JXLabelObject *labelObj = _array[i];
        if (i == 0) {
            [labelsName appendString:labelObj.groupName];
        }else {
            [labelsName appendFormat:@",%@",labelObj.groupName];
        }
    }
    if (labelsName.length > 0) {
        _labContLab.text = labelsName;
        _labContLab.textColor = TEXT_COLOR;
    }else {
        _labContLab.text = @"通过标签给联系人进行分类";
        _labContLab.textColor = self.textVColor;
    }
    
}

// 确定按钮
- (void)onSave {
    
    BOOL flag = NO;
    for (NSInteger i = 0; i < _array.count; i ++) {
        WH_JXLabelObject *labelObj = _array[i];
        
        // 添加输入框输入的新创建的标签
        if (!labelObj.groupId) {
            flag = YES;
            [g_server WH_friendGroupAdd:labelObj.groupName toView:self];
        }
    }
    
    // 没有新创建的标签，直接更新已存在标签
    if (!flag) {
        NSMutableString *userIdListStr = [NSMutableString string];
        for (NSInteger i = 0; i < _array.count; i ++) {
            WH_JXLabelObject *obj = _array[i];
            if (i == 0) {
                [userIdListStr appendFormat:@"%@", obj.groupId];
            }else {
                [userIdListStr appendFormat:@",%@", obj.groupId];
            }
        }
        
        [g_server WH_friendGroupUpdateFriendToUserId:self.user.userId groupIdStr:userIdListStr toView:self];
    }
}


-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([self WH_validateCellPhoneNumber:textView.text]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",textView.text]]];
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    _watermarkLab.hidden = YES;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    
    _watermarkLab.hidden = textView.text.length > 0;
//    _watermarkLab.hidden = YES;
    
//    static CGFloat maxHeight =70.0f;
    CGFloat maxHeight = CGRectGetHeight(self.describeView.frame) - 40 - 8;
    
    //防止输入时在中文后输入英文过长直接中文和英文换行
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-14, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    _baseView.frame = CGRectMake(20, _baseView.frame.origin.y, CGRectGetWidth(self.describeView.frame) - 32 , CGRectGetHeight(self.describeView.frame) - 40 - 8);
    
}



//服务器返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_FriendGroupAdd]) {
        
        NSMutableString *userIdListStr = [NSMutableString stringWithFormat:@"%@", self.user.userId];
        
        // 添加新标签后更新标签的用户列表
        [g_server WH_friendGroupUpdateGroupUserListWithGroupId:dict[@"groupId"] userIdListStr:userIdListStr toView:self];
        
        WH_JXLabelObject *label = [[WH_JXLabelObject alloc] init];
        if (dict) {
            label.userId = dict[@"userId"];
            label.groupId = dict[@"groupId"];
            label.groupName = dict[@"groupName"];
        }
        label.userIdList = userIdListStr;
        // 插入新创建的标签
        [label insert];
        
        WH_JXLabelObject *lastObj;
        // 查找到新创建的标签的最后一个
        for (NSInteger i = _array.count - 1; i >= 0; i --) {
            WH_JXLabelObject *obj = _array[i];
            if (!obj.groupId) {
                lastObj = obj;
                break;
            }
        }
        
        // 更新新创建的标签的其他字段
        for (WH_JXLabelObject *labelObj in _array) {
            if ([label.groupName isEqualToString:labelObj.groupName]) {
                labelObj.groupId = label.groupId;
                labelObj.userId = label.userId;
                labelObj.userIdList = label.userIdList;
                break;
            }
        }
        
        // 如果接口已成功添加完最后一条标签后，再更新用户的标签列表
        if ([label.groupName isEqualToString:lastObj.groupName]) {
            
            NSMutableString *userIdListStr = [NSMutableString string];
            for (NSInteger i = 0; i < _array.count; i ++) {
                WH_JXLabelObject *obj = _array[i];
                if (i == 0) {
                    [userIdListStr appendFormat:@"[%@", obj.groupId];
                }else if (i == self.array.count - 1) {
                    [userIdListStr appendFormat:@",%@]", obj.groupId];
                }else {
                    [userIdListStr appendFormat:@",%@", obj.groupId];
                }
            }
            
            [g_server WH_friendGroupUpdateFriendToUserId:self.user.userId groupIdStr:userIdListStr toView:self];
            
        }
    }
    
    if ([aDownload.action isEqualToString:wh_act_FriendGroupUpdateFriend]) {
        
        // 更新数据库
        for (WH_JXLabelObject *labelObj in _allArray) {
            [labelObj update];
        }
        self.user.remarkName = _name.text;
        if (_detail.textColor != self.textVColor) {
            self.user.describe = _detail.text;
        }else {
            self.user.describe = nil;
        }
        if ([self.delegate respondsToSelector:self.didSelect]) {
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:self.user waitUntilDone:NO];
        }

        [self actionQuit];
    }
}



#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


-(UITextView*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s {
    UITextView* p = [[UITextView alloc] init];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    p.returnKeyType = UIReturnKeyDone;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    p.textAlignment = NSTextAlignmentLeft;
    p.textColor = TEXT_COLOR;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = sysFontWithSize(15);
    [parent addSubview:p];
    return p;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.wh_tableBody) {
        [self.view endEditing:YES];
    }
}


- (BOOL)WH_validateCellPhoneNumber:(NSString *)cellNum{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,184,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2478])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,175,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[56]|8[56])\\d{8}$";
    
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
    NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    // NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if(([regextestmobile evaluateWithObject:cellNum] == YES)
       || ([regextestcm evaluateWithObject:cellNum] == YES)
       || ([regextestct evaluateWithObject:cellNum] == YES)
       || ([regextestcu evaluateWithObject:cellNum] == YES)){
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)getNumber:(NSString *)string {
    NSString *pattern = @"\\d*";
    
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSLog(@"%@",error);
    __block NSString *number = [NSString string];
    [regex enumerateMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (NSMatchingReportProgress==flags) {
            
        }else{
            /**
             *  系统内置方法
             */
            if (NSTextCheckingTypePhoneNumber==result.resultType) {
                number = [string substringWithRange:result.range];
            }
            /**
             *  长度为11位的数字串
             */
            if (result.range.length==11) {
                number = [string substringWithRange:result.range];
            }
        }
    }];
    return number;
}

-(JXLabel*)WH_createLabel:(UIView*)parent default:(NSString*)s selector:(SEL)selector{
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 -20,44-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = sysFontWithSize(14);
    p.textAlignment = NSTextAlignmentLeft;
    p.didTouch = selector;
    p.wh_delegate = self;
    [parent addSubview:p];
    return p;
}

- (UIView *)createCommonViewWithOrginY:(CGFloat)orginY viewHeight:(CGFloat)height labelText:(NSString *)text{
    UIView *markView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, orginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, height)];
    [markView setBackgroundColor:HEXCOLOR(0xffffff)];
    markView.layer.masksToBounds = YES;
    markView.layer.cornerRadius = g_factory.cardCornerRadius;
    markView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    markView.layer.borderWidth = g_factory.cardBorderWithd;
    [self.wh_tableBody addSubview:markView];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 60, (height > HEIGHT)?HEIGHT:CGRectGetHeight(markView.frame))];
    nameLab.text = text;
    nameLab.textColor = HEXCOLOR(0x3A404C);
    nameLab.font = FONT;
    [markView addSubview:nameLab];
    return markView;
}

- (void)textFieldEditChanged:(UITextField *)textField{
    if (_name == textField) {
        [g_factory setTextFieldInputLengthLimit:textField maxLength:NAME_INPUT_MAX_LENGTH];
    }
}


- (void)sp_getUsersMostLiked:(NSString *)string {
    NSLog(@"Get Info Success");
}
@end
