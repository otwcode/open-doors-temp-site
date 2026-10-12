import os
import argparse

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload


def get_service():
    # If modifying these scopes, delete the file token.json.
    SCOPES = ["https://www.googleapis.com/auth/drive.file", "https://www.googleapis.com/auth/drive.metadata.readonly"]

    token_path = os.path.join(os.getcwd(), "token.json")
    cred_path = os.path.join(os.getcwd(), "credentials.json")

    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists(token_path):
        creds = Credentials.from_authorized_user_file(token_path, SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                cred_path, SCOPES
            )
            creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open(token_path, "w") as token:
        token.write(creds.to_json())

    service = build("drive", "v3", credentials=creds)
    return service


def upload_file(drive_service, filename, mimetype, metadata, resumable=True, chunksize=1048576):
    media = MediaFileUpload(filename, mimetype=mimetype, resumable=resumable, chunksize=chunksize)
    request = drive_service.files().create(body=metadata, media_body=media).execute()
    filesize = os.stat(filename).st_size
    if filesize > chunksize:
        response = None
        while response is None:
            if hasattr(request, "next_chunk"):
                next_chunk = getattr(request, "next_chunk")
                if callable(next_chunk):
                    chunk = request.next_chunk()
                    if chunk:
                        status, response = chunk
                        if status:
                            print("Uploaded %d%%." % int(status.progress() * 100))
                else:
                    break
            else:
                break
    print("Upload Complete!")


if __name__ == "__main__":
    argdict = {
        "filename": "Path of zip file on local computer",
        "parent": "Google Drive folder ID"
    }
    parser = argparse.ArgumentParser(description="Upload temp site zip to google drive")
    for name, helptext in argdict.items():
        parser.add_argument(
            "-d" + name, "--" + name, type=str, help=helptext, required=True
        )

    args = parser.parse_args()
    filename = os.path.basename(args.filename)

    metadata = {
        "name": filename,
        "parents": [args.parent]
    }
    upload_file(get_service(), filename, 'application/zip', metadata)