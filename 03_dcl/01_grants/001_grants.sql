GRANT USAGE ON SCHEMA access TO access_reader, access_writer;

GRANT SELECT ON access.administrator TO access_reader;
GRANT SELECT, INSERT, UPDATE ON access.administrator TO access_writer;
