# Briq ERP – Docker Odoo Setup (How to Use)

This document describes the **exact flow** for setting up and running a client-based Odoo environment using Docker.

Follow the steps **in order**.

---

## 1️⃣ Create the `.env` File

This repository includes only:

```
.env.sample
```

You must **manually create** the `.env` file.

### Steps

1. Copy `.env.sample`
2. Paste it in the same directory
3. Rename it to:

```
.env
```

Do **not** commit `.env` to Git (especially in production).

---

## 2️⃣ Create the `data` Folder Structure

In the project root, manually create the following folders:

```
data/
├── clients/
├── briq_var_lib/
└── postgres_db/
```

### Purpose of Each Folder

| Folder          | Purpose                          |
| --------------- | -------------------------------- |
| `clients/`      | Custom Odoo modules per client   |
| `briq_var_lib/` | Odoo filestore (stored locally)  |
| `postgres_db/`  | PostgreSQL data (stored locally) |

---

## 3️⃣ Configure `.env` Variables

Edit the `.env` file and set **only relative paths inside `data/`**.

```env
BRIQ_SRC=./data/clients
BRIQ_VAR_LIB=./data/briq_var_lib
POSTGRES_DATA=./data/postgres_db
```

⚠️ Rules:

* Do NOT use system root paths
* Do NOT rename variables
* Make sure all folders exist

---

## 4️⃣ Set Up Client Modules Structure

Inside the `data/clients` folder, create a folder **per client**.

### Example

```
data/
└── clients/
    └── client_a/
        ├── briq_erp/
        └── client_modules/
```

### What Goes Inside

* **`briq_erp/`**

  * Clone the official Briq ERP repository here
  * Example:

    ```bash
    git clone https://github.com/briq-global/erp.git briq_erp
    ```

* **`client_modules/`**

  * Client-specific Odoo modules

Each folder represents an Odoo addons path.

---

## 5️⃣ Create a Client-Specific Docker Compose File

Copy the base compose file:

```
docker-compose.yml
```

Rename it using the client name:

```
docker-compose-client_a.yml
```

---

## 6️⃣ Update Volumes in Client Compose File

Edit `docker-compose-client_a.yml` and update the Odoo service volumes:

```yaml
volumes:
  - ./odoo.conf:/etc/odoo/odoo.conf
  - ./data/odoo/addons:/mnt/extra-addons
  - ${BRIQ_VAR_LIB}:/var/lib/odoo
  - ${BRIQ_SRC}/client_a/briq_erp:/mnt/briq_erp
  - ${BRIQ_SRC}/client_a/client_modules:/mnt/client_modules
```

### Explanation

| Mount                 | Purpose                 |
| --------------------- | ----------------------- |
| `/mnt/briq_erp`       | Core Briq ERP modules   |
| `/mnt/client_modules` | Client-specific modules |

These folders behave like **standard Odoo addons paths**.

---

## 7️⃣ Run Docker for the Client

Start the containers using the client-specific compose file:

```bash
docker compose -f docker-compose-client_a.yml up -d
```

Docker will:

* Build the Odoo image
* Start PostgreSQL
* Mount client modules
* Initialize Odoo

⏳ Wait for the build to complete.

---

## 8️⃣ Access Odoo

Open your browser:

```
http://localhost:18088
```

Create or log in to the Odoo database.

9️⃣ Backup and Restore Docker Volumes

It is highly recommended to regularly backup your Odoo and PostgreSQL volumes to prevent data loss.

A. Backup Volumes

Run the following commands from your project root:

# Backup Odoo filestore
docker run --rm -v ${BRIQ_VAR_LIB}:/data -v $(pwd):/backup alpine \
    tar czf /backup/odoo_filestore_backup.tar.gz -C /data .

# Backup PostgreSQL data
docker run --rm -v ${POSTGRES_DATA}:/data -v $(pwd):/backup alpine \
    tar czf /backup/postgres_backup.tar.gz -C /data .


Creates compressed .tar.gz files in your project root.

Store backups safely outside Docker.

B. Restore Volumes

To restore from a backup:

# Restore Odoo filestore
docker run --rm -v ${BRIQ_VAR_LIB}:/data -v $(pwd):/backup alpine \
    tar xzf /backup/odoo_filestore_backup.tar.gz -C /data

# Restore PostgreSQL data
docker run --rm -v ${POSTGRES_DATA}:/data -v $(pwd):/backup alpine \
    tar xzf /backup/postgres_backup.tar.gz -C /data


Ensure the containers are stopped before restoring.

After restoring, start your client containers again:

docker compose -f docker-compose-client_a.yml up -d


⚠️ Tip: Always backup before upgrading Odoo, modules, or performing major database operations.

✅ Summary Flow

Copy .env.sample → .env

Create data/ folders

Configure .env

Create client folder inside data/clients

Clone Briq ERP repo

Add client-specific modules

Copy & rename docker-compose per client

Update volume paths

Run Docker compose

Backup volumes regularly