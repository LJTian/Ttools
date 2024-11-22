#/bin/bash

# rpm_qf_cmd sed
# ceho sed-4.8-6.0.1.uelc20.01.x86_64
whereis $1 | awk '{ print $2 }' | xargs rpm -qf
