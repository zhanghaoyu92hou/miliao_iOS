//
//  WH_JXMyFile.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXMyFile.h"
//#import "WH_JXChat_WHViewController.h"
//#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
//#import "WH_JX_WHCell.h"
//#import "WH_JXRoomPool.h"
#import "JXTableView.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_menuImageView.h"
#import "QCheckBox.h"
//#import "XMPPRoom.h"
//#import "WH_JXRoomObject.h"
#import "WH_FileList_WHCell.h"

@interface WH_JXMyFile ()

@end

@implementation WH_JXMyFile

- (id)init
{
    self = [super init];
    if (self) {
        self.title = Localized(@"WaHu_JXMyFileVC_SelFile");
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack   = YES;
        //self.view.frame = g_window.bounds;
        [self WH_createHeadAndFoot];
        self.wh_isShowFooterPull = NO;
        _selMenu = 0;
        
        //添加文件的确定按钮，无用
//        UIButton* _btn;
//        _btn = [UIFactory WH_create_WHCommonButton:@"确定" target:self action:@selector(onAdd)];
//        _btn.frame = CGRectMake(JX_SCREEN_WIDTH - 70, 20+10, 60, 24);
//        [self.wh_tableHeader addSubview:_btn];
    }
    return self;
}


- (void)onAdd{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _array=[[NSMutableArray alloc] init];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_FileList_WHCell *cell=nil;
//    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%d",_refreshCount,indexPath.row];
    NSString* cellName = [NSString stringWithFormat:@"WH_FileList_WHCell"];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
//        cell = [WH_FileList_WHCell alloc];
//        cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
        cell = [[NSBundle mainBundle] loadNibNamed:@"WH_FileList_WHCell" owner:self options:nil][0];
    }
    NSString *s=_array[indexPath.row];
    
    [_table WH_addToPool:cell];
    cell.title.text = [s lastPathComponent];
    cell.subtitle.text = [s pathExtension];
    cell.headImage.image = [UIImage imageNamed:@"WH_file_button_normal"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    NSString *s=_array[indexPath.row];
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:s waitUntilDone:NO];
    
    [self actionQuit];
//    _pSelf = nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    [cell retain];
    [_table WH_delFromPool:cell];
}

- (void)dealloc {
    [_array removeAllObjects];
//    [_array release];
//    [super dealloc];
}
//读到聊天记录里面的图片
-(void)getArrayData{
    //获取路径下的所有文件
    _array=[FileInfo getFiles:myTempFilePath];
}

-(void)refresh{
    [self WH_stopLoading];
    _refreshCount++;
    [_array removeAllObjects];
//    [_array release];
    [self getArrayData];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)WH_scrollToPageUp{
    [self refresh];
}


- (void)sp_didUserInfoFailed {
    NSLog(@"Get Info Failed");
}
@end
