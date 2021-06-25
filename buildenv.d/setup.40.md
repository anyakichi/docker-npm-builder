Change into the project directory.

```
$ [[ -e package.json ]] || cd $(basename -s .git "${GIT_REPO}")
```
