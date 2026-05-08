#!/bin/bash 
export LANG=en_US.UTF-8
pink_c='\033[38;5;211m'
green_c='\033[38;5;118m'
orange_c='\033[38;5;208m'
white_c='\033[1;37m'
plain='\033[0m'
pink(){ printf "\033[38;5;211m%s\033[0m\n" "$1";}
green(){ printf "\033[38;5;118m%s\033[0m\n" "$1";}
yellow(){ printf "\033[38;5;208m%s\033[0m\n" "$1";}  # 深橙色，仅用于重要警告
white(){ printf "\033[0m%s\033[0m\n" "$1";}
blue(){ printf "\033[38;5;118m%s\033[0m\n" "$1";}
red(){ printf "\033[38;5;211m%s\033[0m\n" "$1";}
readp(){ IFS='' read -r -p "$(echo -e "\033[38;5;211m$1\033[0m")" $2;}
[[ $EUID -ne 0 ]] && yellow "请以root模式运行脚本" && exit

# 自动安装快捷命令与持久化脚本
if [[ ! -f /root/qiqi_acme.sh || "$0" == *"fd"* || "$0" == "/dev/fd/"* ]]; then
    curl -sL https://raw.githubusercontent.com/qiqi-style/qiqi_acme/main/qiqi_acme.sh -o /root/qiqi_acme.sh
    chmod +x /root/qiqi_acme.sh
fi
#[[ -e /etc/hosts ]] && grep -qE '^ *172.65.251.78 gitlab.com' /etc/hosts || echo -e '\n172.65.251.78 gitlab.com' >> /etc/hosts
if [[ -f /etc/redhat-release ]]; then
release="Centos"
elif cat /etc/issue | grep -q -E -i "alpine"; then
release="alpine"
elif cat /etc/issue | grep -q -E -i "debian"; then
release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
else 
red "不支持当前的系统，请选择使用Ubuntu,Debian,Centos系统" && exit 
fi
vsid=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)
op=$(cat /etc/redhat-release 2>/dev/null || cat /etc/os-release 2>/dev/null | grep -i pretty_name | cut -d \" -f2)
if [[ $(echo "$op" | grep -i -E "arch") ]]; then
red "脚本不支持当前的 $op 系统，请选择使用Ubuntu,Debian,Centos系统。" && exit
fi

v4v6(){
v4=$(curl -s4m5 icanhazip.com -k)
v6=$(curl -s6m5 icanhazip.com -k)
}

if [ ! -f /root/.acqiqi_update ]; then
green "首次安装qiqi-acme脚本必要的依赖……"
if [[ x"${release}" == x"alpine" ]]; then
apk add wget curl tar jq tzdata openssl expect git socat iproute2 virt-what
else
if [ -x "$(command -v apt-get)" ]; then
apt update -y
apt install socat -y
apt install cron -y
elif [ -x "$(command -v yum)" ]; then
yum update -y && yum install epel-release -y
yum install socat -y
elif [ -x "$(command -v dnf)" ]; then
dnf update -y
dnf install socat -y
fi
if [[ $release = Centos && ${vsid} =~ 8 ]]; then
cd /etc/yum.repos.d/ && mkdir backup && mv *repo backup/ 
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e "s|mirrors.cloud.aliyuncs.com|mirrors.aliyun.com|g " /etc/yum.repos.d/CentOS-*
sed -i -e "s|releasever|releasever-stream|g" /etc/yum.repos.d/CentOS-*
yum clean all && yum makecache
cd
fi
if [ -x "$(command -v yum)" ] || [ -x "$(command -v dnf)" ]; then
if ! command -v "cronie" &> /dev/null; then
if [ -x "$(command -v yum)" ]; then
yum install -y cronie
elif [ -x "$(command -v dnf)" ]; then
dnf install -y cronie
fi
fi
if ! command -v "dig" &> /dev/null; then
if [ -x "$(command -v yum)" ]; then
yum install -y bind-utils
elif [ -x "$(command -v dnf)" ]; then
dnf install -y bind-utils
fi
fi
fi

packages=("curl" "openssl" "lsof" "socat" "dig" "tar" "wget")
inspackages=("curl" "openssl" "lsof" "socat" "dnsutils" "tar" "wget")
for i in "${!packages[@]}"; do
package="${packages[$i]}"
inspackage="${inspackages[$i]}"
if ! command -v "$package" &> /dev/null; then
if [ -x "$(command -v apt-get)" ]; then
apt-get install -y "$inspackage"
elif [ -x "$(command -v yum)" ]; then
yum install -y "$inspackage"
elif [ -x "$(command -v dnf)" ]; then
dnf install -y "$inspackage"
fi
fi
done
fi
touch /root/.acqiqi_update
fi

if [[ -z $(curl -s4m5 icanhazip.com -k) ]]; then
yellow "检测到VPS为纯IPV6，添加dns64"
echo -e "nameserver 2a00:1098:2b::1\nnameserver 2a00:1098:2c::1\nnameserver 2a01:4f8:c2c:123f::1" > /etc/resolv.conf
sleep 2
fi

acme2(){
if [[ -n $(lsof -i :80|grep -v "PID") ]]; then
yellow "检测到80端口被占用，现执行80端口全释放"
sleep 2
lsof -i :80|grep -v "PID"|awk '{print "kill -9",$2}'|sh >/dev/null 2>&1
green "80端口全释放完毕！"
sleep 2
fi
}
acme3(){
readp "请输入注册所需的邮箱（回车跳过则自动生成虚拟gmail邮箱）：" Aemail
if [ -z $Aemail ]; then
auto=`date +%s%N |md5sum | cut -c 1-6`
Aemail=$auto@gmail.com
fi
yellow "当前注册的邮箱名称：$Aemail"
green "开始安装acme.sh申请证书脚本"
bash ~/.acme.sh/acme.sh --uninstall >/dev/null 2>&1
rm -rf ~/.acme.sh
uncronac
wget -N https://github.com/Neilpang/acme.sh/archive/master.tar.gz >/dev/null 2>&1
tar -zxvf master.tar.gz >/dev/null 2>&1
cd acme.sh-master >/dev/null 2>&1
./acme.sh --install >/dev/null 2>&1
cd
curl https://get.acme.sh | sh -s email=$Aemail
if [[ -n $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
green "安装acme.sh证书申请程序成功"
bash ~/.acme.sh/acme.sh --upgrade --use-wget --auto-upgrade
else
red "安装acme.sh证书申请程序失败" && exit
fi
}

checktls(){
# 泛域名目录名直接用原始域名（*.domain.com），所有路径操作均已加双引号保护，Shell 不会 glob 展开
ymdir="${ym}"
if [[ -f /root/qiqissl/${ymdir}/cert.crt && -f /root/qiqissl/${ymdir}/private.key ]] && [[ -s /root/qiqissl/${ymdir}/cert.crt && -s /root/qiqissl/${ymdir}/private.key ]]; then
cronac
green "域名证书申请成功或已存在！域名证书（cert.crt）和密钥（private.key）已保存到 /root/qiqissl/${ymdir} 文件夹内" 
yellow "公钥文件crt路径如下，可直接复制"
green "/root/qiqissl/${ymdir}/cert.crt"
yellow "密钥文件key路径如下，可直接复制"
green "/root/qiqissl/${ymdir}/private.key"
listym=$(bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}')
echo "$listym" > "/root/qiqissl/${ymdir}/ca.log"

else
bash ~/.acme.sh/acme.sh --uninstall >/dev/null 2>&1
rm -rf "/root/qiqissl/${ymdir}"
rm -rf ~/.acme.sh
uncronac
red "遗憾，域名证书申请失败，建议如下："
yellow "1、如果解析到的IP是104.2开头的或者172开头的IP，请确保CF中的CDN黄云已关闭，解析的IP必须是VPS的本地IP"
echo
yellow "2、更换下二级域名自定义名称再尝试执行重装脚本（重要）"
green "例：原二级域名 x.example.com ，在cloudflare中重命名其中的x名称"
echo
yellow "3、因为同个本地IP连续多次申请证书有时间限制，等一段时间再重装脚本" && exit
fi
}

installCA(){
# 泛域名目录名直接用原始域名（*.domain.com），所有路径操作均已加双引号保护，Shell 不会 glob 展开
ymdir="${ym}"
mkdir -p "/root/qiqissl/${ymdir}"
bash ~/.acme.sh/acme.sh --install-cert -d "${ym}" --key-file "/root/qiqissl/${ymdir}/private.key" --fullchain-file "/root/qiqissl/${ymdir}/cert.crt" --ecc
}

checkip(){
v4v6
if [[ -z $v4 ]]; then
vpsip=$v6
elif [[ -n $v4 && -n $v6 ]]; then
vpsip="$v6 或者 $v4"
else
vpsip=$v4
fi
domainIP=$(dig @8.8.8.8 +time=2 +short "$ym" 2>/dev/null | grep -m1 '^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$')
if echo $domainIP | grep -q "network unreachable\|timed out" || [[ -z $domainIP ]]; then
domainIP=$(dig @2001:4860:4860::8888 +time=2 aaaa +short "$ym" 2>/dev/null | grep -m1 ':')
fi
if echo $domainIP | grep -q "network unreachable\|timed out" || [[ -z $domainIP ]] ; then
red "未解析出IP，请检查域名是否输入有误" 
yellow "是否尝试手动输入强行匹配？"
yellow "1：是！输入域名解析的IP"
yellow "2：否！退出脚本"
readp "请选择：" menu
if [ "$menu" = "1" ] ; then
green "VPS本地的IP：$vpsip"
readp "请输入域名解析的IP，与VPS本地IP($vpsip)保持一致：" domainIP
else
exit
fi
elif [[ -n $(echo $domainIP | grep ":") ]]; then
green "当前域名解析到的IPV6地址：$domainIP"
else
green "当前域名解析到的IPV4地址：$domainIP"
fi
if [[ ! $domainIP =~ $v4 ]] && [[ ! $domainIP =~ $v6 ]]; then
yellow "当前VPS本地的IP：$vpsip"
red "当前域名解析的IP与当前VPS本地的IP不匹配！！！"
green "建议如下："
if [[ "$v6" == "2a09"* || "$v4" == "104.28"* ]]; then
yellow "WARP未能自动关闭，请手动关闭！"
else
yellow "1、请确保CDN小黄云关闭状态(仅限DNS)，其他域名解析网站设置同理"
yellow "2、请检查域名解析网站设置的IP是否正确"
fi
exit 
else
green "IP匹配正确，申请证书开始…………"
fi
}

checkacmeca(){
if [[ "${ym}" == *ip6.arpa* ]]; then
red "目前不支持ip6.arpa域名申请证书" && exit
fi
nowca=`bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}'`
if [[ $nowca == $ym ]]; then
red "经检测，输入的域名已有证书申请记录，不用重复申请"
red "证书申请记录如下："
bash ~/.acme.sh/acme.sh --list
yellow "如果一定要重新申请，请先执行删除证书选项" && exit
fi
}

ACMEstandaloneDNS(){
v4v6
#vpsip=${v4:-$v6}
readp "请输入解析完成的域名:" ym
#if [ -z "$ym" ]; then
#case "$vpsip" in *:*) ym="${vpsip//:/-}.nip.io" ;; *) ym="${vpsip//./-}.nip.io" ;; esac
#fi
green "已输入的域名:$ym" && sleep 1
checkacmeca
checkip
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh --issue -d ${ym} --standalone -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh --issue -d ${ym} --standalone -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
installCA
checktls
}

ACMEDNS(){
IFS='' read -r -p "$(echo -e "\033[38;5;211m请输入解析完成的域名:\033[0m")" ym
# 去除首尾空白，防止复制粘贴带入多余空格
ym=$(echo "$ym" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
green "已输入的域名:$ym" && sleep 1
checkacmeca
freenom=`echo $ym | awk -F '.' '{print $NF}'`
if [[ $freenom =~ tk|ga|gq|ml|cf ]]; then
red "经检测，你正在使用freenom免费域名解析，不支持当前DNS API模式，脚本退出" && exit 
fi
if echo "$ym" | grep -qF '*'; then
green "经检测，当前为泛域名证书申请，" && sleep 2
# 泛域名无法直接dig，用根域名做IP检测
ymback="$ym"
ym=$(echo "$ym" | sed 's/^\*\.//')
checkip
ym="$ymback"
else
green "经检测，当前为单域名证书申请，" && sleep 2
checkip
fi
echo
ab="请选择托管域名解析服务商：\n1.Cloudflare\n2.腾讯云DNSPod\n3.阿里云Aliyun\n 请选择："
readp "$ab" cd
case "$cd" in 
1 )
readp "请复制Cloudflare的Global API Key：" GAK
export CF_Key="$GAK"
readp "请输入登录Cloudflare的注册邮箱地址：" CFemail
export CF_Email="$CFemail"
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${ym} -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${ym} -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
;;
2 )
readp "请复制腾讯云DNSPod的DP_Id：" DPID
export DP_Id="$DPID"
readp "请复制腾讯云DNSPod的DP_Key：" DPKEY
export DP_Key="$DPKEY"
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_dp -d ${ym} -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_dp -d ${ym} -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
;;
3 )
readp "请复制阿里云Aliyun的Ali_Key：" ALKEY
export Ali_Key="$ALKEY"
readp "请复制阿里云Aliyun的Ali_Secret：" ALSER
export Ali_Secret="$ALSER"
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_ali -d ${ym} -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_ali -d ${ym} -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
esac
installCA
checktls
}

ACMEDNScheck(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
ACMEDNS
else
systemctl stop wg-quick@wgcf >/dev/null 2>&1
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
ACMEDNS
systemctl start wg-quick@wgcf >/dev/null 2>&1
systemctl restart warp-go >/dev/null 2>&1
systemctl enable warp-go >/dev/null 2>&1
systemctl start warp-go >/dev/null 2>&1
fi
}

ACMEstandaloneDNScheck(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
ACMEstandaloneDNS
else
systemctl stop wg-quick@wgcf >/dev/null 2>&1
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
ACMEstandaloneDNS
systemctl start wg-quick@wgcf >/dev/null 2>&1
systemctl restart warp-go >/dev/null 2>&1
systemctl enable warp-go >/dev/null 2>&1
systemctl start warp-go >/dev/null 2>&1
fi
}

acme(){
ab="1.选择独立80端口模式申请证书（仅需域名，小白推荐），安装过程中将强制释放80端口\n2.选择DNS API模式申请证书（需域名、ID、Key），自动识别单域名与泛域名\n 请选择："
readp "$ab" cd
case "$cd" in 
1 ) acme2 && acme3 && ACMEstandaloneDNScheck;;
2 ) acme3 && ACMEDNScheck;;
esac
}

Certificate(){
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh证书申请，无法执行" && exit 
green "Main_Domainc下显示的域名就是已申请成功的域名证书，Renew下显示对应域名证书的自动续期时间点"
bash ~/.acme.sh/acme.sh --list
#readp "请输入要撤销并删除的域名证书（复制Main_Domain下显示的域名，退出请按Ctrl+c）:" ym
#if [[ -n $(bash ~/.acme.sh/acme.sh --list | grep $ym) ]]; then
#bash ~/.acme.sh/acme.sh --revoke -d ${ym} --ecc
#bash ~/.acme.sh/acme.sh --remove -d ${ym} --ecc
#rm -rf /root/qiqissl/${ym}
#green "撤销并删除${ym}域名证书成功"
#else
#red "未找到你输入的${ym}域名证书，请自行核实！" && exit
#fi
}

acmeshow(){
if [[ -n $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
caacme1=`bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}'`
if [[ -n $caacme1 && ! $caacme1 == "Main_Domain" ]] && [[ -f /root/qiqissl/${caacme1}/cert.crt && -f /root/qiqissl/${caacme1}/private.key && -s /root/qiqissl/${caacme1}/cert.crt && -s /root/qiqissl/${caacme1}/private.key ]]; then
caacme=$caacme1
else
caacme='无证书申请记录'
fi
else
caacme='未安装acme'
fi
}
cronac(){
uncronac
crontab -l > /tmp/crontab.tmp
echo "0 0 * * * root bash ~/.acme.sh/acme.sh --cron -f >/dev/null 2>&1" >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}
uncronac(){
crontab -l > /tmp/crontab.tmp
sed -i '/--cron/d' /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}
acmerenew(){
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh证书申请，无法执行" && exit 
green "以下显示的域名就是已申请成功的域名证书"
bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}'
echo
#ab="1.无脑一键续期所有证书（推荐）\n2.选择指定的域名证书续期\n0.返回上一层\n 请选择："
#readp "$ab" cd
#case "$cd" in 
#1 ) 
green "开始续期证书…………" && sleep 3
bash ~/.acme.sh/acme.sh --cron -f
checktls
#;;
#2 ) 
#readp "请输入要续期的域名证书（复制Main_Domain下显示的域名）:" ym
#if [[ -n $(bash ~/.acme.sh/acme.sh --list | grep $ym) ]]; then
#bash ~/.acme.sh/acme.sh --renew -d ${ym} --force --ecc
#checktls
#else
#red "未找到你输入的${ym}域名证书，请自行核实！" && exit
#fi
#;;
#0 ) start_menu;;
#esac
}
uninstall(){
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh证书申请，无法执行" && exit 
curl https://get.acme.sh | sh
bash ~/.acme.sh/acme.sh --uninstall
# 保留用户的证书文件
rm -rf ~/.acme.sh
sed -i '/acme.sh.env/d' ~/.bashrc 
source ~/.bashrc
uncronac
rm -f /root/qiqi_acme.sh /root/.acqiqi_update
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && green "acme.sh卸载完毕" || red "acme.sh卸载失败"
}

clear
echo
# ── QIQI-STYLE Banner  粉色→绿色 渐变 ──
echo -e "\033[38;5;211m  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░\033[0m"
echo
echo -e "  \033[38;5;211m ██████╗  \033[38;5;212m██╗\033[38;5;213m ██████╗  \033[38;5;214m██╗\033[38;5;215m         \033[38;5;118m███████╗\033[38;5;119m████████╗\033[38;5;120m██╗   ██╗\033[38;5;121m██╗     \033[38;5;157m███████╗\033[0m"
echo -e "  \033[38;5;211m██╔═══██╗ \033[38;5;212m██║\033[38;5;213m██╔═══██╗ \033[38;5;214m██║\033[38;5;215m         \033[38;5;118m██╔════╝\033[38;5;119m╚══██╔══╝\033[38;5;120m╚██╗ ██╔╝\033[38;5;121m██║     \033[38;5;157m██╔════╝\033[0m"
echo -e "  \033[38;5;212m██║   ██║ \033[38;5;213m██║\033[38;5;214m██║   ██║ \033[38;5;215m██║\033[38;5;216m  ▄▄▄▄▄  \033[38;5;118m██║     \033[38;5;119m   ██║   \033[38;5;120m ╚████╔╝ \033[38;5;121m██║     \033[38;5;157m█████╗\033[0m"
echo -e "  \033[38;5;213m██║   ██║ \033[38;5;214m██║\033[38;5;215m██║   ██║ \033[38;5;216m██║\033[38;5;217m  ▀▀▀▀▀  \033[38;5;118m███████╗\033[38;5;119m   ██║   \033[38;5;120m  ╚██╔╝  \033[38;5;121m██║     \033[38;5;157m██╔══╝\033[0m"
echo -e "  \033[38;5;213m██║▄▄ ██║ \033[38;5;214m██║\033[38;5;215m██║▄▄ ██║ \033[38;5;216m██║\033[38;5;217m         \033[38;5;119m╚════██║\033[38;5;120m   ██║   \033[38;5;121m   ██║   \033[38;5;157m██║     \033[38;5;157m██║\033[0m"
echo -e "  \033[38;5;214m╚██████╔╝ \033[38;5;215m██║\033[38;5;216m╚██████╔╝ \033[38;5;217m██║\033[38;5;218m         \033[38;5;119m███████║\033[38;5;120m   ██║   \033[38;5;121m   ██║   \033[38;5;157m███████╗\033[38;5;194m███████╗\033[0m"
echo -e "  \033[38;5;215m ╚══▀▀═╝  \033[38;5;216m╚═╝\033[38;5;217m ╚══▀▀═╝  \033[38;5;218m╚═╝\033[0m         \033[38;5;120m╚══════╝\033[38;5;121m   ╚═╝   \033[38;5;157m   ╚═╝   \033[38;5;157m╚══════╝\033[38;5;194m╚══════╝\033[0m"
echo
echo -e "\033[38;5;118m  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░\033[0m"
echo
echo -e "  \033[38;5;118m⬥ qiqi Github   \033[38;5;118m:  https://github.com/qiqi-style\033[0m"
echo -e "  \033[38;5;118m⬥ qiqi 博客     \033[0m:  （暂空）"
echo -e "  \033[38;5;118m⬥ qiqi YouTube  \033[0m:  （暂空）"
echo -e "  \033[38;5;211m⬥ qiqi_acme版本 \033[38;5;118m:  v1.0\033[0m"
echo -e "\033[38;5;211m  ─────────────────────────── ⚠ 使用须知 ─────────────────────────────  \033[0m"
echo -e "  \033[38;5;245m1.\033[0m 本脚本仅支持单IP的VPS，SSH登录IP须与VPS公网IP一致"
echo -e "  \033[38;5;245m2.\033[0m 80端口模式：仅支持单域名证书，80端口空闲时可自动续期"
echo -e "  \033[38;5;245m3.\033[0m DNS API模式：支持单域名与泛域名，无条件自动续期"
yellow "  ⚠ 泛域名申请前，需在域名解析处添加一条 * 的记录 (格式：*.yourdomain.com)"
echo -e "  \033[38;5;118m⬥ 公钥路径 \033[38;5;211m→\033[0m  /root/qiqissl/<域名>/cert.crt"
echo -e "  \033[38;5;118m⬥ 密钥路径 \033[38;5;211m→\033[0m  /root/qiqissl/<域名>/private.key"
echo
echo -e "\033[38;5;211m  ───────────────────── 当前证书状态 ──────────────────────────────────  \033[0m"
acmeshow
echo -e "  \033[38;5;118m已申请证书 \033[38;5;211m→\033[0m  ${caacme}"
echo
echo -e "\033[38;5;211m  ──────────────────────── 功能菜单 ───────────────────────────────────  \033[0m"
echo -e "  \033[38;5;118m[ 1 ]\033[0m  申请 letsencrypt ECC 证书（80端口 / DNS API 双模式）"
echo -e "  \033[38;5;118m[ 2 ]\033[0m  查询已申请证书 及 自动续期时间点"
echo -e "  \033[38;5;118m[ 3 ]\033[0m  手动一键续期证书"
echo -e "  \033[38;5;208m[ 4 ]\033[0m  删除证书 并 卸载 ACME 脚本"
echo -e "  \033[38;5;245m[ 0 ]\033[0m  退出"
echo
readp "  请输入选项数字 → " NumberInput
case "$NumberInput" in
1 ) acme;;
2 ) Certificate;;
3 ) acmerenew;;
4 ) uninstall;;
* ) exit
esac
