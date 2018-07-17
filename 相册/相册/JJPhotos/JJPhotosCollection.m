//
//  JJPhotosCollection.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotosCollection.h"
#import "JJShowPhotosVIew.h"

@interface JJPhotosCollection ()<UICollectionViewDelegate,UICollectionViewDataSource,JJPhotosCollectionCellDelegate>

@property (nonatomic , strong) NSMutableArray *data;
@property (nonatomic , strong) UIButton *addBtn;
@property (nonatomic , strong) UIButton *deleteBtn;
@property (nonatomic , strong) NSMutableArray <JJPhotosCollectionCell *>*selectCells;
@property (nonatomic , strong) NSMutableDictionary *identifies;
@property (nonatomic , assign) BOOL isMax;
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
    
    // 每次先从字典中根据IndexPath取出唯一标识符
    NSString *identifier = [_identifies objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"JJPhotosCollectionCell--%@", [NSString stringWithFormat:@"%@", indexPath]];
        [_identifies setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
        // 注册Cell
        [self registerClass:[JJPhotosCollectionCell class]  forCellWithReuseIdentifier:identifier];
    }
    JJPhotosCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.asset = self.items[indexPath.row];
    cell.delegate = self;
    cell.isMax = self.isMax;
    return  cell;
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
    _items = items;
    self.data = [NSMutableArray arrayWithArray:_items];
    [self reloadData];
    
    // 这里面需要延迟执行,需要等到相册刷新完成之后再滚动到最低端
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.contentSize.height > self.frame.size.height) {
            [self setContentOffset:CGPointMake(0, self.contentSize.height - self.frame.size.height) animated:NO];
        }
    });
}

@end
