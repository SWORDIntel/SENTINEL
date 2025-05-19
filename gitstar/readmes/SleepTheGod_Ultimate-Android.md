Root Access Verification Ensures the script exits if root access is not available, providing a clear error message.

Fallback Mechanisms Provides alternative methods for kernel and firmware dumps if the primary method fails.

Secure SSH Setup Installs and configures an SSH server, if necessary, using the most appropriate method depending on the device's capabilities.

Port Forwarding Configures port forwarding to allow remote connections via SSH and ADB, ensuring secure and controlled access.

Forensic Logging Captures system logs and dmesg output for forensic analysis, which is crucial for high-level security work.

Cleanup and Stealth Removes any temporary files created during the operation to minimize the footprint and maintain stealth.

Final Security Measures Disables ADB over TCP/IP after the operation to prevent unauthorized access.
