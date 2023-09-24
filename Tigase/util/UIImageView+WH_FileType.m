//
//  UIImageView+WH_FileType.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/10.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "UIImageView+WH_FileType.h"

@implementation UIImageView (WH_FileType)

-(void)setFileType:(NSInteger)fileType{
    NSString * imageStr = nil;
    switch (fileType) {
        case 1://图片
            imageStr = @"picturefile";
            break;
        case 2:
            imageStr = @"music";
            break;
        case 3:
            imageStr = @"video";
            break;
        case 4:
            imageStr = @"WH_file_dir";
            break;
        case 5:
            imageStr = @"WH_file_dir";
            break;
        case 6:
            imageStr = @"WH_file_dir";
            break;
        case 7:
            imageStr = @"WH_file_dir";
            break;
        case 8:
            imageStr = @"WH_file_dir";
            break;
        case 9:
            imageStr = @"WH_file_dir";
            break;
        case 10:
            imageStr = @"WH_file_dir";
            break;
            
        default:
            imageStr = @"WH_file_dir";
            break;
    }
    self.image = [UIImage imageNamed:imageStr];
}


- (void)sp_upload {
    NSLog(@"Get Info Failed");
}
@end
