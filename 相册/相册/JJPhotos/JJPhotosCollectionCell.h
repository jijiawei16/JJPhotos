//
//  JJPhotosCollectionCell.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJPhotoManager.h"

@protocol JJPhotosCollectionCellDelegate <NSObject>

// 选择了最大数
- (void)JJPhotosCollectionCellDidSelectMaxCount;
- (void)JJPhotosCollectionCellDidNotSelectMaxCount;
@end
@interface JJPhotosCollectionCell : UICollectionViewCell

/* 代理 */
@property (nonatomic , weak) id<JJPhotosCollectionCellDelegate>delegate;
/* 选中按钮 */
@property (nonatomic , strong) UIButton *select;
/* 标识id */
@property (nonatomic , strong) PHAsset *asset;
/* 数量标题 */
@property (nonatomic , strong) NSString *title;
/* 是否最大值 */
@property (nonatomic , assign) BOOL isMax;
/*
 * 显示遮罩
 */
- (void)showShade;

/*
 * 隐藏遮罩
 */
- (void)hiddenShade;
@end
