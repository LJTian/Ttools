#!/bin/bash

echo "rpmbuild_load start"
echo "参数为 ba bb bp 等 与 rpmbuild -ba 使用一致, 第三个参数为 -d 时开启 debug 日志"

PWD=`pwd`
ACTION=$1
DEBUG=$2
echo ${ACTION}
if [ 1"${ACTION}" == 1 ]; then
        ACTION="bp"
fi

mkdir -p ${PWD}/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
cp *.spec ${PWD}/rpmbuild/SPECS
files=`grep -E "Source|Patch" *.spec | awk '{print $2}'`

for file in $files
do
        echo ${file}
        cp ${file} ${PWD}/rpmbuild/SOURCES/
done

if [ 1"${DEBUG}" == 1"-d" ]; then
	rpmbuild --define="_topdir `pwd`/rpmbuild" --nodebuginfo -${ACTION} ${PWD}/rpmbuild/SPECS/*.spec -vv
else
	rpmbuild --define="_topdir `pwd`/rpmbuild" --nodebuginfo -${ACTION} ${PWD}/rpmbuild/SPECS/*.spec
fi
