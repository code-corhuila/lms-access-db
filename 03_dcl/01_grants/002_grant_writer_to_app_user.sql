-- Ties the permission-carrying role to the actual login user — the role was
-- NOLOGIN on purpose (001_create_roles.sql); the login user itself is
-- created by lms-infra-postgres's init script, not by this migration
-- (rules/3-Anexo-J, J.7: "el dominio concede su rol de escritura a su
-- propio usuario").
GRANT access_writer TO access_app;
