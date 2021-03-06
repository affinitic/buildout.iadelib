FROM docker-prod.affinitic.be/iadelib:cache

LABEL plone=$PLONE_VERSION \
  name="PM 4.1" \
  description="PloneMeeting 4.1" \
  version="4.1" \
  maintainer="Affinitic"

COPY --chown=plone docker-initialize.py docker-entrypoint.sh /

USER plone

COPY --chown=plone *.conf *.sh *.cfg Makefile *.py *.txt /home/plone/plone-pm/
WORKDIR /home/plone/plone-pm

RUN rm -rf src/
RUN sed -i '/^    instance[0-9]/d' prod.cfg \
  && mkdir -p var/filestorage/ \
  && touch var/filestorage/Data.fs \
  && make buildout cfg=docker.cfg

USER root
RUN apt-get purge -y \
   build-essential \
   libpq-dev \
   libreadline-dev \
   wget \
   git \
   subversion \
   libpcre3-dev \
   libssl-dev \
   libxml2-dev \
   libxslt1-dev \
   libbz2-dev \
   libffi-dev \
   libjpeg62-dev \
   libopenjp2-7-dev \
   libldap2-dev \
   zlib1g-dev \
   python-dev \
   python-pip \
   virtualenv

RUN apt-get autoremove -y \
  && apt-get clean autoclean \
  && rm -rf /home/plone/.buildout/downloads/ /var/lib/apt/lists/* /tmp/* /var/tmp/* /home/plone/.cache /home/plone/.local

# ---------
# MS CORE FONTS
# ---------
# from http://askubuntu.com/a/25614
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
RUN apt-get install -y --no-install-recommends fontconfig ttf-mscorefonts-installer
ADD localfonts.conf /etc/fonts/local.conf
RUN fc-cache -f -v


USER plone
WORKDIR /home/plone/plone-pm
ENV ZEO_HOST=db \
 ZEO_PORT=8100 \
 HOSTNAME_HOST=local \
 PROJECT_ID=plone

EXPOSE 8081
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
