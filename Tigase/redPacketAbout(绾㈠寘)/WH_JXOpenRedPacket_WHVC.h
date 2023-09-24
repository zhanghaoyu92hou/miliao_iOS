//
//  WH_JXOpenRedPacket_WHVC.h
//  Tigase_imChatT
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXPacketObject.h"
#import "WH_JXGetPacketList.h"
@interface WH_JXOpenRedPacket_WHVC : WH_admob_WHViewController{
//    ATMHud * _wait;
    WH_JXOpenRedPacket_WHVC *_pSelf;
}
@property (strong, nonatomic) IBOutlet UIImageView *wh_headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *wh_fromUserLabel;
@property (strong, nonatomic) IBOutlet UILabel *wh_greetLabel;
@property (strong, nonatomic) IBOutlet UILabel *wh_moneyLabel;
@property (strong, nonatomic) IBOutlet UIView *wh_centerRedPView;

@property (strong, nonatomic) NSDictionary * wh_dataDict;
@property (strong, nonatomic) WH_JXPacketObject * wh_packetObj;
@property (strong, nonatomic) NSArray * wh_packetListArray;
@property (strong, nonatomic) IBOutlet UIView *wh_blackBgView;

- (void)WH_doRemove;

- (void)sp_getMediaData;
@end
