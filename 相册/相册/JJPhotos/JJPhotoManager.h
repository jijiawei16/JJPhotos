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

+ (instancetype)manager;

#pragma mark 图片获取与处理
/*
 * 获取相册列表
 */
- (NSArray<JJAblumInfo *> *)getAllAblums;

/*
 * 获取指定相册集图片资源
 */
- (NSArray<PHAsset *> *)fetchAssetsInCollection:(PHAssetCollection *)collection asending:(BOOL)asending;

/*
 * 获取资源对应的图片
 */
- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

/*
 * 获取资源对应的原图大小
 */
- (void)getImageDataLength:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock;

///*
// * 解析资源数组成对应的图片数组(这里需要先处理照片然后diss控制器),废弃
// */
//- (void)getImagesWithIsOriginal:(BOOL)isOriginal completeBlock:(void(^)(void))completeBlock;

/*
 * 获取选中相册图片数组
 */
+ (NSArray *)getPhotos;

#pragma mark 图片保存与操作cell
/*
 * 设置最大图片选择数
 */
@property (nonatomic , assign) NSInteger maxCount;

/*
 * 判断选中图片数是否超过了最大值
 */
+ (BOOL)isMax;

/*
 * 获取选中的图片的asset数组
 */
+ (NSArray *)getAssets;

/*
 * 图片
 */
@property (nonatomic , strong) NSMutableDictionary *titles;

/*
 * 清理选取数据
 */
+ (void)clear;
/*
 * 清理图片数组
 */
+ (void)clearImages;
/*
 * 添加数据
 */
- (void)addcell:(JJPhotosCollectionCell *)cell asset:(id)asset;

/*
 * 删除数据
 */
- (void)delectCell:(JJPhotosCollectionCell *)cell asset:(id)asset;
@end
