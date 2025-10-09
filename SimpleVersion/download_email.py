import os
import base64
import pickle
from datetime import datetime
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

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

def debug_search(service, user_id='me'):
    """Debug function to test different search queries"""
    print("=== DEBUGGING EMAIL SEARCH ===")
    
    # Test 1: Get any recent emails (no filter)
    print("\n1. Testing: Any recent emails (no filter)")
    try:
        results = service.users().messages().list(userId=user_id, maxResults=5).execute()
        messages = results.get('messages', [])
        print(f"Found {len(messages)} recent messages")
        
        for i, msg in enumerate(messages[:3]):
            full_msg = service.users().messages().get(userId=user_id, id=msg['id'], format='full').execute()
            headers = full_msg['payload'].get('headers', [])
            subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), 'No Subject')
            print(f"  {i+1}. Subject: {subject}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 2: Search for "Latest Log File" (case sensitive)
    print("\n2. Testing: subject:'Latest Log File' (exact match)")
    try:
        results = service.users().messages().list(userId=user_id, maxResults=10, q='subject:"Latest Log File"').execute()
        messages = results.get('messages', [])
        print(f"Found {len(messages)} messages with exact subject")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 3: Search for "latest" (case insensitive)
    print("\n3. Testing: subject contains 'latest' (case insensitive)")
    try:
        results = service.users().messages().list(userId=user_id, maxResults=10, q='subject:latest').execute()
        messages = results.get('messages', [])
        print(f"Found {len(messages)} messages with 'latest' in subject")
        
        for i, msg in enumerate(messages[:3]):
            full_msg = service.users().messages().get(userId=user_id, id=msg['id'], format='full').execute()
            headers = full_msg['payload'].get('headers', [])
            subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), 'No Subject')
            print(f"  {i+1}. Subject: {subject}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 4: Search for "log" 
    print("\n4. Testing: subject contains 'log'")
    try:
        results = service.users().messages().list(userId=user_id, maxResults=10, q='subject:log').execute()
        messages = results.get('messages', [])
        print(f"Found {len(messages)} messages with 'log' in subject")
        
        for i, msg in enumerate(messages[:3]):
            full_msg = service.users().messages().get(userId=user_id, id=msg['id'], format='full').execute()
            headers = full_msg['payload'].get('headers', [])
            subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), 'No Subject')
            print(f"  {i+1}. Subject: {subject}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 5: Search for emails with attachments
    print("\n5. Testing: emails with attachments")
    try:
        results = service.users().messages().list(userId=user_id, maxResults=10, q='has:attachment').execute()
        messages = results.get('messages', [])
        print(f"Found {len(messages)} messages with attachments")
        
        for i, msg in enumerate(messages[:3]):
            full_msg = service.users().messages().get(userId=user_id, id=msg['id'], format='full').execute()
            headers = full_msg['payload'].get('headers', [])
            subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), 'No Subject')
            print(f"  {i+1}. Subject: {subject}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n=== END DEBUGGING ===\n")

def get_latest_messages(service, user_id='me', num_messages=10):
    # First run debug to see what's available
    debug_search(service, user_id)
    
    # Try multiple search patterns
    search_patterns = [
        'subject:"Latest Log File" has:attachment',  # Original exact match
        'subject:"Latest Log Files" has:attachment',  # Plural version
        'subject:latest subject:log has:attachment',  # Contains both words
        'subject:log has:attachment',                 # Just log files with attachments
        'has:attachment'                              # Any emails with attachments
    ]
    
    for pattern in search_patterns:
        print(f"Trying search pattern: {pattern}")
        
        results = service.users().messages().list(userId=user_id, maxResults=50, q=pattern).execute()
        messages = results.get('messages', [])
        
        if messages:
            print(f"SUCCESS! Found {len(messages)} messages with pattern: {pattern}")
            break
        else:
            print(f"No messages found with pattern: {pattern}")
    
    if not messages:
        print('No messages found with any search pattern.')
        return []
    
    print(f"Found {len(messages)} matching messages. Fetching details...")
    
    # Fetch full message objects with date
    full_messages = []
    for i, msg in enumerate(messages):
        msg_id = msg['id']
        print(f"Fetching message {i+1}/{len(messages)}: {msg_id}")
        
        full_msg = service.users().messages().get(userId=user_id, id=msg_id, format='full').execute()
        
        # Get the subject and date for debugging
        headers = full_msg['payload'].get('headers', [])
        subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), 'No Subject')
        date_header = next((h['value'] for h in headers if h['name'].lower() == 'date'), 'No Date')
        
        # Add internalDate as integer for sorting
        internal_date = int(full_msg.get('internalDate', '0'))
        full_msg['internalDateInt'] = internal_date
        
        # Convert to readable date for debugging
        readable_date = datetime.fromtimestamp(internal_date / 1000).strftime('%Y-%m-%d %H:%M:%S')
        
        print(f"  Subject: {subject}")
        print(f"  Date: {readable_date}")
        print(f"  Internal Date: {internal_date}")
        
        full_messages.append(full_msg)
    
    # Sort by internalDate descending (latest first)
    print("\nSorting messages by date (latest first)...")
    full_messages.sort(key=lambda m: m['internalDateInt'], reverse=True)
    
    # Show sorted order
    print("Sorted messages:")
    for i, msg in enumerate(full_messages[:num_messages]):
        headers = msg['payload'].get('headers', [])
        subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), 'No Subject')
        readable_date = datetime.fromtimestamp(msg['internalDateInt'] / 1000).strftime('%Y-%m-%d %H:%M:%S')
        print(f"  {i+1}. {subject} - {readable_date}")
    
    # Return the top N
    return full_messages[:num_messages]

def save_attachments(msg, service, user_id='me'):
    print(f"\nProcessing message: {msg['id']}")
    
    # Get subject for debugging
    headers = msg['payload'].get('headers', [])
    subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), 'No Subject')
    print(f"Subject: {subject}")
    
    attachments_found = 0
    
    def process_part(part):
        nonlocal attachments_found
        filename = part.get('filename', '')
        body = part.get('body', {})
        
        if filename and 'attachmentId' in body:
            print(f"  Found attachment: {filename}")
            att_id = body['attachmentId']
            att = service.users().messages().attachments().get(userId=user_id, messageId=msg['id'], id=att_id).execute()
            data = att['data']
            file_data = base64.urlsafe_b64decode(data.encode('UTF-8'))
            filepath = os.path.join(SAVE_FOLDER, filename)
            with open(filepath, 'wb') as f:
                f.write(file_data)
            print(f"  Saved: {filename}")
            attachments_found += 1
        
        # Process nested parts
        if 'parts' in part:
            for subpart in part['parts']:
                process_part(subpart)
    
    # Process all parts of the message
    payload = msg.get('payload', {})
    if 'parts' in payload:
        for part in payload['parts']:
            process_part(part)
    else:
        # Single part message
        process_part(payload)
    
    if attachments_found == 0:
        print("  No attachments found in this message")
    else:
        print(f"  Total attachments saved: {attachments_found}")

def main():
    print("Starting Gmail attachment downloader...")
    service = authenticate_gmail()
    print("Authentication successful!")
    
    messages = get_latest_messages(service, num_messages=2)  # Get latest 2 emails
    if messages:
        print(f"\nProcessing {len(messages)} messages...")
        for msg in messages:
            save_attachments(msg, service)
        print(f"\nDone. Attachments saved to {SAVE_FOLDER}")
    else:
        print("No matching messages found.")

if __name__ == '__main__':
    main()