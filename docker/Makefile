#! make

PWD := $(shell pwd)
UID := $(shell id -u)
GID := $(shell id -g)

all: build up

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
	rm vikingr.html ../docs/vikingr-x.html

report:
	docker exec -it -e PASSWORD=raukr -w /home/rstudio raukr \
		sudo -u rstudio R -e "v <- vignette(package = 'vikingr', topic = 'flex'); file.copy(file.path(v['Dir'], 'doc', v['PDF']), '~/vikingr.html')"

browse-report:
	firefox vikingr.html &

browse-report-x:
	firefox ../docs/vikingr-x.html &
	
encrypt-report:
	# using docker image gaow/staticrypt for the utility
	# takes the ".html" from the present working directory, use your own file
	# outputs a "-x.html" file that needs unlocking with the given password

	docker run --rm -u $(UID):$(GID) -v "$(PWD):/tmp" gaow/staticrypt \
		staticrypt /tmp/vikingr.html raukr -o /tmp/vikingr-x.html
	mv vikingr-x.html ../docs

release:
	docker login
	docker push recraft/raukr:3.6.0
