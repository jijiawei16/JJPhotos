//
//  JJShowPhotosVIew.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/26.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJShowPhotosVIew.h"
#import "JJWebImage.h"

#define sw self.frame.size.width
#define sh self.frame.size.height
@interface JJShowPhotosVIew ()<UIScrollViewDelegate>

@property (nonatomic , strong) NSArray *items;
@property (nonatomic , strong) UIButton *save;
@property (nonatomic , strong) UILabel *left;
@end
@implementation JJShowPhotosVIew

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = CGRectMake(0, 0, window.frame.size.width+10, window.frame.size.height);
        self.backgroundColor = [UIColor blackColor];
        self.pagingEnabled = YES;
        self.delegate = self;
        
       self.left = [[UILabel alloc] initWithFrame:CGRectMake(0, window.frame.size.height-50, 80, 50)];
        _left.textColor = [UIColor whiteColor];
        _left.textAlignment = NSTextAlignmentCenter;
        
        self.save = [[UIButton alloc] initWithFrame:CGRectMake(window.frame.size.width-100, window.frame.size.height-50, 100, 50)];
        [_save addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
        [_save setTitle:@"保存" forState:UIControlStateNormal];
        [_save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}
- (void)setUpItems:(NSArray *)items current:(NSInteger)current
{
    _items = items;
    CGFloat y = 0;
    CGFloat height = 0;
    UIImage *image;
    NSString *imgUrl;
    for (NSInteger i = 0; i<items.count; i++) {
        if ([items[i] isKindOfClass:[UIImage class]]) {
            image = items[i];
            height = image.size.height*sw/image.size.width;
            if (height > sh) {
                y = 0;
            }else {
                y = (sh-height)/2;
            }
        }else {
            imgUrl = [NSString stringWithFormat:@"%@",items[i]];
            height = (sw-10)*400/700;
            if (height > sh) {
                y = 0;
            }else {
                y = (sh-height)/2;
            }

        }
        UIScrollView *back = [[UIScrollView alloc] initWithFrame:CGRectMake(i*(sw), 0, sw, sh)];
        back.contentSize = CGSizeMake(0, height);
        [self addSubview:back];
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        click.numberOfTapsRequired = 1;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, sw-10, height)];
        [imageView addGestureRecognizer:click];
        imageView.userInteractionEnabled = YES;
        if ([items[i] isKindOfClass:[UIImage class]]) {
            imageView.image = image;
        }else {
            [imageView jj_setImageWithUrl:[NSURL URLWithString:imgUrl]];
        }
        [back addSubview:imageView];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentSize = CGSizeMake(items.count*(sw), 0);
    [window addSubview:self];
    [window addSubview:_left];
    if (_showSave) [window addSubview:_save];
    
    _left.text = [NSString stringWithFormat:@"%ld / %lu",(long)current+1,(unsigned long)_items.count];
    self.contentOffset = CGPointMake(current*sw, 0);
}
#pragma mark scrollView代理事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int num = (int)(scrollView.contentOffset.x/sw)+1;
    _left.text = [NSString stringWithFormat:@"%d / %lu",num,(unsigned long)_items.count];
}
#pragma mark 按钮点击和手势事件
- (void)click:(UITapGestureRecognizer *)sender
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_left removeFromSuperview];
    [_save removeFromSuperview];
    [self removeFromSuperview];
}
- (void)save:(UIButton *)sender
{
    NSLog(@"保存照片");
}
@end
