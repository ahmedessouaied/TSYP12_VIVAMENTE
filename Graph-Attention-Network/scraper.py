import os
import requests
from bs4 import BeautifulSoup
from tqdm import tqdm

BASE_URL = "https://dcapswoz.ict.usc.edu/wwwdaicwoz/"

SAVE_DIR = "./Dataset"

def fetch_file_list(base_url):
    """Fetch the list of .zip files from the given URL."""
    print("Fetching file list...")
    response = requests.get(base_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    files = [a['href'] for a in soup.find_all('a', href=True) if a['href'].endswith('.zip')]
    return files

def download_file(base_url, file_name, save_dir):
    """Download a single file with a progress bar."""
    file_url = base_url + file_name
    local_path = os.path.join(save_dir, file_name)
    
    if os.path.exists(local_path):
        print(f"{file_name} already exists. Skipping...")
        return
    
    response = requests.get(file_url, stream=True)
    total_size = int(response.headers.get('content-length', 0))
    
    print(f"Downloading {file_name}...")
    with open(local_path, "wb") as file, tqdm(
        desc=file_name,
        total=total_size,
        unit='B',
        unit_scale=True,
        unit_divisor=1024,
    ) as bar:
        for data in response.iter_content(chunk_size=1024):
            file.write(data)
            bar.update(len(data))


def download_dataset(base_url, save_dir):
    """Download all .zip files from the given URL."""
    os.makedirs(save_dir, exist_ok=True)
    file_list = fetch_file_list(base_url)
    
    print(f"Found {len(file_list)} files to download.")
    for file_name in file_list:
        download_file(base_url, file_name, save_dir)
    print("All files downloaded successfully!")


if __name__ == "__main__":
    download_dataset(BASE_URL, SAVE_DIR)