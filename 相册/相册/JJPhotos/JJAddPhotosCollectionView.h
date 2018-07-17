//
//  JJAddPhotosCollectionView.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/25.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JJAddPhotosCollectionView;

@protocol JJAddPhotosCollectionViewDelegate <NSObject>
///数据源发生了改变
- (void)JJAddPhotosCollectionView:(JJAddPhotosCollectionView*)collection Changeitems:(NSArray *)items index:(NSInteger)index;
///点击了某个cell
- (void)JJAddPhotosCollectionView:(JJAddPhotosCollectionView*)collection didSelectIndex:(NSInteger)index;
///frame发生了改变
- (void)JJAddPhotosCollectionView:(JJAddPhotosCollectionView*)collection ChangeFrame:(CGRect)frame;
@end

@interface JJAddPhotosCollectionView : UICollectionView

///代理
@property (nonatomic , weak) id<JJAddPhotosCollectionViewDelegate>jj_delegate;

///图片添加最大数
@property (nonatomic , assign) NSInteger maxCount;

///每一行图片最大数
@property (nonatomic , assign) NSInteger rows;

///是否显示删除按钮
@property (nonatomic , assign) BOOL showDelect;

///父控制器
@property (nonatomic , strong) UIViewController *superVC;

///设置数据源
- (void)addItems:(NSArray *)items;

///获取数据源数组
- (NSArray *)getItems;
@end
