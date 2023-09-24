//
//  UIAlertController+category.h
//  IntelligenceStudents
//
//  Created by xiaoshunliang on 2016/12/14.
//  Copyright © 2016年 GaoJuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (category)

+ (void)showPhotoAlerControllerPicker:(UIImagePickerController *)pick controller:(UIViewController *)controller sourceView:(UIView *)view;

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller block:(void (^)(NSInteger buttonIndex))inblock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
