#!/bin/bash

# set -x

profile_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd)
root_dir=$(dirname $profile_dir)

# 引入配置
source $root_dir/config/conf.profile

source $profile_dir/env.profile
source $profile_dir/alias.profile
source $profile_dir/commonutil.profile
source $profile_dir/adbutil.profile


export PATH=$root_dir/tools:$PATH
