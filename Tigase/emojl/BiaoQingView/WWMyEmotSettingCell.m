//
//  WWMyEmotSettingCell.m
//  WaHu
//
//  Created by Apple on 2019/3/2.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWMyEmotSettingCell.h"
@interface WWMyEmotSettingCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIButton *RemoveBtn;

@end
@implementation WWMyEmotSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIColor *color = kColorThemeColor;
    self.RemoveBtn.layer.borderColor = color.CGColor;
    self.RemoveBtn.layer.borderWidth = 1;
    self.RemoveBtn.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (WWMyEmotSettingCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    WWMyEmotSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WWMyEmotSettingCell class])];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WWMyEmotSettingCell class]) owner:nil options:nil] firstObject];
    }
    return cell;
}
- (IBAction)removeBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(MyEmotSettingCellDidClickRemoveBtn:dataDic:)]) {
        [self.delegate MyEmotSettingCellDidClickRemoveBtn:sender dataDic:self.dataDic];
    }
}

- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dataDic[@"emoPackFileUrl"]]] placeholderImage:Message_PlaceholderImage];
    self.titleL.text = [NSString stringWithFormat:@"%@",dataDic[@"emoPackName"]];
    
}


@end
