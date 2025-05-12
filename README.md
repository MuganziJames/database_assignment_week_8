# 📚 Library Management System (Relational DB)

A full‑featured MySQL schema that powers day‑to‑day library operations—memberships, cataloguing, loans, fines, reservations, events, and audit logs—all in one place.

---

## 🔍 Project Overview

| Feature             | What it Covers                                          |
| ------------------- | ------------------------------------------------------- |
| **Core Catalog**    | Books, physical copies, categories, publishers, authors |
| **Circulation**     | Loans, renewals, fines, reservations                    |
| **Patrons & Staff** | Members, staff user table with roles                    |
| **Events Module**   | Library events and registrations                        |
| **Audit Trail**     | System logs for key actions                             |
| **ACID‑Safe**       | InnoDB, FK constraints, cascading rules                 |

Built purely with SQL—no ORMs or extra middleware—making it easy to import into any MySQL 8.0+ server.

---

## 🚀 Quick‑Start / Setup

```bash
# 1. Clone the repo
$ git clone https://github.com/your‑username/library‑management‑db.git
$ cd library‑management‑db

# 2. Log into MySQL
$ mysql ‑u <user> ‑p

# 3. Create a schema & load objects
mysql> SOURCE ./schema/library_management_schema.sql;

# 4. (Optional) Load sample data
mysql> SOURCE ./sample/seed_data.sql;
```

> **Heads‑up:** Default engine is **InnoDB**.  SQL has been tested on MySQL 8.0.  For 5.7 you may need to tweak `CHECK` constraints or default `DATE` values—see comments inside the schema file.

---

## 🖼️ Entity‑Relationship Diagram (ERD)

![ERD Diagram](./library_erd.png)


## 🗂️ Repository Structure

```
.
├── schema/
│   └── library_management_schema.sql   # 👉 main CREATE TABLE script
├── sample/
│   ├── seed_data.sql                  # optional demo rows
│   └── truncate_all.sql               # quick clean‑up helper
├── docs/
│   └── erd/
│       ├── library_mg_erd.png         # diagram for README
│       └── library_mg.drawio          # draw.io source file
└── README.md                          # this file
```

---

## 🤝 Contributing / Extending

* **Indexes** – add composite keys for your most common queries.
* **Views** – handy read‑only summary views can go into `schema/views/`.
* **Procedures / Triggers** – feel free to enforce business rules (e.g., auto‑renew grace period or daily fine accrual).

Pull requests are welcome—just open an issue first to discuss major changes.

---

## 📜 License

This project is released under the MIT License. See `LICENSE` for details.

## Crafted by James Muganzi💻