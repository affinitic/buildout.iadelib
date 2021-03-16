# -*- coding: utf-8 -*-

from Zope2.App import startup
from plone import api
from transaction import commit
from zope.component.hooks import setSite

import argparse


def remove_contents():
    meeting_configs = api.content.find(portal_type="MeetingConfig")
    for meeting_config in meeting_configs:
        config = meeting_config.getObject()

        annexs = api.content.find(portal_type="annex")
        for annex in annexs:
            delete_element(annex.getObject())

        annex_decisions = api.content.find(portal_type="annexDecision")
        for annex_decision in annex_decisions:
            delete_element(annex_decision.getObject())

        meeting_item_name = "MeetingItem{0}".format(config.shortName)
        meeting_items = api.content.find(portal_type=meeting_item_name)
        for meeting_item in meeting_items:
            delete_element(meeting_item.getObject())

        meeting_name = "Meeting{0}".format(config.shortName)
        meetings = api.content.find(portal_type=meeting_name)
        for meeting in meetings:
            delete_element(meeting.getObject())


def delete_element(obj):
    api.content.delete(obj, check_linkintegrity=False)


def main(app):
    startup.startup()

    parser = argparse.ArgumentParser()
    parser.add_argument("-c", help="Path to the script that are given by instance")
    parser.add_argument("--name", help="Name of plone site", default="Plone")
    args = parser.parse_args()

    setSite(app[args.name])
    with api.env.adopt_user(username="admin"):
        remove_contents()
    commit()


# If this script lives in your source tree, then we need to use this trick so that
# five.grok, which scans all modules, does not try to execute the script while
# modules are being loaded on the start-up
if "app" in locals():
    main(app)  # NOQA
