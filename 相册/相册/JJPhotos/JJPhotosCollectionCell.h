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

/**
 * 图片数量达到了最大数
 */
- (void)JJPhotosCollectionCellDidSelectMaxCount;

/**
 * 图片数量没有达到最大数
 */
- (void)JJPhotosCollectionCellDidNotSelectMaxCount;
@end

@interface JJPhotosCollectionCell : UICollectionViewCell

/// 代理
@property (nonatomic , weak) id<JJPhotosCollectionCellDelegate>delegate;
/// 选中按钮
@property (nonatomic , strong) UIButton *select;
/// 相册图片
@property (nonatomic , strong) UIImageView *photo;
/// 标识id
@property (nonatomic , strong) PHAsset *asset;
/// 数量标题
@property (nonatomic , strong) NSString *title;
/// 是否最大值
@property (nonatomic , assign) BOOL isMax;
/// 标识
@property (nonatomic , assign) NSInteger rowNum;

/**
 * 显示遮罩
 */
- (void)showShade;

/**
 * 隐藏遮罩
 */
- (void)hiddenShade;

/**
 * 选中当前cell
 */
- (void)selectBtnClick;
@end
