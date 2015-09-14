healthcheck() {
    local HC_HOST=$1 HC_PORT=$2 HC_SLEEP_IN_SECONDS=$3
    echo "healthcheck $HC_HOST:$HC_PORT (wait ${HC_SLEEP_IN_SECONDS}s)"
    while ! nc -z -w 2 $HC_HOST $HC_PORT; do echo "$HC_HOST:$HC_PORT not reachable. Try again in ${HC_SLEEP_IN_SECONDS}s" && sleep $HC_SLEEP_IN_SECONDS; done
}
