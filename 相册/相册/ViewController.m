//
//  ViewController.m
//  相册
//
//  Created by 16 on 2018/6/15.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "ViewController.h"
#import "JJAddPhotosCollectionView.h"
#import "JJPhotoManager.h"
#import "JJPhotosViewController.h"

@interface ViewController ()<JJAddPhotosCollectionViewDelegate>

@property (nonatomic , strong) JJAddPhotosCollectionView *addPhoto;
@end

@implementation ViewController
{
    UIImageView *img;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.addPhoto = [[JJAddPhotosCollectionView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 200)];
    self.addPhoto.maxCount = 30;
    self.addPhoto.rows = 4;
    self.addPhoto.showDelect = YES;
    self.addPhoto.jj_delegate = self;
    self.addPhoto.superVC = self;
    [self.view addSubview:self.addPhoto];
    
    UIButton *icon = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 50, 50)];
    icon.backgroundColor = [UIColor redColor];
    [icon addTarget:self action:@selector(icon) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:icon];

    img = [[UIImageView alloc] initWithFrame:CGRectMake(200, 300, 100, 100)];
    [self.view addSubview:img];

}
- (void)icon
{
    JJPhotosViewController *photoVC = [[JJPhotosViewController alloc] initWithcallBack:^(NSArray *images) {
        
        NSLog(@"%@",images);
        img.image = images[0];
    }];
    photoVC.maxCount = 1;
    [self presentViewController:photoVC animated:YES completion:nil];
}
- (void)JJAddPhotosCollectionView:(JJAddPhotosCollectionView *)collection ChangeFrame:(CGRect)frame
{
    NSLog(@"改变frame");
}
- (void)JJAddPhotosCollectionView:(JJAddPhotosCollectionView *)collection didSelectIndex:(NSInteger)index
{
    NSLog(@"点击了第%ld个",(long)index);
}
- (void)JJAddPhotosCollectionView:(JJAddPhotosCollectionView *)collection Changeitems:(NSArray *)items index:(NSInteger)index
{
    NSLog(@"修改了第%ld个,现在的数组是%@",(long)index,items);
}
@end
