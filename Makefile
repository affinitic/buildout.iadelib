
cfg:=buildout.cfg


requirements.txt:
	wget https://raw.githubusercontent.com/IMIO/buildout.pm/4.1.28/requirements.txt

bin/buildout: requirements.txt
	virtualenv-2.7 -p python2.7 .
	bin/pip install -r requirements.txt

.PHONY: buildout
buildout: bin/buildout
	bin/buildout -t 60 -Nc $(cfg)

.PHONY: cleanall
cleanall:  ## Clears build artefacts
	rm -fr lib bin develop-eggs downloads eggs parts .installed.cfg include

.PHONY: pull-image
pull-image:
	docker pull docker-prod.affinitic.be/iadelib:latest
