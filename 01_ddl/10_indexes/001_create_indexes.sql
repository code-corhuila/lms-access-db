-- username is the business key — uniqueness lives here, not an inline
-- UNIQUE on the column (rules/2-anexos/A-db-postgres.md, rule 4).
CREATE UNIQUE INDEX idx_administrator_username ON access.administrator (username);
