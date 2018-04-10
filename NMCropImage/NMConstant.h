//
//  NMConstant.h
//  NMCropImage
//
//  Created by Nuomi1908 on 2018/2/11.
//  Copyright © 2018年 Nuomi1908 All rights reserved.
//

#ifndef NMConstant_h
#define NMConstant_h

#import "AppDelegate.h"


// 当前设备屏幕的宽度和高度
#define CurrentScreenScale [UIScreen mainScreen].scale
#define CurrentScreenWidth [UIScreen mainScreen].bounds.size.width
#define CurrentScreenHeight [UIScreen mainScreen].bounds.size.height
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define NavBarHeight 44
#define NavTopHeight ((StatusBarHeight)+(NavBarHeight)+10)

#endif /* ICConstant_h */
