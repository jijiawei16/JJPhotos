//
//  JJAlbumListTableView.m
//  相册
//
//  Created by 16 on 2018/7/17.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJAlbumListTableView.h"
#import "JJWebImage.h"
#import "JJPhotoManager.h"

@interface JJAlbumListTableView()<UITableViewDelegate,UITableViewDataSource>

///数据源数组
@property (nonatomic , strong) NSArray<JJAblumInfo *> *items;
@end
@implementation JJAlbumListTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor colorWithRed:41/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}
- (void)setUpItems:(NSArray<JJAblumInfo *> *)items
{
    self.items = items;
    [self reloadData];
}
#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJAblumInfo *info = self.items[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row]];
    UIImageView *img = [[UIImageView alloc] init];
    UILabel *title = [[UILabel alloc] init];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row]];
        cell.backgroundColor = [UIColor clearColor];
        
        // 顶部分割线
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width-15, 0.5)];
        top.backgroundColor = [UIColor whiteColor];
        [cell addSubview:top];
        // 添加图片
        img.frame = CGRectMake(15, 10, 40, 40);
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        [cell addSubview:img];
        // 添加文字
        title.textAlignment = NSTextAlignmentLeft;
        title.frame = CGRectMake(60, 10, [UIScreen mainScreen].bounds.size.width-70, 40);
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont systemFontOfSize:15];
        [cell addSubview:title];
    }
    
    // 设置size会让图片变得清楚一点
    [[JJPhotoManager manager] fetchImageInAsset:info.coverAsset size:CGSizeMake(self.frame.size.width*4, self.frame.size.height*4) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
        img.image = image;
    }];
    title.text = [NSString stringWithFormat:@"%@(%ld)",info.ablumName,(long)info.count];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.jj_delegate respondsToSelector:@selector(JJAlbumListTableViewDidSelectAlbum:)]) {
        [self.jj_delegate JJAlbumListTableViewDidSelectAlbum:self.items[indexPath.row]];
    }
}
#pragma mark 重命名
- (NSString *)getNewTitle:(NSString *)title
{

    return @"XXX";
}
@end
