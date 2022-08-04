#!/bin/bash
#
# Legal Notice
#
# This document and associated source code (the "Work") is a part of a
# benchmark specification maintained by the TPC.
#
# The TPC reserves all right, title, and interest to the Work as provided
# under U.S. and international laws, including without limitation all patent
# and trademark rights therein.
#
# No Warranty
#
# 1.1 TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE INFORMATION
#     CONTAINED HEREIN IS PROVIDED "AS IS" AND WITH ALL FAULTS, AND THE
#     AUTHORS AND DEVELOPERS OF THE WORK HEREBY DISCLAIM ALL OTHER
#     WARRANTIES AND CONDITIONS, EITHER EXPRESS, IMPLIED OR STATUTORY,
#     INCLUDING, BUT NOT LIMITED TO, ANY (IF ANY) IMPLIED WARRANTIES,
#     DUTIES OR CONDITIONS OF MERCHANTABILITY, OF FITNESS FOR A PARTICULAR
#     PURPOSE, OF ACCURACY OR COMPLETENESS OF RESPONSES, OF RESULTS, OF
#     WORKMANLIKE EFFORT, OF LACK OF VIRUSES, AND OF LACK OF NEGLIGENCE.
#     ALSO, THERE IS NO WARRANTY OR CONDITION OF TITLE, QUIET ENJOYMENT,
#     QUIET POSSESSION, CORRESPONDENCE TO DESCRIPTION OR NON-INFRINGEMENT
#     WITH REGARD TO THE WORK.
# 1.2 IN NO EVENT WILL ANY AUTHOR OR DEVELOPER OF THE WORK BE LIABLE TO
#     ANY OTHER PARTY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO THE
#     COST OF PROCURING SUBSTITUTE GOODS OR SERVICES, LOST PROFITS, LOSS
#     OF USE, LOSS OF DATA, OR ANY INCIDENTAL, CONSEQUENTIAL, DIRECT,
#     INDIRECT, OR SPECIAL DAMAGES WHETHER UNDER CONTRACT, TORT, WARRANTY,
#     OR OTHERWISE, ARISING IN ANY WAY OUT OF THIS OR ANY OTHER AGREEMENT
#     RELATING TO THE WORK, WHETHER OR NOT SUCH AUTHOR OR DEVELOPER HAD
#     ADVANCE NOTICE OF THE POSSIBILITY OF SUCH DAMAGES.
#

shopt -s expand_aliases

#script assumes clush or pdsh
unalias psh
if (type clush > /dev/null); then
  alias psh=clush
  alias dshbak=clubak
elif (type pdsh > /dev/null); then
  alias psh=pdsh
fi
parg="-a"

## TEST SUITE ##

echo -e "${green} ============= System  =========== ${NC}"

echo -e "${green}System ${NC}"
psh $parg "$SUDO `which dmidecode` |grep -A2 '^System Information'" | dshbak -c
echo ""
echo ""
echo -e "${green}BIOS ${NC}"
psh $parg "$SUDO `which dmidecode` | grep -A3 '^BIOS I'" | dshbak -c
echo ""
echo ""

echo -e "${green}Memory ${NC}"
psh $parg "cat /proc/meminfo | grep -i ^memt | uniq" | dshbak -c
echo ""
echo ""
echo -e "${green}Number of Dimms ${NC}"
psh $parg "echo -n 'DIMM slots: '; $SUDO `which dmidecode` |grep -c '^[[:space:]]*Locator:'" | dshbak -c
psh $parg "echo -n 'DIMM count is: '; $SUDO `which dmidecode` | grep "Size"| grep -c "MB"" | dshbak -c
psh $parg "$SUDO `which dmidecode` | awk '/Memory Device$/,/^$/ {print}' | grep -e '^Mem' -e Size: -e Speed: -e Part | sort -u | grep -v -e 'NO DIMM' -e 'No Module Installed' -e Unknown" | dshbak -c
echo ""
echo ""
# probe for cpu info ###############
echo -e "${green}CPU ${NC}"
psh $parg "grep '^model name' /proc/cpuinfo | sort -u" | dshbak -c
echo ""
psh $parg "`which lscpu` | grep -v -e op-mode -e ^Vendor -e family -e Model: -e Stepping: -e BogoMIPS -e Virtual -e ^Byte -e '^NUMA node(s)'" | dshbak -c
echo ""
echo ""
# probe for nic info ###############
echo -e "${green}NIC ${NC}"
psh $parg "`which ifconfig` | egrep '(^e|^p)' | awk '{print \$1}' | xargs -l $SUDO `which ethtool` | grep -e ^Settings -e Speed" | dshbak -c
echo ""
psh $parg "`which lspci` | grep -i ether" | dshbak -c
echo ""
#psh $parg "ip link show | sed '/ lo: /,+1d' | awk '/UP/{sub(\":\",\"\",\$2);print \$2}' | xargs -l `which ethtool` | grep -e ^Settings -e Speed" | dshbak -c
echo ""
echo ""
# probe for disk info ###############
echo -e "${green}Storage ${NC}"
psh $parg "echo 'Storage Controller: '; `which lspci` | grep -i -e raid -e storage -e lsi" | dshbak -c 
echo ""
psh $parg "dmesg | grep -i raid | grep -i scsi" | dshbak -c
echo ""
psh $parg "lsblk -id | awk '{print \$1,\$4}'|sort | nl" | dshbak -c
echo ""
echo ""

echo -e "${green} ================ Software  ======================= ${NC}"
echo ""
echo ""
echo -e "${green}Linux Release ${NC}"
psh $parg "cat /etc/*release | uniq" | dshbak -c
echo ""
echo ""
echo -e "${green}Linux Version ${NC}"
psh $parg "uname -srvm | fmt" | dshbak -c
echo ""
echo ""
echo -e "${green}Date ${NC}"
psh $parg date | dshbak -c
echo ""
echo ""
echo -e "${green}NTP Status ${NC}"
psh $parg "ntpstat 2>&1 | head -1" | dshbak -c
echo ""
echo ""
echo -e "${green}SELINUX ${NC}"
psh $parg "echo -n 'SElinux status: '; grep ^SELINUX= /etc/selinux/config 2>&1" | dshbak -c
echo ""
echo ""
echo -e "${green}IPTables ${NC}"
psh $parg "`which chkconfig` --list iptables 2>&1" | dshbak -c
echo ""
psh $parg "$SUDO `which service` iptables status 2>&1 | head -10" | dshbak -c
echo ""
echo ""
echo -e "${green}Transparent Huge Pages ${NC}"
#eval enpath=$(echo /sys/kernel/mm/*transparent_hugepage/enabled)
#psh $parg "echo -n 'Transparent Huge Pages: '; $SUDO cat $enpath" | dshbak -c
psh $parg "$SUDO cat /sys/kernel/mm/*transparent_hugepage/enabled" | dshbak -c
echo ""
echo ""
echo -e "${green}CPU Speed${NC}"
psh $parg "echo -n 'CPUspeed Service: '; $SUDO `which service` cpuspeed status 2>&1" | dshbak -c
psh $parg "echo -n 'CPUspeed Service: '; `which chkconfig` --list cpuspeed 2>&1" | dshbak -c
#psh $parg "echo -n 'Frequency Governor: '; for dev in /sys/devices/system/cpu/cpu[0-9]*; do cat \$dev/cpufreq/scaling_governor; done | uniq -c" | dshbak -c
echo ""
echo ""
echo -e "${green}Java Version${NC}"
psh $parg 'java -version 2>&1; echo JAVA_HOME is ${JAVA_HOME:-Not Defined!}' | dshbak -c
echo ""
echo ""
echo -e "${green}Hostname Lookup${NC}"
psh $parg 'ip addr show' 
echo ""
echo ""
echo -e "${green}Open File Limit${NC}"
psh $parg 'echo -n "Open file limit(should be >32K): "; ulimit -n' | dshbak -c








