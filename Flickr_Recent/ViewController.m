//
//  ViewController.m
//  Flickr_Recent
//
//  Created by SIVASANKAR DEVABATHINI on 10/3/15.
//  Copyright (c) 2015 SIVASANKAR DEVABATHINI. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"

static NSString * const API_KEY = @"d515b0f9f2c88d498153db3c68649bbe";

static NSString * const recentPhotosURL = @"https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=%@&format=json&nojsoncallback=1";

@interface ViewController (){
    NSArray *recentPhotos;
    NSMutableArray *urlsArray;
    int photoIndex;
    MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *picTitle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getRecentPhotos];
    HUD = [[MBProgressHUD alloc]init];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading";
    [HUD removeFromSuperViewOnHide];
    [HUD show:YES];
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)getRecentPhotos{
    
    photoIndex = 0;
    
    NSString *urlString = [NSString stringWithFormat:recentPhotosURL, API_KEY];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                recentPhotos =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"photos"][@"photo"];
                
                urlsArray = [[NSMutableArray alloc]init];
                for (int index = 0; index < recentPhotos.count ; index++){
                    [urlsArray addObject:[self generatePhotoURL:recentPhotos[index]]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imgView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:urlsArray[photoIndex]]]];
                    self.picTitle.text = recentPhotos[photoIndex][@"title"];
                    HUD.hidden = YES;
                });
            }]
     resume];
}

-(NSURL*)generatePhotoURL:(NSDictionary*)photoDict{
    
    //https://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
    
    static NSString *baseStr = @"static.flickr.com/";
    
    NSMutableString *URLString = [NSMutableString stringWithString:@"https://"];
    [URLString appendFormat:@"farm%@.",photoDict[@"farm"]];
    

    [URLString appendString:baseStr];
    [URLString appendFormat:@"%@/%@_%@.jpg",photoDict[@"server"],photoDict[@"id"],photoDict[@"secret"]];
    
    return [NSURL URLWithString:URLString];
    
    
}

-(void)swipeleft:(UIGestureRecognizer*)gesture{
    
    if(photoIndex >= urlsArray.count) return;
    
    photoIndex++;
    [UIView transitionWithView:self.imgView duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           self.imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlsArray[photoIndex]]];
                           self.picTitle.text = recentPhotos[photoIndex][@"title"];
                       } completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
