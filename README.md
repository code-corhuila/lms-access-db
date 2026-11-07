# lms-access-db

> Access bounded context: database

Part of the **LMS Library** distributed system — team `lms-library`, Grupo 2.
Governance and documentation live in [`library-docs`](https://github.com/code-corhuila/library-docs).

User story: **HU-01 Administrator Authentication**.

## Migration scope

**Comes from** `lms-library` → the `access-db` and `access-migrate` service blocks of
`docker-compose.yml`, the `access-db-data` volume, and the DDL currently sitting in
`access-service/migrations/`.

**This repository owns the whole database structure** — schema, roles, grants and migrations.
`lms-access-api` only consumes it; it no longer carries the schema. The PostgreSQL instance itself
(image, volume, healthcheck, login users) belongs to `lms-infra-postgres`, which is shared by every
domain (`rules/3-Anexo-J`).

Database: `access_db` in CI, the shared instance's database in real environments.

## Structure

Follows `rules/2-anexos/A-db-postgres.md` (the course's own repository norm), with **Liquibase 4.29**
as the migration tool (`ADR-010-liquibase-for-database-migrations.md`).

```
01_ddl/          → extensions (pgcrypto), schema access, table administrator, indexes
02_dml/          → seeds/updates/deletes/upserts/patches — empty today, no seed data
03_dcl/          → roles access_reader/access_writer (NOLOGIN), grants, access_writer → access_app
04_tcl/          → transaction blocks, manual recoveries, release tags — empty today
05_rollbacks/    → mirrors 01_ddl/03_dcl, one .rollback.sql per .sql that reverts it
changelog/
└── changelog-master.yaml → the single Liquibase entry point
deploy/
├── compose.yml            → this domain's Liquibase executor (no DB service — shared instance)
└── liquibase.properties   → changelog path and changelog-table names (no credentials)
.github/workflows/db-ci.yml → reconstruction check on every PR
```

The `administrator` table (singular, per the norm's rule 1) lives in schema `access`, never
`public` — **this corrects the prior Go implementation**, which queried a bare `administrators`
table in the implicit `public` schema (`ADR-011`'s migration note). The id is a `uuid` generated
with `gen_random_uuid()`, `username` is `text` with a `CHECK` on length (1–100) and a unique index
`idx_administrator_username`.

On a shared instance two domains would collide on Liquibase's default tracking tables, so this one
uses `databasechangelog_access` and `databasechangeloglock_access` (Anexo J, J.6).

## Roles and the `access_app` user

Migrations run as the instance administrator. The running `lms-access-api` never does: it connects
as `access_app`, a login user created by `lms-infra-postgres`'s init script, and this repository
only grants it `access_writer` (`03_dcl/01_grants/002_grant_writer_to_app_user.sql`, Anexo J, J.7).

That means **`access_app` must exist before the migrations run**. In real environments
`lms-infra-postgres` creates it; in CI the workflow creates it as its first step, because the CI
database starts empty.

## Verifying the migrations locally

`deploy/compose.yml` is not meant to run alone: it depends on the `postgres` service and the
external `platform` network that `lms-infra-postgres` provides, which `include:`s this file.

To check this repository by itself, reproduce what `db-ci.yml` runs, with Docker only:

```bash
docker network create access-check
docker run -d --name access-pg --network access-check \
  -e POSTGRES_USER=lms_user -e POSTGRES_PASSWORD=lms_password -e POSTGRES_DB=access_db \
  postgres:16-alpine
docker exec access-pg psql -U lms_user -d access_db \
  -c "CREATE ROLE access_app LOGIN PASSWORD 'local-only-password'"

lb() {
  docker run --rm --network access-check -v "$PWD:/liquibase/changelog" -w /liquibase/changelog \
    liquibase/liquibase:4.29 --defaults-file=deploy/liquibase.properties \
    --url=jdbc:postgresql://access-pg:5432/access_db --username=lms_user --password=lms_password "$@"
}
lb update               # builds from empty
lb update               # must apply zero changesets
lb rollback-count 999   # full teardown
lb update               # rebuilds after rollback

docker rm -f access-pg && docker network rm access-check
```

Wait a few seconds after starting `access-pg` so PostgreSQL is ready before the first command.

Liquibase reads `deploy/liquibase.properties`, so it tracks this domain's migrations in `databasechangelog_access` and `databasechangeloglock_access`, the same as on the shared instance.

## Delivered in

PR #2 (schema, table and indexes with their rollbacks) and PR #3 (roles and grants, changelog
master, deploy executor, CI workflow and PR template).

The full map lives in `library-docs`.

---

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `library-docs`.
