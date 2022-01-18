<!-- badges: start -->
[![R-CMD-check](https://github.com/JohnCoene/npm/workflows/R-CMD-check/badge.svg)](https://github.com/JohnCoene/npm/actions)
<!-- badges: end -->

# npm

Interact with [npm](https://www.npmjs.com/) from the R console.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("JohnCoene/npm")
```

## Example

``` r
library(npm)
npm_install("browserify", scope = "global")

npm_init()
npm_install("jquerjqueryy")
npm_run("--version")
```

Also see [yarn](https://github.com/JohnCoene/yarn).
