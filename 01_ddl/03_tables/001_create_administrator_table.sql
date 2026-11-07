-- The Access bounded context's aggregate root — one row per administrator
-- (library-docs/02-domain/entities-and-rules.md). Named "administrator"
-- (singular), not "administrators" — rules/2-anexos/A-db-postgres.md, rule 1.
--
-- Corrects the prior Go implementation's table, which lived as
-- `administrators` in the implicit `public` schema — ADR-011's migration
-- note: this table is the one source of truth from here on.
--
-- username's uniqueness is enforced by idx_administrator_username
-- (01_ddl/10_indexes), not an inline UNIQUE here — kept with the other
-- explicitly-named constraints/indexes, per rule 4.
CREATE TABLE access.administrator (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

  username          text        NOT NULL CHECK (char_length(username) BETWEEN 1 AND 100),
  password_hash     text        NOT NULL,

  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
