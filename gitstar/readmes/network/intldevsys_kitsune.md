
```                                                                                                                

 /$$       /$$   /$$                                                 
| $$      |__/  | $$                                                 
| $$   /$$ /$$ /$$$$$$   /$$$$$$$ /$$   /$$ /$$$$$$$   /$$$$$$       
| $$  /$$/| $$|_  $$_/  /$$_____/| $$  | $$| $$__  $$ /$$__  $$      
| $$$$$$/ | $$  | $$   |  $$$$$$ | $$  | $$| $$  \ $$| $$$$$$$$      
| $$_  $$ | $$  | $$ /$$\____  $$| $$  | $$| $$  | $$| $$_____/      
| $$ \  $$| $$  |  $$$$//$$$$$$$/|  $$$$$$/| $$  | $$|  $$$$$$$      
|__/  \__/|__/   \___/ |_______/  \______/ |__/  |__/ \_______/      
          
```

## **Summary**

A simple, high-performance FTP scanning utility written in Go, featuring intelligent IP list management and resource controls.  Can effectively crawl hundreds of thousands of anonymous FTP servers while maintaining operational efficiency through automatic IP list updates and scan throttling. Current performance characteristics are as follows:

> Throughput: 150-200 files/second per IP (varies by server)

> Memory: ~2MB base + 50KB per active scan

> Network: 5 concurrent connections/IP (FTP protocol limits)


## Key Features
1. **Progressive IP List Management**
   - Auto-removal of processed IPs from `ips.txt`
   - Prevention of duplicate scans through real-time file updates
   - Manual IP removal during active operations

2. **Resource Controls**
   - Automatic scan termination at 8,000 files/IP (modify to your preference)
   - Configurable directory depth (-depth flag)
   - File extension filters (include/exclude lists)

3. **Operational Flexibility**
   - Pause/resume functionality
   - Concurrent scanning with goroutine management
   - Context-aware cancellation propagation

4. **Audit & Reporting**
   - Real-time results display
   - Persistent `results.txt` logging
   - Scan progress monitoring

> [!IMPORTANT]
> For research purposes only. Always consider the potential consequences of scanning and interacting with data that you do not have explicit permission to access.

## Installation
```
go mod init kitsune.go
go mod tidy
go build kitsune.go
```


## Usage

A line-separated list of IP addresses named 'ips.txt' should be included in the directory you intend for the results.txt file to be stored for ease of use. Be sure to save a backup copy of 'ips.txt' in another directory, as the one utilized for this tool will automatically delete each IP in real-time once it's been scanned.

### For a basic scan, simply run:

```
./kitsune
```

### To narrow search results or expand crawl depth, various options are available as well; for example:

```
./kitsune -include .pdf,.docx -exclude .tmp,.log -depth 5
```


