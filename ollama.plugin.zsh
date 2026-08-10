# 内部辅助函数
_ollama_stop_all() {
    local model
    for model in $(ollama ps 2>/dev/null | awk 'NR>1 {print $1}'); do
        command ollama stop "$model"
    done
}

# 包装函数（拦截命令）
ollama() {
    if [[ "$1" == "stop" && "$2" == "all" ]]; then
        _ollama_stop_all
    elif [[ "$1" == "run" && -n "$OLLAMA_STOPALL_BEFORE_RUN" ]]; then
        _ollama_stop_all
        echo "ollama-plugin: Stop running models..."
        command ollama "$@"
    else
        command ollama "$@"
    fi
}
