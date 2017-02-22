//
//  ViewController.m
//  ORC-testProject
//
//  Created by 李翔 on 17/2/14.
//  Copyright © 2017年 李翔. All rights reserved.
//

#import "ViewController.h"
#import <TesseractOCR/TesseractOCR.h>
//#import <TesseractOCRiOS/TesseractOCR.h>
#import "UIImageCVMatConverter.h"
#import <GPUImage/GPUImage.h>
#include "easypr.h"
#include "easypr/util/switch.hpp"
#include "GlobalData.hpp"
using namespace easypr;
CPlateRecognize pr;

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#endif

@interface ViewController ()<G8TesseractDelegate,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,
                            UIPopoverControllerDelegate
                            >
{
    cv::CascadeClassifier faceCascade;
    cv::Mat source_image;
    cv::Mat RGB;
}

@property (strong, nonatomic) NSMutableArray <UIImage *>*imageArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIPopoverController *popoverController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.imageArray = [NSMutableArray array];
    
    
    [self recognizeSetup];

}

- (void)recognizeSetup
{
    NSString* bundlePath=[[NSBundle mainBundle] bundlePath];
    std::string mainPath=[bundlePath UTF8String];
    GlobalData::mainBundle()=mainPath;
    
    cout << "test_plate_recognize" << endl;
    
    pr.setLifemode(true);
    pr.setDebug(false);
    pr.setMaxPlates(4);
    //pr.setDetectType(PR_DETECT_COLOR | PR_DETECT_SOBEL);
    pr.setDetectType(easypr::PR_DETECT_CMSER);
    
    UIImage *temp = [UIImage imageNamed:@"images.jpeg"];
    [self.imageArray addObject:temp];
    UIImage *temp_image=[UIImageCVMatConverter scaleAndRotateImageBackCamera:temp];
    [self.imageArray addObject:temp_image];
    source_image = [UIImageCVMatConverter cvMatFromUIImage:temp_image];
    [self.imageArray addObject:[UIImageCVMatConverter UIImageFromCVMat:source_image]];
    [self plateRecognition:source_image];
    [self.tableView reloadData];


//    NSString *nsstring=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
//    string image_path=[nsstring UTF8String];
    
//    source_image=imread(image_path);
//    resize(source_image, source_image,cv::Size(source_image.cols/2,source_image.rows/2));
//    [self.imageArray addObject:[UIImageCVMatConverter UIImageFromCVMat:source_image]];
//    [self plateRecognition:source_image];
//    [self.tableView reloadData];
}

#pragma mark -ClickAction
- (IBAction)AlbumClick:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];

}

- (IBAction)CameraClick:(id)sender {
}

#pragma mark imagePickDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *temp = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageArray addObject:temp];
    UIImage *temp_image=[UIImageCVMatConverter scaleAndRotateImageBackCamera:temp];
    [self.imageArray addObject:temp_image];
    source_image = [UIImageCVMatConverter cvMatFromUIImage:temp_image];
    [self.imageArray addObject:[UIImageCVMatConverter UIImageFromCVMat:source_image]];
    [self plateRecognition:source_image];
    [self.tableView reloadData];
    
}

-(UIImage*)plateRecognition:(cv::Mat&)src
{
    UIImage *plateimage;
    
    vector<CPlate> plateVec;
    double t=cv::getTickCount();
    int result = pr.plateRecognize(src, plateVec);
    t=cv::getTickCount()-t;
    NSLog(@"time %f",t*1000/cv::getTickFrequency());
    if (result == 0) {
        size_t num = plateVec.size();
        for (size_t j = 0; j < num; j++) {
            cout << "plateRecognize: " << plateVec[j].getPlateStr() << endl;
        }
    }
    
    if (result != 0) cout << "result:" << result << endl;
    if(plateVec.size()==0){
       
        [self.label performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"No Plate"] waitUntilDone:NO];
        return plateimage;
    }
    string name=plateVec[0].getPlateStr();
    NSString *resultMessage = [NSString stringWithCString:plateVec[0].getPlateStr().c_str()
                                                 encoding:NSUTF8StringEncoding];
    [self.label performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@",resultMessage] waitUntilDone:NO];
    
    
    if (result != 0)
        cout << "result:" << result << endl;
    return plateimage;
}


#pragma mark - tesseractFunction

- (void)tesseractFunction
{

    
    
    
    self.imageArray = [[NSMutableArray alloc] init];
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"chi_sim+eng"];
    //获取去阈值图片
    //抓取要预处理的图像
    UIImage * inputImage = [UIImage imageNamed:@"6AC6E71A-634E-4E61-B928-53555ADBD124.png"];
    [self.imageArray addObject:inputImage];
    
    UIImage *grayImage = [inputImage g8_grayScale];
    [self.imageArray addObject:grayImage];
    
    UIImage *blackImage = [inputImage g8_blackAndWhite];
    [self.imageArray addObject:blackImage];
    
    //    //初始化我们的自适应阈值过滤器
    //    GPUImageAdaptiveThresholdFilter * stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc ] init ];
    //    stillImageFilter.blurRadiusInPixels = 4.0;  //调整此设置以调整过滤器的模糊半径，默认为4.0
    //    //从过滤器中检索过滤的图像
    //    UIImage * filteredImage = [stillImageFilter imageByFilteringImage: inputImage];
    
    //operation.tesseract.image = [[UIImage imageNamed:@"Lenore.png"] g8_blackAndWhite];
    operation.tesseract.image = blackImage;
    [self.imageArray addObject:[operation.tesseract image]];
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSingleColumn;
    operation.tesseract.delegate = self;
    
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
        NSLog(@"%@", [recognizedTesseract recognizedText]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = [recognizedTesseract recognizedText];
            [self.tableView reloadData];
        });
        
    };
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];

}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    
    if (![self.imageArray containsObject:[tesseract thresholdedImage]]) {
        [self.imageArray addObject:[tesseract thresholdedImage]];
    }
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}


- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView_Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIImageView *view = [cell viewWithTag:100];
    if (view) {
         view.image = self.imageArray[indexPath.row];
    }else
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 376, 120)];
        view.tag = 100;
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.image = self.imageArray[indexPath.row];
        [cell addSubview:view];
    }
    
    return cell;
}


@end
