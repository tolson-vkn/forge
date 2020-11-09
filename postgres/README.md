# Postgres

Some useful things from time to time.

## Random

### Get current connections; IP and User

```
SELECT pid, now() - query_start as duration, state, username, client_addr as IP FROM pg_stat_activity ORDER BY now() - query_stat DESC;
```

### Idle Connections

```
SELECT pid, now() - query_start as duration, state, username, client_addr as IP FORM pg_stat_activity WHERE now() - query_start > interval '5 minutes' ORDER BY now() - query_start DESC;
```

### How optimized

```
EXPLAIN ANALYZE SELECT * FROM table;
```

### ADD USER

```
CREATE ROLE foobar LOGIN PASSWORD 'password';

GRANT CONNECT ON DATABASE thedb TO foobar;
GRANT USAGE ON SCHEMA theschema TO foobar;
GRANT SELECT ON ALL TABLES IN SCHEMA theschema TO foobar;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA theschema TO foobar;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA theschema TO foobar;

ALTER DEFAULT PRIVILEGES IN SCHEMA theschema GRANT SELECT ON TABLES TO foobar;
ALTER DEFAULT PRIVILEGES IN SCHEMA theschema GRANT SELECT ON SEQUENCES TO foobar;
ALTER DEFAULT PRIVILEGES IN SCHEMA theschema GRANT SELECT ON FUNCTIONS TO foobar;
```

### BYTEA to TEXT

SERVER\_ENCODING does funky things like `\n` becoming `\012` etc. 


```
SELECT convert_from(decode(x, 'escape'), 'UTF-8')
FROM encode(E'\n\t\f\b\p\k\j\l\mestPrepared'::bytea, 'escape')
  AS t(x);
```

#### Just give it to me as a column, k thx

```
select encode(table.column, 'escape') as name from table
```

