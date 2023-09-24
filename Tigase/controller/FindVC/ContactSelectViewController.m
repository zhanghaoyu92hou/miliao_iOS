//
//  ContactSelectViewController.m
//  Tigase
//
//  Created by 政委 on 2020/6/4.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "ContactSelectViewController.h"
#import "AddressBookFriendCell.h"
#import "AddressBookFriendModel.h"
#import "BMChineseSort.h"

@interface ContactSelectViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *contactTable;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@end

@implementation ContactSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getChineseSort];
    [self configUI];
}
- (void)getChineseSort {
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:self.dataSource key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            NSLog(@"%@--%@--%@", unGroupArr, sectionTitleArr, sortedObjArr);
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [self.contactTable reloadData];
        }
    }];
}
- (void)configUI {

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
    UIButton *back = [JXXMPP createButtonWithFrame:CGRectMake(10, JX_SCREEN_TOP - 38, 28, 28) image:[UIImage imageNamed:@"title_back"]];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:back];
    
    UILabel *title = [JXXMPP createLabelWith:@"选择联系人" frame:CGRectMake(JX_SCREEN_WIDTH/2 - 50, JX_SCREEN_TOP - 35, 100, 25) color:HEXCOLOR(0x333333) font:18];
    title.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:title];
       
       UITableView *contactTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP) style:UITableViewStylePlain];
       contactTable.delegate = self;
       contactTable.dataSource = self;
       contactTable.backgroundColor = RGB(244, 245, 250);
       contactTable.separatorStyle = UITableViewCellAccessoryNone;
       [contactTable registerClass:[AddressBookFriendCell class] forCellReuseIdentifier:@"AddressBookFriendCell"];
       [self.view addSubview:contactTable];
       self.contactTable = contactTable;

}
- (void)backAction {
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
}
- (void)chooseContactWihtContact:(ChooseContact)contactInfo {
    self.contactInfo = contactInfo;
}

#pragma mark - Table view     --------代理--------     data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.letterResultArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.letterResultArr[section];
    return array.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressBookFriendCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AddressBookFriendCell"];
    if(cell==nil){
        cell = [[AddressBookFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressBookFriendCell"];
    }
    AddressBookFriendModel *model = self.letterResultArr[indexPath.section][indexPath.row];
    NSString* dir  = [NSString stringWithFormat:@"%d",[model.toUserId intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir,model.toUserId];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    if (model.remarkName.length == 0) {
        cell.nicknameLabel.hidden = YES;
        cell.remarkLabel.hidden = YES;
        cell.contentLabel.hidden = NO;
        cell.contentLabel.text = model.toNickname;
    } else {
        cell.nicknameLabel.hidden = NO;
        cell.remarkLabel.hidden = NO;
        cell.contentLabel.hidden = YES;
        cell.remarkLabel.text = model.remarkName;
        cell.nicknameLabel.text = [NSString stringWithFormat:@"昵称：%@", model.toNickname];
    }
    return cell;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 30)];
    view.backgroundColor = RGB(244, 245, 250);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = [NSString stringWithFormat:@"%@", self.indexArray[section]];
    NSLog(@"%@", label.text);
    label.textColor = HEXCOLOR(0x8C9AB8);
    [view addSubview:label];
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressBookFriendModel *model = self.letterResultArr[indexPath.section][indexPath.row];
    _contactInfo(model);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [g_navigation WH_dismiss_WHViewController:self animated:YES];
    });
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
#pragma mark - 懒加载
- (NSMutableArray *)indexArray {
    if (!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}
- (NSMutableArray *)letterResultArr {
    if (!_letterResultArr) {
        _letterResultArr = [NSMutableArray array];
    }
    return _letterResultArr;
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
