# SQL Project — Job Postings Analytics

Comprehensive SQL project for loading and analyzing job postings data. This repository contains CSV datasets, SQL table creation / modification scripts, and a set of analytic queries that produce insights such as top-paying jobs, in-demand skills, and optimal skill combinations.

## Table of contents

- Project overview
- Repository structure
- Data files
- Data model (high-level)
- SQL scripts (analytics)
- Loading scripts and instructions
- How to run (example commands)
- Assumptions & notes
- Contributing
- License & contact

## Project overview

This project demonstrates an end-to-end SQL workflow for a small data warehouse built from job posting CSVs. It includes:

- Raw CSV files (dimensions & fact table)
- SQL scripts to create/modify database tables
- Analytic SQL queries to answer business questions (top paying jobs, top skills, demand vs pay, etc.)

It is intentionally lightweight and DB-agnostic at the SQL level, but the instructions use PostgreSQL as the recommended engine for loading CSVs and running scripts.

## Repository structure

Top-level layout:

- `csv_files/` — source CSV data used by the project
	- `company_dim.csv`
	- `job_postings_fact.csv`
	- `skills_dim.csv`
	- `skills_job_dim.csv`
- `project_sql/` — analytic queries and reports
	- `1_top_paying.sql`
	- `2_top_paying_skills.sql`
	- `3_top_demanded_skills.sql`
	- `4_top_paying_skills.sql`
	- `5_optimal_skills.sql`
- `sql_load/` — scripts used to create database & tables and apply schema changes
	- `1_create_database.sql`
	- `2_create_tables.sql`
	- `3_modify_tables.sql`
	- `CREATE TABLE employees(.sql` (note: this filename appears to be malformed; see Known issues)
- `README.md` — this file

## Data files

All CSV files live in `csv_files/`. Brief descriptions:

- `company_dim.csv` — company-level dimension data (company id, name, industry, location, etc.).
- `job_postings_fact.csv` — fact table containing job postings (job id, company id, salary/pay details, posting date, title, etc.).
- `skills_dim.csv` — skills dimension (skill id, skill name, categories, etc.).
- `skills_job_dim.csv` — junction table mapping skills to job postings (job id, skill id), modeling the many-to-many relationship between jobs and skills.

Notes about the CSVs:

- Expect header row in each CSV.
- Files are assumed UTF-8 encoded and comma-separated.
- If your CSVs use a different delimiter or encoding, adjust the copy/import command accordingly.

## Data model (high-level)

The project follows a simple dimensional model:

- Fact: `job_postings_fact` — one row per job posting. Contains foreign keys to `company_dim` and related attributes such as salary.
- Dim: `company_dim` — company metadata.
- Dim: `skills_dim` — skill metadata.
- Bridge: `skills_job_dim` — many-to-many mapping between job postings and skills.

This layout supports queries for top paying jobs, most demanded skills, and analyses that join skill-level information to job pay data.

## SQL scripts (analytics)

The `project_sql/` directory contains prepared queries. Each file is named to indicate the analysis it performs:

- `1_top_paying.sql` — identifies top paying job titles or companies (depends on query definition in file).
- `2_top_paying_skills.sql` — maps skills to pay and produces a ranking of highest paying skills.
- `3_top_demanded_skills.sql` — lists the most frequently required skills across job postings.
- `4_top_paying_skills.sql` — (appears similar to `2_` — verify if it's a variant or duplicate) — check file contents for differences.
- `5_optimal_skills.sql` — suggests optimal skill combinations for maximizing pay or demand (based on available data and logic in the script).

Open each `.sql` file to view specific assumptions and column names used; some scripts may expect columns to exist or be named according to `2_create_tables.sql`.

## Loading scripts (`sql_load/`)

This folder contains SQL scripts to create the database and tables.

- `1_create_database.sql` — creates the target database/schema. Run this first.
- `2_create_tables.sql` — DDL for creating tables (`company_dim`, `job_postings_fact`, `skills_dim`, `skills_job_dim`, etc.).
- `3_modify_tables.sql` — any schema tweaks or ALTER statements applied after initial creation.
- `CREATE TABLE employees(.sql` — this filename looks corrupted (contains parenthesis). Confirm the intended filename and contents before running.

## How to run (example using PostgreSQL)

These steps assume you have PostgreSQL and `psql` installed. Adjust if you prefer another RDBMS.

1) Create the database (run as a user with CREATE DATABASE rights):

```bash
# create database (example name: job_db)
psql -U your_pg_user -f "sql_load/1_create_database.sql"
```

Alternatively, inside `psql`:

```sql
-- open psql then run
\i sql_load/1_create_database.sql
```

2) Create tables:

```bash
psql -U your_pg_user -d job_db -f "sql_load/2_create_tables.sql"
```

3) Apply post-creation schema changes (if present):

```bash
psql -U your_pg_user -d job_db -f "sql_load/3_modify_tables.sql"
```

4) Load CSV files into the newly created tables. Using `psql`'s `\copy` (client-side) is convenient when you have the CSVs locally. Example commands:

```bash
psql -U your_pg_user -d job_db

-- inside psql, run (example for company_dim):
\copy company_dim FROM 'csv_files/company_dim.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy job_postings_fact FROM 'csv_files/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy skills_dim FROM 'csv_files/skills_dim.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy skills_job_dim FROM 'csv_files/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
```

If you prefer to run the copies from the shell (non-interactive), you can use:

```bash
psql -U your_pg_user -d job_db -c "\copy company_dim FROM 'csv_files/company_dim.csv' CSV HEADER;"
```

5) Run analytic queries. Each SQL file in `project_sql/` can be executed against `job_db`.

```bash
psql -U your_pg_user -d job_db -f "project_sql/1_top_paying.sql"
psql -U your_pg_user -d job_db -f "project_sql/3_top_demanded_skills.sql"
```

You can capture results to CSV using `\copy (SELECT ...) TO 'out.csv' CSV HEADER` or by redirecting `psql` output.

## Quick example: run all steps (shell)

```bash
# Create DB (if script creates DB and sets search_path)
psql -U your_pg_user -f sql_load/1_create_database.sql

# Create/alter tables
psql -U your_pg_user -d job_db -f sql_load/2_create_tables.sql
psql -U your_pg_user -d job_db -f sql_load/3_modify_tables.sql

# Load CSVs
psql -U your_pg_user -d job_db -c "\copy company_dim FROM 'csv_files/company_dim.csv' CSV HEADER;"
psql -U your_pg_user -d job_db -c "\copy job_postings_fact FROM 'csv_files/job_postings_fact.csv' CSV HEADER;"
psql -U your_pg_user -d job_db -c "\copy skills_dim FROM 'csv_files/skills_dim.csv' CSV HEADER;"
psql -U your_pg_user -d job_db -c "\copy skills_job_dim FROM 'csv_files/skills_job_dim.csv' CSV HEADER;"

# Run analytics
psql -U your_pg_user -d job_db -f project_sql/1_top_paying.sql
psql -U your_pg_user -d job_db -f project_sql/3_top_demanded_skills.sql
```

Replace `your_pg_user` and `job_db` with your PostgreSQL username and database name.

## Assumptions & notes

- CSV files contain a header row with column names that match table column names in `2_create_tables.sql`. If column names differ, either adjust the CSV header or load into a staging table and transform.
- The `CREATE TABLE employees(.sql` filename looks malformed; open `sql_load/` and rename or correct this file before running it.
- Some SQL scripts in `project_sql/` may contain database-specific functions or syntax — review and adapt to your RDBMS.
- If you plan to load large CSVs, consider increasing `maintenance_work_mem`, disabling indexes before bulk load, or using `COPY` server-side if files are on the DB server.

## Troubleshooting

- Permission errors when running `\copy` usually mean `psql` can't access the CSV path — either run `psql` from the repository root or use absolute paths.
- Encoding issues: confirm CSV encoding (UTF-8 recommended). Use tools like `iconv` to convert.
- If a SQL script fails due to missing columns, inspect the DDL in `sql_load/2_create_tables.sql` and reconcile column names.

## Contributing

Contributions are welcome. Suggested workflow:

1. Fork the repository
2. Create a feature branch
3. Add or update SQL scripts / CSV sample data
4. Open a pull request with a description of changes

Please include sample data or small test CSVs when adding scripts that change schema or query logic.

## License

There is no license file in this repository at the moment. If you want to open-source this project, add a `LICENSE` (for example, MIT) to the repo.

## Contact

For questions about the code or data, open an issue in the repository with reproducible steps and relevant files.

---

If you'd like, I can also:

- Inspect the SQL files and add short, per-file summaries inside `project_sql/`.
- Fix the malformed filename under `sql_load/` and ensure scripts run in the correct order.
- Create a small sample dataset and a quick `docker-compose`+`postgres` setup for repeatable local testing.

Tell me which of those (if any) you'd like me to do next.

