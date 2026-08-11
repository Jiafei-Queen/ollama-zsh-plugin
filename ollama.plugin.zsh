# 内部辅助函数
SCRIPT_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ollama"
_ollama_probe_running="$SCRIPT_DIR/ollama_probe_running.sh"
_ollama_stop_all="$SCRIPT_DIR/ollama_stop_all.sh"
_ollama_ps="$SCRIPT_DIR/ollama_ps.sh"

ollama() {
    case "$1" in
        "stop")
            if [[ "$2" == "all" ]]; then
                /bin/sh "$_ollama_stop_all"
                return
            fi
            ;;
        "run")
            if [[ -n "$OLLAMA_STOPALL_BEFORE_RUN" && -n "$2" ]]; then
                running=false

                local -a models
                models=(${(f)"$(/bin/sh "$_ollama_probe_running")"})

                for model in $models; do
                    if [[ "$model" == "$2" ]]; then
                        running=true
                    fi
                done

                if [[ $running == false && ${#models[@]} > 0 ]]; then
                    echo "ollama-plugin: Stop running models..."
                    /bin/sh "$_ollama_stop_all" "$2"
                fi
            fi
            ;;
        "ps")
            shift 
            zsh "$_ollama_ps" "$@"
            return
            ;;
    esac

    command ollama "$@"
}
