//
//  JJPhotographCollectionViewCell.m
//  相册
//
//  Created by 16 on 2018/7/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotographCollectionViewCell.h"
#import "JJPhotograph.h"

@implementation JJPhotographCollectionViewCell
{
    JJPhotograph *photograph;
    UIImageView *top;
    UIView *head;
}
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
    // 添加拍照界面
    if (photograph == nil) {
        photograph = [[JJPhotograph alloc] initWithFrame:self.bounds type:JJ_PhotographTypeOnlyImage];
    }
    [self addSubview:photograph];
    
    if (top == nil) {
        top = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-28)/2, (self.frame.size.height-23)/2, 28, 23)];
        top.image = [UIImage imageNamed:@"camera"];
    }
    [self addSubview:top];
    
    if (head == nil) {
        head = [[UIView alloc] initWithFrame:self.bounds];
        head.backgroundColor = [UIColor grayColor];
        head.alpha = 0.5;
        head.hidden = YES;
    }
    [self addSubview:head];
}
- (void)click:(UITapGestureRecognizer *)sender
{
    if ([self.delegate respondsToSelector:@selector(JJPhotographCollectionViewCellDidSelect)]) {
        [self.delegate JJPhotographCollectionViewCellDidSelect];
    }
}
- (void)showShade
{
    head.hidden = NO;
    self.userInteractionEnabled = NO;
}
- (void)hiddenShade
{
    head.hidden = YES;
    self.userInteractionEnabled = YES;
}
@end
