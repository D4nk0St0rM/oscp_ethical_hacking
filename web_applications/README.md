source: OWSAP

### SQL Injection
SQL injection testing checks if it is possible to inject data into the application so that it executes a user-controlled SQL query in the database.

An [SQL injection](https://owasp.org/www-community/attacks/SQL_Injection) attack consists of insertion or "injection" of either a partial or complete SQL query via the data input or transmitted from the client (browser) to the web application. 

In general the way web applications construct SQL statements involving SQL syntax written by the programmers is mixed with user-supplied data. Example:

`select title, text from news where id=$id`

In the example above the variable `$id` contains user-supplied data, while the remainder is the SQL static part supplied by the programmer; making the SQL statement dynamic.

Because the way it was constructed, the user can supply crafted input trying to make the original SQL statement execute further actions of the user's choice. The example below illustrates the user-supplied data "10 or 1=1", changing the logic of the SQL statement, modifying the WHERE clause adding a condition "or 1=1".

`select title, text from news where id=10 or 1=1`


