# githttp

A simple GIT server.

⚠️ for testing purposes only, serves a single repository through HTTP without any authentication.

## Usage

Docker:

```sh
docker run -p 8080:80 graviteeio/git-http-server
git clone http://localhost:8080/repository.git
```

## Acknowledgements

This is just a wrapper around
[node-git-http-server](https://github.com/bahamas10/node-git-http-server)
which is based on
[git-http-backend](https://github.com/substack/git-http-backend).
