### PoC for Vulnerabilities in RtsPer.sys (Realtek SD Card Reader Driver)

- CVE-2022-25477: dumping driver's logs
- CVE-2022-25478: reading and writing to the driver's PCI configuration space
- CVE-2022-25479: dumping kernel stack and heap memory
- CVE-2022-25480: indirect write to kernel memory at a poorly controlled address
- CVE-2024-40431: indirect write to kernel memory. Combined with CVE-2022-25479, this allows writing to a predictable kernel address

For the moment, the PoC only supports driver version 10.0.16299.21305, which is quite old. Support for version 10.0.22000.21350 is planned.

For more details, refer to the [blog post](https://zwclose.github.io/2024/10/14/rtsper1.html).