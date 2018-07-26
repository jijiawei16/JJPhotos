//
//  JJPhotosCollectionCell.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotosCollectionCell.h"

@interface JJPhotosCollectionCell ()

/* 相册图片 */
@property (nonatomic , strong) UIImageView *photo;
/* 遮罩 */
@property (nonatomic , strong) UIView *head;
@end
@implementation JJPhotosCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        click.numberOfTapsRequired = 1;
        [self addGestureRecognizer:click];
        self.userInteractionEnabled = YES;
        [self creatViews];
    }
    return self;
}
- (void)creatViews
{
    [self addSubview:self.photo];
    [self addSubview:self.select];
    [self addSubview:self.head];
}
#pragma mark 设置数据源
- (void)setAsset:(PHAsset *)asset
{
    _asset = asset;
    NSArray *assets = [JJPhotoManager getAssets];
    [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (asset == (PHAsset *)obj) {
            self.select.selected = YES;
        }
    }];
    // 设置size会让图片变得清楚一点
    [[JJPhotoManager manager] fetchImageInAsset:self.asset size:CGSizeMake(self.frame.size.width*4, self.frame.size.height*4) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
        
        self.photo.image = image;
    }];
}
- (void)setIsMax:(BOOL)isMax
{
    _isMax = isMax;
    if (![self.title isEqualToString:@""]&&self.title) {
        _select.backgroundColor = [UIColor redColor];
        [_select setTitle:self.title forState:UIControlStateNormal];
    }else {
        _select.backgroundColor = [UIColor clearColor];
        [_select setTitle:@"" forState:UIControlStateNormal];
        if (self.isMax) {
            [self showShade];
        }else {
            [self hiddenShade];
        }
    }
}
- (void)showShade
{
    if (!self.select.selected) {
        self.head.hidden = NO;
        self.userInteractionEnabled = NO;
    }else {
        self.head.hidden = YES;
        self.userInteractionEnabled = YES;
    }
}
- (void)hiddenShade
{
    self.head.hidden = YES;
    self.userInteractionEnabled = YES;
}
#pragma mark 按钮点击事件
- (void)click:(UITapGestureRecognizer *)sender
{
    [self selectBtnClick];
}
- (void)selectBtnClick
{
    // 判断是否需要设置弹性动画
    if (!_select.selected) {
        
        _select.selected = YES;
        // 先缩小
        _select.transform = CGAffineTransformMakeScale(0.6, 0.6);
        _select.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.select.userInteractionEnabled = YES;
        });
        // 弹簧动画，参数分别为：时长，延时，弹性（越小弹性越大），初始速度
        [UIView animateWithDuration: 0.5 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0.3 options:0 animations:^{
            // 放大
            self.select.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
    
        // 将背景图片去掉
        [_select setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [[JJPhotoManager manager] addcell:self asset:self.asset];
        
    }else {
        _select.selected = NO;
        // 重新设置背景图片
        self.select.userInteractionEnabled = YES;
        [_select setImage:[UIImage imageNamed:@"图片未选中"] forState:UIControlStateNormal];
        [[JJPhotoManager manager] delectCell:self asset:self.asset];
    }
    
    // 先判断是否达到了图片的最大值,判断是否可以选择该图片
    if ([JJPhotoManager isMax]) {
        if ([self.delegate respondsToSelector:@selector(JJPhotosCollectionCellDidSelectMaxCount)]) {
            [self.delegate JJPhotosCollectionCellDidSelectMaxCount];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(JJPhotosCollectionCellDidNotSelectMaxCount)]) {
            [self.delegate JJPhotosCollectionCellDidNotSelectMaxCount];
        }
    }
}
#pragma mark 懒加载
- (UIImageView *)photo
{
    if (_photo == nil) {
        _photo = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, self.frame.size.width-2, self.frame.size.height-2)];
        _photo.contentMode = UIViewContentModeScaleAspectFill;
        _photo.clipsToBounds = YES;
        _photo.userInteractionEnabled = YES;
    }
    return _photo;
}
- (UIButton *)select
{
    if (_select == nil) {
        _select = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-25, 3, 22, 22)];
        _select.layer.cornerRadius = 11.0;
        _select.selected = NO;
        [_select setImage:[UIImage imageNamed:@"图片未选中"] forState:UIControlStateNormal];
        [_select setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _select.titleLabel.font = [UIFont systemFontOfSize:14];
        [_select addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _select;
}
- (UIView *)head
{
    if (_head == nil) {
        _head = [[UIView alloc] initWithFrame:self.bounds];
        _head.backgroundColor = [UIColor grayColor];
        _head.alpha = 0.5;
        _head.hidden = YES;
    }
    return _head;
}
@end
