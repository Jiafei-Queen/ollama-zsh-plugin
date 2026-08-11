# ollama-zsh-plugin

A Zsh plugin providing command completion for Ollama AI models management.

## Features

- Autocompletes Ollama commands
- Provides the functionality to stop other models before running a model

## Installation

Please ensure that Oh-My-Zsh is installed before installing this plugin.

1. Clone this repository in Oh-My-Zsh's plugins directory:
```sh
git clone https://github.com/Jiafei-Queen/ollama-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ollama
```
2. Activate the plugin in `~/.zshrc`:
```sh
plugins=(... ollama)
```
3. Restart your shell or run:
```sh
source ~/.zshrc
```

## Usage

### Basic completion
Once installed, the plugin will automatically provide command completion for Ollama. Type `ollama` followed by a space and press Tab to see available commands. For commands that work with models (`run`, `show`, `stop`, `rm`, `cp`, `pull`), pressing Tab after the command will suggest available model names.

### Better `ollama ps`
- `ollama ps -f`

```
$ ollama ps -f
gemma3:270m
e7d36fb2c3b3
409 MB
100% GPU
32K
2 min
```

- `ollama ps [nispcu]`

```
$ ollama ps "nsc" 
NAME   		SIZE		CONTEXT		
gemma3:270m	409 MB		32K
```

### Stop all models
`ollama stop all`

### Stop other models before run a new one
1. Add this line to `~/.zshrc`:
```sh
export OLLAMA_STOPALL_BEFORE_RUN=1
```
2. Restart your shell or run:
```sh
source ~/.zshrc
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

