SCRIPT_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ollama"
models=$(/bin/sh "$SCRIPT_DIR/ollama_probe_running.sh")

for model in $models; do
    should_skip=false

    for skip in "$@"; do
        if [[ "$model" == "$skip" ]]; then
            should_skip=true
            break
        fi
    done

    if [[ "$should_skip" == false ]]; then
        command ollama stop "$model"
    fi
done
