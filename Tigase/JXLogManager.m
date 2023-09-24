//
//  WH_PrintManager.m
//  wahu_imChat
//
//  Created by Apple on 2019/6/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_PrintManager.h"
#import "WH_DragView.h"

@interface WH_PrintManager ()

@property (nonatomic, strong) UITextView *logTextView;

@end

@implementation WH_PrintManager

+ (instancetype)shared{
    static WH_PrintManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WH_PrintManager alloc] init];
        [manager showDragView];
    });
    return manager;
}

- (void)showDragView{
#ifdef DEBUG
    WH_DragView *logoView = [[WH_DragView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY([UIScreen mainScreen].bounds) , 70, 70)];
    logoView.layer.cornerRadius = 14;
    logoView.wh_isKeepBounds = YES;
    [[self keyWindow] addSubview:logoView];
    __weak typeof(self) weakSelf = self;
    logoView.wh_clickDragViewBlock = ^(WH_DragView *dragView){
        if (dragView.tag != 1001) {
            dragView.tag = 1001;
            [weakSelf showOutputLogPan];
            [[weakSelf keyWindow] bringSubviewToFront:dragView];
        } else {
            dragView.tag = 0;
            [weakSelf hideOutputLogPan];
        }
    };
#endif
}

- (UITextView *)logTextView{
    if (!_logTextView) {
        _logTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) / 3)];
        _logTextView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _logTextView.textColor = [UIColor whiteColor];
        _logTextView.editable = NO;
        _logTextView.text = @"实时日志:\n";
        _logTextView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_logTextView.bounds));
        [[self keyWindow] addSubview:_logTextView];
    }
    return _logTextView;
}

- (void)showOutputLogPan{
    [UIView animateWithDuration:0.25 animations:^{
        self.logTextView.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideOutputLogPan{
    [UIView animateWithDuration:0.25 animations:^{
        self.logTextView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_logTextView.bounds));
    }];
}

- (UIWindow *)keyWindow{
    UIResponder *delegate = (UIResponder *)([UIApplication sharedApplication].delegate);
    UIWindow *keyWindow = [delegate valueForKey:@"window"];
    return keyWindow;
}

FOUNDATION_EXPORT void output_log(NSString * _Nullable format, ...){
    va_list args;
    va_start(args, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    dispatch_async(dispatch_get_main_queue(), ^{
        [WH_PrintManager shared].logTextView.text = [[WH_PrintManager shared].logTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@\n",formatStr]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WH_PrintManager shared].logTextView setContentOffset:CGPointMake(0, [WH_PrintManager shared].logTextView.contentSize.height-CGRectGetHeight([WH_PrintManager shared].logTextView.bounds)) animated:YES];
        });
    });
}


- (void)sp_checkDefualtSetting:(NSString *)mediaCount {
    NSLog(@"Check your Network");
}
@end
