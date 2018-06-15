//
//  JJAblumInfo.h
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface JJAblumInfo : NSObject

@property (nonatomic, copy) NSString *ablumName; //相册名字

@property (nonatomic, assign) NSInteger count; //总照片数

@property (nonatomic, strong) PHAssetCollection *assetCollection; //相册

@property (nonatomic, strong) PHAsset *coverAsset; //封面

+ (instancetype)infoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection;
@end
