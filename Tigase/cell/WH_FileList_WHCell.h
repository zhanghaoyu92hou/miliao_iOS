//
//  WH_FileList_WHCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/6/13.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_FileList_WHCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *headImage;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *subtitle;


- (void)sp_upload;
@end
