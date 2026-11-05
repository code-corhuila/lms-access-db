-- pgcrypto provides gen_random_uuid(), used as the default for every table's
-- primary key in this domain.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
