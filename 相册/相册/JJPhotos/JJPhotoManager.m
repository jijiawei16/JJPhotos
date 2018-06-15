//
//  JJPhotoManager.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJPhotoManager.h"
#import "JJPhotosCollectionCell.h"

#define OriginalRatio 0.9
#define SCREEN_W    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_H    ([[UIScreen mainScreen] bounds].size.height)
@interface JJPhotoManager ()

// 解析后的图片数组
@property (nonatomic , strong) NSMutableArray *images;
// 相册列表
@property (nonatomic ,strong) NSMutableArray<JJAblumInfo *> * ablumsList;

// 选中的cell数组
@property (nonatomic , strong) NSMutableArray <JJPhotosCollectionCell*>*cells;
// 选中的图片asset数组
@property (nonatomic , strong) NSMutableArray <PHAsset *>*assets;
@end
@implementation JJPhotoManager

+ (instancetype)manager
{
    static JJPhotoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JJPhotoManager alloc]init];
        manager.ablumsList = [NSMutableArray array];
        manager.cells = [NSMutableArray array];
        manager.assets = [NSMutableArray array];
        manager.images = [NSMutableArray array];
    });
    return manager;
}

/*
 * 获取所有相册
 */
- (NSArray<JJAblumInfo *> *)getAllAblums
{
    //先清空数组
    [_ablumsList removeAllObjects];
    
    //列出并加入所有智能相册
    PHFetchResult * smartAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [self fetchCollection:smartAblums];
    
    //列出列出并加入所有用户创建的相册
    PHFetchResult * topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    [self fetchCollection:topLevelUserCollections];
    
    return _ablumsList;
}

/*
 * 获取相册资源
 */
- (void)fetchCollection:(PHFetchResult *)obj {
    
    //如果obj是所有相册的合集
    [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            
            //返回此相册的资源集合
            PHFetchResult * result = [self fetchResultInCollection:obj asending:NO];
            
            //如果有资源
            if (result.count) {
                
                //创建此相册的信息集
                JJAblumInfo * info = [JJAblumInfo infoFromResult:result collection:obj];
                
                //加入到数组中
                [_ablumsList addObject:info];
            }
        }
    }];
}


/*
 * 获取（指定相册）或者（所有相册）资源的合集，并按资源的创建时间进行排序 YES  倒序 NO
 */
- (PHFetchResult *)fetchResultInCollection:(PHAssetCollection *)collection asending:(BOOL)asending {
    
    PHFetchOptions * option = [[PHFetchOptions alloc]init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:asending]];
    PHFetchResult * result;
    //获取指定相册资源合集
    if (collection) {
        
        result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
    }
    //获取所有相册资源合集
    else {
        result = [PHAsset fetchAssetsWithOptions:option];
    }
    return result;
}

/*
 * 获取（指定相册）或者（所有相册 collection为nil）资源
 */
- (NSArray<PHAsset *> *)fetchAssetsInCollection:(PHAssetCollection *)collection asending:(BOOL)asending{
    
    NSMutableArray<PHAsset *> * list = [NSMutableArray array];
    
    PHFetchResult * result;
    
    //获取指定相册资源
    if (collection) {
        
        result = [self fetchResultInCollection:collection asending:asending];
    }
    //获取所有相册资源
    else {
        
        result = [self fetchResultInCollection:nil asending:asending];
        
    }
    
    //枚举添加到数组
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [list addObject:obj];
    }];
    
    return list;
}

/*
 * 获取资源对应的图片
 */
- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock {
    
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc]init];
    //resizeMode：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
    option.resizeMode = isResize ? PHImageRequestOptionsResizeModeFast : PHImageRequestOptionsResizeModeNone;
    option.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (completeBlock) completeBlock(result, info);
    }];
}

/*
 * 获取资源对应的原图大小
 */
- (void)getImageDataLength:(PHAsset *)asset completeBlock:(void(^)(CGFloat length))completeBlock{
    
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc]init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    option.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        if (completeBlock) completeBlock(imageData.length / 1000.0);
    }];
}

/*
 * 解析图片数组,顺序会改变
 */
- (void)getImagesWithIsOriginal:(BOOL)isOriginal completeBlock:(void(^)(void))completeBlock
{
    // 判断是否选中了图片
    if (_assets.count == 0) {
        [JJPhotoManager manager].images = [NSMutableArray array];
        [JJPhotoManager clear];
        if (completeBlock) completeBlock();
    }
    // 设置占位数据
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 0; i < _assets.count; i ++) {

        PHAsset * asset = _assets[i];
        CGSize size;

        if (isOriginal) {

            //源图 -> 不压缩
            size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);

        }else {

            //压缩的图 －> 以最长边为屏幕分辨率压缩
            CGFloat scale = (CGFloat)asset.pixelWidth / (CGFloat)asset.pixelHeight;
            if (scale > 1.0) {

                if (asset.pixelWidth < SCREEN_W) {
                    //最长边小于屏幕宽度时，采用原图
                    size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
                }else {
                    //压缩
                    size = CGSizeMake(SCREEN_W, SCREEN_W / scale);
                }

            }else {

                if (asset.pixelHeight < SCREEN_H) {
                    //最长边小于屏幕高度时，采用原图
                    size = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
                }else {
                    //压缩
                    size = CGSizeMake(SCREEN_H * scale, SCREEN_H);
                }
            }
        }

        [self fetchImageInAsset:asset size:size isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            
            //当图片读取到指定尺寸时
            if (image.size.width >= size.width * OriginalRatio || image.size.height >= size.height * OriginalRatio) {

                [images addObject:image];

                //全部图片读取完毕,并初始化选中相册的数组
                if (images.count == _assets.count) {

                    self.images = images;
                    [JJPhotoManager clear];
                    if (completeBlock) completeBlock();
                }
            }
        }];
    }
}

/*
 * 获取解析后的图片数组
 */
+ (NSArray *)getPhotos
{
    return [JJPhotoManager manager].images;
}

#pragma mark 图片保存与操作
+ (BOOL)isMax
{
    NSInteger cell_count = [JJPhotoManager manager].cells.count;
    NSInteger asset_count = [JJPhotoManager manager].assets.count;
    NSInteger max_count = [JJPhotoManager manager].maxCount;
    
    if (max_count == cell_count||asset_count == max_count) {
        return YES;
    }else {
        return NO;
    }
}
+ (NSArray *)getAssets
{
    return [JJPhotoManager manager].assets;
}
#pragma mark 清空数组
+ (void)clear
{
    // 清除选中的数据
    [JJPhotoManager manager].assets = [NSMutableArray array];
    [JJPhotoManager manager].cells  = [NSMutableArray array];
}
+ (void)clearImages
{
    [JJPhotoManager manager].images = [NSMutableArray array];
}
- (void)addcell:(JJPhotosCollectionCell *)cell asset:(id)asset
{
    if (![self.cells containsObject:cell]) {
        [self.cells addObject:cell];
    }
    if (![self.assets containsObject:asset]) {
        [self.assets addObject:asset];
        PHAsset *set = (PHAsset*)asset;
        [self fetchImageInAsset:asset size:CGSizeMake(set.pixelWidth, set.pixelHeight) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            
            if ([[NSString stringWithFormat:@"%@",info[@"PHImageResultIsDegradedKey"]] isEqualToString:@"1"]) return;
            if (![self.images containsObject:image]) {
                [self.images addObject:image];
            }
        }];
    }
    [self reloadCells];
}
- (void)delectCell:(JJPhotosCollectionCell *)cell asset:(id)asset
{
    if ([self.cells containsObject:cell]) {
        cell.select.backgroundColor = [UIColor clearColor];
        cell.title = @"";
        [self.cells removeObject:cell];
    }
    if ([self.assets containsObject:asset]) {
        for (NSInteger i = 0; i<self.assets.count; i++) {
            if (asset == self.assets[i]) {
                // 延迟一段时间再删除，有可能图片还没有保存好
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.images removeObjectAtIndex:i];
                });
            }
        }
        [self.assets removeObject:asset];
    }
    [self reloadCells];
}
// 刷新选中cell的布局
- (void)reloadCells{
    [self.cells enumerateObjectsUsingBlock:^(JJPhotosCollectionCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
        obj.title = [NSString stringWithFormat:@"%lu",idx+1];
        [obj.select setTitle:obj.title forState:UIControlStateNormal];
        obj.select.backgroundColor = [UIColor redColor];
    }];
}
@end
