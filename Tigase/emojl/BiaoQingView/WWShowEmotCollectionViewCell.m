//
//  WWShowEmotCollectionViewCell.m
//  WaHu
//
//  Created by Apple on 2019/3/1.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWShowEmotCollectionViewCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface WWShowEmotCollectionViewCell ()
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *iconImageView;
@end
@implementation WWShowEmotCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDataDic:(NSDictionary *)dataDic
{
    _dataDic = dataDic;
    
    typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:checkNull(dataDic[@"fileUrl"])];
    if ([url.absoluteString rangeOfString:@".gif"].location != NSNotFound) {
        
        [self loadAnimatedImageWithURL:url completion:^(FLAnimatedImage *animatedImage) {
            weakSelf.iconImageView.animatedImage = animatedImage;
            
        }];
        
    }else {
        [self.iconImageView sd_setImageWithURL:url placeholderImage:Message_PlaceholderImage];
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
