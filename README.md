
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vikingr

<!-- badges: start -->

<!-- badges: end -->

The goal of `vikingr` - [name
etymology](https://en.wikipedia.org/wiki/Vikings#Etymology) - is to
provide a way to decode and work with data provided in the [AIS
format](https://gpsd.gitlab.io/gpsd/AIVDM.html) from within R. Or rather
the primary goal is to use some of the techniques taught at the Raukr
2019 workshop when creating an R package.

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

# or if devtools is > 2.0
devtools::install_github("mskyttner/vikingr", dependencies = TRUE,
  build = TRUE, build_opts = c("--no-resave-data", "--no-manual"))
```

## Example

This is a basic example which shows typical usage:

``` r

suppressPackageStartupMessages(library(dplyr))
library(knitr)
library(vikingr)

# get a few of the encoded messages

log <- read_ais_log(vikingr_example("vikingr-visby-2019-ais"))

# display some encoded messages, but ...
# escape the message which otherwise can appear
# garbled when displayed in the markdown

log_escaped <- 
  log %>% 
  slice(2:5) %>% 
  mutate(message = sprintf("<code>%s</code>", message))

kable(escape = FALSE, log_escaped)
```

| timestamp           | message                                                                  |
| :------------------ | :----------------------------------------------------------------------- |
| 2019-06-12 12:15:48 | <code>\!AIVDM,1,1,,A,H39n\`<24TC=D744;49@Ej001P0030>,0\*0E,632874</code> |
| 2019-06-12 12:16:06 | <code>\!AIVDM,1,1,,B,13uDcBPOh01CcmBPvc\`eLnBB0D0?,0\*57,1476282</code>  |
| 2019-06-12 12:17:38 | <code>\!AIVDM,1,1,,A,13uDcBP0001CcmNPvcWePnEB08GU,0\*32,5881853</code>   |
| 2019-06-12 12:26:44 | <code>\!AIVDM,1,1,,A,H39wK\<P\<h586222222222222220,0\*6B,32127775</code> |

``` r

# decode messages and add timestamps from the log

parsed_messages <- read_ais(log$message)
#> Warning in read_ais(log$message): 910 parsing failure(s) for a total of
#> 10913 messages. Use readr::problems() for details.

df <-
  parsed_messages %>% 
  left_join(log) %>% 
  select(timestamp, everything())
#> Joining, by = "message"

# display a few decoded messages, escaping the raw message

df_escaped <- 
  df %>% 
  slice(1:5) %>% 
  select(1:5) %>%
  mutate(message = sprintf("<code>%s</code>", message))

kable(df_escaped, escape = FALSE)
```

| timestamp           | message                                                                  | msgtype | repeat |      mmsi |
| :------------------ | :----------------------------------------------------------------------- | ------: | -----: | --------: |
| 2019-06-12 12:15:38 | <code>\!AIVDM,1,1,,A,H39n`218t@F1`<u861Jr04m=@E8>@,0\*29,142656</code>   |      24 |      0 | 211658760 |
| 2019-06-12 12:15:48 | <code>\!AIVDM,1,1,,A,H39n\`<24TC=D744;49@Ej001P0030>,0\*0E,632874</code> |      24 |      0 | 211658760 |
| 2019-06-12 12:16:06 | <code>\!AIVDM,1,1,,B,13uDcBPOh01CcmBPvc\`eLnBB0D0?,0\*57,1476282</code>  |       1 |      0 | 265628490 |
| 2019-06-12 12:17:38 | <code>\!AIVDM,1,1,,A,13uDcBP0001CcmNPvcWePnEB08GU,0\*32,5881853</code>   |       1 |      0 | 265628490 |
| 2019-06-12 12:26:44 | <code>\!AIVDM,1,1,,A,H39wK\<P\<h586222222222222220,0\*6B,32127775</code> |      24 |      0 | 211802930 |

``` r

# display a few of the parsing issues with readr::problems()

library(readr)

parsing_issues <- 
  problems(parsed_messages) %>% 
  slice(1:5) %>% 
  mutate(actual = sprintf("<code>%s</code>", actual))

kable(parsing_issues, escape = FALSE)
```

| row | col     | expected              | actual                                                                                                  |
| --: | :------ | :-------------------- | :------------------------------------------------------------------------------------------------------ |
|  63 | message | ais.py-compliant data | <code>\!AIVDM,2,1,4,B,53u=au000001\<M0f2210ThuB3O?N1\<F22222220j0000040Ht3l2C3m0,0\*02,355629407</code> |
|  64 | message | ais.py-compliant data | <code>\!AIVDM,2,2,4,B,ShE85R1\`0j8\<L80,2\*79,355629407</code>                                          |
| 118 | message | ais.py-compliant data | <code>\!AIVDM,2,1,2,A,53uDcBP00003M\<7;C7A8E\<=DF1HUA=@\`58p6220k104225hj82ERDhVH,0\*19,2314900</code>  |
| 119 | message | ais.py-compliant data | <code>\!AIVDM,2,2,2,A,888888888888880,2\*26,2314900</code>                                              |
| 150 | message | ais.py-compliant data | <code>\!AIVDM,2,1,2,B,53uDcBP00003M\<7;C7A8E\<=DF1HUA=@\`58p6220k104225hj82ERDhVH,0\*1A,19614642</code> |

Inspect a single record:

``` r
# these are the details for a single record
record <- 
  df %>% slice(1) %>% t() %>% as.vector() %>% tibble() %>% 
  mutate(field = names(df)) %>% 
  select(field, value = 1)

kable(record)
```

| field        | value                                                     |
| :----------- | :-------------------------------------------------------- |
| timestamp    | 2019-06-12 12:15:38                                       |
| message      | \!AIVDM,1,1,,A,H39n`218t@F1`<u861Jr04m=@E8>@,0\*29,142656 |
| msgtype      | 24                                                        |
| repeat       | 0                                                         |
| mmsi         | 211658760                                                 |
| partno       | 0                                                         |
| shipname     | RODE ZORA V. AMSTERD                                      |
| shiptype     | NA                                                        |
| vendorid     | NA                                                        |
| callsign     | NA                                                        |
| to\_bow      | NA                                                        |
| to\_stern    | NA                                                        |
| to\_port     | NA                                                        |
| to\_starbord | NA                                                        |
| status       | NA                                                        |
| turn         | NA                                                        |
| speed        | NA                                                        |
| accuracy     | NA                                                        |
| lon          | NA                                                        |
| lat          | NA                                                        |
| course       | NA                                                        |
| heading      | NA                                                        |
| second       | NA                                                        |
| maneuver     | NA                                                        |
| raim         | NA                                                        |
| radio        | NA                                                        |
| reserved     | NA                                                        |
| regional     | NA                                                        |
| cs           | NA                                                        |
| display      | NA                                                        |
| dsc          | NA                                                        |
| band         | NA                                                        |
| msg22        | NA                                                        |
| assigned     | NA                                                        |
| is\_error    | NA                                                        |

## Improvements

Parsed data for individual records can be checked against results from
other parsers or web services that can parse AIS messages. Improvements
can be sent as a PR, for details see instructions below.

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
    $ git push origin add-cli-support
    
    # open a pull request for the topic branch you've just pushed
    $ hub pull-request
    → (opens a text editor for your pull request message)
