
import pandas as pd 
company  = [
'google.com',
'facebook.com',
'youtube.com',
'baidu.com',
'ucnews.in',
'wikipedia.org',
'twitter.com',
'xvideos.com',
'instagram.com',
'pornhub.com',
'xnxx.com',
'yahoo.co.jp',
'google.com.br',
'yandex.ru',
'yahoo.com',
'bit.ly',
'naver.com',
'youtu.be',
'amazon.com',
'xhamster.com',
'worldometers.info',
'globo.com',
'ucweb.com',
'smt.docomo.ne.jp',
'zoom.us',
'taboola.com',
'live.com',
'qq.com',
'samsung.com',
'cnn.com',
'vk.com',
'pinterest.com',
'outbrain.com',
'uol.com.br',
'reddit.com',
'msn.com',
'news.yahoo.co.jp',
'ebay.com',
'accuweather.com',
'rakuten.co.jp',
'whatsapp.com',
'bbc.com',
'mail.ru',
'bbc.co.uk',
'bing.com',
'fandom.com',
'ok.ru',
'office.com',
'weather.com',
'irs.gov',
'bongacams.com',
'tiktok.com',
'quora.com',
'auone.jp',
'daum.net',
'youporn.com',
'taobao.com',
'amazon.co.jp',
'walmart.com',
'sohu.com',
'imdb.com',
'line.me',
'fc2.com',
'covid19india.org',
'sogou.com',
'theguardian.com',
'wordpress.com',
'paypal.com',
'livejasmin.com',
'foxnews.com',
'tribunnews.com',
'cookpad.com',
'google.de',
'zhihu.com',
'craigslist.org',
'redtube.com',
'amazon.de',
'duckduckgo.com',
'anybunny.tv',
'twitch.tv',
'news.google.com',
'dailymail.co.uk',
'ameblo.jp',
'pornhubpremium.com',
'nytimes.com',
'archiveofourown.org',
'cgtn.com',
'chaturbate.com',
'livedoor.jp',
'microsoftonline.com',
'google.co.in',
'goo.ne.jp',
'nbryb.com',
'linkedin.com',
'netflix.com',
'news.naver.com',
'tsyndicate.com',
'hurriyet.com.tr',
'syosetu.com',
'apple.com'
]

pd.DataFrame(company).to_csv("file.csv",index=False)