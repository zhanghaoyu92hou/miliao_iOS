//
//  WH_WeiboSearchViewController.m
//  Tigase
//
//  Created by 政委 on 2020/6/6.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_WeiboSearchViewController.h"
#import "AddressBookFriendModel.h"
#import "AddressBookFriendCell.h"
#import "WH_WeiboCell.h"
#import "WH_ContactCell.h"
#import "ContactSelectViewController.h"
#import "WH_JXWeiboDetailViewController.h"

@interface WH_WeiboSearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, WH_WeiboCellDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource> {
    ATMHud* _wait;
}
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UITableView *searchTable;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *currentArray;
@property (nonatomic, strong) NSMutableArray *weiboArray;
@property (nonatomic, strong) UIView *windowView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *month;
@property (nonatomic, copy) NSString *releaseString;
@property (nonatomic, copy) NSString *currentUserId;
//无搜索数据占位图
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, strong) UICollectionView *friendCollectionView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIButton *releasePersonBtn;
@property (nonatomic, strong) UIButton *releaseTimeBtn;
@property (nonatomic, strong) UILabel *contactLabel;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, copy) NSString *lastUserId;//上次搜索时的userId
@property (nonatomic, copy) NSString *lastKeyWord;//上次搜索时的keyWord
@property (nonatomic, copy) NSString *lastMonthStr;//上次搜索时的monthStr
@property (nonatomic, copy) NSString *lastType;//上次搜索时的type

@end

@implementation WH_WeiboSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
    [self.searchBar becomeFirstResponder];
    [self getFriend];
    [g_notify addObserver:self selector:@selector(searchViewRefreshNotification) name:kWeiboSearchViewRefresh object:nil];
}
- (void)searchViewRefreshNotification {
    //刷新当前搜索页面
    [g_server searchCircleWithUserId:self.lastUserId keyWord:!self.lastUserId || [self.lastUserId isEqualToString:MY_USER_ID] ? self.lastKeyWord : @"" monthStr:self.lastMonthStr pageIndex:@"0" pageSize:@"5" type:self.lastType toView:self];
}
//顶部刷新获取数据
-(void)WH_scrollToPageUp{
    
}
//上拉加载
-(void)WH_getServerData{
      [_wait start];
    NSLog(@"%d", _page);
    if (self.wh_isShowFooterPull) {
        [g_server searchCircleWithUserId:self.lastUserId keyWord:!self.lastUserId || [self.lastUserId isEqualToString:MY_USER_ID] ? self.lastKeyWord : @"" monthStr:self.lastMonthStr pageIndex:[NSString stringWithFormat:@"%d", _page] pageSize:@"5" type:self.lastType toView:self];
    }
}
- (void)configUI {
    self.releaseString = @"";
    self.lastMonthStr = @"";
    self.year = @"不限";
    self.month = @"不限";
    self.view.backgroundColor = RGB(244, 245, 250);
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    self.topView = topView;
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(JX_SCREEN_WIDTH);
        make.height.mas_equalTo(JX_SCREEN_TOP);
    }];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"搜索朋友圈";
    searchBar.delegate = self;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.tintColor = HEXCOLOR(0x3A404C);
    searchBar.barTintColor = [UIColor clearColor];
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.enablesReturnKeyAutomatically = YES;
    searchBar.backgroundColor = HEXCOLOR(0xFAFBFC);
    searchBar.layer.cornerRadius = 15;
    searchBar.layer.masksToBounds = YES;
    searchBar.layer.borderColor = HEXCOLOR(0xEEF0F5).CGColor;
    searchBar.layer.borderWidth = 0.5;
    //通过 KVC 获取到内部的 textField, 然后自定制处理
            UITextField *searchField = [searchBar valueForKey:@"searchField"];
            if (searchField) {
                [searchField setBorderStyle:UITextBorderStyleNone];
                NSMutableAttributedString *placeholderString = [[NSMutableAttributedString alloc] initWithString:searchBar.placeholder attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0xD1D6E0)}];
                searchField.attributedPlaceholder = placeholderString;
                searchField.frame = CGRectMake(0, 0, searchBar.width, searchBar.height);
                searchField.textColor = HEXCOLOR(0x3A404C);
                searchField.font = [UIFont systemFontOfSize:14.0];
                searchField.backgroundColor = HEXCOLOR(0xFAFBFC);
            }
    [self.topView addSubview:searchBar];
    self.searchBar = searchBar;
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(JX_SCREEN_TOP - 37);
        make.width.mas_equalTo(JX_SCREEN_WIDTH - 80);
        make.height.mas_equalTo(30);
    }];
//    UIButton *cleanButton = [JXXMPP createButtonWithFrame:CGRectMake(searchBar.width - 24, 5, 20, 20) image:[UIImage imageNamed:@"WH_Image_Text_Close"]];
//    [cleanButton addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [searchBar addSubview:cleanButton];
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancel setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
    cancel.layer.cornerRadius = 15;
    cancel.layer.masksToBounds = YES;
    cancel.layer.borderColor = HEXCOLOR(0xEEF0F5).CGColor;
    cancel.layer.borderWidth = 0.5;
    [cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancel];
    self.cancelButton = cancel;
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(searchBar.mas_right).offset(10);
        make.top.mas_equalTo(JX_SCREEN_TOP - 37);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    UITableView *searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP) style:UITableViewStylePlain];
    searchTable.delegate = self;
    searchTable.dataSource = self;
    searchTable.backgroundColor = RGB(244, 245, 250);
    searchTable.separatorStyle = UITableViewCellAccessoryNone;
    [searchTable registerClass:[AddressBookFriendCell class] forCellReuseIdentifier:@"AddressBookFriendCell"];
    [self.view addSubview:searchTable];
    self.searchTable = searchTable;
    _table.frame = CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP);
    _table.hidden = YES;
//    UITableView *weiboTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP) style:UITableViewStylePlain];
//    weiboTable.delegate = self;
//    weiboTable.dataSource = self;
////    weiboTable.backgroundColor = RGB(244, 245, 250);
//    weiboTable.separatorStyle = UITableViewCellAccessoryNone;
//    weiboTable.hidden = YES;
//    [weiboTable registerClass:[WH_WeiboCell class] forCellReuseIdentifier:@"WH_WeiboCell"];
//    [self.view addSubview:weiboTable];
//    self.weiboTable = weiboTable;
    
    [self.view addSubview:self.windowView];
    [self.view addSubview:self.placeholderView];
}
- (void)cancelAction {
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
}
- (void)getFriend {
    NSLog(@"%@", MY_USER_ID);
    [g_server WH_listAttentionWithPage:0 userId:MY_USER_ID toView:self];
}
- (void)releasePersonAction {
    ContactSelectViewController *contactSVC = [[ContactSelectViewController alloc] init];
    contactSVC.dataSource = self.dataSource;
    [contactSVC chooseContactWihtContact:^(AddressBookFriendModel * _Nonnull friendModel) {
        self.headView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 40);
        self.contactLabel.hidden = YES;
        self.friendCollectionView.hidden = YES;
        self.line.hidden = YES;
        self.currentUserId = friendModel.toUserId;
       [self.releasePersonBtn setTitle:[NSString stringWithFormat:@"%@  ", friendModel.remarkName.length > 0 ? friendModel.remarkName : friendModel.toNickname]  forState:UIControlStateNormal];
        [JXXMPP becomeButtonStyle:self.releasePersonBtn];
        _page = 0;
        [g_server searchCircleWithUserId:friendModel.toUserId keyWord:@"" monthStr:self.lastMonthStr pageIndex:[NSString stringWithFormat:@"%d", _page] pageSize:@"5" type:self.lastType toView:self];
        self.lastUserId = friendModel.toUserId;
        self.lastKeyWord = @"";

    }];
    [g_navigation pushViewController:contactSVC animated:YES];
}
- (void)releaseTimeAction {
    self.placeholderView.hidden = YES;
    [self.pickerView reloadAllComponents];
    [self windowViewShow];
}
- (void)finishAction {
    NSLog(@"%@--%@", self.year, self.month);
    NSArray *array = [[JXXMPP getCurrentDay] componentsSeparatedByString:@"-"];
    if (([array[0] intValue] == [self.year intValue] && [array[1] intValue] < [self.month intValue])) {
        [GKMessageTool showText:@"请选择正确时间"];
        return;
    }
    if ([self.year isEqualToString:@"不限"] && ![self.month isEqualToString:@"不限"]) {
        [GKMessageTool showText:@"请选择年份"];
        return;
    }
    [self windowViewHiden];
    
    NSString *type = @"";
    NSString *monthStr = @"";
    if ([self.year isEqualToString:@"不限"] && [self.month isEqualToString:@"不限"]) {
        self.releaseString = @"不限";
        type = @"0";
    }
    if (![self.year isEqualToString:@"不限"] && ![self.month isEqualToString:@"不限"]) {
        self.releaseString = [NSString stringWithFormat:@"%@年%@月", self.year, self.month];
        type = @"1";
        monthStr = [NSString stringWithFormat:@"%@-%02d", self.year, [self.month intValue]];
    }
    if ([self.year isEqualToString:@"不限"] && ![self.month isEqualToString:@"不限"]) {
        self.releaseString = [NSString stringWithFormat:@"%@月", self.month];
        type = @"3";
        monthStr = [NSString stringWithFormat:@"%02d", [self.month intValue]];
    }
    if (![self.year isEqualToString:@"不限"] && [self.month isEqualToString:@"不限"]) {
        self.releaseString = [NSString stringWithFormat:@"%@年", self.year];
        type = @"2";
        monthStr = self.year;
    }
    if (_table.tableHeaderView) {
        [self.releaseTimeBtn setTitle:[NSString stringWithFormat:@"%@  ", self.releaseString]  forState:UIControlStateNormal];
        [JXXMPP becomeButtonStyle:self.releaseTimeBtn];
    }
    [_table reloadData];
    NSLog(@"%@-%@-%@-%@", monthStr, type, self.currentUserId, self.searchBar.text);
    _page = 0;
    [g_server searchCircleWithUserId:self.currentUserId ? self.currentUserId : MY_USER_ID keyWord:!self.currentUserId || [self.currentUserId isEqualToString:MY_USER_ID] ? self.searchBar.text : @"" monthStr:monthStr pageIndex:[NSString stringWithFormat:@"%d", _page] pageSize:@"5" type:type toView:self];
    self.lastType = type;
    self.lastMonthStr = monthStr;
    self.lastKeyWord = self.searchBar.text;
    self.lastUserId = self.currentUserId ? self.currentUserId : MY_USER_ID;
}
- (void)quitAction {
    [self windowViewHiden];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchTable) {
        return self.currentArray.count;
    } else {
        NSLog(@"%ld", self.weiboArray.count);
        return self.weiboArray.count;
    }
}
#pragma mark - Table view     --------代理--------     data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchTable) {
    AddressBookFriendCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AddressBookFriendCell"];
    if(cell==nil){
        cell = [[AddressBookFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressBookFriendCell"];
    }
    AddressBookFriendModel *model = self.currentArray[indexPath.row];
    NSString* dir  = [NSString stringWithFormat:@"%d",[model.toUserId intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir,model.toUserId];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    if (model.remarkName.length == 0) {
        cell.nicknameLabel.hidden = YES;
        cell.remarkLabel.hidden = YES;
        cell.contentLabel.hidden = NO;
        cell.contentLabel.text = model.toNickname;
        [JXXMPP getAttributeTextWithLabel:cell.contentLabel textString:self.searchBar.text color:HEXCOLOR(0x0093FF)];
    } else {
        cell.nicknameLabel.hidden = NO;
        cell.remarkLabel.hidden = NO;
        cell.contentLabel.hidden = YES;
        cell.remarkLabel.text = model.remarkName;
        cell.nicknameLabel.text = [NSString stringWithFormat:@"昵称：%@", model.toNickname];
        [JXXMPP getAttributeTextWithLabel:cell.remarkLabel textString:self.searchBar.text color:HEXCOLOR(0x0093FF)];
        [JXXMPP getAttributeTextWithLabel:cell.nicknameLabel textString:self.searchBar.text color:HEXCOLOR(0x0093FF)];
    }
    return cell;
    } else {
        NSString *CellIdentifier = @"WH_WeiboCell";
        WH_WeiboCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil){
            cell = [WH_WeiboCell alloc];
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
//        if (self.isSend) {
//            cell.contentView.userInteractionEnabled = NO;
//        }else {
//            cell.contentView.userInteractionEnabled = YES;
//        }
        
        WeiboData * weibo;
        if ([self.weiboArray count] > indexPath.row) {
            weibo=[self.weiboArray objectAtIndex:indexPath.row];
        }
        cell.delegate = self;
        cell.viewController = self;
        cell.wh_tableViewP = tableView;
        cell.tag   = indexPath.row;
        cell.isPraise = weibo.isPraise;
        cell.isCollect = weibo.isCollect;
        cell.weibo = weibo;
        [cell setupData];
        cell.wh_moreMenu.hidden = YES;
        cell.wh_btnReport.hidden = YES;
        cell.suSeparateLine.hidden = YES;
        cell.wh_btnLike.hidden = YES;
        cell.wh_tableReply.hidden = YES;
        for (UILabel *label in cell.content.subviews) {
            if (label.tag == 1314) {
                [label removeFromSuperview];
            }
        }
        UILabel *subLabel = [JXXMPP createLabelWith:weibo.match.source frame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 70, cell.content.height) color:RGB(50, 50, 50) font:14.5];
            subLabel.backgroundColor = [UIColor whiteColor];
        subLabel.numberOfLines = 0;
        subLabel.tag = 1314;
            [cell.content addSubview:subLabel];
        
//        [JXXMPP getAttributeTextWithLabel:subLabel textString:self.searchBar.text color:HEXCOLOR(0x0093FF)];
        NSMutableAttributedString *text = [subLabel.attributedText mutableCopy];
        [text addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x0093FF) range:[subLabel.text rangeOfString:self.searchBar.text]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0; // 设置行间距
        [text addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
        subLabel.attributedText = text;
        NSLog(@"=============%ld",indexPath.row);
        float height=[self tableView:tableView heightForRowAtIndexPath:indexPath];
        UIView * view=[cell.contentView viewWithTag:1200];
        if(view==nil){
            UIView* line = [[UIView alloc]init];
            line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
            line.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
            [cell.contentView  addSubview:line];
            line.tag=1200;
        }else{
            view.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
        }
//        if (self.isCollection) {
//            cell.wh_btnReply.hidden = YES;
//            cell.wh_btnLike.hidden = YES;
//            cell.wh_btnReport.hidden = YES;
//            cell.wh_btnCollection.hidden = YES;
//        }
//        if (self.isCollection || [weibo.userId isEqualToString:MY_USER_ID]) {
//
//            cell.delBtn.hidden = NO;
//        }else {
//            cell.delBtn.hidden = YES;
//        }
//
//        if (self.isSend) {
//            cell.delBtn.hidden = YES;
//        }
//
//        [self WH_doAutoScroll:indexPath];
        return cell;
    }
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchTable) {
    if (self.currentArray.count == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 40)];
    view.backgroundColor = RGB(244, 245, 250);
    UIImageView *search = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12.5, 15, 15)];
    [search setImage:[UIImage imageNamed:@"icon_search"]];
    [view addSubview:search];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(45, 12.5, 120, 15)];
    title.text = @"搜索好友的朋友圈";
    title.font = [UIFont systemFontOfSize:12.f];
    title.textColor = HEXCOLOR(0x969696);
    [view addSubview:title];
    return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 80)];
        view.backgroundColor = [UIColor whiteColor];
        UIButton *releaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        releaseButton.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 40);
        releaseButton.backgroundColor = RGB(244, 245, 250);
        [releaseButton addTarget:self action:@selector(releaseTimeAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:releaseButton];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 12.5, 100, 15)];
        label.font = [UIFont systemFontOfSize:12.0];
        label.text = self.releaseString.length == 0 ? @"发布时间" : self.releaseString;
        label.textColor = HEXCOLOR(0x969696);
        [releaseButton addSubview:label];
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 25, 12.5, 15, 15)];
        [arrow setImage:[UIImage imageNamed:@"newicon_arrowup"]];
        [releaseButton addSubview:arrow];
        UILabel *circle = [[UILabel alloc] initWithFrame:CGRectMake(20, 52.5, 60, 15)];
        circle.font = [UIFont systemFontOfSize:12.0];
        circle.text = self.weiboArray.count == 0 ? @"" : @"好友圈";
        circle.textColor = HEXCOLOR(0x8C9AB8);
        [view addSubview:circle];
        if (_table.tableHeaderView) {
            circle.frame = CGRectMake(20, 12.5, 60, 15);
            releaseButton.hidden = YES;
            view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 40);
        }
        
        return view;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchTable) {
        AddressBookFriendModel *model = self.currentArray[indexPath.row];
        [self.searchBar resignFirstResponder];
        if (model.remarkName.length > 0) {
            self.searchBar.text = model.remarkName;
        } else {
            self.searchBar.text = model.toNickname;
        }
        UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
        if (searchField) {
            searchField.textColor = HEXCOLOR(0x0093FF);
        }
//        self.searchBar.e = NO;
        self.currentUserId = model.toUserId;
        _page = 0;
    [g_server searchCircleWithUserId:self.currentUserId keyWord:@"" monthStr:@"" pageIndex:[NSString stringWithFormat:@"%d", _page] pageSize:@"5" type:@"0" toView:self];
        self.lastType = @"0";
        self.lastUserId = self.currentUserId;
        self.lastMonthStr = @"";
        self.lastKeyWord = @"";
    } else {
        WH_JXWeiboDetailViewController *weiboDetailVC = [WH_JXWeiboDetailViewController alloc];
        weiboDetailVC.user = g_myself;
        weiboDetailVC.isFrom = 2;
        WeiboData *wh_selectWeiboData = [self.weiboArray objectAtIndex:indexPath.row];
        weiboDetailVC.messageId = wh_selectWeiboData.messageId;
        weiboDetailVC = [weiboDetailVC init];
        [g_navigation pushViewController:weiboDetailVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchTable) {
        return 60;
    } else {
        if ([self.weiboArray count] != 0 && [self.weiboArray count] > indexPath.row) {
            WeiboData * data=[self.weiboArray objectAtIndex:indexPath.row];
            float height;
            if(data.shouldExtend){
                if(data.linesLimit){
                    height=data.heightOflimit+25;
                }else{
                    height=data.height+25;
                }
            }else{
                height=data.height;
            }
            if (data.location.length > 0) {
                height += 15;
            }
            WHLog(@"%f", height);
            if (data.audios.count > 0) {
                return data.imageHeight+height+6+data.fileHeight + data.shareHeight + 5;
            }
            return 80.0+data.imageHeight+height+6+data.fileHeight + data.shareHeight + 5;
//            return height + 26;
//            float n = [WH_WeiboCell getHeightByContent:data];
//            return n+20;
        }
        return 0;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchTable) {
        if (self.currentArray.count == 0) {
            return 0.01;
        }
        return 40;
    } else {
        if (_table.tableHeaderView) {
            return 40;
        }
        return 80;
    }
}
#pragma mark CollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WH_ContactCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WH_ContactCell" forIndexPath:indexPath];
    AddressBookFriendModel *model = self.currentArray[indexPath.row];
    NSString* dir  = [NSString stringWithFormat:@"%d",[model.toUserId intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir,model.toUserId];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    if (model.remarkName.length == 0) {
        cell.nicknameLabel.text = model.toNickname;
        cell.remarkLabel.text = @"";
    } else {
        cell.nicknameLabel.text = model.remarkName;
        cell.remarkLabel.text = [NSString stringWithFormat:@"昵称:%@", model.toNickname];
    }
    [JXXMPP getAttributeTextWithLabel:cell.nicknameLabel textString:self.searchBar.text color:HEXCOLOR(0x0093FF)];
    [JXXMPP getAttributeTextWithLabel:cell.remarkLabel textString:self.searchBar.text color:HEXCOLOR(0x0093FF)];
        
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //实现cell的点击方法
            AddressBookFriendModel *model = self.currentArray[indexPath.row];
            [self.searchBar resignFirstResponder];
            if ([model.remarkName containsString:self.searchBar.text]) {
                self.searchBar.text = model.remarkName;
            } else {
                self.searchBar.text = model.toNickname;
            }
            UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
            if (searchField) {
                searchField.textColor = HEXCOLOR(0x0093FF);
            }
    _table.tableHeaderView = self.headView;
        self.headView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 40);
        self.contactLabel.hidden = YES;
        self.friendCollectionView.hidden = YES;
        self.line.hidden = YES;
            self.currentUserId = model.toUserId;
    [self.releasePersonBtn setTitle:[NSString stringWithFormat:@"%@  ", model.remarkName.length > 0 ? model.remarkName : model.toNickname]  forState:UIControlStateNormal];
    [JXXMPP becomeButtonStyle:self.releasePersonBtn];
    _page = 0;
    [g_server searchCircleWithUserId:self.currentUserId keyWord:@"" monthStr:@"" pageIndex:[NSString stringWithFormat:@"%d", _page] pageSize:@"5" type:@"0" toView:self];
    self.lastType = @"0";
    self.lastMonthStr = @"";
    self.lastKeyWord = @"";
    self.lastUserId = self.currentUserId;
}
#pragma mark -UIPickerViewDelegate
//返回有几列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}
//返回指定列的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 6;
    } else {
        return 13;
    }
}
//返回指定列的行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35.0f;
}
//返回指定列的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.pickerView.width/2;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pickerView.width/2, 35)];
    title.textColor = HEXCOLOR(0xB0B0B0);
    title.textAlignment = NSTextAlignmentCenter;
    [view addSubview:title];
    NSInteger year = [[[[JXXMPP getCurrentDay] componentsSeparatedByString:@"-"] firstObject] integerValue];
    if (component == 0) {
        if (row == 0) {
            title.text = @"不限";
        } else {
            title.text = [NSString stringWithFormat:@"%ld", year - row + 1];
        }
    } else {
        if (row == 0) {
        title.text = @"不限";
        } else {
        title.text = [NSString stringWithFormat:@"%ld", row];
        }
    }
    return view;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger year = [[[[JXXMPP getCurrentDay] componentsSeparatedByString:@"-"] firstObject] integerValue];
    if (component == 0) {
        if (row == 0) {
            self.year = @"不限";
        } else {
            self.year = [NSString stringWithFormat:@"%ld", year - row + 1];
        }
    } else {
        if (row == 0) {
            self.month = @"不限";
        } else {
            self.month = [NSString stringWithFormat:@"%ld", row];
        }
    }
}
//服务器返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    //更新本地好友
    if ([aDownload.action isEqualToString:wh_act_AttentionList]) {
        [_wait stop];
        [self.dataSource removeAllObjects];
        for (NSDictionary *dic in array1) {
            AddressBookFriendModel *model = [[AddressBookFriendModel alloc] init];
            model.remarkName = [JXXMPP getString:dic[@"remarkName"]];
            model.toUserId = [JXXMPP getString:dic[@"toUserId"]];
            model.toNickname = [JXXMPP getString:dic[@"toNickname"]];
            model.userNickname = model.remarkName.length > 0 ? model.remarkName : model.toNickname;
            NSLog(@"%@", model.userNickname);
            [self.dataSource addObject:model];
        }
    }
    //搜索朋友圈
    if ([aDownload.action isEqualToString:act_getCircleWithCondition]) {
        self.wh_isShowFooterPull = [array1 count] >= 5;

        if(_page==0) {
            [self.weiboArray removeAllObjects];
        }

        //数据莫名为空
        if(self.weiboArray != nil){
            NSMutableArray * tempData = [[NSMutableArray alloc] init];
            for (int i=0; i<[array1 count]; i++) {
                NSDictionary* row = [array1 objectAtIndex:i];
                WeiboData * weibo=[[WeiboData alloc]init];
                [weibo WH_getDataFromDict:row];
                [tempData addObject:weibo];
            }
            if (tempData.count > 0){
                [self.weiboArray addObjectsFromArray:tempData];
                [self loadWeboData:self.weiboArray complete:nil formDb:NO];
            }else {
                if (dict) {
                    WeiboData *data = [[WeiboData alloc] init];
                    [data WH_getDataFromDict:dict];
                    [tempData addObject:data];
                    [self.weiboArray addObjectsFromArray:tempData];
                    [self loadWeboData:self.weiboArray complete:nil formDb:NO];
                }
            }
        }
        self.searchTable.hidden = YES;
        _table.hidden = NO;
        if (self.weiboArray.count == 0) {
            self.placeholderView.hidden = NO;
        } else {
            self.placeholderView.hidden = YES;
        }
        [_table reloadData];

    }
}
-(void)loadWeboData:(NSArray*)webos complete:(void(^)())complete formDb:(BOOL)fromDb
{
    //用i循环遍历
    for(int i = 0 ; i < [webos count];i++){
        WeiboData * weibo = [webos objectAtIndex:i];
        weibo.match=nil;
        [weibo setMatch];
        weibo.uploadFailed=NO;
        weibo.linesLimit=YES;
        weibo.imageHeight=[WH_HBShowImageControl WH_heightForFileStr:weibo.smalls];
        weibo.replyHeight=[weibo heightForReply];
        if(weibo.type == weibo_dataType_file) weibo.fileHeight = 90;
        if (weibo.type == weibo_dataType_share) {
            weibo.shareHeight = 70;
        }
    }
    //需要在遍历时改变内容，所以弃用
//    for(WeiboData * weibo in webos){
//        weibo.match=nil;
//        [weibo setMatch];
//        weibo.uploadFailed=NO;
//        weibo.linesLimit=YES;
//        weibo.imageHeight=[WH_HBShowImageControl heightForFileStr:weibo.smalls];
//        weibo.replyHeight=[weibo heightForReply];
//    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        refreshCount++;
        [_table reloadData];
        if(complete){
            complete();
        }
    });
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
#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (self.searchTable.hidden) {
        return NO;
    }
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSLog(@"输入的关键字是---%@---%lu",searchText,(unsigned long)searchText.length);
    if (searchBar.text.length == 0) {
        self.placeholderView.hidden = YES;
        _table.hidden = YES;
        _table.tableHeaderView = nil;
        [self.weiboArray removeAllObjects];
        [self.releaseTimeBtn setTitle:@"发布时间  " forState:UIControlStateNormal];
        [self.releasePersonBtn setTitle:@"发布人  " forState:UIControlStateNormal];
        [JXXMPP becomeButtonStyle:self.releaseTimeBtn];
        [JXXMPP becomeButtonStyle:self.releasePersonBtn];
        self.searchTable.hidden = NO;
        self.releaseString = @"";
        self.lastType = 0;
        self.lastMonthStr = @"";
        self.lastKeyWord = nil;
        self.lastUserId = nil;
        self.currentUserId = nil;
        [self.currentArray removeAllObjects];
        [self.searchTable reloadData];
        UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
        if (searchField) {
            searchField.textColor = HEXCOLOR(0x3A404C);
        }
        [self.searchBar becomeFirstResponder];
        return;
    }
    [self.currentArray removeAllObjects];
    for (AddressBookFriendModel *model in self.dataSource) {
        if ([model.remarkName containsString:searchText] || [model.toNickname containsString:searchText]) {
            [self.currentArray addObject:model];
        }
    }
    if (self.currentArray.count == 0) {
        self.searchTable.hidden = YES;
        return ;
    } else {
        self.searchTable.hidden = NO;
        [self.searchTable reloadData];
        self.searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
}

//点击键盘上的搜索时
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%@", searchBar.text);
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.textColor = HEXCOLOR(0x0093FF);
    }
    _table.tableHeaderView = self.headView;
    if (self.currentArray.count == 0) {
        self.headView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 40);
        self.contactLabel.hidden = YES;
        self.friendCollectionView.hidden = YES;
        self.line.hidden = YES;
    } else {
        self.headView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.line.bottom);
        self.contactLabel.hidden = NO;
        self.friendCollectionView.hidden = NO;
        self.line.hidden = NO;
    }
    _page = 0;
    [g_server searchCircleWithUserId:MY_USER_ID keyWord:searchBar.text monthStr:@"" pageIndex:[NSString stringWithFormat:@"%d", _page] pageSize:@"5" type:@"0" toView:self];
    self.lastType = @"0";
    self.lastMonthStr = @"";
    self.lastKeyWord = searchBar.text;
    self.lastUserId = MY_USER_ID;
    [self.searchBar resignFirstResponder];
    [self.friendCollectionView reloadData];
}

//发布时间弹出/收回
- (void)windowViewShow {
    [UIView animateWithDuration:.2 animations:^{
        self.windowView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}
- (void)windowViewHiden{
    [UIView animateWithDuration:.2 animations:^{
        self.windowView.frame = CGRectMake(0, 2 * JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}
#pragma mark - 懒加载
- (UIView *)windowView {
    if (!_windowView) {
        _windowView = [[UIView alloc] initWithFrame:CGRectMake(0, 2 * JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
        _windowView.backgroundColor = RGBA(0, 0, 0, 0.5);
//        _windowView.alpha = 0.5;
        
        UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 310, JX_SCREEN_WIDTH, 320)];
        content.backgroundColor = [UIColor whiteColor];
        content.layer.cornerRadius = 10;
        content.layer.masksToBounds = YES;
        [_windowView addSubview:content];
        
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 58)];
        top.backgroundColor = HEXCOLOR(0xFCFCFC);
        [content addSubview:top];
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        cancel.frame = CGRectMake(12, 15, 28, 28);
        [cancel setImage:[UIImage imageNamed:@"弹窗关闭"] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(quitAction) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:cancel];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(content.width/2- 40, 16.5, 80, 15)];
        title.text = @"发布时间";
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = HEXCOLOR(0x8C9AB8);
        title.font = [UIFont systemFontOfSize:18.0];
        [top addSubview:title];
        UIButton *finish = [UIButton buttonWithType:UIButtonTypeCustom];
        finish.frame = CGRectMake(JX_SCREEN_WIDTH - 55, 15, 55, 28);
        [finish setTitle:@"完成" forState:UIControlStateNormal];
        [finish setTitleColor:HEXCOLOR(0x0093FF) forState:UIControlStateNormal];
        [finish addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:finish];
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 88, JX_SCREEN_WIDTH, 200)];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        [content addSubview:pickerView];
        self.pickerView = pickerView;
    }
    return _windowView;
}
- (UIView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP + 40, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP - 40)];
        _placeholderView.backgroundColor = RGB(244, 245, 250);
        _placeholderView.hidden= YES;
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, JX_SCREEN_WIDTH - 20, 20)];
        content.text = @"未搜索到相关朋友圈";
        content.textAlignment = NSTextAlignmentCenter;
        content.font = [UIFont systemFontOfSize:13];
        content.textColor = HEXCOLOR(0xBAC3D5);
        [_placeholderView addSubview:content];
    }
    return _placeholderView;
}
- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 220)];
        _headView.backgroundColor = [UIColor whiteColor];
        UIView *top = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, _headView.width, 40)];
        top.backgroundColor = RGB(244, 245, 250);
        [_headView addSubview:top];
        UIButton *releasePerson = [JXXMPP createButtonWith:@"发布人  " frame:CGRectMake(0, 0, _headView.width/2, 40) color:HEXCOLOR(0x969696) font:12 image:[UIImage imageNamed:@"newicon_arrowup"]];
        [JXXMPP becomeButtonStyle:releasePerson];
        [releasePerson addTarget:self action:@selector(releasePersonAction) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:releasePerson];
        self.releasePersonBtn = releasePerson;
        UIButton *releaseTime = [JXXMPP createButtonWith:@"发布时间  " frame:CGRectMake(_headView.width/2, 0, _headView.width/2, 40) color:HEXCOLOR(0x969696) font:12 image:[UIImage imageNamed:@"newicon_arrowup"]];
        [JXXMPP becomeButtonStyle:releaseTime];
        [releaseTime addTarget:self action:@selector(releaseTimeAction) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:releaseTime];
        self.releaseTimeBtn = releaseTime;
        UILabel *contact = [JXXMPP createLabelWith:@"相关联系人" frame:CGRectMake(20, 52, 80, 15) color:HEXCOLOR(0x8C9AB8) font:12];
        [_headView addSubview:contact];
        self.contactLabel = contact;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        //设置单元格大小
        layout.itemSize = CGSizeMake(65, 120);
        //    layout.itemSize = CGSizeMake(itemWidth, 165);
        //最小行间距(默认为10)
        layout.minimumLineSpacing = 15;
        //最小item间距（默认为10）
        layout.minimumInteritemSpacing = 15;
        //设置UICollectionView的滑动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //设置UICollectionView的间距
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 0);
        
        UICollectionView *firstCollect = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 80, _headView.width, 120) collectionViewLayout:layout];
        firstCollect.backgroundColor = [UIColor clearColor];
        //遵循CollectionView的代理方法
        firstCollect.delegate = self;
        firstCollect.dataSource = self;
        //注册cell
        [firstCollect registerClass:[WH_ContactCell class] forCellWithReuseIdentifier:@"WH_ContactCell"];
        [_headView addSubview:firstCollect];
        self.friendCollectionView = firstCollect;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, firstCollect.bottom, _headView.width, 10)];
        line.backgroundColor = RGB(244, 245, 250);
        [_headView addSubview:line];
        _headView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, line.bottom);
        self.line = line;
    }
    return _headView;
}
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (NSMutableArray *)currentArray {
    if (!_currentArray) {
        _currentArray = [NSMutableArray array];
    }
    return _currentArray;
}
- (NSMutableArray *)weiboArray {
    if (!_weiboArray) {
        _weiboArray = [NSMutableArray array];
    }
    return _weiboArray;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
