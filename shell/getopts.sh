#!/bin/bash
 
usage(){
  echo "
Usage:
  -i, --ip    target server ip
  -p, --port    target service port
  -h, --help    display this help and exit
 
  example1: ./testGetopts.sh -i192.168.1. -p80
  example2: ./testGetopts.sh -i 192.168.1.1 -p
"
# getopts只能在shell脚本中使用，不能像getopt一样在命令行中单独使用
# getopts只支持短格式不支持长格式
# getopts如果设定有选项值的选项，如果没提供选项值那么会直接报错
# getopts选项要么有选项值要么没有选项值，没有可有也可以没有
# getopts选项后可紧接选项值，也可以使用空格隔开；为与getopt统一建议使用紧接格式
 
}
 
main(){
  # 选项有:表示该选项需要选项值
  while getopts "i:p:h" arg
  do
    case $arg in
      i)
         #参数存在$OPTARG中
         ip="$OPTARG"
         echo "ip:    $ip"
         ;;
      p)
         port="$OPTARG"
         echo "port:    $port"
         ;;
      h)
         usage
         # 打印usage之后直接用exit退出程序
         exit
         ;;
      ?)
         #当有不认识的选项的时候arg值为?
         echo "unregistered argument"
         exit
         ;;
    esac
  done
}
 
main $@
