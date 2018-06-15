//
//  JJPhotosCollection.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJPhotosCollectionCell.h"
@class JJPhotosCollection;

@protocol JJPhotosCollectionDelegate <NSObject>

// 点击了某个cell
- (void)JJPhotosCollectionDidSelectIndex:(NSInteger)index;
@end
@interface JJPhotosCollection : UICollectionView

// 代理
@property (nonatomic , weak) id<JJPhotosCollectionDelegate>jj_delegate;

// 设置数据源
@property (nonatomic , strong) NSArray *items;
@end
