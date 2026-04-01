# Add a vim comment to automatically disable ale.
# vim: ALEDisable
config.load_autoconfig(False)
c.content.blocking.method = 'both'
c.session.lazy_restore = True

c.editor.command = ['foot', 'vim', '-f', "{file}", '-c', 'set spell']
c.fileselect.single_file.command = ['foot', 'yazi', '--chooser-file', '{}']
c.fileselect.folder.command = ['foot', 'yazi', '--cwd-file', '{}']
c.fileselect.multiple_files.command = ['foot', 'yazi', '--chooser-file', '{}']
c.fileselect.handler = 'external'

c.url.searchengines['d'] = 'https://en.wiktionary.org/wiki/Special:Search?search={}'
c.url.searchengines['g'] = 'https://encrypted.google.com/search?q={}'
c.url.searchengines['l'] = 'https://google.com/search?q={}&btnI'
c.url.searchengines['w'] = 'https://en.wikipedia.org/wiki/Special:Search/{}'
c.url.searchengines['yt'] = 'https://youtube.com/results?search_query={}'

config.bind('e', 'cmd-set-text -s :open')
config.bind('E', 'cmd-set-text -s :open --tab --related')
config.bind('<Ctrl-l>',
    'config-cycle -t scrolling.bar never always ;; '
    'config-cycle -t tabs.show never always ;; '
    'config-cycle -t statusbar.show in-mode always'
)
