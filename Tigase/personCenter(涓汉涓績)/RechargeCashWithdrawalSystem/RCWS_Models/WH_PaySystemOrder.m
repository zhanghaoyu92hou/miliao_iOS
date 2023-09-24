//
//  WH_PaySystemOrder.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_PaySystemOrder.h"

@implementation WH_PaySystemOrder

- (void)setZfje:(NSString *)zfje{
    if (_zfje != zfje) {
        _zfje = [zfje copy];
        if (!_money) {
            self.money = zfje;
        }
    }
}

@end
