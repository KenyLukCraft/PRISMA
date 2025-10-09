# Gmail Attachment Downloader

This script downloads attachments from the latest Gmail email with a subject containing "Latest Log File".

## Prerequisites
- Python 3.7+
- A Google Cloud OAuth2 credentials file (client_secret_...json) for Gmail API access

## Setup
1. **Clone or copy this folder to your PC.**
2. **Place your Google OAuth2 credentials file** (e.g., `client_secret_686416689898-h9fgmb7kcvglupul76gipb7g7toetkci.apps.googleusercontent.com.json`) in this folder.
3. **Install dependencies:**
   ```sh
   pip install -r requirements.txt
   ```

## Usage
1. Run the script:
   ```sh
   python download_email.py
   ```
2. The first time, a browser window will open for you to log in and authorize Gmail access.
3. Attachments from the latest email with subject containing "Latest Log File" will be saved to the `gmail_attachments` folder.

## Files
- `download_email.py` — The main script
- `requirements.txt` — Python dependencies
- `client_secret_...json` — Your Google OAuth2 credentials (download from Google Cloud Console)
- `token.pickle` — Auto-generated after first login, stores your access token
- `gmail_attachments/` — Folder where attachments are saved

## Customization
- To change the subject filter, edit the `query` variable in `download_email.py`.
- To download more than one email, adjust `maxResults` in the script.

## Troubleshooting
- Make sure your credentials file is named correctly and in the same folder as the script.
- If you get authentication errors, delete `token.pickle` and re-run the script to re-authenticate.
- Ensure IMAP is enabled in your Gmail settings (for full Gmail API access).

## References
- [Gmail API Python Quickstart](https://developers.google.com/gmail/api/quickstart/python)
- [Google Cloud Console](https://console.cloud.google.com/) 