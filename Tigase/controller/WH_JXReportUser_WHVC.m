//
//  WH_JXReportUser_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 17/6/26.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXReportUser_WHVC.h"

#import "WH_CustomActionSheetView.h"
#import "UIView+WH_CustomAlertView.h"

@interface WH_JXReportUser_WHVC ()<UITextViewDelegate, UIAlertViewDelegate>
@property (nonatomic,strong) UITextView * reasonView;
@property (nonatomic,strong) UILabel * placeLabel;
@property (nonatomic, strong) NSArray *array;

@property (nonatomic, strong) NSDictionary *currentReason;

@end

@implementation WH_JXReportUser_WHVC

-(instancetype)init{
    self = [super init];
    if (self) {
        
        
        [self.tableView setBackgroundColor:g_factory.globalBgColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    self.title = Localized(@"WaHu_JXUserInfo_WaHuVC_Report");
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    if ([self.user.roomFlag intValue] > 0  || self.user.roomId.length > 0) {
        _array = @[
                   @{@"reasonId":@200, @"reasonStr":Localized(@"JX_HaveGamblingBehavior")},
                   @{@"reasonId":@210, @"reasonStr":Localized(@"JX_CheatedMoney")},
                   @{@"reasonId":@220, @"reasonStr":Localized(@"JX_Harassment")},
                   @{@"reasonId":@230, @"reasonStr":Localized(@"JX_SpreadRumors")}
                   ];
    }
    else if (self.isUrl) {
        _array = @[
                   @{@"reasonId":@300, @"reasonStr":@"网页包含欺诈信息（如：假红包）"},
                   @{@"reasonId":@301, @"reasonStr":@"网页包含色情信息"},
                   @{@"reasonId":@302, @"reasonStr":@"网页包含暴力恐怖信息"},
                   @{@"reasonId":@303, @"reasonStr":@"网页包含政治敏感信息"},
                   @{@"reasonId":@304, @"reasonStr":@"网页包含在收集个人隐私信息（如：钓鱼链接）"},
                   @{@"reasonId":@305, @"reasonStr":@"网页包含诱导分享/关注性质的内容"},
                   @{@"reasonId":@306, @"reasonStr":@"网页可能包含谣言信息"},
                   @{@"reasonId":@307, @"reasonStr":@"网页包含赌博信息"},
                   ];
    }
    else {
        _array = @[
                   @{@"reasonId":@100, @"reasonStr":Localized(@"JX_InappropriateContent")},
                   @{@"reasonId":@101, @"reasonStr":Localized(@"JX_Pornography")},
                   @{@"reasonId":@102, @"reasonStr":Localized(@"JX_Posting_illegal")},
                   @{@"reasonId":@103, @"reasonStr":Localized(@"JX_Gambling")},
                   @{@"reasonId":@104, @"reasonStr":Localized(@"JX_PoliticalRumors")},
                   @{@"reasonId":@105, @"reasonStr":Localized(@"JX_Nuisance")},
                   @{@"reasonId":@106, @"reasonStr":Localized(@"JX_Other_illegal_content")},
                   @{@"reasonId":@120, @"reasonStr":Localized(@"JX_FraudToCheatMoney")},
                   @{@"reasonId":@130, @"reasonStr":Localized(@"JX_HaveBeenStolen")},
                   @{@"reasonId":@140, @"reasonStr":Localized(@"JX_Infringement")},
                   @{@"reasonId":@150, @"reasonStr":Localized(@"JX_ReleaseCounterfeitInformation")},
                   ];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, _array.count*55) style:UITableViewStylePlain];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_tableBody addSubview:self.tableView];
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = g_factory.cardCornerRadius;
    self.tableView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    self.tableView.layer.borderWidth = g_factory.cardBorderWithd;
//    self.
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reportCell"];
        
        
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 19, (55 - 12)/2, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [cell.contentView addSubview:iv];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, JX_SCREEN_WIDTH, .5)];
        line.backgroundColor = g_factory.globalBgColor;
        [cell addSubview:line];
    }
    NSDictionary *dict = _array[indexPath.row];
    cell.textLabel.text = dict[@"reasonStr"];
    [cell.textLabel setTextColor:HEXCOLOR(0x3A404C)];
    [cell.textLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = _array[indexPath.row];
    _currentReason = dict;
    
//    [g_App showAlert:Localized(@"JX_ConfirmReportInformation") delegate:self tag:2457 onlyConfirm:NO];
    
    CGFloat viewH = 206;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 206+24;
    }
    WH_CustomActionSheetView *share = [[WH_CustomActionSheetView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH) WithTitle:Localized(@"JX_ConfirmReportInformation")];
    
    [share showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(share) weakShare = share;
    __weak typeof(self) weakSelf = self;
    share.wh_okActionBlock = ^{
        [weakShare hideView];
        
        if (_delegate && [_delegate respondsToSelector:@selector(report:reasonId:)]) {
            [_delegate report:_user reasonId:_currentReason[@"reasonId"]];
            if (weakSelf.isUrl) {
                [weakSelf.view removeFromSuperview];
            }else {
                [weakSelf actionQuit];
            }
        }
        
    };
    share.wh_cancelActionBlock = ^{
        [weakShare hideView];
    };
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(report:reasonId:)]) {
            [_delegate report:_user reasonId:_currentReason[@"reasonId"]];
            if (self.isUrl) {
                [self.view removeFromSuperview];
            }else {
                [self actionQuit];
            }
        }
    }
}

//-(void)report{
//    if (_reasonView.text.length <= 0) {
//        [g_App showAlert:Localized(@"JX_ContentEmpty")];
//        return;
//    }
//    if (_delegate && [_delegate respondsToSelector:@selector(report:text:)]) {
//        [_delegate report:_user text:_reasonView.text];
//        [self actionQuit];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidChange:(UITextView *)textView{
    _placeLabel.hidden = YES;
}


- (void)sp_getLoginState {
    NSLog(@"Get User Succrss");
}
@end
