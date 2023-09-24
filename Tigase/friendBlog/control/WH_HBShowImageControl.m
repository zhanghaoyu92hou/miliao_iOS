//
//  WH_HBShowImageControl.m
//  MyTest
//
//  Created by weqia on 13-8-8.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import "WH_HBShowImageControl.h"
#import "NSStrUtil.h"
#import "UIImageView+HBHttpCache.h"
#import "ObjUrlData.h"
#import "JSONKit.h"
@implementation WH_HBShowImageControl
@synthesize delegate,wh_bFirstSmall,wh_smallTag,wh_bigTag,wh_controller,wh_larges;
#pragma -mark 覆盖父类的方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
    }
    return self;
}

#pragma -mark 私有方法
-(void)layoutImages
{
    int count=(int)[_imgurls count];
    if(count==1) {
        if (wh_bFirstSmall) {
            [self drawLessThree];
        } else {
            [self drawSingleImage:[_imgurls objectAtIndex:0]];
        }
    }
    else if(count<=3)
        [self drawLessThree];
    else if(count==4)
        [self drawFour];
    else
        [self drawMoreFour];
    [self drawFile];
    
}
-(void)drawFile
{
    if([_files count]>0){
        float y;
        int imgCount=(int)[_imgurls count];
        if(imgCount==0){
            y=0;
        }else if(imgCount==1){
            y=MAX_HEIGHT;
        }else{
            y=([_imgurls count]/4+1)*(IMAGE_SPACE+IMAGE_SIZE);
        }
        UIImageView * imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, y+5, 44, 29)];
        imageView.image=[UIImage imageNamed:@"f_attach"];
        [self addSubview:imageView];
        UIImageView * countView=[[UIImageView alloc]initWithFrame:CGRectMake(22, 10, 18, 18)];
        countView.image=[UIImage imageNamed:@"f_attach_count"];
        UILabel * countLabel=[[UILabel alloc]initWithFrame:CGRectMake(22, 10, 18, 18)];
        countLabel.backgroundColor=[UIColor clearColor];
        countLabel.textAlignment=NSTextAlignmentCenter;
        countLabel.textColor=[UIColor whiteColor];
        countLabel.font=[UIFont systemFontOfSize:12];
        countLabel.text=[NSString stringWithFormat:@"%ld",[_files count]];
        [imageView addSubview:countView];
        [imageView addSubview:countLabel];
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookFileAction:)];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled=YES;
    }
    
}


-(void)uploadFinish
{
    if(delegate&&[delegate respondsToSelector:@selector(WH_showImageControlFinishLoad:)])
        [delegate WH_showImageControlFinishLoad:self];
}

-(void)drawSingleImage:(ObjUrlData*)url
{
    UIImageView * imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (self.wh_isCollect)?IMAGE_SIZE:MAX_WIDTH, (self.wh_isCollect)?IMAGE_SIZE:MAX_HEIGHT)];
    [self addSubview:imageView];
    [self drawImage:imageView file:url];
    [self uploadFinish];
    return;

}

-(void)drawLessThree
{
    int count=(int)[_imgurls count];
    for(int i=0;i<count;i++)
    {
        UIImageView * imageView=[[UIImageView alloc]initWithFrame:CGRectMake((IMAGE_SIZE+IMAGE_SPACE)*i, 0, IMAGE_SIZE, IMAGE_SIZE)];
        ObjUrlData * file=[_imgurls objectAtIndex:i];
        [self addSubview:imageView];
        [self drawImage:imageView file:file];
        if(count-1==i){
            [self uploadFinish];
        }
    }
}

-(void)drawFour
{
    int count=(int)[_imgurls count];
    for(int i=0;i<count;i++)
    {
        UIImageView * imageView=[[UIImageView alloc]initWithFrame:CGRectMake((IMAGE_SPACE+IMAGE_SIZE)*(i%2),(IMAGE_SPACE+IMAGE_SIZE)*(i/2), IMAGE_SIZE, IMAGE_SIZE)];
        ObjUrlData * file=[_imgurls objectAtIndex:i];
        [self addSubview:imageView];
        [self drawImage:imageView file:file];
        if(i==count-1)
            [self uploadFinish];
    }
}

-(void)drawMoreFour
{
    int count=(int)[_imgurls count];
    for(int i=0;i<count;i++)
    {
        UIImageView * imageView=[[UIImageView alloc]initWithFrame:CGRectMake((IMAGE_SPACE+IMAGE_SIZE)*(i%3),(IMAGE_SPACE+IMAGE_SIZE)*(i/3), IMAGE_SIZE, IMAGE_SIZE)];
        ObjUrlData * file=[_imgurls objectAtIndex:i];
        [self addSubview:imageView];
        [self drawImage:imageView file:file];
        if(i==count-1)
            [self uploadFinish];
    }
}

-(void)drawImage:(UIImageView*)imageView file:(ObjUrlData*)file
{
//    NSMutableString * smlStr=[[NSMutableString alloc]init];
//    NSMutableString * bigStr=[[NSMutableString alloc]init];
//    if([NSStrUtil notEmptyOrNull:file.url]){
//        [smlStr appendFormat:@"%@&th=%d",file.url,smallTag];
//        [bigStr appendFormat:@"%@&th=%d",file.url,bigTag];
//    }
    [_bigUrls addObject:file.url];
    [ _imageViews addObject:imageView];
    UIActivityIndicatorView * indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((imageView.frame.size.width-20)/2, (imageView.frame.size.height-20)/2, 20, 20)];
    [imageView addSubview:indicator];
    [indicator startAnimating];
    
    imageView.contentMode=UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds=YES;
//    __block UIImageView * wimageView=imageView;
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"Default_Gray"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(WH_lookImageAction:)];
        imageView.userInteractionEnabled=YES;
        [imageView addGestureRecognizer:tap];
        imageView.image = image;
    }];
    
}

#pragma -mark 事件响应方法
-(void)lookFileAction:(UIGestureRecognizer*)sender
{
    if(delegate&&[delegate respondsToSelector:@selector(WH_lookFileAction:files:)]){
        [delegate WH_lookFileAction:self files:_files];
    }
}

-(void)WH_lookImageAction:(UIGestureRecognizer*)sender
{
    if(delegate&&[delegate respondsToSelector:@selector(WH_lookImageAction:)])
        [delegate WH_lookImageAction:self];
    _imageList=[[HBImageViewList alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [_imageList WH_addTarget:self tapOnceAction:@selector(WH_dismissImageAction:)];
    int index=(int)[_imageViews indexOfObject:sender.view];
//    if(IOS_VERSION<7.0){
//        [UIApplication sharedApplication].statusBarHidden=YES;
//    }
    UIImageView * view=(UIImageView*)sender.view;
//    NSString * url=[_bigUrls objectAtIndex:index];
    ObjUrlData* p = [wh_larges objectAtIndex:index];
    NSString * url=p.url;
    p = nil;
    _util=[[NSImageUtil alloc]init];
    int count=(int)[_imageViews count];
    for(int i=0;i<count;i++){
        UIImage * image=((UIImageView*)[_imageViews objectAtIndex:i]).image;
        if(image){
            [_images addObject:image];
        }

    }
    [_util showBigImageWithUrl:url fromView:view complete:^(UIView * backView) {
        [backView setHidden:YES];
        //[_imageList addImagesURL:_bigUrls withSmallImage:_images];
        //[_imageList addImagesURL:larges withSmallImage:_images];
        [_imageList WH_addImages:_imageViews];
        [_imageList WH_setIndex:index];
        [self.window addSubview:_imageList];
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];
}

-(void)WH_dismissImageAction:(UIImageView*)sender
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    int index=(int)[_imageList.wh_imageViews indexOfObject:sender.superview];
    if (index < 0) {
        return;
    }
    UIImageView * view=[_imageViews objectAtIndex:index];
    _imageList.target = nil;//取消循环引用
    [_imageList removeFromSuperview];
    _imageList = nil;
    [_images removeAllObjects];
     NSString * url=[_bigUrls objectAtIndex:index];
    [_util goBackToView:view withImageUrl:url];
    _util = nil;
}

#pragma -mark 接口方法

-(void)WH_setImagesFileStr:(id)fileStr
{
    if(fileStr==nil)
        return;
    if ([fileStr isKindOfClass:[NSArray class]]) {
        if(((NSArray*)fileStr).count==0)
            return;
        id object=[((NSArray*)fileStr) objectAtIndex:0];
        if([object isKindOfClass:[ObjUrlData class]]){
            [self WH_setImagesWithFiles:(NSArray*)fileStr];
            return;
        }
        fileStr = [fileStr JSONString];
    } 
    NSArray *objArr = [ObjUrlData getDataArray:fileStr];
    [self WH_setImagesWithFiles:objArr];
}

-(void)WH_setImagesWithFiles:(NSArray*)files1
{
    NSMutableArray * images=[[NSMutableArray alloc]init];
    NSMutableArray * files=[[NSMutableArray alloc]init];
    int count=(int)[files1 count];
    for(int i=0;i<count;i++){
        ObjUrlData * data =[files1 objectAtIndex:i];
        if ([data.url isKindOfClass:[NSString class]]) {
            if([data.url length]>0){
                NSArray * array=[data.mime componentsSeparatedByString:@"/"];
                NSString * mime=[array objectAtIndex:0];
                if([mime isEqualToString:@"image"])
                    [images addObject:data];
                else{
                    [files addObject:data];
                }
            }
        }
    }
    //weibo说说预展示图片的Url（不清晰）
    _imgurls=images;
    _files=files;
    _bigUrls=[[NSMutableArray alloc]init];
    _images=[[NSMutableArray alloc]init];
    _imageViews=[[NSMutableArray alloc]init];
    for(UIView * view in self.subviews)
        [view removeFromSuperview];
    [self layoutImages];
}

+(float)WH_heightForFileStr:(id)fileStr
{
    if(fileStr==nil)
        return 0;
    if ([fileStr isKindOfClass:[NSArray class]]) {
        if(((NSArray*)fileStr).count==0)
            return 0;
        id object=[((NSArray*)fileStr) objectAtIndex:0];
        if([object isKindOfClass:[ObjUrlData class]]){
            return [self WH_heightForFiles:(NSArray*)fileStr];
        }
        fileStr = [fileStr JSONString];
    }
    NSArray *objArr = [ObjUrlData getDataArray:fileStr];
    return [self WH_heightForFiles:objArr];
}

+(float)WH_heightForFiles:(NSArray*)files1
{
    int imageCount=0;
    int count=(int)[files1 count];
    for(int i=0;i<count;i++){
        ObjUrlData * data =[files1 objectAtIndex:i];
        NSArray * array=[data.mime componentsSeparatedByString:@"/"];
        NSString * mime=[array objectAtIndex:0];
        if([mime isEqualToString:@"image"])
            imageCount++;
    }
    float offset;
    if(imageCount==count){
        offset=0;
    }else{
        offset=40;
    }
    if(imageCount==0)
        return offset;
    else if(imageCount==1){
        return  MAX_HEIGHT+offset;
    }else{
        if (imageCount % 3 == 0) {
            return (imageCount/3)*(IMAGE_SIZE+IMAGE_SPACE)+offset;
            
        }else {
            return (imageCount/3+1)*(IMAGE_SIZE+IMAGE_SPACE)+offset;
            
        }
    }
}


- (void)sp_getMediaData {
    NSLog(@"Check your Network");
}
@end
