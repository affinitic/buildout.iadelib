.PHONY: buildout

requirements.txt:
	wget https://raw.githubusercontent.com/IMIO/buildout.pm/4.1.5/requirements.txt

bin/buildout: requirements.txt
	virtualenv-2.7 .
	bin/pip install -r requirements.txt

buildout: bin/buildout
	bin/buildout -N

cleanall:  ## Clears build artefacts
	rm -fr lib bin develop-eggs downloads eggs parts .installed.cfg include
