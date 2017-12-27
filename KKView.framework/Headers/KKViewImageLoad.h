//
//  KKViewImageLoad.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <KKView/KKView.h>

typedef void (^KKViewImageLoadBlock)(UIImage * image, NSError * error);

extern id KKViewImageLoad(NSString * url,KKViewImageLoadBlock block);

extern void KKViewImageCancel(id task);


