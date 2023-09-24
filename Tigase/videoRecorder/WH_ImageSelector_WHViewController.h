//
//  WH_ImageSelector_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/1/19.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@protocol ImageSelectorViewDelegate <NSObject>

-(void)imageSelectorDidiSelectImage:(NSString *)imagePath;

@end

@interface WH_ImageSelector_WHViewController : WH_admob_WHViewController


@property (nonatomic,strong) NSArray * imageFileNameArray;
@property (nonatomic, weak) id<ImageSelectorViewDelegate> imgDelegete;


@end
