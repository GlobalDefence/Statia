//
//  LightUtils.m
//  LightUtils
//
//  Created by XuRuomeng on 14-2-7.
//
//

#import "LightUtils.h"

@implementation LightUtils

#pragma mark - LightUtils CPU

+ (NSUInteger)CPUFrequencyNow
{
    return [self getSysInfo:HW_CPU_FREQ];
}

+ (NSUInteger)CPU_L2_CacheSize
{
    return (NSUInteger)[self getSysInfo:HW_L2CACHESIZE];
}

+ (NSUInteger)CPU_L3_CacheSize
{
    return (NSUInteger)[self getSysInfo:HW_L3CACHESIZE];
}

+ (NSUInteger)CPU_L1_D_CacheSize
{
    return (NSUInteger)[self getSysInfo:HW_L1DCACHESIZE];
}

+ (NSUInteger)CPU_L1_I_CacheSize
{
    return (NSUInteger)[self getSysInfo:HW_L1ICACHESIZE];
}

+ (NSUInteger)CPUCount
{
    return [self getSysInfo:HW_NCPU];
}

+ (NSString *)CPUType
{
    switch ([self platformType])
    {
        case UIDevice3GiPhone: return IPHONE_3G_CPUTYPE;
        case UIDevice3GSiPhone: return IPHONE_3GS_CPUTYPE;
        case UIDevice4iPhone: return IPHONE_4_CPUTYPE;
        case UIDevice4SiPhone: return IPHONE_4S_CPUTYPE;
        case UIDevice5iPhone: return IPHONE_5_CPUTYPE;
        case UIDevice5CiPhone: return IPHONE_5c_CPUTYPE;
        case UIDevice5SiPhone: return IPHONE_5s_CPUTYPE;
        case UIDevice4GiPod: return IPOD_4G_CPUTYPE;
        case UIDevice5GiPod: return IPOD_5G_CPUTYPE;
        case UIDevice1GiPad: return IPAD_1G_CPUTYPE;
        case UIDevice2GiPad: return IPAD_2G_CPUTYPE;
        case UIDevice3GiPad: return IPAD_3G_CPUTYPE;
        case UIDevice4GiPad: return IPAD_4G_CPUTYPE;
        case UIDevice5GiPad: return IPAD_5G_CPUTYPE;
        default: return IOS_CPUTYPE_UNKNOWN;
    }
}

+ (NSArray *)CPUUsage
{
    NSMutableArray *usage = [NSMutableArray array];
    
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if(_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if(err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        for(unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if(_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            float u = _inUse / _total * 100.f;
            [usage addObject:[NSNumber numberWithFloat:u]];
        }
        
        [_cpuUsageLock unlock];
        
        if(_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        
        _prevCPUInfo = _cpuInfo;
        _numPrevCPUInfo = _numCPUInfo;
        
        _cpuInfo = nil;
        _numCPUInfo = 0U;
    } else {
        
    }
    return usage;
}


+ (NSString *)CPUFrequency
{
    switch ([self platformType])
    {
        case UIDevice3GiPhone: return IPHONE_3G_CPUFREQUENCY;
        case UIDevice3GSiPhone: return IPHONE_3GS_CPUFREQUENCY;
        case UIDevice4iPhone: return IPHONE_4_CPUFREQUENCY;
        case UIDevice4SiPhone: return IPHONE_4S_CPUFREQUENCY;
        case UIDevice5iPhone: return IPHONE_5_CPUFREQUENCY;
        case UIDevice5CiPhone: return IPHONE_5c_CPUFREQUENCY;
        case UIDevice5SiPhone: return IPHONE_5s_CPUFREQUENCY;
        case UIDevice4GiPod: return IPOD_4G_CPUFREQUENCY;
        case UIDevice5GiPod: return IPOD_5G_CPUFREQUENCY;
        case UIDevice1GiPad: return IPAD_1G_CPUFREQUENCY;
        case UIDevice2GiPad: return IPAD_2G_CPUFREQUENCY;
        case UIDevice3GiPad: return IPAD_3G_CPUFREQUENCY;
        case UIDevice4GiPad: return IPAD_4G_CPUFREQUENCY;
        case UIDevice5GiPad: return IPAD_5G_CPUFREQUENCY;
        default: return IOS_CPUFREQUENCY_UNKNOWN;
    }
    
}

#pragma mark - LightUtils Memory

+ (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

+ (NSUInteger)memoryBytesFree
{
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t     vm_stat;
    host_page_size(host_port, &pagesize);
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");
    natural_t  mem_free = vm_stat.free_count * (int)pagesize;
    return mem_free;
}

+ (NSUInteger)memoryBytesTotal
{
    return [self getSysInfo:HW_PHYSMEM];
}

+ (NSUInteger)memoryInactive
{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return -1;
    }
    else
    {
        return vmstat.inactive_count;
    }
}

+ (NSUInteger)memoryActive
{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return -1;
    }
    else
    {
        return vmstat.active_count;
    }
}

+ (NSUInteger)memoryWire
{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return -1;
    }
    else
    {
        return vmstat.wire_count;
    }
}

#pragma mark - LightUtils Platform

+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *)platformInfo
{
    return [self getSysInfoByName:"hw.machine"];
}

+ (NSUInteger) platformType
{
    NSString *platform = [self platformInfo];
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    if ([platform hasPrefix:@"iPhone5.1"])          return UIDevice5iPhone;
    if ([platform hasPrefix:@"iPhone5.2"])          return UIDevice5iPhone;
    if ([platform hasPrefix:@"iPhone5"])            return UIDevice5CiPhone;
    if ([platform hasPrefix:@"iPhone6"])            return UIDevice5SiPhone;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    
    // iPad
    if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([platform hasPrefix:@"iPad2"])              return UIDevice2GiPad;
    if ([platform hasPrefix:@"iPad3"])              return UIDevice3GiPad;
    if ([platform hasPrefix:@"iPad4"])              return UIDevice4GiPad;
    if ([platform hasPrefix:@"iPad5"])              return UIDevice5GiPad;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

#pragma mark - LightUtils Process

+ (NSArray *)process
{
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL ,0};
    size_t miblen = 4;
    size_t size;
    int st = sysctl(mib, (int)miblen, NULL, &size, NULL, 0);
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    do
	{
		size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess)
		{
			if (process)
			{
                free(process);
				process = NULL;
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, (int)miblen, process, &size, NULL, 0);
    }while (st == -1 && errno == ENOMEM);
    if (st == 0)
	{
        if (size % sizeof(struct kinfo_proc) == 0)
		{
            int nprocess = (int)size / sizeof(struct kinfo_proc);
            if (nprocess)
			{
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--)
				{
					NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
					NSString * proc_CPU = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pctcpu];
                    
					//NSString * proc_useTime = [[NSString alloc] initWithFormat:@"%s",asctime(localtime(&(process[i].kp_proc.p_un.__p_starttime.tv_sec)))];
                    //task_t the_task;
                    //struct task_basic_info info;
                    //mach_msg_type_number_t size = sizeof(info);
                    
                    //kern_return_t kerr = task_info(task_for_pid(mach_task_self(), process[i].kp_proc.p_pid, &the_task),TASK_BASIC_INFO,(task_info_t)&info,&size);
					NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
					[dic setValue:processID forKey:@"PID"];
					[dic setValue:processName forKey:@"NAME"];
					[dic setValue:proc_CPU forKey:@"CPU"];
					//[dic setValue:proc_useTime forKey:@"TIME"];
                    //if (kerr == KERN_SUCCESS) {
                    //[dic setValue:[NSString stringWithFormat:@"%lu",info.resident_size] forKey:@"MEM"];
                    //}
                    [array addObject:dic];
                }
                free(process);
				process = NULL;
				return array;
            }
        }
    }
    return nil;
}

#pragma mark - LightUtils WiFi

+ (NSString *)WiFiIPAddress
{
    NSString *result = nil;
    struct ifaddrs *interfaces;
    char str[INET_ADDRSTRLEN];
    if (getifaddrs(&interfaces))
        return nil;
    struct ifaddrs *test_addr = interfaces;
    while (test_addr) {
        if(test_addr->ifa_addr->sa_family == AF_INET) {
            if (strcmp(test_addr->ifa_name, "en0") == 0) {
                inet_ntop(AF_INET, &((struct sockaddr_in *)test_addr->ifa_addr)->sin_addr, str, INET_ADDRSTRLEN);
                result = [NSString stringWithUTF8String:str];
                break;
            }
        }
        test_addr = test_addr->ifa_next;
    }
    freeifaddrs(interfaces);
    return result;
}

+ (NSString *)WiFiMacAddress
{
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSMutableString *outstring = [[NSMutableString alloc] init];
    [outstring appendFormat:@"%02x",*ptr];
    [outstring appendFormat:@":"];
    [outstring appendFormat:@"%02x",*(ptr + 1)];
    [outstring appendFormat:@":"];
    [outstring appendFormat:@"%02x",*(ptr + 2)];
    [outstring appendFormat:@":"];
    [outstring appendFormat:@"%02x",*(ptr + 3)];
    [outstring appendFormat:@":"];
    [outstring appendFormat:@"%02x",*(ptr + 4)];
    [outstring appendFormat:@":"];
    [outstring appendFormat:@"%02x",*(ptr + 5)];
    free(buf);
    return [outstring uppercaseString];
}

+ (NSString *)WiFiName
{
    NSBundle *b = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Preferences.framework"];
    BOOL success = [b load];
    if (success) {
        Class PSSystemConfigurationDynamicStoreWifiWatcher = NSClassFromString(@"PSSystemConfigurationDynamicStoreWifiWatcher");
        id tt = [PSSystemConfigurationDynamicStoreWifiWatcher sharedInstance];
        NSDictionary *wifi = [[NSDictionary alloc] init];
        wifi = [tt wifiConfig];
        [PSSystemConfigurationDynamicStoreWifiWatcher releaseSharedInstance];
        return [wifi objectForKey:@"wifiName"];
    }else{
        return nil;
    }
}

+(uint32_t)WiFiOutputFlow
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return -1;
    }
    
    uint32_t wifiOBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        //wifi flow
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wifiOBytes += if_data->ifi_obytes;
        }
        
    }
    freeifaddrs(ifa_list);
    return wifiOBytes;
}

+(uint32_t)WiFiInputFlow
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return -1;
    }
    uint32_t wifiIBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        //wifi flow
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wifiIBytes += if_data->ifi_ibytes;
        }
    }
    freeifaddrs(ifa_list);
    return wifiIBytes;
}


+(uint32_t)WiFiAllFlow
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return -1;
    }
    
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow   = 0;
    
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
        }
    }
    freeifaddrs(ifa_list);
    return wifiFlow;
}

+ (NSString *)WiFiBSSID
{
    return [[[super alloc] wifiInfo] valueForKey:@"BSSID"];
}

+ (NSInteger)WiFiChannel
{
    return [[[[[super alloc] wifiInfo] valueForKey:@"CHANNEL"] objectForKey:@"CHANNEL"] integerValue];
}

+ (NSInteger)WiFiSignalStrength
{
    return [[[[super alloc] wifiInfo] valueForKey:@"RATE"] integerValue];
}

+ (BOOL)WiFiEnabled{
    NSBundle *b = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Preferences.framework"];
    BOOL success = [b load];
    if (success) {
        Class PSSystemConfigurationDynamicStoreWifiWatcher = NSClassFromString(@"PSSystemConfigurationDynamicStoreWifiWatcher");
        return [PSSystemConfigurationDynamicStoreWifiWatcher wifiEnabled];
    }else{
        return NO;
    }
}

#pragma mark - LightUtils Phone

+ (NSInteger)PhoneSignalStrength
{
    void *libHandle = dlopen("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony", RTLD_LAZY);
    int (*CTGetSignalStrength)();
    CTGetSignalStrength = dlsym(libHandle, "CTGetSignalStrength");
    if( CTGetSignalStrength == NULL) NSLog(@"Could not find CTGetSignalStrength");
    int result = CTGetSignalStrength();
    dlclose(libHandle);
    return result;
}

#pragma mark - LightUtils Private

- (NSDictionary *)wifiInfo
{
    libHandle = dlopen("/System/Library/SystemConfiguration/IPConfiguration.bundle/IPConfiguration", RTLD_LAZY);
    
    char *error;
    
    if (libHandle == NULL && (error = dlerror()) != NULL)  {
        NSLog(@"%s", error);
        exit(1);
    }
    
    apple80211Open = dlsym(libHandle, "Apple80211Open");
    apple80211Bind = dlsym(libHandle, "Apple80211BindToInterface");
    apple80211Close = dlsym(libHandle, "Apple80211Close");
    apple80211GetInfoCopy = dlsym(libHandle, "Apple80211GetInfoCopy");
    
    apple80211Open(&airportHandle);
    apple80211Bind(airportHandle, @"en0");
    
    CFDictionaryRef info = NULL;
    
    apple80211GetInfoCopy(airportHandle, &info);
    
    apple80211Close(airportHandle);
    
    return (__bridge NSDictionary *)info;
}

@end
