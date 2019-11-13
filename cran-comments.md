## Test environments
* local OS X install, R 3.6.1
* ubuntu 16.04 (on travis-ci), R 3.6.1
* win-builder (devel and release)

## R CMD check results

❯ checking package dependencies ... NOTE
  Package suggested but not available for checking: ‘msgpack’

0 errors ✔ | 0 warnings ✔ | 1 note ✖

msgpack is optional dpendent package available on GitHub and one RTD function depends on it. RTD provides installation check for it and recommend to install it interactively.

## revdepcheck results

There are currently no downstream dependencies for this package.
