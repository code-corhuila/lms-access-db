# lms-access-db

> Access bounded context: database

Part of the **LMS Library** distributed system — team `lms-library`, Grupo 2.
Governance and documentation live in [`library-docs`](https://github.com/code-corhuila/library-docs).

## Migration scope

**Comes from** `lms-library` → the `access-db` and `access-migrate` service blocks of
`docker-compose.yml`, the `access-db-data` volume, and the DDL currently sitting in
`access-service/migrations/`.

**This repository owns the whole database structure** — image, configuration, volume, healthcheck,
schema, seeds and migrations. `lms-access-api` only consumes it; it no longer carries the schema.

Database: `access_db`.

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
