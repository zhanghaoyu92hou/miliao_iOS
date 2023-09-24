//
//  WH_JXSetChatTextFont_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/5/21.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXSetChatTextFont_WHVC.h"
#import "WH_JXBaseChat_WHCell.h"
#import "WH_JXMessage_WHCell.h"

@interface WH_JXSetChatTextFont_WHVC ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, assign) CGFloat oldFont;
@end

@implementation WH_JXSetChatTextFont_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEXCOLOR(0xD0D0D0);
    self.tableView.backgroundColor = HEXCOLOR(0xD0D0D0);
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = NO;
    self.wh_isGotoBack = YES;
    self.title = Localized(@"JX_FontSize");
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self WH_createHeadAndFoot];
    _array = [NSMutableArray array];
    [self getData];
    [self.tableView reloadData];
    
    self.oldFont = g_constant.chatFont;
    
    JXLabel *done = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH -90, JX_SCREEN_TOP - 34, 80, 25)];
    done.wh_delegate = self;
    done.didTouch = @selector(done:);
    done.text = Localized(@"JX_Finish");
    done.font = sysFontWithSize(14);
    done.textColor = HEXCOLOR(0x3A404C);
    done.textAlignment = NSTextAlignmentRight;
    [self.wh_tableHeader addSubview:done];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - JX_SCREEN_BOTTOM - 80, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM + 80)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    //滑块设置
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, JX_SCREEN_WIDTH - 40, 20)];
    _slider.minimumValue = 1;
    _slider.maximumValue = 6;
    _slider.minimumTrackTintColor = [UIColor clearColor];
    _slider.maximumTrackTintColor = [UIColor clearColor];

    [_slider setValue:(g_constant.chatFont + 2.0 - 15.0)];
    
    //背景图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 55, _slider.frame.size.width - 5, 10)];
    UIImage *img = [UIImage imageNamed:@"sliderbg"];
    imageView.image = img;
    
    //添加点击手势和滑块滑动事件响应
    [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    
    [_slider addGestureRecognizer:tap];
    [view addSubview:imageView];
    [view addSubview:_slider];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x, 25, 20, 20)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor blackColor];
    label.text = @"A";
    [view addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) - 15, 25, 20, 20)];
    label.font = [UIFont systemFontOfSize:19.0];
    label.textColor = [UIColor blackColor];
    label.text = @"A";
    [view addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + (imageView.frame.size.width / 6), 25, 40, 20)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = HEXCOLOR(0xB1B2B1);
    label.text = Localized(@"JX_Standard");
    [view addSubview:label];
}
- (void)done:(JXLabel *)label {
    self.oldFont = g_constant.chatFont;
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    [msg updateAllChatMsgHeight];
    [self actionQuit];
}

- (void)actionQuit {
    [super actionQuit];
    if (self.oldFont != g_constant.chatFont) {
        g_constant.chatFont = self.oldFont;
    }
    [g_default setObject:[NSNumber numberWithFloat:g_constant.chatFont] forKey:kChatFont];
}

- (void)valueChanged:(UISlider *)sender
{
    //只取整数值，固定间距
    NSString *tempStr = [self numberFormat:sender.value];
    [sender setValue:tempStr.floatValue];
    g_constant.chatFont = tempStr.floatValue + 15.0 - 2.0;
    [self.tableView reloadData];
}

- (void)tapAction:(UITapGestureRecognizer *)sender
{
    //取得点击点
    CGPoint p = [sender locationInView:_slider];
    //计算处于背景图的几分之几，并将之转换为滑块的值（1~6）
    float tempFloat = (p.x - 20) / (_slider.frame.size.width) * 6 + 1;
    NSString *tempStr = [self numberFormat:tempFloat];
    //    NSLog(@"%f,%f,%@", p.x, tempFloat, tempStr);
    [_slider setValue:tempStr.floatValue];
    g_constant.chatFont = tempStr.floatValue + 15.0 - 2.0;
    [self.tableView reloadData];
}

/**
 *  四舍五入
 *
 *  @param num 待转换数字
 *
 *  @return 转换后的数字
 */
- (NSString *)numberFormat:(float)num
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"0"];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:num]];
}

- (void)getData {
    WH_JXMessageObject *msg1 = [[WH_JXMessageObject alloc] init];
    msg1.type = [NSNumber numberWithInt:1];
    msg1.fromUserId = g_myself.userId;
    msg1.content = Localized(@"JX_FontPreviewSize");
    msg1.isMySend = YES;
    [_array addObject:msg1];
    
    WH_JXMessageObject *msg2 = [[WH_JXMessageObject alloc] init];
    msg2.type = [NSNumber numberWithInt:1];
    msg2.content = Localized(@"JX_SettingTheSizeOfTheFont");

    msg2.fromUserId = CALL_CENTER_USERID;
    [_array addObject:msg2];
    
}


#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
    
    NSLog(@"indexPath.row:%ld,%ld",indexPath.section,indexPath.row);
    
    //返回对应的Cell
    WH_JXBaseChat_WHCell * cell = [self getCell:msg indexPath:indexPath];
    cell.msg = msg;
    cell.indexNum = (int)indexPath.row;
    cell.delegate = self;
//    cell.chatCellDelegate = self;
//    cell.readDele = @selector(readDeleWithUser:);
    cell.isShowHead = YES;
    [cell setCellData];
    [cell setHeaderImage];
    [cell setBackgroundImage];
    [cell isShowSendTime];
    //转圈等待
    if ([msg.isSend intValue] == transfer_status_ing) {
        [cell drawIsSend];
    }
    msg = nil;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
    msg.chatMsgHeight = @"0";
    
    switch ([msg.type intValue]) {
        case kWCMessageTypeText:
            return [WH_JXMessage_WHCell getChatCellHeight:msg];
            break;
        default:
            return [WH_JXBaseChat_WHCell getChatCellHeight:msg];
            break;
    }
}


#pragma mark -----------------获取对应的Cell-----------------
- (WH_JXBaseChat_WHCell *)getCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    WH_JXBaseChat_WHCell * cell = nil;
    switch ([msg.type intValue]) {
        case kWCMessageTypeText:
            cell = [self WH_creat_WHMessageCell:msg indexPath:indexPath];
            break;
        default:
            cell = [[WH_JXBaseChat_WHCell alloc] init];
            break;
    }
    return cell;
}
#pragma  mark -----------------------创建对应的Cell---------------------
//文本
- (WH_JXBaseChat_WHCell *)WH_creat_WHMessageCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXMessage_WHCell";
    WH_JXMessage_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXMessage_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_getLoginState {
    NSLog(@"Get User Succrss");
}
@end
