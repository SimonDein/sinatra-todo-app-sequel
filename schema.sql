CREATE TABLE lists (
  id serial      PRIMARY KEY,
name varchar(50) UNIQUE NOT NULL
);

CREATE TABLE todos (
         id serial      PRIMARY KEY,
    list_id int         NOT NULL REFERENCES lists(id),
       name varchar(50) NOT NULL CHECK (length(name) > 0),
  completed boolean     NOT NULL DEFAULT false
);