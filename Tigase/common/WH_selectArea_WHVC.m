//
//  WH_selectArea_WHVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_selectArea_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
//#import "WH_JX_WHCell.h"
#import "WH_JXRoomPool.h"
#import "JXTableView.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_menuImageView.h"
#import "WH_JXConstant.h"
#import "WH_selectArea_WHVC.h"

#define row_height 40

@interface WH_selectArea_WHVC ()

@end

@implementation WH_selectArea_WHVC
@synthesize parentId,parentName;
@synthesize selected;
@synthesize delegate;
@synthesize didSelect;
@synthesize selValue;

- (id)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack   = YES;
        self.title = self.parentName;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self WH_createHeadAndFoot];
        self.wh_isShowFooterPull = NO;
        self.wh_isShowHeaderPull = NO;
        
        _table.backgroundColor = [UIColor whiteColor];
        _selMenu = 0;
        _array = [g_constant getArea:parentId];
        
        _keys = [_array allKeys];
        _keys = [_keys sortedArrayUsingSelector:@selector(compare:)];
//        [_keys retain];
    }
    return self;
}

- (void)dealloc {
    self.parentName = nil;
    self.selValue = nil;
//    [_keys release];
//    [_array release];
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return [_array count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
        cell = [UITableViewCell alloc];
        [_table WH_addToPool:cell];
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, row_height)];
        if(indexPath.row==0)
            p.text = parentName;
        else
            p.text = [_array objectForKey:[_keys objectAtIndex:indexPath.row-1]];
        p.font = sysFontWithSize(15);
        [cell addSubview:p];
//        [p release];
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(18,row_height-0.5,JX_SCREEN_WIDTH-18-20,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [cell addSubview:line];
//        [line release];
        
        if(indexPath.row>0){
            UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_flag"]];
            iv.frame = CGRectMake(JX_SCREEN_WIDTH-20, (row_height-13)/2, 7, 13);
            [cell addSubview:iv];
//            [iv release];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selValue = self.parentName;
    self.selected = self.parentId;
    if(indexPath.row>0){
        self.selValue = [_array objectForKey:[_keys objectAtIndex:indexPath.row-1]];
        self.selected = [[_keys objectAtIndex:indexPath.row-1] intValue];
    }
    if (delegate && [delegate respondsToSelector:didSelect])
//        [delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
    [self actionQuit];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}

@end
