command ollama ps 2>/dev/null | awk 'NR>1 {print $1}'
