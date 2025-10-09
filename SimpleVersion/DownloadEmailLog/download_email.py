import os
import base64
import re
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import pickle

# --- CONFIGURATION ---
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']
CREDENTIALS_FILE = r'C:\Users\Keny\PycharmProjects\OnelinePowerShell\SimpleVersion\client_secret_686416689898-h9fgmb7kcvglupul76gipb7g7toetkci.apps.googleusercontent.com.json'
TOKEN_FILE = 'token.pickle'
SAVE_FOLDER = r'C:\Users\Keny\PycharmProjects\OnelinePowerShell\gmail_attachments'

if not os.path.exists(SAVE_FOLDER):
    os.makedirs(SAVE_FOLDER)

def authenticate_gmail():
    creds = None
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE, 'rb') as token:
            creds = pickle.load(token)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_FILE, SCOPES)
            creds = flow.run_local_server(port=0)
        with open(TOKEN_FILE, 'wb') as token:
            pickle.dump(creds, token)
    return build('gmail', 'v1', credentials=creds)

def get_latest_message(service, user_id='me'):
    # Search for emails with subject containing "Latest Log File" and having attachments
    query = 'subject:"Latest Log File" has:attachment'
    results = service.users().messages().list(userId=user_id, maxResults=1, q=query).execute()
    messages = results.get('messages', [])
    if not messages:
        print('No messages found with subject containing \"Latest Log File\".')
        return None
    msg_id = messages[0]['id']
    return service.users().messages().get(userId=user_id, id=msg_id).execute()

def save_attachments(msg, service, user_id='me'):
    for part in msg['payload'].get('parts', []):
        filename = part.get('filename')
        body = part.get('body', {})
        if filename and 'attachmentId' in body:
            att_id = body['attachmentId']
            att = service.users().messages().attachments().get(userId=user_id, messageId=msg['id'], id=att_id).execute()
            data = att['data']
            file_data = base64.urlsafe_b64decode(data.encode('UTF-8'))
            filepath = os.path.join(SAVE_FOLDER, filename)
            with open(filepath, 'wb') as f:
                f.write(file_data)
            print(f"Saved: {filename}")

def main():
    service = authenticate_gmail()
    msg = get_latest_message(service)
    if msg:
        save_attachments(msg, service)
        print(f"Done. Attachments saved to {SAVE_FOLDER}")

if __name__ == '__main__':
    main()