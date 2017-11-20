
#! /bin/sh
if which oclint 2>/dev/null; then
    echo 'oclint exist'
else
    brew tap oclint/formulae
    brew install oclint
fi
if which xcpretty 2>/dev/null; then
    echo 'xcpretty exist'
else
    gem install xcpretty
fi
commid=$(git rev-parse HEAD)
lastCommitId=$(git rev-parse HEAD~1)
commnadFiles=""
changfiles=$(git diff --name-only  $commid $lastCommitId   | grep '^[^(Pods/)].*\.m$')
echo "changfiles: $changfiles"

for file in $changfiles ; do
	    echo "git dddd:$file"
    if [[ -f $file ]]; then
        echo "git ......:$file"
        commnadFiles=" $commnadFiles -i $file"
    fi
done
echo "git检查有修改的文件: $commnadFiles"

# allfiles=$(git ls-files)
# echo "allfiles=:$(git ls-files)"
# uncheckfile=""
# for allfile in $allfiles; do
# 	a="nochange"
# 	for commandfile in commnadFiles; do
# 		if [ $commandfile == $allfile ];then
# 			a="haschange"
# 		fi
# 	done
#     # if [ $a == "nochange" && （ {$allfile##*.} == ".h" ||  {$allfile##*.} == ".m" ） ]; then
#     # 	uncheckfile=" $uncheckfile  $allfile"
#     # fi
# done
#     	echo "忽略的的文件: $uncheckfile"

 echo "---------------------------------------------------"

xcodebuild clean
xcodebuild | xcpretty -r json-compilation-database -o compile_commands.json
oclint-json-compilation-database \
-e Pods \
-e build \
$commnadFiles \
-- \
-stats \
-verbose \
-report-type   html -o result.html \
-max-priority-1=9999 -max-priority-2=9999 -max-priority-3=9999 \
-rc LONG_LINE=130 \
-rc LONG_METHOD=150 \
-rc MINIMUM_CASES_IN_SWITCH=2 \
-rc LONG_VARIABLE_NAME=20 \
-rc CYCLOMATIC_COMPLEXITY=10 \
-rc LONG_CLASS=2000 \
-rc NCSS_METHOD=40 \
-rc NESTED_BLOCK_DEPTH=5 \
-rc TOO_MANY_FIELDS=20 \
-rc TOO_MANY_METHODS=30 \
-rc TOO_MANY_PARAMETERS=5 \
-disable-rule ShortVariableName \
-disable-rule=BrokenOddnessCheck \
-disable-rule=VerifyProhibitedCall \
-disable-rule=VerifyProtectedMethod \
-disable-rule=SubclassMustImplement \
-disable-rule=BaseClassDestructorShouldBeVirtualOrProtected \
-disable-rule=DestructorOfVirtualClass \
-disable-rule=ParameterReassignment \
-disable-rule=AvoidDefaultArgumentsOnVirtualMethods \
-disable-rule=AvoidPrivateStaticMembers \
-disable-rule=TooManyParameters \
-disable-rule=UnusedMethodParameter \
-disable-rule=UseObjectSubscripting \
-disable-rule=AssignIvarOutsideAccessors
if [ $? -eq 0 ]; then
   printf "\e[1;36m报告生成成功！\e[0m\n"
else
   printf "\e[1;31m报告生成失败\e[0m\n"
   exit 1
fi