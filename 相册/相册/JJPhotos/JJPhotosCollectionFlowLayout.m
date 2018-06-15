//
//  JJPhotosCollectionFlowLayout.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotosCollectionFlowLayout.h"

#define itemsNum 4
@interface JJPhotosCollectionFlowLayout ()

// 用来存collection的数据
@property (nonatomic , strong) NSMutableArray *items;
@end
@implementation JJPhotosCollectionFlowLayout

- (NSMutableArray *)items
{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 设置控件水平和竖直间距
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    //把初始化数组
    [self.items removeAllObjects];
    
    //开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.items addObject:attrs];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.items;
}

// 在这个方法里面修改控件的布局(自定义布局)
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 在这个地方设置cell的frame，瀑布流也是在这个地方写
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat w = width/itemsNum;
    CGFloat h = width/itemsNum;
    CGFloat x = indexPath.row%itemsNum*w;
    CGFloat y = indexPath.row/itemsNum*h;
    attrs.frame = CGRectMake(x, y, w, h);
    return attrs;
}

- (CGSize)itemSize
{
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat w = width/itemsNum;
    CGFloat h = width/itemsNum;
    return CGSizeMake(w, h);
}
@end
