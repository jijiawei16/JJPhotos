//
//  JJAddPhotoCollectionViewCell.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJAddPhotoCollectionViewCell.h"
#import "JJWebImage.h"

@interface JJAddPhotoCollectionViewCell ()

// 删除按钮
@property (nonatomic , strong) UIButton *delect;
// 展示图片
@property (nonatomic , strong) UIImageView *imageView;
// 回调
@property (nonatomic , copy) JJAddPhotoCollectionViewCellCallBack block;
@end
@implementation JJAddPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, self.frame.size.width-18, self.frame.size.width-18)];
        // 设置图片展示格式
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.delect = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-18,0, 18, 18)];
        [self.delect addTarget:self action:@selector(delect:) forControlEvents:UIControlEventTouchUpInside];
        [self.delect setBackgroundImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
        [self addSubview:self.delect];
    }
    return self;
}
- (void)delect:(UIButton *)sender
{
    self.block();
}
- (void)setUpImage:(UIImage *)image
{
    self.delect.hidden = YES;
    self.imageView.image = image;
}
- (void)setUpImage:(UIImage *)image callBack:(JJAddPhotoCollectionViewCellCallBack)callBack
{
    self.delect.hidden = NO;
    self.block = callBack;
    self.imageView.image = image;
}
- (void)setUpImageUrl:(NSString *)imageUrl
{
    self.delect.hidden = YES;
    [self.imageView jj_setImageWithUrl:[NSURL URLWithString:imageUrl]];
}
- (void)setUpImageUrl:(NSString *)imageUrl callBack:(JJAddPhotoCollectionViewCellCallBack)callBack
{
    self.delect.hidden = NO;
    self.block = callBack;
    [self.imageView jj_setImageWithUrl:[NSURL URLWithString:imageUrl]];
}
@end
