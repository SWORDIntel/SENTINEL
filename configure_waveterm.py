with open("waveterm_config.sh", 'w') as f:
    f.write("#!/bin/bash\n\n")
    f.write("\"${WAVETERM_PATH:-/opt/Wave/resources/app.asar.unpacked/dist/bin/wsh-0.11.2-linux.x64}\" setvar -b global TEST='test'\n")
