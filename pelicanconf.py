#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Qian Gu'
SITENAME = u"Qian's Blog"
SITEURL = 'https://guqian110.github.io'

PATH = 'content'

TIMEZONE = 'Asia/Shanghai'
DATE_FORMATS = {'zh':'%Y-%m-%d %H:%M'}

DEFAULT_LANG = u'zh'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (('Pelican', 'http://getpelican.com/'),
         ('Python.org', 'http://python.org/'),
         ('Jinja2', 'http://jinja.pocoo.org/'))
         

# Social widget
SOCIAL = (('twitter', 'http://twitter.com/guqian110'),
          ('github', 'http://github.com/guqian110'))

DEFAULT_PAGINATION = 5

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

ARTICLE_URL = 'posts/{category}/{slug}.html'
ARTICLE_SAVE_AS = 'posts/{category}/{slug}.html'
PAGE_URL = 'pages/{slug}.html'
PAGE_SAVE_AS = 'pages/{slug}.html'

GITHUB_URL = 'https://github.com/guqian110'
GITHUB_USER = 'guqian110'
DISPLAY_TAGS_INLINE = True
# DISPLAY_ARCHIVE_ON_SIDEBAR = True
# YEAR_ARCHIVE_SAVE_AS = 'archive/{date:%Y}_index.html'
# MONTH_ARCHIVE_SAVE_AS = 'archive/{date:%Y}/{date:%m}_index.html'
DIRECT_TEMPLATES = {'index', 'categories', 'authors', 'archives', 'search'}
###################### bootstrap3 cfg ###########################
THEME = '../pelican-themes/pelican-bootstrap3'
JINJA_ENVIRONMENT = {'extensions': ['jinja2.ext.i18n']}
PLUGIN_PATHS = ['../pelican-plugins']
PLUGINS = ['i18n_subsites', 'tag_cloud', 'related_posts', 'series', 'tipue_search', 'liquid_tags', 'sitemap', ]
SHOW_ARTICLE_AUTHOR = True
SHOW_ARTICLE_CATEORY = True
SHOW_DATE_MODIFIED = True
PYGEMNTS_STYLE = 'monokai'
SITELOGO = 'images/logo.png'
FAVICON = 'images/favicon.png'
SITELOGO_SIZE = 32
DISPLAY_BREADCRUMBS = True
DISPLAY_CATEGORY_IN_BREADCRUMBS = True
DISPLAY_ARTICLE_INFO_ON_INDEX = True
DISPLAY_ARCHIVES_IN_BREADCRUMBS = True
TAG_CLOUD_MAX_ITEMs = 20
CC_LICENSE = 'CC-BY-NC'
ABOUT_ME = 'Icer + BYR'
AVATAR = 'images/logo.png'
###################### bootstrap3 cfg ###########################
DISQUS_DISPLAY_COUNTS = True
DISQUS_ID_PREFIX_SLUG = True
DISQUS_SITENAME = 'guqian110'

SITEMAP = {
    "format": "xml",
    "priorities": {
        "articles": 0.7,
        "indexes": 0.5,
        "pages": 0.3,
    },
    "changefreqs": {
        "articles": "monthly",
        "indexes": "daily",
        "pages": "monthly",
    }
}

DISPLAY_PAGES_ON_MENU = True
