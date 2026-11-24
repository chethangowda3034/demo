# MARPOL-SAFE | Shipping Operations Demo

A Streamlit demonstration for shipboard environmental records, review workflows, evidence attachments, screening prompts, audit history, reporting, and a searchable MARPOL reference index. The application uses **MongoDB** for operational data and keeps uploaded evidence files in a local `evidence_store/` directory.

## Requirements

- Python 3.10 or newer
- A reachable MongoDB server (local MongoDB Community Server or MongoDB Atlas)
- VS Code or another Python editor

## Setup on Windows

1. Extract the ZIP and open the `MARPOL-SAFE-Shipping-Demo` folder in VS Code.
2. Open a terminal in that folder and create a virtual environment:

   ```powershell
   py -m venv .venv
   .\.venv\Scripts\python.exe -m pip install -r requirements.txt
   ```

3. Start your MongoDB server. For a local MongoDB installation, the default connection is `mongodb://localhost:27017`. For MongoDB Atlas, copy your deployment connection string.
4. Set the connection details in the same PowerShell terminal. For local MongoDB:

   ```powershell
   $env:MONGODB_URI="mongodb://localhost:27017"
   $env:MONGODB_DATABASE="marpol_safe"
   ```

   For Atlas, use your Atlas connection string as the `MONGODB_URI` value. Keep credentials private; do not commit them to GitHub.

5. Import the existing demo data from the SQLite database included with this ZIP:

   ```powershell
   .\.venv\Scripts\python.exe migrate_sqlite_to_mongodb.py
   ```

   The migration imports the `records`, `alerts`, `audit`, `attachments`, `vessel_profile`, and `library_items` tables as MongoDB collections. It preserves their existing `id` values. The importer stops rather than overwriting non-empty collections. Use `--replace` only when you deliberately want to delete and replace those six collections.

6. Start the local demo. The launcher explicitly opts in to demo accounts and binds Streamlit to loopback (`127.0.0.1`):

   ```powershell
   .\run_app.bat
   ```

   To start it manually, set `$env:APP_ENV="demo"` and `$env:ENABLE_DEMO_ACCOUNTS="true"`, then run `.\.venv\Scripts\python.exe -m streamlit run app.py --server.address 127.0.0.1`.

7. Open `http://127.0.0.1:8501`. Keep the terminal open while using the app; press **Ctrl+C** to stop it.

The application reads configuration from environment variables first, then Streamlit secrets. When neither is set, it uses the local defaults above. A blank MongoDB database is initialized with the demo vessel profile and sample data automatically. Remote MongoDB URIs require TLS; loopback MongoDB connections may use plaintext for local development.

## Demo sign-ins

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `admin123` |
| Chief Engineer | `chief` | `marpol123` |
| Officer | `officer` | `marpol123` |
| Cadet | `cadet` | `marpol123` |

These demo accounts can authenticate only when `ENABLE_DEMO_ACCOUNTS=true`, the app is not in production mode, and Streamlit binds to a loopback address. Never expose the demo configuration through a reverse proxy or public network.

For production, set `APP_ENV=production`, provide a unique `BOOTSTRAP_ADMIN_PASSWORD` (at least 8 characters) for first-time setup, and deploy behind a TLS-terminating reverse proxy. Remote MongoDB connections require TLS automatically. Do not enable demo accounts in production.

## Streamlit Community Cloud (public demo)

This deployment is suitable only for synthetic demo data, not real vessel records. The app has no anonymous or public read-only account: demo credentials are deliberately disabled on public hosts, and the bootstrap Admin password must remain private. Public visitors will see the sign-in screen unless you separately create and securely share an appropriate account.

1. Push the application source to a GitHub repository. The ignore rules exclude local databases, MongoDB files, evidence uploads, and secrets.
2. Create a dedicated MongoDB Atlas database for the demo. Use a dedicated database user with access only to that database and configure network access according to MongoDB's and Streamlit Community Cloud's current guidance.
3. In Streamlit Community Cloud, create an app from the repository's `main` branch and select `app.py`.
4. In the app's **Advanced settings → Secrets**, paste the contents of `.streamlit/secrets.toml.example` after replacing the MongoDB URI and bootstrap password. Keep the actual values in Streamlit's secret settings; never commit them.
5. Deploy. The first run initializes sample data in a blank database and creates an Admin account from `BOOTSTRAP_ADMIN_PASSWORD` when no enabled Admin exists. Keep this credential private.

Evidence file bytes are stored on the app's local filesystem and may be lost when Community Cloud restarts the app. Do not rely on that storage for durable uploads. Public deployment does not make this prototype suitable for operational or regulatory use.

## MongoDB structure

The app stores data in these collections:

- `records` — shipboard operational records and approval status.
- `alerts` — screening prompts and resolution status.
- `audit` — user actions and review history.
- `attachments` — evidence file metadata linked to records.
- `vessel_profile` — vessel identity and voyage profile.
- `library_items` — MARPOL reference summaries and company guidance.
- `counters` — atomic integer ID allocation for the app's displayed IDs.
- `login_attempts` — expiring, server-side failed-login counters shared across browser sessions.

The MongoDB collections contain operational data and attachment metadata. The evidence file bytes remain in `evidence_store/`; back up that folder together with MongoDB.
Admins can inspect the application collections in the read-only **Database Explorer** workspace. Password and token fields are redacted, and login-attempt records are excluded.

## Project files

- `app.py` — Streamlit UI and MongoDB-backed application logic.
- `migrate_sqlite_to_mongodb.py` — one-time importer for the legacy SQLite database.
- `marpol_safe.db` — local SQLite migration source; excluded from GitHub because it may contain local data. The running application does not read or write it.
- `assets/` — local SVG ship illustrations.
- `evidence_store/` — created beside the app when a user uploads evidence.
- `.env.example` — example MongoDB environment variables (copy values into your shell or deployment environment; the app does not load `.env` automatically).
- `.streamlit/secrets.toml.example` — safe template for Streamlit Community Cloud secrets; do not commit a populated `secrets.toml`.

## MARPOL Library scope

The library contains summaries of Annexes I–VI and links to IMO pages. These summaries are navigation aids, not the full legal text. Follow current IMO publications, supplements, and the vessel's approved procedures when checking requirements. The demo does not automatically synchronize amendments.

## Demonstration limitations

This is a local sales-demo prototype, not a production shipboard service or legal compliance determination. Demo GPS coordinates are simulated; alerts are review prompts; and the queue action only changes a MongoDB flag. It is not connected to vessel equipment, a company identity provider, or a shore server. User password verifiers are stored using PBKDF2; demo credentials are fixed and must remain restricted to the loopback-only demo.

Before using operational data, add managed identity, company/vessel tenancy, authorization review, secure evidence storage, backups, synchronization controls, and operational/regulatory validation. Do not expose this prototype directly to the public internet.
