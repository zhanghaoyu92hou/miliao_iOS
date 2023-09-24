//
//  DMDropDownMenu.m
//  DMDropDownMenu
//
//  Created by 王佳斌 on 16/5/19.
//  Copyright © 2016年 Draven_M. All rights reserved.
//

#import "DMDropDownMenu.h"

#define tableH 180
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define kBorderColor g_factory.cardBorderColor


@implementation DMDropDownMenu

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setUpView];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self p_setUpView];
    
}

- (void)setListArr:(NSArray *)listArr
{
    if (listArr.count > 0) {
        _listArr = listArr;
        id obj = listArr[0];
        if ([obj isKindOfClass:[NSString class]]) {
            _curText.text = _listArr[0];
        }else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)obj;
            _curText.text = dic[@"question"];
        }
    }
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    id obj = _listArr[currentIndex];
    if ([obj isKindOfClass:[NSString class]]) {
        _curText.text = obj;
    }else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)obj;
        _curText.text = dic[@"question"];
    }
}
- (void)p_setUpView {
    self.arrowImageName = @"down";
    
    _isOpen = NO;
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _menuBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _menuBtn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    [_menuBtn.layer setCornerRadius:g_factory.cardCornerRadius];
    _menuBtn.layer.borderWidth = g_factory.cardBorderWithd;
    _menuBtn.clipsToBounds = YES;
    _menuBtn.layer.masksToBounds = YES;
    
    [_menuBtn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_menuBtn];
    
    self.curText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 30, self.frame.size.height)];
    _curText.textColor = [UIColor blackColor];
    _curText.textAlignment = NSTextAlignmentLeft;
    [_menuBtn addSubview:_curText];
    
    UIImage *image = [UIImage imageNamed:_arrowImageName];
    
    self.arrowImg = [[UIImageView alloc] initWithImage:image];
    _arrowImg.center = CGPointMake(self.frame.size.width - 15, self.frame.size.height/2);
    [_menuBtn addSubview:_arrowImg];
    
    self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0) style:UITableViewStylePlain];
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    [_menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    _menuTableView.layer.borderWidth = 1;
    _menuTableView.layer.borderColor = kBorderColor.CGColor;
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.superview addSubview:_menuTableView];
}

- (void)setTitle:(NSString *)str
{
    _titleLabel.text = str;
}

- (void)setTitleHeight:(CGFloat)height
{
    CGRect frame = CGRectMake(0, self.frame.origin.y - height, self.frame.size.width, height);
    _titleLabel.frame = frame;
}

- (void)tapAction
{
    if (self.listArr.count == 0) {
        return;
    }
    [self closeOtherJRView];
    if (_isOpen) {
        _isOpen = NO;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _menuTableView.frame;
            frame.size.height = 0;
            [_menuTableView setFrame:frame];
            _arrowImg.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [_menuTableView removeFromSuperview];
            
//            _arrowImg.transform = CGAffineTransformRotate(_arrowImg.transform, DEGREES_TO_RADIANS(180));
        }];
    }else {
        _isOpen = YES;
        [UIView animateWithDuration:0.3 animations:^{
            
            //         [self.superview addSubview:_menuTableView];
            [_menuTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            [self.superview addSubview:_menuTableView];
            [self.superview bringSubviewToFront:_menuTableView];
            CGRect frame = _menuTableView.frame;
            frame.size.height = tableH;
            [_menuTableView setFrame:frame];
            _arrowImg.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
//            [self transformArroImage];
        }];
    }
}
- (void)transformArroImage {
    [UIView animateWithDuration:0.3 animations:^{
        _arrowImg.transform = _isOpen ? CGAffineTransformRotate(_arrowImg.transform, DEGREES_TO_RADIANS(180)) : CGAffineTransformIdentity;
    }];
}
- (void)closeOtherJRView
{
    for (UIView * view in self.superview.subviews) {
        if ([view isKindOfClass:[DMDropDownMenu class]] && view!=self) {
            DMDropDownMenu * otherView = (DMDropDownMenu *)view;
            if (otherView.isOpen) {
                otherView.isOpen = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect frame = otherView.menuTableView.frame;
                    frame.size.height = 0;
                    [otherView.menuTableView setFrame:frame];
                } completion:^(BOOL finished) {
                    [otherView.menuTableView removeFromSuperview];
                    otherView.arrowImg.transform = CGAffineTransformRotate(otherView.arrowImg.transform, DEGREES_TO_RADIANS(180));
                }];
            }
        }
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14];
        label.tag = 1000;
        label.numberOfLines = 0;
        [cell addSubview:label];
        
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(10, self.frame.size.height + 5, cell.frame.size.width - 20, 0.5)];
        line.image = [UIImage imageNamed:@"line"];
        
        [cell addSubview:line];
    }
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
    id obj = self.listArr[indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        label.text = obj;
    }else if ([obj isKindOfClass:[NSDictionary class]]) {
        label.text = obj[@"question"];
    }
    
    return cell;
};


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tapAction];
    id obj = _listArr[indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        _curText.text = obj;
    }else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)obj;
        _curText.text = dic[@"question"];
    }
    if ([_delegate respondsToSelector:@selector(selectIndex:AtDMDropDownMenu:)]) {
        [_delegate selectIndex:indexPath.row AtDMDropDownMenu:self];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString * string = self.listArr[indexPath.row];
//    CGRect bounds = [string boundingRectWithSize:CGSizeMake(self.frame.size.width - 20, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14] } context:NULL];
//    NSLog(@"%f",bounds.size.height);
    return 50;
}


@end
