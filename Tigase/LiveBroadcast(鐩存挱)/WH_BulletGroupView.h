//
//  WH_BulletGroupView.h
//  BulletForIOS
//
//  Created by 王朝阳 on 16/4/27.
//  Copyright © 2016年 Risun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_BulletView.h"

@interface WH_BulletGroupView : UIView

@property (nonatomic, strong) NSArray<NSString *> *dataSource;   //原始数据源,后面加入的数据不进入这里;数据是nsstring类型的

/*
 *我们弹幕group是横跨整个屏幕的，右边出现，左边消失
 *originY       视图原点的Y坐标
 *traHeight     弹幕轨道的高度
 *traNum        弹幕轨道的数量
 */
-(instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight rowNum:(NSUInteger)rowNum;

//这个字典中设置弹幕的字体、颜色、背景，具体哪些键等。
-(void)setBulletDic:(BulletSettingDic *)bulletDic;

//在数据源中添加数据,在原数据源数据取完后，会继续获取这里的数据显示。
-(void)addObjectsToDataSource:(NSArray <NSString *>*)arrayToAdd;

/**
 添加单个弹幕
 */
-(void)showNewBarrage:(NSString *)content;

//开始显示弹幕
-(void)startBullet;

//停止显示弹幕
-(void)stopBullet;

//暂停
-(void)pauseBullet;

//继续
-(void)resumeBullet;

@end
