//
//  JXLabel.h
//  sjvodios
//
//  Created by  on 19-5-2-1.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXLabel : UILabel {
    NSObject	*_wh_delegate;
}
@property (nonatomic, weak) NSObject* wh_delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) BOOL      wh_changeAlpha;
@property (nonatomic, assign) int       wh_line;


@end
