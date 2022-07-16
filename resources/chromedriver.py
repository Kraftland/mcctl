#!/usr/bin/python3
#import cfscrape
#import requests
import sys
import os
url = sys.argv[1]
path = os.system('pwd')
import undetected_chromedriver as uc
import time
#scraper = cfscrape.create_scraper()
#requestExe = scraper.get(url)
#with open(name, "wb") as name:
#    name.write(requestExe.content)
download_dir = path
chrome_options = uc.ChromeOptions()
chrome_options.add_experimental_option("prefs", {
  "download.default_directory": download_dir,
  "download.prompt_for_download": False,
  "safebrowsing.enabled": True,

})
chrome_options.add_argument("--safebrowsing-manual-download-blacklist=8aac55848d1aadf4b361430276886ca6f9364c31eaf1542611afd78a30fd9dc1");
#chrome_options.add_argument("--headless");
#chrome_options.add_argument("--disable-gpu");
#chrome_options.headless = True
wdriver = uc.Chrome(options=chrome_options)

wdriver.get(url)
time.sleep(25)
#wdriver.find_element_by_link_text(text).click()
#wdriver.find_element("link text", text).click()

