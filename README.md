
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vikingr

<!-- badges: start -->

<!-- badges: end -->

The goal of `vikingr` is to provide a way to decode and work with data
provided in the [AIS format](https://gpsd.gitlab.io/gpsd/AIVDM.html)
from within R.

Some demo data is bundled into the package that can be used offline as
an example dataset. This data was captured from the Visby Harbor during
the RaukR summer school 2019. This is a subset of some realistic data
from the modern-day viking ships that traffic the Visby harbor in
Gotland, Sweden.

## Installation

You can install the development version of `vikingr`from
[GitHub](https://github.com/mskyttner/vikingr) with:

``` r
# install.packages("devtools")
devtools::install_github("mskyttner/vikingr", build_vignettes = TRUE)
```

## Example

This is a basic example which shows you how typical usage:

``` r
library(vikingr)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

# display a few of the encoded messages

log <- read_ais_log(system.file("extdata", "vikingr-visby-2019-ais", package = "vikingr"))
knitr::kable(log %>% slice(1:5))
```

| timestamp           | message                                                     |
| :------------------ | :---------------------------------------------------------- |
| 2019-06-12 12:15:38 | \!AIVDM,1,1,,A,H39n`218t@F1`<u861Jr04m=@E8>@,0\*29,142656   |
| 2019-06-12 12:15:48 | \!AIVDM,1,1,,A,H39n\`<24TC=D744;49@Ej001P0030>,0\*0E,632874 |
| 2019-06-12 12:16:06 | \!AIVDM,1,1,,B,13uDcBPOh01CcmBPvc\`eLnBB0D0?,0\*57,1476282  |
| 2019-06-12 12:17:38 | \!AIVDM,1,1,,A,13uDcBP0001CcmNPvcWePnEB08GU,0\*32,5881853   |
| 2019-06-12 12:26:44 | \!AIVDM,1,1,,A,H39wK\<P\<h586222222222222220,0\*6B,32127775 |

``` r

# display a few decoded messages

df <- read_ais(log$message)
knitr::kable(df %>% slice(1:5) %>% select(1:5))
```

| msgtype | repeat |      mmsi | partno | shipname             |
| ------: | -----: | --------: | -----: | :------------------- |
|      24 |      0 | 211658760 |      0 | RODE ZORA V. AMSTERD |
|      24 |      0 | 211658760 |      1 | NA                   |
|       1 |      0 | 265628490 |     NA | NA                   |
|       1 |      0 | 265628490 |     NA | NA                   |
|      24 |      0 | 211802930 |      0 | CLARA                |

## Development

[![Get the GitHub CLI
Badge](https://img.shields.io/badge/CLI-GitHub%20CLI%20Friendly-blue.svg)](https://hub.github.com)

The [GitHub CLI tool](https://hub.github.com) can be used for
reproducible collaboration workflows when collaborating on this (or any
other) repo, for whatever reason - such as for convenience and
automation support or perhaps because someone is handing out CLI badges
and you want one ;).

Usage example while at the CLI, if you want to add a feature branch that
provides command line support for using this R package along with usage
examples:

    $ hub clone mskyttner/vikingr
    $ cd vikingr
    
    # create a topic branch
    $ git checkout -b add-cli-support
    
    # make some changes... then ...
    
    $ git commit -m "done with feature"
    
    # It's time to fork the repo!
    $ hub fork --remote-name=origin
    → (forking repo on GitHub...)
    → git remote add origin git@github.com:YOUR_USER/vikingr.git
    
    # push the changes to your new remote
    $ git push origin feature
    
    # open a pull request for the topic branch you've just pushed
    $ hub pull-request
    → (opens a text editor for your pull request message)
