{
  writeShellApplication,
  rlwrap,
  socat,
  ...
}:

writeShellApplication {
  name = "redis-cli";
  runtimeInputs = [
    rlwrap
    socat
  ];
  text = ''
    REDIS_HOST="${"1:-127.0.0.1"}"
    REDIS_PORT="${"2:-6379"}"  
    rlwrap -S "${REDIS_HOST}:${REDIS_PORT}> " socat tcp:${REDIS_HOST}:${REDIS_PORT} STDIO
  '';
}
