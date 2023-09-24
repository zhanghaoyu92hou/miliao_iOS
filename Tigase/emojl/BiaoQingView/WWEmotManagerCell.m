//
//  WWEmotManagerCell.m
//  WaHu
//
//  Created by Apple on 2019/3/5.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWEmotManagerCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface WWEmotManagerCell ()
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *contentImageView;
@end
@implementation WWEmotManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    UIColor *color = RGB(223, 223, 223);
//    self.layer.borderColor = color.CGColor;
//    self.layer.borderWidth = 1;
    
    self.choseBtn.userInteractionEnabled = NO;
}


- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    
    if ([checkNull(dataDic[@"url"]) isEqualToString:@"first_jian"]) {
        self.contentImageView.image = [UIImage imageNamed:@"icon_emot_jian"];
        self.choseBtn.hidden = YES;
    }else{
        
        typeof(self) weakSelf = self;
        NSURL *url = [NSURL URLWithString:checkNull(dataDic[@"url"])];
        if ([url.absoluteString rangeOfString:@".gif"].location != NSNotFound) {
            
            [self loadAnimatedImageWithURL:url completion:^(FLAnimatedImage *animatedImage) {
                weakSelf.contentImageView.animatedImage = animatedImage;
                
            }];
            
        }else {
            [self.contentImageView sd_setImageWithURL:url placeholderImage:Message_PlaceholderImage];
        }
        
        self.choseBtn.hidden = NO;
        
    }
    
}

- (void)loadAnimatedImageWithURL:(NSURL *const)url completion:(void (^)(FLAnimatedImage *animatedImage))completion
{
    NSString *const filename = url.lastPathComponent;
    NSString *const diskPath = [dataFilePath stringByAppendingPathComponent:filename];
    
    NSData * __block animatedImageData = [[NSFileManager defaultManager] contentsAtPath:diskPath];
    FLAnimatedImage * __block animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
    
    if (animatedImage) {
        if (completion) {
            completion(animatedImage);
        }
    } else {
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            animatedImageData = data;
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:animatedImageData];
            if (animatedImage) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(animatedImage);
                    });
                }
                [data writeToFile:diskPath atomically:YES];
            }
        }] resume];
    }
}



@end
