

#import <Foundation/Foundation.h>


@protocol XlwDeviceDelegate <NSObject>
-(bool)onSmartFound:(char*)mac  MODULE_IP:(char*)ip MODULE_VER:(char*)ver MODULE_CAP:(char*)cap MODULE_EXT:(char*)ext;
-(bool)onSearchFound:(char*)mac  MODULE_IP:(char*)ip MODULE_VER:(char*)ver MODULE_CAP:(char*)cap MODULE_EXT:(char*)ext;
-(void)onStatusChange:(char*)mac  MODULE_STATUS:(int)status;
-(void)onReceive:(char*)mac RECEIVE_DATA:(char*)data RECEIVE_LEN:(int)len;                              //收到的数据
-(void)onSendError:(char*)mac SEND_SN:(int)sn SEND_ERR:(int)err;                                        //收到的数据
@end


@interface XlwDevice:NSObject{
    id<XlwDeviceDelegate> delegate;
}
@property(retain) id<XlwDeviceDelegate> delegate;

-(void)LibraryInit;
-(void)LibraryRelease; //释放资源
-(void)LibrarySuspend;
-(void)LibraryResume;
-(char*)GetLibraryVersion;

-(void)SetServer:(char*)value;                        //serve地址, 缺省为appsrv.xlwtech.com
-(void)SetServerTimeout:(int)value;

-(void)SetStatucCheck:(int)interval;               //状态检查间隔，＝0不检查
-(int)DeviceStatuGet:(char*)mac;

-(void)DeviceSearch;                     //搜索模块
-(void)DeviceClear;                      //清除模块搜索列表
-(int) DeviceCount;
-(char*)DeviceMacGet:(int)index;         //获取搜索结果
-(char*)DeviceIpGet:(int)index;
-(char*)DeviceIpGetByMac:(char*)mac;



-(bool)SmartConfigV3_Start:(char*)ssid PASSWORD:(char*)pass TIMEOUT:(int)timeOut;          //请求smartconfig
-(bool)SmartConfigV2_Start:(char*)ssid PASSWORD:(char*)pass TIMEOUT:(int)timeOut;

- (void)SmartConfigStop; //停止smartconfig

-(int)SmartConfigProgressGet;


-(int)DeviceConnect:(char*)mac;
-(int)DeviceIsConnected:(char*)mac;
-(int)DoSendLocal:(char*)mac SEND_DATA:(char*)data SEND_LEN:(int)length;
-(int)DoSendServer:(char*)mac SEND_DATA:(char*)data SEND_LEN:(int)length;
-(int)DoSend:(char*)mac SEND_DATA:(char*)data SEND_LEN:(int)length;
-(int)UdpSend:(char*)ip PORT:(int)port SEND_DATA:(char*)data SEND_LEN:(int)length;

@end
