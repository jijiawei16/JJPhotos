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

/// 解析后的小图片数组
@property (nonatomic , strong) NSMutableArray *images;
/// 解析后的原图数组
@property (nonatomic , strong) NSMutableArray *Artworks;
/// 当前页面所有cell
@property (nonatomic , strong) NSMutableArray *allCells;
/// 当前页面所有原图大小
@property (nonatomic , strong) NSMutableArray *artworkSizes;
/// 相册列表
@property (nonatomic ,strong) NSMutableArray<JJAblumInfo *> * ablumsList;
/// 选中的cell数组
@property (nonatomic , strong) NSMutableArray <JJPhotosCollectionCell*>*selectCells;
/// 选中的图片asset数组
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
        manager.selectCells = [NSMutableArray array];
        manager.assets = [NSMutableArray array];
        manager.images = [NSMutableArray array];
        manager.Artworks = [NSMutableArray array];
        manager.allCells = [NSMutableArray array];
        manager.artworkSizes = [NSMutableArray array];
    });
    return manager;
}

/**
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

/**
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


/**
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

/**
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

/**
 * 获取资源对应的图片
 */
- (void)fetchImageInAsset:(PHAsset *)asset size:(CGSize)size isResize:(BOOL)isResize completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock {
    
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc]init];
    option.resizeMode = isResize ? PHImageRequestOptionsResizeModeFast : PHImageRequestOptionsResizeModeNone;
    option.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (completeBlock) completeBlock(result, info);
    }];
}

/**
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

+ (NSArray *)getPhotos
{
    return [JJPhotoManager manager].images;
}
+ (NSArray *)getArtworks
{
    return [JJPhotoManager manager].Artworks;
}
+ (NSArray *)getAllCells
{
    return [JJPhotoManager manager].allCells;
}
+ (void)reloadCellsAndArtworkSizesWithcount:(NSInteger)count
{
    for (NSInteger i = 0; i < count; i++) {
        [[JJPhotoManager manager].allCells addObject:@""];
        [[JJPhotoManager manager].artworkSizes addObject:@""];
    }
}
+ (void)addCell:(JJPhotosCollectionCell *)cell index:(NSInteger)index
{
    [JJPhotoManager manager].allCells[index] = cell;
}
+ (void)addCellImgSize:(CGFloat)size index:(NSInteger)index
{
    [JJPhotoManager manager].artworkSizes[index] = @(size);
}
#pragma mark 图片保存与操作
+ (BOOL)isMax
{
    NSInteger cell_count = [JJPhotoManager manager].selectCells.count;
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
    [JJPhotoManager manager].selectCells  = [NSMutableArray array];
    [JJPhotoManager manager].images = [NSMutableArray array];
    [JJPhotoManager manager].Artworks = [NSMutableArray array];
    [JJPhotoManager manager].Artworks = [NSMutableArray array];
    [JJPhotoManager manager].allCells = [NSMutableArray array];
    [JJPhotoManager manager].artworkSizes = [NSMutableArray array];
}
/**
 * 添加一个cell和图片信息
 * @param cell 要添加的cell
 * @param asset 图片信息
 */
- (void)addcell:(JJPhotosCollectionCell *)cell asset:(id)asset
{
    if (![self.selectCells containsObject:cell]) {
        [self.selectCells addObject:cell];
    }
    if (![self.assets containsObject:asset]) {
        [self.assets addObject:asset];
        PHAsset *set = (PHAsset*)asset;
        // 保存缩略图图片和原图
        if (![self.images containsObject:cell.photo.image]) {
            [self.images addObject:cell.photo.image];
        }
        [self fetchImageInAsset:asset size:CGSizeMake(set.pixelWidth, set.pixelHeight) isResize:YES completeBlock:^(UIImage *image, NSDictionary *info) {
            
            if ([[NSString stringWithFormat:@"%@",info[@"PHImageResultIsDegradedKey"]] isEqualToString:@"1"]) return;
            if (![self.Artworks containsObject:image]) {
                [self.Artworks addObject:image];
            }
        }];
    }
    [self reloadSelectCells];
}
/**
 * 删除cell和相关图片信息
 * @param cell 要添加的cell
 * @param asset 图片信息
 */
- (void)delectCell:(JJPhotosCollectionCell *)cell asset:(id)asset
{
    if ([self.selectCells containsObject:cell]) {
        cell.select.backgroundColor = [UIColor clearColor];
        cell.title = @"";
        [self.selectCells removeObject:cell];
    }
    if ([self.assets containsObject:asset]) {
        for (NSInteger i = 0; i<self.assets.count; i++) {
            if (asset == self.assets[i]) {
                // 延迟一段时间再删除，有可能图片还没有保存好
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.Artworks removeObjectAtIndex:i];
                    [self.images removeObjectAtIndex:i];
                });
            }
        }
        [self.assets removeObject:asset];
    }
    [self reloadSelectCells];
}
/**
 * 刷新选中cell的布局
 */
- (void)reloadSelectCells
{
    __block CGFloat size = 0;
    [self.selectCells enumerateObjectsUsingBlock:^(JJPhotosCollectionCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
        obj.select.selected = YES;
        obj.title = [NSString stringWithFormat:@"%lu",idx+1];
        [obj.select setTitle:obj.title forState:UIControlStateNormal];
        obj.select.backgroundColor = [UIColor redColor];
        size += [self.artworkSizes[obj.rowNum] floatValue];
    }];
    self.selectSize = size;
}
+ (NSArray<JJPhotosCollectionCell*> *)getSelectCells
{
    return [JJPhotoManager manager].selectCells;
}
- (void)reloadNewSelectCells:(NSArray<JJPhotosCollectionCell *> *)cells
{
    self.selectCells = [NSMutableArray arrayWithArray:cells];
}
@end
