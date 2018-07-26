//
//  JJPhotosCollection.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotosCollection.h"
#import "JJShowPhotosVIew.h"
#import "JJPhotograph.h"
#import "JJPhotographCollectionViewCell.h"

@interface JJPhotosCollection ()<UICollectionViewDelegate,UICollectionViewDataSource,JJPhotosCollectionCellDelegate,JJPhotographDelegate,JJPhotographCollectionViewCellDelegate>

@property (nonatomic , strong) NSMutableArray *data;
@property (nonatomic , strong) UIButton *addBtn;
@property (nonatomic , strong) UIButton *deleteBtn;
@property (nonatomic , strong) NSMutableArray <JJPhotosCollectionCell *>*selectCells;
@property (nonatomic , strong) NSMutableDictionary *identifies;
@property (nonatomic , assign) BOOL isMax;
@property (nonatomic , strong) JJPhotograph *photographWindow;
@end
@implementation JJPhotosCollection

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.isMax = NO;
        self.identifies = [NSMutableDictionary dictionary];
        self.data = [NSMutableArray array];
        self.showsHorizontalScrollIndicator = false;
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (NSInteger)_data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == 0&&[self.photoListName isEqualToString:@"Camera Roll"]) {
        
        NSString *identifier = [_identifies objectForKey:@"photo"];
        if (identifier == nil) {
            identifier = @"photo";
            [self registerClass:[JJPhotographCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        }
        JJPhotographCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }else {
     
        // 每次先从字典中根据IndexPath取出唯一标识符
        NSString *identifier = [_identifies objectForKey:[NSString stringWithFormat:@"%@",self.items[indexPath.row]]];
        if (identifier == nil) {
            identifier = [NSString stringWithFormat:@"%@",self.items[indexPath.row]];
            [_identifies setValue:identifier forKey:[NSString stringWithFormat:@"%@",self.items[indexPath.row]]];
            // 注册Cell
            [self registerClass:[JJPhotosCollectionCell class]  forCellWithReuseIdentifier:identifier];
        }
        JJPhotosCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.rowNum = indexPath.row;
        cell.asset = self.items[indexPath.row];
        cell.delegate = self;
        cell.isMax = self.isMax;
        return  cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"这部分功能之后再实现,点击查看全部照片");
}
#pragma mark 相册选择代理方法
- (void)JJPhotosCollectionCellDidNotSelectMaxCount
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[JJPhotosCollectionCell class]]) {
            JJPhotosCollectionCell *cell = (JJPhotosCollectionCell *)obj;
            [cell hiddenShade];
        }
        if ([obj isKindOfClass:[JJPhotographCollectionViewCell class]]) {
            JJPhotographCollectionViewCell *cell = (JJPhotographCollectionViewCell *)obj;
            [cell hiddenShade];
        }
    }];
    self.isMax = NO;
    ///刷新完成按钮
    if ([self.jj_delegate respondsToSelector:@selector(JJPhotosCollectionDidSelectCell)]) {
        [self.jj_delegate JJPhotosCollectionDidSelectCell];
    }
}
- (void)JJPhotosCollectionCellDidSelectMaxCount
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[JJPhotosCollectionCell class]]) {
            JJPhotosCollectionCell *cell = (JJPhotosCollectionCell *)obj;
            [cell showShade];
        }
        if ([obj isKindOfClass:[JJPhotographCollectionViewCell class]]) {
            JJPhotographCollectionViewCell *cell = (JJPhotographCollectionViewCell *)obj;
            [cell showShade];
        }
    }];
    self.isMax = YES;
    ///刷新完成按钮
    if ([self.jj_delegate respondsToSelector:@selector(JJPhotosCollectionDidSelectCell)]) {
        [self.jj_delegate JJPhotosCollectionDidSelectCell];
    }
}
#pragma mark 设置数据源
- (void)setItems:(NSArray *)items
{
    // 如果是相册的列表,展示拍照功能
    if ([self.photoListName isEqualToString:@"Camera Roll"]) {
        NSMutableArray *temp = [NSMutableArray arrayWithObjects:@"拍照", nil];
        [temp addObjectsFromArray:items];
        _items = temp;
    }else {
        _items = items;
    }
    self.data = [NSMutableArray arrayWithArray:_items];
    self.identifies = [NSMutableDictionary dictionary];
    [self reloadData];
    
    // 如果不是第一次加载,延迟选中cell
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.needSelect) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            NSArray *cells = [JJPhotoManager getCells];
            [JJPhotoManager clear];
            NSMutableArray *temp = [NSMutableArray array];
            [cells enumerateObjectsUsingBlock:^(JJPhotosCollectionCell *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger num = obj.rowNum;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num+1 inSection:0];
                JJPhotosCollectionCell *cell = (JJPhotosCollectionCell *)[self cellForItemAtIndexPath:indexPath];
                [cell selectBtnClick];
                [temp addObject:cell];
            }];
            [[JJPhotoManager manager] reloadNewCells:temp];
            JJPhotosCollectionCell *cell = (JJPhotosCollectionCell *)[self cellForItemAtIndexPath:indexPath];
            [cell selectBtnClick];
            cell.select.selected = YES;
        }
    });
}

#pragma mark 展示拍照界面
- (void)JJPhotographCollectionViewCellDidSelect
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // 添加拍照界面
    if (self.photographWindow == nil) {
        self.photographWindow = [[JJPhotograph alloc] initWithFrame:CGRectMake(0, window.bounds.size.height, window.bounds.size.width, window.bounds.size.height) type:JJ_PhotographTypeNomal];
        self.photographWindow.delegate = self;
    }
    [window addSubview:self.photographWindow];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.photographWindow.frame = CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height);
    }];
}
- (void)JJPhotographDisappear:(JJPhotograph *)photograph save:(BOOL)save
{
    [UIView animateWithDuration:0.2 animations:^{
        photograph.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        self.photographWindow = nil;
        [self.photographWindow removeFromSuperview];
    }];
    if ([self.jj_delegate respondsToSelector:@selector(JJPhotosCollectionReloadItems:)]) {
        [self.jj_delegate JJPhotosCollectionReloadItems:save];
    }
}
@end
