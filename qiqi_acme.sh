#!/bin/bash 
export LANG=en_US.UTF-8

QIQI_PROJECT_NAME="${QIQI_PROJECT_NAME:-qiqi_acme}"
QIQI_PROJECT_VERSION="${QIQI_PROJECT_VERSION:-v3.0}"
QIQI_PROJECT_DESCRIPTION="${QIQI_PROJECT_DESCRIPTION:-中文 SSL 证书申请与续期管理脚本}"
QIQI_PROJECT_URL="${QIQI_PROJECT_URL:-https://github.com/qiqi-style/qiqi_acme}"
QIQI_THEME_LOCAL="${QIQI_THEME_LOCAL:-/root/qiqi_acme_theme.sh}"
QIQI_THEME_URL="${QIQI_THEME_URL:-https://raw.githubusercontent.com/qiqi-style/qiqi_acme/main/theme.sh}"

load_qiqi_theme(){
local script_dir theme_file
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
for theme_file in "${script_dir}/theme.sh" "${QIQI_THEME_LOCAL}"; do
if [[ -f "$theme_file" ]]; then
# shellcheck source=/dev/null
. "$theme_file"
return 0
fi
done
if [[ $EUID -eq 0 ]] && command -v curl >/dev/null 2>&1; then
if curl -fsSL --max-time 8 "$QIQI_THEME_URL" -o "$QIQI_THEME_LOCAL" 2>/dev/null && [[ -s "$QIQI_THEME_LOCAL" ]]; then
# shellcheck source=/dev/null
. "$QIQI_THEME_LOCAL"
return 0
fi
fi
return 1
}

load_qiqi_theme || true

if [[ -z "${QIQI_THEME_LOADED:-}" ]]; then
pink_c='\033[38;5;211m'
green_c='\033[38;5;118m'
orange_c='\033[38;5;208m'
white_c='\033[1;37m'
plain='\033[0m'
QIQI_PINK="$pink_c"
QIQI_GREEN="$green_c"
QIQI_ORANGE="$orange_c"
QIQI_GRAY='\033[38;5;245m'
QIQI_CYAN='\033[38;5;81m'
QIQI_WHITE="$white_c"
QIQI_PLAIN="$plain"
pink(){ printf "\033[38;5;211m%s\033[0m\n" "$1";}
green(){ printf "\033[38;5;118m%s\033[0m\n" "$1";}
yellow(){ printf "\033[38;5;208m%s\033[0m\n" "$1";}  # 深橙色，仅用于重要警告
white(){ printf "\033[0m%s\033[0m\n" "$1";}
blue(){ printf "\033[38;5;118m%s\033[0m\n" "$1";}
red(){ printf "\033[38;5;211m%s\033[0m\n" "$1";}
muted(){ printf "\033[38;5;245m%s\033[0m\n" "$1";}
readp(){ IFS='' read -r -p "$(printf "\033[38;5;211m%b\033[0m" "$1")" "$2";}
qiqi_line(){ printf "\033[38;5;211m%s\033[0m\n" "────────────────────────────────────────────────────────────────────────";}
qiqi_section(){ printf "\n\033[38;5;211m  ───────────────────── %s ─────────────────────\033[0m\n" "$1";}
qiqi_menu_item(){
local num="$1" label="$2" desc="${3:-}"
if [[ -n "$desc" ]]; then
printf "  \033[38;5;118m[ %s ]\033[0m  %s %s\n" "$num" "$label" "$desc"
else
printf "  \033[38;5;118m[ %s ]\033[0m  %s\n" "$num" "$label"
fi
}
qiqi_banner(){
local project_name="${1:-qiqi_acme}" version="${2:-v3.0}" description="${3:-中文 SSL 证书申请与续期管理脚本}" project_url="${4:-https://github.com/qiqi-style/qiqi_acme}"
echo
printf "\033[38;5;211m  %s\033[0m\n" "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
echo
printf "  \033[38;5;211m ██████╗  \033[38;5;212m██╗\033[38;5;213m ██████╗  \033[38;5;214m██╗         \033[38;5;118m███████╗\033[38;5;119m████████╗\033[38;5;120m██╗   ██╗\033[38;5;121m██╗     ███████╗\033[0m\n"
printf "  \033[38;5;211m██╔═══██╗ \033[38;5;212m██║\033[38;5;213m██╔═══██╗ \033[38;5;214m██║         \033[38;5;118m██╔════╝\033[38;5;119m╚══██╔══╝\033[38;5;120m╚██╗ ██╔╝\033[38;5;121m██║     ██╔════╝\033[0m\n"
printf "  \033[38;5;212m██║   ██║ \033[38;5;213m██║\033[38;5;214m██║   ██║ \033[38;5;215m██║  ▄▄▄▄▄  \033[38;5;118m██║        \033[38;5;119m██║    \033[38;5;120m╚████╔╝ \033[38;5;121m██║     █████╗\033[0m\n"
printf "  \033[38;5;213m██║   ██║ \033[38;5;214m██║\033[38;5;215m██║   ██║ \033[38;5;216m██║  ▀▀▀▀▀  \033[38;5;118m███████╗   \033[38;5;119m██║     \033[38;5;120m╚██╔╝  \033[38;5;121m██║     ██╔══╝\033[0m\n"
printf "  \033[38;5;213m██║▄▄ ██║ \033[38;5;214m██║\033[38;5;215m██║▄▄ ██║ \033[38;5;216m██║         \033[38;5;119m╚════██║   ██║      ██║   \033[38;5;157m██║     ██║\033[0m\n"
printf "  \033[38;5;214m╚██████╔╝ \033[38;5;215m██║\033[38;5;216m╚██████╔╝ \033[38;5;217m██║         \033[38;5;119m███████║   ██║      ██║   \033[38;5;157m███████╗███████╗\033[0m\n"
printf "  \033[38;5;215m ╚══▀▀═╝  ╚═╝ ╚══▀▀═╝  ╚═╝         \033[38;5;120m╚══════╝   ╚═╝      ╚═╝   \033[38;5;157m╚══════╝╚══════╝\033[0m\n"
echo
printf "\033[38;5;118m  %s\033[0m\n" "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
echo
printf "  \033[38;5;118m⬥ qiqi Github   :\033[0m  https://github.com/qiqi-style\n"
printf "  \033[38;5;118m⬥ qiqi YouTube  :\033[0m  https://www.youtube.com/@qiqi-style\n"
printf "  \033[38;5;118m⬥ qiqi 博客     :\033[0m  https://qiaiai.xyz\n"
printf "\033[38;5;211m  ─────────────────────────── 项目简介 ─────────────────────────────  \033[0m\n"
printf "  \033[38;5;245m⬥\033[0m 项目地址：\033[38;5;81m%s\033[0m\n" "$project_url"
printf "  \033[38;5;245m⬥\033[0m 当前版本：\033[38;5;81m%s (%s)\033[0m\n" "$version" "$project_name"
printf "  \033[38;5;245m⬥\033[0m %s\n" "$description"
}
fi

normalize_domain_input(){
local value="$1"
value=$(printf '%s' "$value" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
value="${value//＊/*}"
value="${value//。/.}"
value="${value//．/.}"
value="${value//｡/.}"
value="${value//�/}"
printf '%s' "$value" | LC_ALL=C tr -cd 'A-Za-z0-9.*-'
}

validate_domain_input(){
local domain="$1"
local allow_wildcard="$2"
local base label
if [[ -z "$domain" ]]; then
red "域名不能为空，请重新输入正确域名"
return 1
fi
if [[ "$domain" == *"*"* && "$domain" != \*.* ]]; then
red "泛域名格式错误，请使用类似 *.example.com 的格式"
return 1
fi
if [[ "$domain" == \*.* && "$allow_wildcard" != "1" ]]; then
red "独立80端口模式不支持泛域名证书，请选择DNS API模式申请"
return 1
fi
if [[ "$domain" == \*.* ]]; then
base="${domain#\*.}"
else
base="$domain"
fi
if [[ "$base" == *"*"* || "$base" == .* || "$base" == *. || "$base" == *..* || "$base" != *.* ]]; then
red "域名格式错误，请输入类似 example.com 或 *.example.com 的域名"
return 1
fi
IFS='.' read -r -a labels <<< "$base"
for label in "${labels[@]}"; do
if [[ ! "$label" =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]]; then
red "域名格式错误，请检查每一段域名是否只包含字母、数字和中划线"
return 1
fi
done
}

read_domain_input(){
local allow_wildcard="$1"
readp "请输入解析完成的域名:" ym
ym=$(normalize_domain_input "$ym")
validate_domain_input "$ym" "$allow_wildcard" || return 1
green "已输入的域名:$ym" && sleep 1
}

set_cert_domains(){
cert_install_domain="$ym"
cert_store_domain="$ym"
acme_domain_args=(-d "$ym")
acme_issue_force_args=()
if [[ "$ym" == \*.* ]]; then
cert_install_domain="${ym#\*.}"
cert_store_domain="$ym"
acme_domain_args=(-d "$cert_install_domain" -d "$ym")
green "将把 ${cert_install_domain} 和 ${ym} 放进同一张证书、同一个密钥中" && sleep 1
fi
}
[[ $EUID -ne 0 ]] && yellow "请以root模式运行脚本" && exit

# 自动安装快捷命令与持久化脚本
if [[ ! -f /root/qiqi_acme.sh || "$0" == *"fd"* || "$0" == "/dev/fd/"* ]]; then
    curl -sL https://raw.githubusercontent.com/qiqi-style/qiqi_acme/main/qiqi_acme.sh -o /root/qiqi_acme.sh
    chmod +x /root/qiqi_acme.sh
fi
if [[ ! -s "$QIQI_THEME_LOCAL" ]]; then
    curl -fsSL --max-time 8 "$QIQI_THEME_URL" -o "$QIQI_THEME_LOCAL" 2>/dev/null || true
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
if [[ -n $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
green "检测到已安装acme.sh，将复用现有安装和证书记录"
bash ~/.acme.sh/acme.sh --upgrade --use-wget --auto-upgrade >/dev/null 2>&1 || yellow "acme.sh自动升级失败，将继续使用现有版本"
return 0
fi
readp "请输入注册所需的邮箱（回车跳过则自动生成虚拟gmail邮箱）：" Aemail
if [ -z $Aemail ]; then
auto=`date +%s%N |md5sum | cut -c 1-6`
Aemail=$auto@gmail.com
fi
yellow "当前注册的邮箱名称：$Aemail"
green "开始安装acme.sh申请证书脚本"
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
red "安装acme.sh证书申请程序失败"
return 1
fi
}

checktls(){
ymdir="${cert_store_domain:-$ym}"
if [[ -f /root/qiqissl/${ymdir}/cert.crt && -f /root/qiqissl/${ymdir}/private.key ]] && [[ -s /root/qiqissl/${ymdir}/cert.crt && -s /root/qiqissl/${ymdir}/private.key ]]; then
cronac
green "域名证书申请成功或已存在！域名证书（cert.crt）和密钥（private.key）已保存到 /root/qiqissl/${ymdir} 文件夹内" 
if [[ "$ym" == \*.* && -n "$cert_install_domain" ]]; then
green "该证书和密钥已同时包含 ${cert_install_domain} 和 ${ym}"
fi
yellow "公钥文件crt路径如下，可直接复制"
green "/root/qiqissl/${ymdir}/cert.crt"
yellow "密钥文件key路径如下，可直接复制"
green "/root/qiqissl/${ymdir}/private.key"
echo "${ym}" > "/root/qiqissl/${ymdir}/ca.log"

else
red "遗憾，域名证书申请失败，建议如下："
yellow "已保留现有证书文件、acme.sh程序和自动续期任务，不会自动删除任何内容。"
echo
yellow "1、如果解析到的IP是104.2开头的或者172开头的IP，请确保CF中的CDN黄云已关闭，解析的IP必须是VPS的本地IP"
echo
yellow "2、更换下二级域名自定义名称再尝试执行重装脚本（重要）"
green "例：原二级域名 x.example.com ，在cloudflare中重命名其中的x名称"
echo
yellow "3、因为同个本地IP连续多次申请证书有时间限制，等一段时间再重装脚本"
return 1
fi
}

installCA(){
local install_domain="${cert_install_domain:-$ym}"
local ymdir="${cert_store_domain:-$ym}"
local target_dir="/root/qiqissl/${ymdir}"
local backup_root backup_dir
backup_root=$(mktemp -d /tmp/qiqi-acme-target.XXXXXX)
if [[ -d "$target_dir" && -n "$backup_root" && -d "$backup_root" ]]; then
cp -a "$target_dir" "${backup_root}/"
backup_dir="${backup_root}/$(basename "$target_dir")"
fi
mkdir -p "$target_dir"
if bash ~/.acme.sh/acme.sh --install-cert -d "${install_domain}" --key-file "${target_dir}/private.key" --fullchain-file "${target_dir}/cert.crt" --ecc && [[ -s "${target_dir}/private.key" && -s "${target_dir}/cert.crt" ]]; then
rm -rf "$backup_root"
return 0
fi
if [[ -n "$backup_dir" && -d "$backup_dir" ]]; then
rm -rf "$target_dir"
mv "$backup_dir" "$target_dir"
fi
rm -rf "$backup_root"
red "证书安装失败，未找到可安装的证书文件或acme.sh返回错误"
yellow "正式证书目录未被覆盖，已有可用证书会继续保留"
yellow "如果上方出现 rateLimited / 429 / retry after，表示触发 Let's Encrypt 频率限制，请按提示时间后再申请"
return 1
}

issue_cert(){
local install_domain="${cert_install_domain:-$ym}"
local acme_domain_dir="$HOME/.acme.sh/${install_domain}_ecc"
local backup_root backup_dir had_old_dir=0
backup_root=$(mktemp -d /tmp/qiqi-acme-backup.XXXXXX)
if [[ -d "$acme_domain_dir" ]]; then
if [[ -z "$backup_root" || ! -d "$backup_root" ]]; then
red "创建acme记录备份目录失败，已停止申请，避免覆盖旧记录"
return 1
fi
if ! cp -a "$acme_domain_dir" "${backup_root}/"; then
rm -rf "$backup_root"
red "备份旧acme记录失败，已停止申请，避免覆盖旧记录"
return 1
fi
backup_dir="${backup_root}/$(basename "$acme_domain_dir")"
had_old_dir=1
fi
if "$@"; then
rm -rf "$backup_root"
return 0
fi
if [[ $had_old_dir -eq 1 && -d "$backup_dir" ]]; then
rm -rf "$acme_domain_dir"
mv "$backup_dir" "$acme_domain_dir"
elif [[ $had_old_dir -eq 0 ]]; then
rm -rf "$acme_domain_dir"
fi
rm -rf "$backup_root"
red "证书申请命令执行失败，已停止后续证书安装"
yellow "请查看上方acme.sh输出的具体原因；如果出现 rateLimited / 429 / retry after，请等到提示时间后再申请"
yellow "本次失败不会覆盖已有证书文件；失败生成的acme临时记录已清理或还原"
return 1
}

checkip(){
local require_match="${1:-1}"
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
if [[ "$require_match" != "1" ]]; then
yellow "DNS API模式使用DNS验证，不强制要求域名解析到当前VPS，将继续申请证书"
return 0
fi
yellow "是否尝试手动输入强行匹配？"
yellow "1：是！输入域名解析的IP"
yellow "2：否！退出脚本"
readp "请选择：" menu
if [ "$menu" = "1" ] ; then
green "VPS本地的IP：$vpsip"
readp "请输入域名解析的IP，与VPS本地IP($vpsip)保持一致：" domainIP
else
return 1
fi
elif [[ -n $(echo $domainIP | grep ":") ]]; then
green "当前域名解析到的IPV6地址：$domainIP"
else
green "当前域名解析到的IPV4地址：$domainIP"
fi
if [[ ! $domainIP =~ $v4 ]] && [[ ! $domainIP =~ $v6 ]]; then
yellow "当前VPS本地的IP：$vpsip"
if [[ "$require_match" != "1" ]]; then
yellow "当前域名解析的IP与当前VPS本地的IP不匹配，但DNS API模式不依赖域名IP指向，将继续申请证书"
return 0
fi
red "当前域名解析的IP与当前VPS本地的IP不匹配！！！"
green "建议如下："
if [[ "$v6" == "2a09"* || "$v4" == "104.28"* ]]; then
yellow "WARP未能自动关闭，请手动关闭！"
else
yellow "1、请确保CDN小黄云关闭状态(仅限DNS)，其他域名解析网站设置同理"
yellow "2、请检查域名解析网站设置的IP是否正确"
fi
return 1
else
if [[ "$require_match" == "1" ]]; then
green "IP匹配正确，申请证书开始…………"
else
green "DNS API模式检查完成，申请证书开始…………"
fi
fi
}

checkacmeca(){
if [[ "${ym}" == *ip6.arpa* ]]; then
red "目前不支持ip6.arpa域名申请证书"
return 1
fi
local cert_check_domain="${cert_install_domain:-$ym}"
local cert_list cert_line wildcard_line
cert_list=$(bash ~/.acme.sh/acme.sh --list 2>/dev/null)
cert_line=$(printf '%s\n' "$cert_list" | awk -v domain="$cert_check_domain" 'NR>1 && $1 == domain {print; exit}')
if [[ -n "$cert_line" ]]; then
acme_issue_force_args=(--force)
yellow "检测到 ${cert_check_domain} 已有证书申请记录，将执行覆盖申请"
if [[ "$ym" == \*.* && "$cert_line" == *"$ym"* ]]; then
yellow "已有记录已包含 ${cert_check_domain} 和 ${ym}，本次会重新签发并覆盖安装证书文件"
else
yellow "本次会重新签发 ${ym}，并覆盖安装到 /root/qiqissl/${cert_store_domain:-$ym}/"
fi
yellow "如果触发 Let's Encrypt 频率限制，请等待提示时间后再重新申请"
return 0
fi
if [[ "$ym" == \*.* ]]; then
wildcard_line=$(printf '%s\n' "$cert_list" | awk -v domain="$ym" 'NR>1 && $1 == domain {print; exit}')
if [[ -n "$wildcard_line" ]]; then
acme_issue_force_args=(--force)
yellow "检测到已有单独泛域名证书记录，将覆盖申请为同时包含 ${cert_check_domain} 和 ${ym} 的合并证书"
yellow "如果触发 Let's Encrypt 频率限制，请等待提示时间后再重新申请"
fi
fi
}

ACMEstandaloneDNS(){
v4v6
#vpsip=${v4:-$v6}
read_domain_input 0 || return
set_cert_domains
#if [ -z "$ym" ]; then
#case "$vpsip" in *:*) ym="${vpsip//:/-}.nip.io" ;; *) ym="${vpsip//./-}.nip.io" ;; esac
#fi
checkacmeca || return
checkip || return
if [[ $domainIP = $v4 ]]; then
issue_cert bash ~/.acme.sh/acme.sh --issue "${acme_issue_force_args[@]}" "${acme_domain_args[@]}" --standalone -k ec-256 --server letsencrypt --insecure || return
fi
if [[ $domainIP = $v6 ]]; then
issue_cert bash ~/.acme.sh/acme.sh --issue "${acme_issue_force_args[@]}" "${acme_domain_args[@]}" --standalone -k ec-256 --server letsencrypt --listen-v6 --insecure || return
fi
installCA || return
checktls
}

ACMEDNS(){
read_domain_input 1 || return
set_cert_domains
checkacmeca || return
freenom=`printf '%s' "$ym" | awk -F '.' '{print $NF}'`
if [[ $freenom =~ tk|ga|gq|ml|cf ]]; then
red "经检测，你正在使用freenom免费域名解析，不支持当前DNS API模式"
return 1
fi
if [[ "$ym" == \*.* ]]; then
green "经检测，当前为泛域名证书申请，" && sleep 2
# 泛域名无法直接dig，用根域名做IP检测
ymback="$ym"
ym="${ym#\*.}"
if ! checkip 0; then
ym="$ymback"
return 1
fi
ym="$ymback"
else
green "经检测，当前为单域名证书申请，" && sleep 2
checkip 0 || return
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
issue_cert bash ~/.acme.sh/acme.sh --issue "${acme_issue_force_args[@]}" --dns dns_cf "${acme_domain_args[@]}" -k ec-256 --server letsencrypt --insecure || return
;;
2 )
readp "请复制腾讯云DNSPod的DP_Id：" DPID
export DP_Id="$DPID"
readp "请复制腾讯云DNSPod的DP_Key：" DPKEY
export DP_Key="$DPKEY"
issue_cert bash ~/.acme.sh/acme.sh --issue "${acme_issue_force_args[@]}" --dns dns_dp "${acme_domain_args[@]}" -k ec-256 --server letsencrypt --insecure || return
;;
3 )
readp "请复制阿里云Aliyun的Ali_Key：" ALKEY
export Ali_Key="$ALKEY"
readp "请复制阿里云Aliyun的Ali_Secret：" ALSER
export Ali_Secret="$ALSER"
issue_cert bash ~/.acme.sh/acme.sh --issue "${acme_issue_force_args[@]}" --dns dns_ali "${acme_domain_args[@]}" -k ec-256 --server letsencrypt --insecure || return
;;
* )
yellow "输入有误，已返回主菜单"
return 1
;;
esac
installCA || return
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
ab="1.选择独立80端口模式申请证书（仅需域名），安装过程中将强制释放80端口\n2.选择DNS API模式申请证书（推荐、需域名、ID、Key），自动识别单域名与泛域名\n 请选择："
readp "$ab" cd
case "$cd" in 
1 ) acme2 && acme3 && ACMEstandaloneDNScheck;;
2 ) acme3 && ACMEDNScheck;;
* ) yellow "输入有误，已返回主菜单";;
esac
}

pause_return(){
echo
readp "按回车返回上一级菜单..." _
}

ensure_acme_ready(){
if [[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
yellow "未安装acme.sh证书申请，无法执行"
return 1
fi
return 0
}

format_cert_time(){
local value="$1"
local formatted
if [[ -z "$value" || "$value" == "-" ]]; then
printf "-"
return
fi
formatted=$(date -d "$value" '+%Y-%m-%d %H:%M' 2>/dev/null)
if [[ -n "$formatted" ]]; then
printf "%s" "$formatted"
else
printf "%s" "$value"
fi
}

cert_time_epoch(){
local value="$1"
date -d "$value" '+%s' 2>/dev/null
}

cert_remaining_days(){
local expire_epoch="$1"
local now_epoch diff_days
now_epoch=$(date '+%s' 2>/dev/null)
if [[ -z "$expire_epoch" || -z "$now_epoch" ]]; then
printf "-"
return
fi
if (( expire_epoch < now_epoch )); then
diff_days=$(( (now_epoch - expire_epoch + 86399) / 86400 ))
printf "已过期%s天" "$diff_days"
else
diff_days=$(( (expire_epoch - now_epoch + 86399) / 86400 ))
printf "%s天" "$diff_days"
fi
}

display_width(){
local text="$1"
local byte width=0
for byte in $(printf "%s" "$text" | od -An -t u1); do
if (( byte < 128 )); then
width=$((width + 1))
elif (( byte >= 192 )); then
width=$((width + 2))
fi
done
printf "%s" "$width"
}

pad_cell(){
local text="$1"
local width="$2"
local text_width padding
text_width=$(display_width "$text")
printf "%s" "$text"
if (( text_width < width )); then
padding=$((width - text_width))
printf "%*s" "$padding" ""
fi
}

repeat_char(){
local char="$1"
local count="$2"
printf "%*s" "$count" "" | tr ' ' "$char"
}

print_cert_table_row(){
printf "  "
pad_cell "$1" "$cert_col_no"
printf " | "
pad_cell "$2" "$cert_col_domain"
printf " | "
pad_cell "$3" "$cert_col_san"
printf " | "
pad_cell "$4" "$cert_col_created"
printf " | "
pad_cell "$5" "$cert_col_expire"
printf " | "
pad_cell "$6" "$cert_col_remain"
printf "\n"
}

print_cert_table_separator(){
printf "  "
repeat_char "-" "$cert_col_no"
printf "%s" "-+-"
repeat_char "-" "$cert_col_domain"
printf "%s" "-+-"
repeat_char "-" "$cert_col_san"
printf "%s" "-+-"
repeat_char "-" "$cert_col_created"
printf "%s" "-+-"
repeat_char "-" "$cert_col_expire"
printf "%s" "-+-"
repeat_char "-" "$cert_col_remain"
printf "\n"
}

cert_store_name_for_record(){
local domain="$1"
local san="$2"
local candidate
if [[ "$san" == *\*.* ]]; then
IFS=',' read -r -a san_items <<< "$san"
for candidate in "${san_items[@]}"; do
candidate="${candidate// /}"
if [[ "$candidate" == \*.* ]]; then
printf "%s" "$candidate"
return
fi
done
fi
if [[ -s "/root/qiqissl/${domain}/cert.crt" ]]; then
printf "%s" "$domain"
elif [[ -s "/root/qiqissl/*.${domain}/cert.crt" ]]; then
printf "*.%s" "$domain"
else
printf "%s" "$domain"
fi
}

cert_expire_raw_for_record(){
local domain="$1"
local san="$2"
local store_name cert_file raw_expire
store_name=$(cert_store_name_for_record "$domain" "$san")
cert_file="/root/qiqissl/${store_name}/cert.crt"
if [[ ! -s "$cert_file" && -s "$HOME/.acme.sh/${domain}_ecc/fullchain.cer" ]]; then
cert_file="$HOME/.acme.sh/${domain}_ecc/fullchain.cer"
elif [[ ! -s "$cert_file" && -s "$HOME/.acme.sh/${domain}/fullchain.cer" ]]; then
cert_file="$HOME/.acme.sh/${domain}/fullchain.cer"
fi
if [[ ! -s "$cert_file" ]]; then
printf "-"
return
fi
raw_expire=$(openssl x509 -enddate -noout -in "$cert_file" 2>/dev/null | sed 's/^notAfter=//')
printf "%s" "$raw_expire"
}

list_cert_options(){
local mode="${1:-plain}"
cert_domains=()
cert_store_names=()
cert_key_lengths=()
local idx=0 domain key_length san ca created renew rest created_local expire_raw expire_epoch expire_local remain_days row_id width
local -a row_ids row_domains row_sans row_created row_expire row_remain
cert_col_no=$(display_width "序号")
cert_col_domain=$(display_width "域名")
cert_col_san=$(display_width "SAN")
cert_col_created=$(display_width "创建时间")
cert_col_expire=$(display_width "到期时间")
cert_col_remain=$(display_width "剩余")
while read -r domain key_length san ca created renew rest; do
if [[ -z "$domain" || "$domain" == "Main_Domain" ]]; then
continue
fi
idx=$((idx + 1))
cert_domains[$idx]="$domain"
cert_key_lengths[$idx]="$key_length"
[[ -z "$san" ]] && san="-"
[[ -z "$created" ]] && created="-"
cert_store_names[$idx]="$(cert_store_name_for_record "$domain" "$san")"
created_local=$(format_cert_time "$created")
expire_raw=$(cert_expire_raw_for_record "$domain" "$san")
expire_epoch=$(cert_time_epoch "$expire_raw")
expire_local=$(format_cert_time "$expire_raw")
if [[ -n "$expire_epoch" ]]; then
remain_days=$(cert_remaining_days "$expire_epoch")
else
remain_days="-"
fi
if [[ "$mode" == "select" ]]; then
row_id="[$idx]"
else
row_id="$idx"
fi
row_ids[$idx]="$row_id"
row_domains[$idx]="$domain"
row_sans[$idx]="$san"
row_created[$idx]="$created_local"
row_expire[$idx]="$expire_local"
row_remain[$idx]="$remain_days"
width=$(display_width "$row_id"); (( width > cert_col_no )) && cert_col_no=$width
width=$(display_width "$domain"); (( width > cert_col_domain )) && cert_col_domain=$width
width=$(display_width "$san"); (( width > cert_col_san )) && cert_col_san=$width
width=$(display_width "$created_local"); (( width > cert_col_created )) && cert_col_created=$width
width=$(display_width "$expire_local"); (( width > cert_col_expire )) && cert_col_expire=$width
width=$(display_width "$remain_days"); (( width > cert_col_remain )) && cert_col_remain=$width
done < <(bash ~/.acme.sh/acme.sh --list 2>/dev/null)
if [[ $idx -eq 0 ]]; then
yellow "当前没有找到已申请证书记录"
return 1
fi
print_cert_table_row "序号" "域名" "SAN" "创建时间" "到期时间" "剩余"
print_cert_table_separator
for ((i=1; i<=idx; i++)); do
print_cert_table_row "${row_ids[$i]}" "${row_domains[$i]}" "${row_sans[$i]}" "${row_created[$i]}" "${row_expire[$i]}" "${row_remain[$i]}"
done
return 0
}

renew_one_cert(){
local domain="$1"
if [[ -z "$domain" ]]; then
yellow "未找到对应证书，请重新选择"
return 1
fi
green "开始续期 ${domain} …………" && sleep 1
if bash ~/.acme.sh/acme.sh --renew -d "$domain" --force --ecc; then
cronac
green "${domain} 续期命令执行完成，已保留acme.sh和所有证书文件"
else
yellow "${domain} 续期失败，已保留acme.sh和所有证书文件"
return 1
fi
}

renew_all_certs(){
green "开始一键续期全部证书…………" && sleep 1
if bash ~/.acme.sh/acme.sh --cron -f; then
cronac
green "全部证书续期命令执行完成，已保留acme.sh和所有证书文件"
else
yellow "全部续期失败或部分证书续期失败，已保留acme.sh和所有证书文件"
return 1
fi
}

safe_cert_name(){
local value="$1"
[[ -n "$value" ]] || return 1
[[ "$value" != /* ]] || return 1
[[ "$value" != *"/"* ]] || return 1
[[ "$value" != "." && "$value" != ".." ]] || return 1
return 0
}

delete_one_cert(){
local domain="$1"
local store_name="$2"
local key_length="$3"
local confirm target_dir acme_dir
local -a remove_args
if [[ -z "$domain" ]]; then
yellow "未找到对应证书，请重新选择"
return 1
fi
[[ -n "$store_name" ]] || store_name="$domain"
if ! safe_cert_name "$domain" || ! safe_cert_name "$store_name"; then
red "证书名称异常，已停止删除，避免误删文件"
return 1
fi
target_dir="/root/qiqissl/${store_name}"
case "$key_length" in
ec-*|EC-*|ecc|ECC)
remove_args=(--ecc)
acme_dir="$HOME/.acme.sh/${domain}_ecc"
;;
*)
remove_args=()
acme_dir="$HOME/.acme.sh/${domain}"
;;
esac
yellow "将删除 acme.sh 记录：${domain}"
yellow "将删除证书文件目录：${target_dir}"
readp "确认删除请输入 DELETE，其他输入取消 → " confirm
if [[ "$confirm" != "DELETE" ]]; then
yellow "已取消删除"
return 1
fi
if bash ~/.acme.sh/acme.sh --remove -d "$domain" "${remove_args[@]}"; then
green "acme.sh 证书记录已删除：${domain}"
else
yellow "acme.sh 删除记录命令返回失败，将继续尝试清理本地证书文件"
fi
rm -rf "$acme_dir" "$target_dir"
green "证书文件已删除：${target_dir}"
}

acmedelete(){
ensure_acme_ready || { pause_return; return; }
local cert_index store_name
while true; do
clear
qiqi_section "删除证书"
yellow "  删除后会移除 acme.sh 记录和 /root/qiqissl/ 下对应证书文件"
if ! list_cert_options select; then
pause_return
return
fi
echo
printf "  ${QIQI_GRAY}[ 0 ]${QIQI_PLAIN}  返回上一级\n"
echo
readp "  请输入要删除的证书编号 → " cd
case "$cd" in
0 ) return;;
'' ) yellow "输入不能为空，请重新选择"; sleep 1;;
*[!0-9]* ) yellow "请输入数字编号"; sleep 1;;
* )
cert_index=$((10#$cd))
if [[ -n "${cert_domains[$cert_index]}" ]]; then
store_name="${cert_store_names[$cert_index]:-${cert_domains[$cert_index]}}"
delete_one_cert "${cert_domains[$cert_index]}" "$store_name" "${cert_key_lengths[$cert_index]}"
pause_return
else
yellow "未找到编号 ${cd} 对应的证书，请重新选择"
sleep 1
fi
;;
esac
done
}

show_cert_status(){
if [[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
yellow "  未安装acme.sh，暂无证书记录"
return 1
fi
list_cert_options plain
}
cronac(){
uncronac
crontab -l > /tmp/crontab.tmp 2>/dev/null
echo "0 0 * * * bash /root/.acme.sh/acme.sh --cron >/dev/null 2>&1" >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}
uncronac(){
crontab -l > /tmp/crontab.tmp 2>/dev/null
sed -i '/--cron/d' /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}
acmerenew(){
ensure_acme_ready || { pause_return; return; }
local cert_index
while true; do
clear
qiqi_section "证书续期"
green "  已申请证书状态如下："
if ! list_cert_options select; then
pause_return
return
fi
echo
qiqi_section "续期操作"
printf "  ${QIQI_ORANGE}[ 99 ]${QIQI_PLAIN} 一键全部续期/升级\n"
printf "  ${QIQI_GRAY}[ 0 ]${QIQI_PLAIN}  返回上一级\n"
echo
readp "  请输入要续期的证书编号 → " cd
case "$cd" in
0 ) return;;
99 ) renew_all_certs; pause_return;;
'' ) yellow "输入不能为空，请重新选择"; sleep 1;;
*[!0-9]* ) yellow "请输入数字编号"; sleep 1;;
* )
cert_index=$((10#$cd))
if [[ -n "${cert_domains[$cert_index]}" ]]; then
renew_one_cert "${cert_domains[$cert_index]}"
pause_return
else
yellow "未找到编号 ${cd} 对应的证书，请重新选择"
sleep 1
fi
;;
esac
done
}
uninstall(){
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh证书申请，无法执行" && return 1
curl https://get.acme.sh | sh
bash ~/.acme.sh/acme.sh --uninstall
# 保留用户的证书文件和管理脚本
rm -rf ~/.acme.sh
sed -i '/acme.sh.env/d' ~/.bashrc 
source ~/.bashrc
uncronac
rm -f /root/.acqiqi_update
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && green "acme.sh卸载完毕，已保留 /root/qiqi_acme.sh 和证书文件" || red "acme.sh卸载失败，/root/qiqi_acme.sh 已保留"
}

start_menu(){
while true; do
clear
qiqi_banner "$QIQI_PROJECT_NAME" "$QIQI_PROJECT_VERSION" "$QIQI_PROJECT_DESCRIPTION" "$QIQI_PROJECT_URL"
qiqi_section "使用须知"
printf "  ${QIQI_GRAY}1.${QIQI_PLAIN} 本脚本仅支持单IP的VPS，SSH登录IP须与VPS公网IP一致\n"
printf "  ${QIQI_GRAY}2.${QIQI_PLAIN} 80端口模式：仅支持单域名证书，80端口空闲时可自动续期\n"
printf "  ${QIQI_GRAY}3.${QIQI_PLAIN} DNS API模式：支持单域名与泛域名，无条件自动续期\n"
yellow "  ⚠ 泛域名申请前，需在域名解析处添加一条 * 的记录 (格式：*.yourdomain.com)"
printf "  ${QIQI_GREEN}⬥ 公钥路径 ${QIQI_PINK}→${QIQI_PLAIN}  /root/qiqissl/<域名>/cert.crt\n"
printf "  ${QIQI_GREEN}⬥ 密钥路径 ${QIQI_PINK}→${QIQI_PLAIN}  /root/qiqissl/<域名>/private.key\n"
qiqi_section "当前证书状态"
show_cert_status
qiqi_section "功能菜单"
qiqi_menu_item "1" "申请 letsencrypt ECC 证书" "（80端口 / DNS API 双模式）"
qiqi_menu_item "2" "手动续期证书"
printf "  ${QIQI_ORANGE}[ 3 ]${QIQI_PLAIN}  ${QIQI_WHITE}卸载 acme.sh（保留管理脚本和证书文件）${QIQI_PLAIN}\n"
printf "  ${QIQI_RED}[ 4 ]${QIQI_PLAIN}  ${QIQI_WHITE}删除证书（删除记录和证书文件）${QIQI_PLAIN}\n"
printf "  ${QIQI_GRAY}[ 0 ]${QIQI_PLAIN}  ${QIQI_WHITE}退出${QIQI_PLAIN}\n"
echo
readp "  请输入选项数字 → " NumberInput
case "$NumberInput" in
1 ) acme; pause_return;;
2 ) acmerenew;;
3 ) uninstall; pause_return;;
4 ) acmedelete;;
0 ) exit;;
* ) yellow "输入有误，请重新选择"; sleep 1;;
esac
done
}

start_menu
