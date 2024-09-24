import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time
import re
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/scrape', methods=['POST'])
def scrape_blog_text():
    url = request.json['url']
    try:
        # Step 1: Try scraping with requests and BeautifulSoup
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        content = extract_content(response.text)
        
        if content:
            return jsonify({'text': clean_text(content)})
        else:
            # Fall back to Selenium if content not found
            return jsonify({'text': scrape_with_selenium(url)})
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the URL: {e}")
        return jsonify({'error': str(e)}), 2500

def extract_content(html):
    soup = BeautifulSoup(html, 'html.parser')
    # Try multiple selectors to find the main content
    selectors = [
        'article', 'main', 
        'div.blog-content', 'div.post-content', 
        'div.entry-content', 'div.content'
    ]
    for selector in selectors:
        content = soup.select_one(selector)
        if content:
            return content.get_text(separator='\n', strip=True)
    return None

def clean_text(raw_text):
    # Remove extra whitespace and newlines
    clean = re.sub(r'\s+', ' ', raw_text).strip()
    # Remove common boilerplate text
    clean = re.sub(r'(Related Articles:|Share this:|Comments|Leave a Reply)', '', clean)
    # Split into paragraphs
    paragraphs = [p.strip() for p in clean.split('\n') if p.strip()]
    return '\n\n'.join(paragraphs)

def scrape_with_selenium(url, timeout=20):
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    
    try:
        driver.get(url)
        # Wait for the content to load
        WebDriverWait(driver, timeout).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )
        # Scroll to load lazy content
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)  # Wait for any lazy-loaded content
        
        page_source = driver.page_source
        content = extract_content(page_source)
        return clean_text(content) if content else None
    finally:
        driver.quit()

if __name__ == "__main__":
    app.run(debug=True)
