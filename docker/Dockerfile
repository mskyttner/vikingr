FROM rocker/geospatial:3.6.0

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  pdftk \
  libpoppler-cpp-dev \
  libgsl0-dev \
  libsodium-dev
  
RUN install2.r --error \
  magick \
  staplr \
  pdftools \
  printr \
  officer \
  available \
  googledrive \
  here

# vikingr installation

RUN install2.r --error \
  DT \
  flexdashboard \
  reticulate \
  rsvg

# workaround for devtools > 2.0

RUN sudo -u rstudio R -e "library(devtools);  install_github('mskyttner/vikingr', dependencies = TRUE, build = TRUE, build_opts = c('--no-resave-data', '--no-manual'))"

#RUN installGithub.r --deps TRUE \
#	mskyttner/vikingr

