//
//  GKDYPlayerViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYPlayer_WHViewController.h"

@interface WH_GKDYPlayer_WHViewController ()

@end

@implementation WH_GKDYPlayer_WHViewController

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.gk_navigationBar.hidden = YES;
    self.gk_statusBarHidden = YES;
    
    [self.view addSubview:self.wh_videoView];
    self.wh_videoView.type = self.type;
    [self.wh_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [self.wh_videoView destoryPlayer];
}

#pragma mark - 懒加载
- (GKDYVideoView *)wh_videoView {
    if (!_wh_videoView) {
        _wh_videoView = [[GKDYVideoView alloc] initWithVC:self isPushed:NO];
    }
    return _wh_videoView;
}


- (void)sp_getUserFollowSuccess {
    NSLog(@"Get Info Success");
}
@end
