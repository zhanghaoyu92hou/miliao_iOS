//
//  JXMoreSelectVC.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/4/16.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_JXMoreSelect_WHVC;

@protocol WH_JXMoreSelectVCDelegate <NSObject>

- (void)didSureBtn:(WH_JXMoreSelect_WHVC *)moreSelectVC indexStr:(NSString *)indexStr;

@end


@interface WH_JXMoreSelect_WHVC : UIViewController

@property (nonatomic, strong) NSString *wh_indexStr;
@property (weak, nonatomic) id <WH_JXMoreSelectVCDelegate>delegate;


- (instancetype)initWithTitle:(NSString *)title dataArray:(NSArray *)dataArray;



- (void)sp_upload;
@end
