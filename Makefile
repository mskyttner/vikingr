#! make

PWD := $(shell pwd)
UID := $(id -u)
GID := $(id -g)

all: build up report browse-report clean

build:
	# uses rocker/geospatial:3.6.0 but extends it with 
	# system libraries pdftk, libpoppler-cpp-dev etc
	# and R packages staplr, magick, pdftools, officer etc
	docker build -t recraft/raukr:3.6.0 .
	
up:
	docker run --name raukr -u $(UID):$(GID) \
		-d -p 8787:8787 -e PASSWORD=raukr \
		-v "$(PWD):/home/rstudio" recraft/raukr:3.6.0
	echo "Use rstudio/raukr to login!"; sleep 3;
	firefox localhost:8787 &
	
clean: clean-docker clean-report

clean-docker:
	docker stop raukr
	docker rm raukr
	
clean-report:
	rm topten.html docs/topten-x.html

report:
	docker exec -it -e PASSWORD=raukr -w /home/rstudio raukr \
		sudo -u rstudio R -e "library(rmarkdown); render('topten.R')"

browse-report:
	firefox topten.html &

browse-report-x:
	firefox docs/topten-x.html &
	
encrypt-report:
	# using docker image gaow/staticrypt for the utility
	# takes the ".html" from the present working directory, use your own file
	# outputs a "-x.html" file that needs unlocking with the given password

	docker run --rm -u $(UID):$(GID) -v "$(PWD):/tmp" gaow/staticrypt \
		staticrypt /tmp/topten.html raukr -o /tmp/topten-x.html
	sudo chown 1000:1000 topten-x.html # permissions issue
	mv topten-x.html docs

release:
	docker login
	docker push recraft/raukr:3.6.0