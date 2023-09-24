//
//  WH_ContentModification_WHView.h
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
//  修改内容/提示内容

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_ContentModification_WHView : UIView<UITextFieldDelegate>

@property (nonatomic ,assign) BOOL isEdit ;//yes:可编辑
@property (nonatomic ,assign) BOOL isLimit; //字数显示 yes:限制
@property (nonatomic, assign) NSInteger wh_limitLen;
@property (nonatomic ,copy) NSString *title;
@property(nonatomic, assign) BOOL isShow;
@property (nonatomic ,strong) UITextField *wh_cTextField;
@property (nonatomic ,copy) NSString *wh_content; //显示的内容

@property (nonatomic ,assign) NSInteger contentType ; //提示类型 0：默认类型 1：进群验证提示

@property (nonatomic, copy) void (^selectActionBlock)(NSInteger buttonTag ,NSString *content);
@property (nonatomic ,copy) void (^closeBlock)();

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content isEdit:(BOOL)edit isLimit:(BOOL)limit;

//进群验证提示框
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title promptContent:(NSString *)pContent content:(NSString *)content isEdit:(BOOL)edit isLimit:(BOOL)limit;



NS_ASSUME_NONNULL_END
- (void)sp_getMediaData;
@end
