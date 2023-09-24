//
//  MiXin_JXTelAreaList_MiXinVC.m
//  wahu_im
//
//  Created by daxiong on 17/4/24.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "WH_CountryCodeViewController.h"
#import "JXMyTools.h"
#import "LetterIndexNavigationView.h"
#import "WH_JXTelArea_WHCell.h"

@interface WH_CountryCodeViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, LetterIndexNavigationViewDelegate>
{
    NSString *_language;
    NSArray *indexArray;
    NSMutableDictionary *allCountiesDic;
    UITableView *countyTable;
    BOOL startSearch;
}
@property (nonatomic, strong) NSMutableArray *telAreaArray;
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) LetterIndexNavigationView *letterIndexView;
@end

@implementation WH_CountryCodeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        self.title = Localized(@"JX_SelectCountryOrArea");
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        
        
        _telAreaArray = [[NSMutableArray alloc] init];
        _telAreaArray = [g_constant.telArea mutableCopy];
       
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    _language = [[NSString alloc] initWithFormat:@"%@",g_constant.sysLanguage];

    [self createHeadAndFoot];
    [self customView];
    [self loadSearchView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self handleDataSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.letterIndexView.keys = indexArray;
            [countyTable reloadData];
        });
    });
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void) customView {
    
    countyTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP) style:UITableViewStylePlain];
    countyTable.backgroundColor = g_factory.globalBgColor;
    countyTable.delegate = self;
    countyTable.dataSource = self;
    countyTable.separatorInset = UIEdgeInsetsZero;
    countyTable.tableFooterView = [UIView new];
    [self.view addSubview:countyTable];
    
    [self.view addSubview:self.letterIndexView];
    
}
- (void)loadSearchView {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
    headView.backgroundColor = UIColor.whiteColor;
    countyTable.tableHeaderView = headView;
    
    //搜索输入框
    
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, headView.height)];
    [searchBtn setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    

    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 7, headView.width-2*g_factory.globelEdgeInset, headView.height-2*7)];
    _seekTextField.delegate = self;
    _seekTextField.placeholder = Localized(@"JX_EnterCountry");
    [_seekTextField setFont:pingFangRegularFontWithSize(13)];
    [_seekTextField setTintColor:HEXCOLOR(0xEBECEF)];
    _seekTextField.backgroundColor = HEXCOLOR(0xFAFBFC);
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    _seekTextField.leftView = searchBtn;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _seekTextField.layer.cornerRadius = 15;
    _seekTextField.clipsToBounds = YES;
    _seekTextField.layer.borderColor = HEXCOLOR(0xEBECEF).CGColor;
    _seekTextField.layer.borderWidth = 1;
    [headView addSubview:_seekTextField];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, headView.bottom, headView.width, 1)];
    bottomLine.backgroundColor = g_factory.globalBgColor;
    [headView addSubview:bottomLine];
}
- (LetterIndexNavigationView *)letterIndexView
{
    if (!_letterIndexView) {
        _letterIndexView = [[LetterIndexNavigationView alloc]init];
        _letterIndexView.frame =  CGRectMake(self.view.right-20.0f, 144, 20.0f, JX_SCREEN_HEIGHT-144*2);
        _letterIndexView.isNeedSearchIcon = NO;
        _letterIndexView.delegate = self;
    }
    return _letterIndexView;
}
- (void)handleDataSource {
    //中国按拼音排序 其他国家按英文
    allCountiesDic = [NSMutableDictionary new];
    for (NSDictionary *item in _telAreaArray) {
        NSString *letter = [_language isEqualToString:@"zh"] ? [self firstCharactor:item[@"country"]] : [item[@"enName"] uppercaseString];
        NSMutableArray *newItems = allCountiesDic[letter];
        if (newItems == nil) {
            newItems = [NSMutableArray new];
        }
        [newItems addObject:item];
        [allCountiesDic setObject:newItems forKey:letter];
    }
    NSString *areaStr = @"86";
    NSString *codeStr = [g_default objectForKey:kMY_USER_AREACODE];
    if (!IsStringNull(codeStr)) {
        areaStr = [g_default objectForKey:kMY_USER_AREACODE];
    }
    NSMutableArray *tempKeys = [NSMutableArray new];
    NSArray *tempArray = [[allCountiesDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [tempKeys addObjectsFromArray:tempArray];
    for (NSDictionary *dic in _telAreaArray) {
        if ([areaStr integerValue] == [dic[@"prefix"] integerValue]) {
            [allCountiesDic setObject:@[dic] forKey:@"默认"];
            break;
        }
    }
    [tempKeys insertObject:@"默认" atIndex:0];
    indexArray = [NSArray arrayWithArray:tempKeys];
}
//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}
#pragma mark --- UITextField
- (void) textFieldDidChange:(UITextField *)textField {
    
    [_telAreaArray removeAllObjects];
    if (textField.text.length > 0) {
        _telAreaArray = [g_constant getSearchTelAreaWithName:textField.text];
        startSearch = YES;
    }else {
        startSearch = NO;
    }
    
    [countyTable reloadData];
}

#pragma mark UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return startSearch ? 1 : indexArray.count;//_areaArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return startSearch ? _telAreaArray.count : [allCountiesDic[indexArray[section]] count];//[[_areaArray objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    WH_JXTelArea_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXTelArea_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    NSArray *countries = allCountiesDic[indexArray[indexPath.section]];
    NSDictionary *dic = startSearch ? _telAreaArray[indexPath.row] : countries[indexPath.row];
    [cell doRefreshWith:dic language:_language];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.wh_telAreaDelegate respondsToSelector:self.wh_didSelect]) {
        //        [self.wh_telAreaDelegate performSelector:self.didSelect withObject:[[_telAreaArray objectAtIndex:indexPath.row] objectForKey:@"prefix"]];
        NSString*areaCodeString = nil;
        if (startSearch) {
            areaCodeString = [NSString stringWithFormat:@"%@",_telAreaArray[indexPath.row][@"prefix"]];
        } else {
            NSString *key = indexArray[indexPath.section];
            NSArray *keyCountries = [allCountiesDic objectForKey:key];
            NSDictionary *countryDic = keyCountries[indexPath.row];
            areaCodeString = [NSString stringWithFormat:@"%@",[countryDic objectForKey:@"prefix"]];
        }
        
        [self.wh_telAreaDelegate performSelectorOnMainThread:self.wh_didSelect withObject:areaCodeString waitUntilDone:NO];
    }
    [self actionQuit];
}

#pragma mark ----- UITableView Header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  startSearch ? 0 : 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"sectionHeader";
    UIView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (!headerView) {
        CGRect rect = [tableView rectForHeaderInSection:section];
        headerView = [[UIView alloc] initWithFrame:rect];
        headerView.height = startSearch ? 0 : rect.size.height;
        headerView.backgroundColor = g_factory.globalBgColor;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 5, headerView.width-10, headerView.height-10)];
        titleLabel.backgroundColor = g_factory.globalBgColor;
        titleLabel.font = pingFangMediumFontWithSize(16);
        titleLabel.tag = 100;
        titleLabel.textColor = HEXCOLOR(0x8C9AB8);
        [headerView addSubview:titleLabel];
    }
    if (indexArray.count > 0 ) {
        UILabel *label = (UILabel *)[headerView viewWithTag:100];
        label.text = indexArray[section];
    }
    
    return headerView;
}


#pragma mark - letter index delegate
- (void)LetterIndexNavigationView:(LetterIndexNavigationView *)LetterIndexNavigationView didSelectIndex:(NSInteger)index
{
    if (index==0) {
        [countyTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }else{
        [countyTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)tableViewIndexTouchesBegan:(LetterIndexNavigationView *)tableViewIndex {
    
}

- (void)tableViewIndexTouchesEnd:(LetterIndexNavigationView *)tableViewIndex {
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
