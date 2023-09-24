//
//  WH_ImageSelector_WHCollectionCell.m
//  Tigase_imChatT
//
//  Created by 1 on 17/1/20.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_ImageSelector_WHCollectionCell.h"

@interface WH_ImageSelector_WHCollectionCell()

@property (nonatomic,assign) NSInteger cellIndex;
@end

@implementation WH_ImageSelector_WHCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self customViewWithFrame:frame];
    }
    return self;
}

- (void)customViewWithFrame:(CGRect)frame{
    _wh_imageView = [[WH_JXImageView alloc] init];
    _wh_imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _wh_imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_wh_imageView];
//    [_imageView release];

    _wh_selectView = [[WH_JXImageView alloc] init];
    _wh_selectView.frame = CGRectMake(frame.size.width-33-5, 5, 33, 33);
    _wh_selectView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_wh_selectView];
//    [_selectView release];
}

-(void)refreshCellWithImagePath:(NSString *)imagePath{
    _yellow.didTouch = self.didImageView;
    _wh_imageView.didTouch = self.didImageView;
    _wh_selectView.didTouch = self.didSelectView;
    
    _wh_imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    if (!_wh_imageView.image) {
        [_wh_imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"Default_Gray"]];
    }
}

-(void)dealloc{
//    [super dealloc];
}

-(void)setIsSelected:(BOOL)value{
    if (value){
        _wh_imageView.layer.borderWidth = 3;
        _wh_imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
        _wh_selectView.image = [UIImage imageNamed:@"selected_true"];
    }
    else{
        _wh_imageView.layer.borderWidth = 0;
        _wh_selectView.image = [UIImage imageNamed:@"selected_fause"];
    }
}

-(void)setDelegate:(id)value{
    _delegate = value;
    
    _wh_selectView.wh_delegate = _delegate;
    _wh_imageView.wh_delegate = _delegate;
    _yellow.wh_delegate = _delegate;
}

-(void)setIndex:(long)value{
    _index = value;
    
    _wh_selectView.tag = _index;
    _wh_imageView.tag = _index;
    _yellow.tag = _index;
}




@end
