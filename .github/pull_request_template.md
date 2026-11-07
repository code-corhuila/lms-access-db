## User story

<!-- code-corhuila/library-docs#NN -->

## What changes and why

<!-- A few lines. -->

## How it was tested

<!-- The reconstruction-verification result (db-ci.yml): build from empty, no-op
on a second run, full rollback, rebuild. -->

## Promotion trail

<!-- Only for a PR into qa or main: the list of commits re-applied, each with its
own `(cherry picked from commit <sha>)` line. Delete this section for a PR into
develop. -->

## Checklist

- [ ] No secrets committed — only `.env.example` with names
- [ ] No table lives in `public`; no key points at another domain's database
- [ ] Every changeset declares its rollback
- [ ] `db-ci.yml` is green
