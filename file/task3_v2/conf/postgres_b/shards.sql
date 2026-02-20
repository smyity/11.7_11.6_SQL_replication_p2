CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Шард с частью информации №1
CREATE SERVER shard_1_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_b1', port '5432', dbname 'test_db');

CREATE USER MAPPING FOR "postgres"
SERVER shard_1_server
OPTIONS (user 'postgres', password 'postgres');

CREATE FOREIGN TABLE books_part1 (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    author character varying NOT NULL,
    title character varying NOT NULL
) SERVER shard_1_server OPTIONS (table_name 'books_part1_data');

-- Шард с частью информации №1
CREATE SERVER shard_2_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_b2', port '5432', dbname 'test_db');

CREATE USER MAPPING FOR "postgres"
SERVER shard_2_server
OPTIONS (user 'postgres', password 'postgres');

CREATE FOREIGN TABLE books_part2 (
    id bigint NOT NULL,
    title text,
    year int
) SERVER shard_2_server OPTIONS (table_name 'books_part2_data');

-- Объединение шардов вертикально через VIEW
CREATE VIEW books_full AS
SELECT 
    c.id, 
    c.author, 
    c.title, 
    d.raw_data
FROM books_part1 c
JOIN books_part2 d ON c.id = d.id; -- Склеивание по ID