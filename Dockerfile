FROM docker-prod.affinitic.be/iadelib:cache

LABEL plone=$PLONE_VERSION \
  name="E-Delib ${PM_VERSION}" \
  description="Deliberation write with Plone" \
  version="${PM_VERSION}-${BUILD_ID}" \
  maintainer="Affinitic"

COPY --chown=plone docker-initialize.py docker-entrypoint.sh /home/plone/

USER plone

COPY --chown=plone *.conf *.sh *.cfg Makefile *.py *.txt /home/plone/
COPY --chown=plone scripts /home/plone/scripts
WORKDIR /home/plone/

RUN rm -rf src/
RUN sed -i '/^    instance[0-9]/d' prod.cfg \
  && mkdir -p var/filestorage/ \
  && touch var/filestorage/Data.fs \
  && make requirements.txt \
  && pip install -r requirements.txt \
  && /home/plone/.local/bin/buildout -t 60 -Nc docker.cfg \
  && rm -rf /home/plone/.buildout/downloads/ /home/plone/.cache

USER root

USER plone
WORKDIR /home/plone/
ENV ZEO_HOST=db \
 ZEO_PORT=8100 \
 HOSTNAME_HOST=local \
 PROJECT_ID=plone

EXPOSE 8081
ENTRYPOINT ["/home/plone/docker-entrypoint.sh"]
CMD ["start"]
