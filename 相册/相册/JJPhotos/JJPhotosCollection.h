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

///选中了cell
- (void)JJPhotosCollectionDidSelectCell;
///拍照界面消失,是否刷新
- (void)JJPhotosCollectionReloadItems:(BOOL)reloadItems;
@end
@interface JJPhotosCollection : UICollectionView

///代理
@property (nonatomic , weak) id<JJPhotosCollectionDelegate>jj_delegate;

///设置数据源
@property (nonatomic , strong) NSArray *items;

///是否是相册列表
@property (nonatomic , strong) NSString *photoListName;
///是否需要选中第一个cell
@property (nonatomic , assign) BOOL needSelect;
@end
