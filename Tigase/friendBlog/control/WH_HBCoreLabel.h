//
//  WH_HBCoreLabel.h
//  CoreTextMagazine
//
//  Created by weqia on 13-10-27.
//  Copyright (c) 2013年 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchParser.h"
@class WH_HBCoreLabel;
@protocol WH_HBCoreLabelDelegate <NSObject>
@optional
-(void)coreLabel:(WH_HBCoreLabel*)coreLabel linkClick:(NSString*)linkStr;
-(void)coreLabel:(WH_HBCoreLabel *)coreLabel phoneClick:(NSString *)linkStr;
-(void)coreLabel:(WH_HBCoreLabel *)coreLabel mobieClick:(NSString *)linkStr;

@end

@interface WH_HBCoreLabel : UILabel
{
    MatchParser* _wh_match;
    
    BOOL touch;
    
    id<MatchParserDelegate> _data;
    
    NSString * _linkStr;
    
    NSString * _linkType;
    
    BOOL _copyEnableAlready;
    
    BOOL _attributed;
}
@property(nonatomic,strong ) MatchParser * wh_match;
@property(nonatomic,weak) IBOutlet id<WH_HBCoreLabelDelegate> wh_delegate;
@property(nonatomic) BOOL wh_linesLimit;
-(void)WH_registerCopyAction;
-(void)setAttributedText:(NSString *)attributedText;

- (void)sp_getMediaData;
-(void)setAText:(NSAttributedString *)text;

@end
