//
//  WH_PhoneVerify_WHVC.m
//  wahu_2.0
//
//  Created by 闫振奎 on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_PhoneVerify_WHVC.h"
#import "WH_BtnInCenter_WHCell.h"
#import "MiXin_JXPayPassword_MiXinVC.h"
#import "WH_InputCaptcha_WHCell.h"
#import "WH_AddFriend_WHCell.h"

@interface WH_PhoneVerify_WHVC () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    
    NSArray <NSArray *> *_items;
}

@end

@implementation WH_PhoneVerify_WHVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
    self.title = @"忘记支付密码";
    
    [self commonInit];
    [self setupUI];
}

- (void)commonInit{
    _items = @[
               @[@{
                     @"title":@"输入登陆密码，完成身份验证",
                     @"content":@"",
                     @"type":@(0),
                     },
                 @{
                     @"title":@"输入登陆密码",
                     @"content":@"",
                     @"type":@(0),
                     },
                 ],
               ];
}

- (void)setupUI{
    [self setupTable];
}

- (void)setupTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(JX_SCREEN_TOP, 0, 0, 0));
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = g_factory.globalBgColor;
    [_tableView registerClass:[WH_BtnInCenter_WHCell class] forCellReuseIdentifier:@"WH_BtnInCenter_WHCell"];
    [_tableView registerClass:[WH_InputCaptcha_WHCell class] forCellReuseIdentifier:@"WH_InputCaptcha_WHCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    } else if (section == 1){
        return 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            WH_AddFriend_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_AddFriend_WHCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = WHSettingCellTypeTitleWithContent;
            cell.bgRoundType = WHSettingCellBgRoundTypeTop;
            cell.iconImageView.image = nil;
            cell.contentLabel.text = nil;
            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:@"请输入 " attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x333333),NSFontAttributeName:g_factory.font16}];
            [titleAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"130****0220" attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x8F9CBB),NSFontAttributeName:g_factory.font16}]];
            [titleAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"手机号码收到的短信验证码，验证身份" attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x8F9CBB),NSFontAttributeName:g_factory.font16}]];
            cell.titleLabel.attributedText = titleAtt;
            return cell;
        } else {
            
        }
    } else if (indexPath.section == 1){
        WH_InputCaptcha_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_InputCaptcha_WHCell"];
        
        return cell;
    } else {
        WH_BtnInCenter_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_BtnInCenter_WHCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.button setTitle:@"下一步" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        cell.onClickButton = ^(WH_BtnInCenter_WHCell * _Nonnull cell, UIButton * _Nonnull button) {
            //点击下一步
//            if (weakSelf.loginPsw.length > 0) {
                MiXin_JXPayPassword_MiXinVC * PayVC = [MiXin_JXPayPassword_MiXinVC alloc];
//                PayVC.oldPsw = weakSelf.loginPsw;
                PayVC.type = JXPayTypeSetupPassword;
                PayVC.enterType = JXEnterTypeForgetPayPsw;
                PayVC = [PayVC init];
                [g_navigation pushViewController:PayVC animated:YES];
//            } else {
//                [GKMessageTool showText:@"请先输入登录密码"];
//            }
        };
        return cell;
    }
}

/*
-(void)getImgCodeImg{
    if(_phone.text.length > 0){
        //    if ([self checkPhoneNum]) {
        //请求图片验证码
        NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSString * codeUrl = [g_server getImgCode:_phone.text areaCode:areaCode];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                UIImage * codeImage = [UIImage imageWithData:data];
                if (codeImage != nil) {
                    self.graphicImage = codeImage;
                    if (_graphicButton) {
                        [_graphicButton setImage:codeImage forState:UIControlStateNormal];
                    }
                }else{
                    [g_App showAlert:Localized(@"JX_ImageCodeFailed")];
                }
                
            }else{
                NSLog(@"%@",connectionError);
                [g_App showAlert:connectionError.localizedDescription];
            }
        }];
    }else{
        
    }
    
}
 */

@end
