//
//  GKDYSearchViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYSearch_WHViewController.h"

@interface WH_GKDYSearch_WHViewController ()

@end

@implementation WH_GKDYSearch_WHViewController

- (void)loadView {
    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WechatIMG240"]];
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
}



@end
