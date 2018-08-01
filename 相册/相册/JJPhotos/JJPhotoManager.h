//
//  JJPhotoManager.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJAblumInfo.h"
#import <Photos/Photos.h>
@class JJPhotosCollectionCell;

@interface JJPhotoManager : NSObject

/// 当前选中图片原图大小
@property (nonatomic , assign) CGFloat selectSize;

+ (instancetype)manager;

#pragma mark 图片获取与处理
/**
 * 获取相册列表
 */
- (NSArray<JJAblumInfo *> *)getAllAblums;

/**
 * 获取指定相册集图片资源
 */
- (NSArray<PHAsset *> *)fetchAssetsInCollection:(PHAssetCollection *)collection asending:(BOOL)asending;

/**
 * 获取资源对应的图片
 */
- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

/**
 * 获取资源对应的原图大小
 */
- (void)getImageDataLength:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock;

/**
 * 获取选中相册小图片数组
 */
+ (NSArray *)getPhotos;

/**
 * 获取选中相册原图数组
 */
+ (NSArray *)getArtworks;

/**
 * 获取当前页面所有图片
 */
+ (NSArray *)getAllCells;

/**
 * 初始化原图相关数组
 * @param count 数组大小
 */
+ (void)reloadCellsAndArtworkSizesWithcount:(NSInteger)count;

/**
 * 保存cell
 * @param cell 添加cell
 * @param index 数组坐标
 */
+ (void)addCell:(JJPhotosCollectionCell *)cell index:(NSInteger)index;

/**
 * 保存当前cellImg的原图大小
 * @param size 原图大小
 * @Param index 数组坐标
 */
+ (void)addCellImgSize:(CGFloat)size index:(NSInteger)index;
#pragma mark 图片保存与操作cell
/**
 * 设置最大图片选择数
 */
@property (nonatomic , assign) NSInteger maxCount;

/**
 * 判断选中图片数是否超过了最大值
 */
+ (BOOL)isMax;

/**
 * 获取选中的图片的asset数组
 */
+ (NSArray *)getAssets;

/**
 * 选中的cell
 */
+ (NSArray<JJPhotosCollectionCell*> *)getSelectCells;

/**
 * 更新新的选中的cells(拍照后使用)
 */
- (void)reloadNewSelectCells:(NSArray<JJPhotosCollectionCell*> *)cells;

/**
 * 清理选取数据
 */
+ (void)clear;

/**
 * 添加数据
 */
- (void)addcell:(JJPhotosCollectionCell *)cell asset:(id)asset;

/**
 * 删除数据
 */
- (void)delectCell:(JJPhotosCollectionCell *)cell asset:(id)asset;

/**
 * 刷新cell
 */
- (void)reloadSelectCells;
@end
