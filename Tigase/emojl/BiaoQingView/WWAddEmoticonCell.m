//
//  WWAddEmoticonCell.m
//  WaHu
//
//  Created by Apple on 2019/3/1.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWAddEmoticonCell.h"
@interface WWAddEmoticonCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *contentL;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *aleadyAddBtn;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end
@implementation WWAddEmoticonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIColor *color = kColorThemeColor;
    self.addBtn.layer.borderColor = color.CGColor;
    self.addBtn.layer.borderWidth = 1;
    self.addBtn.layer.cornerRadius = 5;
    
    UIColor *color2 = HEXCOLOR(0xcccccc);
    self.aleadyAddBtn.layer.borderColor = color2.CGColor;
    self.aleadyAddBtn.layer.borderWidth = 1;
    self.aleadyAddBtn.layer.cornerRadius = 5;
    
    self.aleadyAddBtn.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

+ (WWAddEmoticonCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    WWAddEmoticonCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WWAddEmoticonCell class])];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WWAddEmoticonCell class]) owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    
    [self.iconImageV sd_setImageWithURL:[NSURL URLWithString:dataDic[@"emoPackFileUrl"]] placeholderImage:Message_PlaceholderImage];
    [self.contentL setText:dataDic[@"emoPackName"]];
    [self.desLabel setText:dataDic[@"emoPackProfile"]];
    NSString *status = checkNull(dataDic[@"emoDownStatus"]);
    if ([status isEqualToString:@"0"]) {
        self.addBtn.hidden = NO;
        self.aleadyAddBtn.hidden = YES;
        
    }else if ([status isEqualToString:@"1"]){
        self.addBtn.hidden = YES;
        self.aleadyAddBtn.hidden = NO;
        
    }
}
- (IBAction)addBtnClick:(UIButton *)sender {
    
//    if (self.addEmoticonBtnClickBlock) {
//        self.addEmoticonBtnClickBlock();
//    }
    if ([self.delegate respondsToSelector:@selector(addEmoticonDidClickWithAddBtn:andAleadyBtn:dataDic:)]) {
        [self.delegate addEmoticonDidClickWithAddBtn:self.addBtn andAleadyBtn:self.aleadyAddBtn dataDic:self.dataDic];
    }
}

@end
