//
//  LxCameraView.h
//  ORC-testProject
//
//  Created by 李翔 on 17/2/24.
//  Copyright © 2017年 李翔. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^imageTakeBolck)(UIImage *image);

@interface LxCameraView : UIView

@property (copy, nonatomic) imageTakeBolck imageBlock;

- (void)setupDefaultWithBlock:(imageTakeBolck)block;

@end
