//
//  LightUtils.h
//  LightUtils
//
//  Created by XuRuomeng on 14-2-7.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach_host.h>
#import <mach/mach.h>
#import <mach/vm_map.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <netdb.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <dlfcn.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#pragma mark - Small Header Of PSSystemConfigurationDynamicStoreWifiWatcher

@interface PSSystemConfigurationDynamicStoreWifiWatcher : NSObject{
    struct __SCDynamicStore *_prefs;
    struct __CFString *_wifiKey;
    struct __CFString *_wifiInterface;
    struct __CFString *_tetheringLink;
}
+ (BOOL)wifiEnabled;
+ (void)releaseSharedInstance;
+ (id)sharedInstance;
- (void)dealloc;
- (id)init;
- (id)wifiConfig;
- (id)_wifiNameWithState:(id)arg1;
- (id)_wifiPowerWithState:(id)arg1;
- (id)_wifiTetheringWithState:(id)arg1;
- (void)findKeysAirPortState:(id *)arg1 andTetheringState:(id *)arg2;
@end

#pragma mark - Header Of LightUtils

@interface LightUtils : NSObject{
    void *libHandle;
    void *airportHandle;
    int (*apple80211Open)(void *);
    int (*apple80211Bind)(void *, NSString *);
    int (*apple80211Close)(void *);
    int (*apple80211GetInfoCopy)(void *, CFDictionaryRef *);
}

#pragma mark - LightUtils CPU

+ (NSUInteger)CPUCount;
+ (NSString *)CPUFrequency;
+ (NSUInteger)CPUFrequencyNow;
+ (NSUInteger)CPU_L1_I_CacheSize;
+ (NSUInteger)CPU_L1_D_CacheSize;
+ (NSUInteger)CPU_L2_CacheSize;
+ (NSUInteger)CPU_L3_CacheSize;
+ (NSString *)CPUType;
+ (NSArray *)CPUUsage;

#pragma mark - LightUtils Memory

+ (NSUInteger)memoryBytesFree;
+ (NSUInteger)memoryBytesTotal;
+ (NSUInteger)memoryWire;
+ (NSUInteger)memoryActive;
+ (NSUInteger)memoryInactive;

#pragma mark - LightUtils Process

+ (NSDictionary *)process;

#pragma mark - LightUtils WiFi

+ (uint32_t)WiFiAllFlow;
+ (NSString *)WiFiBSSID;
+ (NSInteger)WiFiChannel;
+ (BOOL)WiFiEnabled;
+ (NSString *)WiFiIPAddress;
+ (uint32_t)WiFiInputFlow;
+ (NSString *)WiFiMacAddress;
+ (NSString *)WiFiName;
+ (uint32_t)WiFiOutputFlow;
+ (NSInteger)WiFiSignalStrength;

#pragma mark - LightUtils Phone

+ (NSInteger)PhoneSignalStrength;

#pragma mark - LightUtils Device Hardware

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define IPHONE_4_NAMESTRING             @"iPhone 4"
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5c_NAMESTRING            @"iPhone 5C"
#define IPHONE_5s_NAMESTRING            @"iPhone 5S"
#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_5G_NAMESTRING              @"iPad 5G"
#define IPAD_MINI_NAMESTRING            @"iPad Mini"
#define IPAD_MINI_2G_NAMESTRING            @"iPad Mini 2"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define SIMULATOR_NAMESTRING            @"iPhone Simulator"
#define SIMULATOR_IPHONE_NAMESTRING     @"iPhone Simulator"
#define SIMULATOR_IPAD_NAMESTRING       @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator" // :)

//iPhone 3G 以后各代的CPU型号和频率
#define IPHONE_3G_CPUTYPE               @"ARM11"
#define IPHONE_3G_CPUFREQUENCY          @"412MHz"
#define IPHONE_3GS_CPUTYPE              @"ARM Cortex A8"
#define IPHONE_3GS_CPUFREQUENCY         @"600MHz"
#define IPHONE_4_CPUTYPE                @"Apple A4"
#define IPHONE_4_CPUFREQUENCY           @"1GHz"
#define IPHONE_4S_CPUTYPE               @"Apple A5"
#define IPHONE_4S_CPUFREQUENCY          @"800MHz"
#define IPHONE_5_CPUTYPE                @"Apple A6"
#define IPHONE_5_CPUFREQUENCY           @"1.3GHz"
#define IPHONE_5c_CPUTYPE               @"Apple A6"
#define IPHONE_5c_CPUFREQUENCY          @"1.3GHz"
#define IPHONE_5s_CPUTYPE               @"Apple A7"
#define IPHONE_5s_CPUFREQUENCY          @"1.3GHz"

//iPod touch 4G 的CPU型号和频率
#define IPOD_4G_CPUTYPE                 @"Apple A4"
#define IPOD_4G_CPUFREQUENCY            @"800MHz"

//iPod touch 5G 的CPU型号和频率
#define IPOD_5G_CPUTYPE                 @"Apple A5"
#define IPOD_5G_CPUFREQUENCY            @"1GHz"

//iPad 1G的CPU型号和频率
#define IPAD_1G_CPUTYPE                 @"Apple A4"
#define IPAD_1G_CPUFREQUENCY            @"1GHz"

//iPad 2G的CPU型号和频率
#define IPAD_2G_CPUTYPE                 @"Apple A5"
#define IPAD_2G_CPUFREQUENCY            @"1GHz"

//iPad 3G的CPU型号和频率
#define IPAD_3G_CPUTYPE                 @"Apple A5X"
#define IPAD_3G_CPUFREQUENCY            @"1GHz"

//iPad 4G的CPU型号和频率
#define IPAD_4G_CPUTYPE                 @"Apple A6X"
#define IPAD_4G_CPUFREQUENCY            @"1GHz"

//iPad 4G的CPU型号和频率
#define IPAD_5G_CPUTYPE                 @"Apple A7"
#define IPAD_5G_CPUFREQUENCY            @"1.3GHz"

//iPad Mini的CPU型号和频率
#define IPAD_MINI_CPUTYPE               @"Apple A5"
#define IPAD_MINI_CPUFREQUENCY          @"1GHz"

//iPad Mini 2的CPU型号和频率
#define IPAD_MINI_2G_CPUTYPE            @"Apple A6"
#define IPAD_MINI_2G_CPUFREQUENCY       @"1.3GHz"

#define IOS_CPUTYPE_UNKNOWN             @"Unknown CPU type"
#define IOS_CPUFREQUENCY_UNKNOWN        @"Unknown CPU frequency"

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceSimulator,
    UIDeviceSimulatoriPhone,
    UIDeviceSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    
    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
    UIDevice4GiPad,
    UIDevice5GiPad,
    
    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceIFPGA,
    
} UIDevicePlatform;

typedef enum {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
    
} UIDeviceFamily;

@end
