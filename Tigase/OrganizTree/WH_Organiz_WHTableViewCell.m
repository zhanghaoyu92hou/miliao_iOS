//
//  WH_Organiz_WHTableViewCell.m
//  Tigase_imChatT
//
//  Created by 1 on 17/5/12.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_Organiz_WHTableViewCell.h"

//#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation WH_Organiz_WHTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.selectedBackgroundView = [UIView new];
//        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        [self customUI];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    
    _wh_additionButton.frame = CGRectMake(self.frame.size.width -22-20, 0, 22, 22);
    _wh_additionButton.center = CGPointMake(_wh_additionButton.center.x, self.contentView.center.y);
    CGRect frame = _wh_nameLabel.frame;
    frame.size.width = CGRectGetMinX(_wh_additionButton.frame) -CGRectGetMinX(_wh_nameLabel.frame) -5;
    _wh_nameLabel.frame = frame;
    _wh_nameLabel.center = CGPointMake(_wh_nameLabel.center.x, self.contentView.center.y);
    
    _wh_arrowView.center = CGPointMake(_wh_arrowView.center.x, self.contentView.center.y);
    
}
-(void)customUI{
    
    _wh_arrowView = [[UIImageView alloc] init];
    _wh_arrowView.frame = CGRectMake(0, 0, 20, 20);
    _wh_arrowView.image = [UIImage imageNamed:@"arrow_right"];
    [self.contentView addSubview:_wh_arrowView];
    
    _wh_nameLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(22, 5, 200, 22) text:@"" font:pingFangRegularFontWithSize(15) textColor:[UIColor blackColor] backgroundColor:nil];
    _wh_nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_wh_nameLabel];
    
    _wh_additionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    _wh_additionButton.frame = CGRectMake(self.frame.size.width -22-20, 11, 22, 22);
    [self.contentView addSubview:_wh_additionButton];
    
    [_wh_additionButton addTarget:self action:@selector(WH_additionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.wh_arrowExpand = NO;
}

- (void)setupWithData:(WH_DepartObject *)dataObj level:(NSInteger)level expand:(BOOL)expand
{
    _wh_arrowView.transform = CGAffineTransformIdentity;
    if (expand == YES) {
        self.wh_arrowExpand = expand;
    }
    self.wh_nameLabel.text = dataObj.departName;
    self.wh_organizObject = dataObj;
   
    if (level == 0) {
        self.backgroundColor = HEXCOLOR(0xe3e6e8);
        self.wh_nameLabel.textColor = [UIColor blackColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
        self.wh_nameLabel.textColor = [UIColor grayColor];
    }
    
    CGFloat left = 20 * level;
    
    CGRect arrowFrame = self.wh_arrowView.frame;
    arrowFrame.origin.x = left;
    self.wh_arrowView.frame = arrowFrame;
    
    CGRect titleFrame = self.wh_nameLabel.frame;
    titleFrame.origin.x = left +22;
    self.wh_nameLabel.frame = titleFrame;
}


#pragma mark - Properties

-(void)setWh_arrowExpand:(BOOL)arrowExpand{
    [self setArrowExpand:arrowExpand animated:YES];
}

- (void)setArrowExpand:(BOOL)arrowExpand animated:(BOOL)animated{
    _wh_arrowExpand = arrowExpand;
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        if (arrowExpand) {
            _wh_arrowView.transform = CGAffineTransformRotate(_wh_arrowView.transform, M_PI_2);
        }else{
            _wh_arrowView.transform = CGAffineTransformRotate(_wh_arrowView.transform, -M_PI_2);
        }
//        _arrowView.hidden = arrowExpand;
    }];
}
//- (void)setAdditionButtonHidden:(BOOL)additionButtonHidden
//{
//    [self setAdditionButtonHidden:additionButtonHidden animated:NO];
//}

//- (void)setAdditionButtonHidden:(BOOL)additionButtonHidden animated:(BOOL)animated
//{
//    _additionButtonHidden = additionButtonHidden;
//    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
//        self.additionButton.hidden = additionButtonHidden;
//    }];
//}


#pragma mark - Actions

- (void)WH_additionButtonTapped:(id)sender
{
    if (self.additionButtonTapAction) {
        self.additionButtonTapAction(sender);
        
    }
}
@end
