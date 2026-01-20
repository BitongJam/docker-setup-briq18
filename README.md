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

---

## ✅ Summary Flow

1. Copy `.env.sample` → `.env`
2. Create `data/` folders
3. Configure `.env`
4. Create client folder inside `data/clients`
5. Clone Briq ERP repo
6. Add client-specific modules
7. Copy & rename docker-compose per client
8. Update volume paths
9. Run Docker compose

---

Your client-based Odoo Docker setup is now ready.
