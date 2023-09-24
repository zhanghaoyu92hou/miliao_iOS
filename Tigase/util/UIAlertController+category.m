//
//  UIAlertController+category.m
//  IntelligenceStudents
//
//  Created by xiaoshunliang on 2016/12/14.
//  Copyright © 2016年 GaoJuan. All rights reserved.
//

#import "UIAlertController+category.h"
@implementation UIAlertController (category)

+ (void)showPhotoAlerControllerPicker:(UIImagePickerController *)picker controller:(UIViewController *)controller sourceView:(UIView *)view {
    UIAlertController *alerSheet = [UIAlertController alertControllerWithTitle:nil message:@"选择照片" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [controller.navigationController presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *pictures = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [controller.navigationController presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alerSheet addAction:album];
    [alerSheet addAction:pictures];
    [alerSheet addAction:cancel];
//    [album setValue:KDARKCOLOR forKey:@"titleTextColor"];
//    [pictures setValue:KDARKCOLOR forKey:@"titleTextColor"];
//    [cancel setValue:KDARKCOLOR forKey:@"titleTextColor"];

    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popPresenter = alerSheet.popoverPresentationController;
        popPresenter.sourceView = view;
        popPresenter.sourceRect = view.bounds;
        [controller presentViewController:alerSheet animated:YES completion:nil];
    }else {
        [controller presentViewController:alerSheet animated:YES completion:nil];
        
    }
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller block:(void (^)(NSInteger buttonIndex))inblock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    //修改title
    //NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:title];
    //[attstr addAttribute:NSForegroundColorAttributeName value:KDARKCOLOR range:NSMakeRange(0, title.length)];
    //[attstr addAttribute:NSFontAttributeName value:KTEXTFONT range:NSMakeRange(0, title.length)];
    //[alert setValue:attstr forKey:@"attributedTitle"];
 
    if (cancelButtonTitle) {
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了alert的取消按钮");
            inblock(2);
        }];
        //[cancle setValue:KDARKCOLOR forKey:@"titleTextColor"];
        [alert addAction:cancle];
    }
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        inblock(1);
    }];
    //[okAction setValue:KBColor forKey:@"titleTextColor"];

    [alert addAction:okAction];
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
