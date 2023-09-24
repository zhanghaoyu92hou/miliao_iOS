//
//  WH_selectValue_WHVC.h
//  sjvodios
//
//  Created by  on 19-5-5-29.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@protocol JXServerResult;

@interface WH_selectValue_WHVC : WH_admob_WHViewController{
    int h1;
}
-(void)getValuesfromArray:(NSArray*)a name:(NSString*)name;
@property(nonatomic,strong) NSMutableArray* values;
@property(nonatomic,strong) NSMutableArray* numbers;
@property(nonatomic,assign) int selected;//选中的索引号
@property(nonatomic,strong) NSString* selValue;//选中的字符串
@property(nonatomic,assign) int selNumber;//选中的数值
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
@property(assign) BOOL quickSelect;//是否快速选择,不需要完成按钮
@end
