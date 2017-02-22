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

#import <GPUImage/GPUImage.h>

@interface ViewController ()<G8TesseractDelegate,
                            UITableViewDelegate,
                            UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray <UIImage *>*imageArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    
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
    // Do any additional setup after loading the view, typically from a nib.
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
