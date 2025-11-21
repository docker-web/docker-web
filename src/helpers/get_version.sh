GET_VERSION () {
  curl --silent $URL_GITHUBRAW/src/env.sh | grep "DOCKERWEB_VERSION" | cut -d "=" -f 2 | cut -d "\"" -f 2
}