#!/bin/sh

#使用方法
# 1. 根据自己的项目情况修改配置
# 2. 将此脚本放在任意目录, 然后命令行中执行 chmod 744 autoipa.sh 或者 chmod u+x autoipa.sh 将其改为可执行
# 3. 之后执行 ./autoipa.sh [-a|all|-c|clean|项目配置名]

#配置,请根据自己的项目情况修改
project_name="projxxx" #项目名
workspace_name=${project_name} #Workspace名,一般和项目名一致
scheme_name=${project_name} #scheme名,一般和项目名称一致
project_path="/Users/username/Documents/Project/projxxx"  #项目路径
archive_path="/Users/username/Documents/Project/bin" #存放xcarchive文件的路径,请预先创建好目录
ipa_path="/Users/username/Documents/Project/bin" #存放ipa文件的路径,请预先创建好目录
develop_provision="projxxx-Test"  #测试用的provisioning profile名称,在开发者中心配置的名称.需下载到本地导入系统中.
dist_provision="XC: com.corp.projxxx" #提交Appstore用的provisioning profile名称,在开发者中心配置的名称.需下载到本地导入系统中.
config_names=("Debug" "Release") #项目配置,创建项目后默认有Debug和Release两种配置.如果自定义了配置,请在此处添加,以空格分隔
start_time=$(date +%Y%m%d%H%M) #开始执行此脚本的时间,用于导出xcarchive和ipa文件的后缀

#变量
build_configs=()
isRelease=0

#函数
function echoUseage()
{
	echo "usage: ./autoipa.sh [-a|all|-c|clean|项目配置名]"
	echo "                    -a|all   编译Debug,Release两种配置"
	echo "                             导出测试,线上,提交Appstore的三种ipa文件"
	echo "                    -c|clean 删除所有生成的xcarchive和ipa文件"
	echo "                    根据指定项目配置生成ipa,比如Debug,Release"
}

#解析参数
if [[ $# -eq 0 ]]; then
	echoUseage
	exit 0
fi
for arg in $@; do
	case ${arg} in
		clean | -c )
			# echo "command: rm -rf ${archive_path}/*.xcarchive"
			# echo "command: rm -rf ${ipa_path}/*.ipa"
			rm -rf ${archive_path}/*.xcarchive
			rm -rf ${ipa_path}/*.ipa
			exit 0
			;;
		all | -a)
			build_configs=(${config_names[@]})
			isRelease=1
			;;
		* )
			if [[ ${arg} = Release ]]; then
				isRelease=1
			fi
			for name in ${config_names[@]}; do
				if [[ ${arg} = ${name} ]]; then
				# echo "arg:${arg} name: ${name}"
				build_configs=(${build_configs[@]} ${arg})
				fi
			done
			if [[ ${#build_configs[@]} == 0 ]]; then
				echoUseage
				exit 0
			fi
			;;
	esac
done

#打包及生成IPA
for ((i=0;i<${#build_configs[@]};i++))
do
	# echo "command: xcodebuild archive -workspace \"${project_path}/${workspace_name}.xcworkspace\" -scheme \"${scheme_name}\" -configuration \"${build_configs[$i]}\" -archivePath \"${archive_path}/${project_name}-${build_configs[$i]}-${start_time}.xcarchive\""
    xcodebuild archive -workspace "${project_path}/${workspace_name}.xcworkspace" -scheme "${scheme_name}" -configuration "${build_configs[$i]}" -archivePath "${archive_path}/${project_name}-${build_configs[$i]}-${start_time}.xcarchive"
	# echo "command: xcodebuild -exportArchive -archivePath \"${archive_path}/${project_name}-${build_configs[$i]}-${start_time}.xcarchive\" -exportPath \"${ipa_path}/${project_name}-${build_configs[$i]}-${start_time}.ipa\" -exportFormat ipa -exportProvisioningProfile \"${develop_provision}\""
	xcodebuild -exportArchive -archivePath "${archive_path}/${project_name}-${build_configs[$i]}-${start_time}.xcarchive" -exportPath "${ipa_path}/${project_name}-${build_configs[$i]}-${start_time}.ipa" -exportFormat ipa -exportProvisioningProfile "${develop_provision}"
done
if [[ ${isRelease} -eq 1 ]]; then
	# echo "command: mv \"${ipa_path}/${project_name}-Release-${start_time}.ipa\" \"${ipa_path}/${project_name}-Online-${start_time}.ipa\""
    mv "${ipa_path}/${project_name}-Release-${start_time}.ipa" "${ipa_path}/${project_name}-Online-${start_time}.ipa"
	# echo "command: xcodebuild -exportArchive -archivePath \"${archive_path}/${project_name}-Release-${start_time}.xcarchive\" -exportPath \"${ipa_path}/${project_name}-Appstore-${start_time}.ipa\" -exportFormat ipa -exportProvisioningProfile \"${dist_provision}\""
	xcodebuild -exportArchive -archivePath "${archive_path}/${project_name}-Release-${start_time}.xcarchive" -exportPath "${ipa_path}/${project_name}-Appstore-${start_time}.ipa" -exportFormat ipa -exportProvisioningProfile "${dist_provision}"
fi

#自动打开存放ipa文件的目录(Finder)
open "${ipa_path}"
