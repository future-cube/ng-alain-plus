#!/bin/bash

# 获取当前最新的 Git 标签
get_current_git_tag() {
  git describe --tags $(git rev-list --tags --max-count=1)
}

# 获取 npm 上的当前版本号
get_current_npm_version() {
  local package_name=$1
  npm view $package_name version
}

# 提取版本号部分
extract_version_parts() {
  local version=$1
  IFS='.' read -r -a version_parts <<< "${version#v}"
  echo "${version_parts[@]}"
}

# 计算默认的新版本号
calculate_new_version() {
  local major=$1
  local minor=$2
  local patch=$3
  local new_major=$((major + 1))
  local new_minor=$((minor + 1))
  local new_patch=$((patch + 1))
  echo "v$new_major.0.0 v$major.$new_minor.0 v$major.$minor.$new_patch"
}

# 询问是否将所有修改更新到 GitHub 上
update_github() {
  read -p "是否将所有修改更新到 GitHub 上？(Y/n): " update_choice
  update_choice=${update_choice:-Y}

  if [[ "$update_choice" == "Y" || "$update_choice" == "y" ]]; then
    git add .
    git commit -m "Update to latest changes"
    git push origin main
  else
    echo "跳过更新到 GitHub。"
  fi
}

# 询问是否打包标签
package_tag() {
  read -p "是否打包标签？(Y/n): " tag_choice
  tag_choice=${tag_choice:-Y}

  if [[ "$tag_choice" == "Y" || "$tag_choice" == "y" ]]; then
    echo "正在获取当前版本号..."

    local current_git_tag=$(get_current_git_tag)
    local current_npm_version=$(get_current_npm_version "@future-cube/ng-alain-plus")

    local version_parts=($(extract_version_parts $current_npm_version))
    local major=${version_parts[0]}
    local minor=${version_parts[1]}
    local patch=${version_parts[2]}

    local new_versions=($(calculate_new_version $major $minor $patch))
    local new_major_version=${new_versions[0]}
    local new_minor_version=${new_versions[1]}
    local default_new_version=${new_versions[2]}

    echo "当前 Git 标签: $current_git_tag"
    echo "当前 npm 版本号: $current_npm_version"

    echo "请选择发布的版本号："
    echo "0. 自行输入"
    echo "1. 大版本号加1 ($new_major_version)"
    echo "2. 次版本号加1 ($new_minor_version)"
    echo "3. 小版本号加1 ($default_new_version) (默认)"

    read -p "请输入选择 (0, 1-3) [默认3]: " version_choice
    version_choice=${version_choice:-3}

    case $version_choice in
      0)
        read -p "请输入新版本号: " new_version
        ;;
      1)
        new_version=$new_major_version
        ;;
      2)
        new_version=$new_minor_version
        ;;
      3|*)
        new_version=$default_new_version
        ;;
    esac

    git tag $new_version
    git push origin $new_version
    echo "已更新到 GitHub 并打包标签版本 $new_version。"
  else
    echo "跳过打包标签。"
  fi
}

# 主程序
update_github
package_tag
