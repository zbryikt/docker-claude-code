# docker-llmcli

run llm cli in docker.

usage:

    # build docker image
    docker build -t llmcli .

    # enter container
    ./run.sh

    # in container, start claude:
    claude

run.sh options:

    --profile PROFILE          specify profile name (default: default)
    --cli claude|gemini        choose CLI tool (default: claude)
    --reset                    reset and recreate container
    -p, --port HOST:CONTAINER  map port (can be used multiple times)

examples:

    # map single port
    ./run.sh -p 3000:8080

    # map multiple ports
    ./run.sh -p 3000:8080 -p 5432:5432

    # bind to localhost only
    ./run.sh -p 127.0.0.1:3000:8080

    # combine options
    ./run.sh --profile dev --cli claude -p 8080:8080


## License

MIT
