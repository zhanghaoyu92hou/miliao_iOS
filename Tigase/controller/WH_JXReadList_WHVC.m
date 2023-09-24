//
//  WH_JXReadList_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2017/9/2.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXReadList_WHVC.h"
#import "WH_JXReadList_WHCell.h"

@interface WH_JXReadList_WHVC ()
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation WH_JXReadList_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM);
    [self WH_createHeadAndFoot];
    
    self.title = Localized(@"JX_ReadList");
    _array = [NSMutableArray array];

    
    [self getLocData];
}

- (void) getLocData {
    _array = [self.msg fetchReadList];

    
    [self.tableView reloadData];
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    NSString* cellName = [NSString stringWithFormat:@"readListCell"];
    WH_JXReadList_WHCell *readListCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!readListCell) {
        readListCell = [[WH_JXReadList_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    readListCell.room = _room;
    WH_JXUserObject * obj = _array[indexPath.row];
    [readListCell setData:obj];
    
    return readListCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
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
