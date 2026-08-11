output=$(ollama ps)

# 无参数直接输出
if [[ $# -eq 0 ]]; then
  echo "$output"
  exit 0
fi

# 跳过表头，解析模型数据
declare -a names ids sizes procs ctxs tills

count=0
first_line=1

while IFS= read -r line; do
  # 跳过表头
  if [[ $first_line -eq 1 ]]; then
    first_line=0
    continue
  fi

  [[ -z "$line" ]] && continue

  name=$(echo "$line" | awk '{print $1}')
  id=$(echo "$line" | awk '{print $2}')
  size=$(echo "$line" | awk '{print $3" "$4}')
  proc=$(echo "$line" | awk '{print $5" "$6}')
  ctx=$(echo "$line" | awk '{print $7}')
  till=$(echo "$line" | awk '{for(j=8;j<=NF;j++) printf "%s ", $j; print ""}' | sed 's/ *$//')

  # ctx 格式化
  if ((ctx % 1024 == 0)) 2>/dev/null; then
    ctx="$((ctx / 1024))K"
  fi

  # till 格式化
  if [[ "$till" =~ ^a\ minute ]]; then
    till="1 min"
  elif [[ "$till" =~ ([0-9]+)\ minute ]]; then
    till="${BASH_REMATCH[1]} min"
  elif [[ "$till" =~ ([0-9]+)\ second ]]; then
    till="${BASH_REMATCH[1]} sec"
  else
    till="n/a"
  fi

  names[$count]="$name"
  ids[$count]="$id"
  sizes[$count]="$size"
  procs[$count]="$proc"
  ctxs[$count]="$ctx"
  tills[$count]="$till"
  ((count++))
done <<<"$output"

arg="$1"

# 计算最长 name 长度
max_name_len=0
for n in "${names[@]}"; do
  if ((${#n} > max_name_len)); then
    max_name_len=${#n}
  fi
done

# 解析选择标志
bname=0
bid=0
bsize=0
bproc=0
bctx=0
btill=0

for ((i = 0; i < ${#arg}; i++)); do
  c="${arg:$i:1}"
  case "$c" in
  n) bname=1 ;; i) bid=1 ;; s) bsize=1 ;;
  p) bproc=1 ;; c) bctx=1 ;; t) btill=1 ;;
  esac
done

# 输出表头
((bname)) && printf "NAME%*s\t\t" $((max_name_len - 8)) ""
((bid)) && printf "ID\t\t"
((bsize)) && printf "SIZE\t\t"
((bproc)) && printf "PROCESSOR\t"
((bctx)) && printf "CONTEXT\t\t"
((btill)) && printf "UNTIL"

# 输出每行数据
for ((j = 0; j < count; j++)); do
  if [[ "$arg" == "-f" ]]; then
    echo "${names[$j]}"
    echo "${ids[$j]}"
    echo "${sizes[$j]}"
    echo "${procs[$j]}"
    echo "${ctxs[$j]}"
    echo "${tills[$j]}"
  fi

  echo

  if ((bname)); then
    spacing=$((max_name_len - ${#names[$j]} - 4))

    if ((spacing >= 0)); then
      tab=$'\t\t'
    else
      spacing=0
      tab=$'\t'
    fi

    printf "%s%*s%s" "${names[$j]}" "$spacing" "" "$tab"
  fi

  ((bid)) && printf "%s\t" "${ids[$j]}"
  ((bsize)) && printf "%s\t\t" "${sizes[$j]}"
  ((bproc)) && printf "%s\t" "${procs[$j]}"
  ((bctx)) && printf "%s\t\t" "${ctxs[$j]}"
  ((btill)) && printf "%s" "${tills[$j]}"
done

echo
