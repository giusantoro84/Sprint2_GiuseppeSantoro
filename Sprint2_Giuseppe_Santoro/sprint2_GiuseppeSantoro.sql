/* Exercici 1 */
USE transactions;
SHOW TABLES;
DESCRIBE company;
DESCRIBE transaction;
SHOW CREATE TABLE transaction;
SELECT COUNT(*) as n_company
FROM company;
SELECT COUNT(*) as n_transaction
FROM transaction;

/*Exercici 2 */
-- punto 1
SELECT distinct c.country
FROM company c
JOIN transaction t
ON c.id = t.company_id
ORDER BY country;
-- punto 2
SELECT count(DISTINCT c.country) AS n_country
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE t.declined = false;
-- punto 3
SELECT AVG(t.amount) AS mitjana_vendes, c.id, c.company_name
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id, c.company_name
ORDER BY mitjana_vendes DESC
LIMIT 1;

/*Exercici 3 */
-- 	punto 1
SELECT *
FROM transaction 
WHERE company_id IN (
	SELECT id
	FROM company
	WHERE country = 'Germany'
);

-- 	punto 2
SELECT company_name 
FROM company 
WHERE id IN (
	SELECT DISTINCT company_id 
	FROM transaction
	WHERE amount > (
		SELECT AVG(amount)
		FROM transaction
	)
)
ORDER BY company_name;

-- 	punto 3
SELECT
    id,
    company_name
FROM company
WHERE id NOT IN (
    SELECT company_id
    FROM transaction
);

/*Exercici 4 */
-- Creo la tabla credit_card
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(34),
    pan VARCHAR(23),
    pin CHAR(4),
    cvv CHAR(3),
    expiring_date VARCHAR(8)
);

-- vinculo clave foranea
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

/*Exercici 5 */
-- aportar modifica
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

-- verifica
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

/*Exercici 6 */
-- Inserto los registros que faltan para garantizar la integridad referencial
INSERT INTO company (id)
VALUES ('b-9999');
INSERT INTO credit_card (id)
VALUES ('CcU-9999');

-- Inserto la transaccion 
INSERT INTO transaction (
    id,
    credit_card_id,
    company_id,
    user_id,
    lat,
    longitude,
    amount,
    declined
)
VALUES (
    '108B1D1D-5B23-A76C-55EF-C568E49A99DD',
    'CcU-9999',
    'b-9999',
    9999,
    829.999,
    -117.999,
    111.11,
    0
);

-- verifico 
SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

/*Exercici 7 */
-- Elimino la columna pan de la tabla credit_card
ALTER TABLE credit_card
DROP COLUMN pan;

-- verifico
DESCRIBE credit_card;

/*Exercici 8 */
-- Creaccion del database
CREATE DATABASE IF NOT EXISTS transactions_new;

-- uso el  database
USE transactions_new;

-- creo las tablas de los usuarios
CREATE TABLE american_users (
    id INT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(255),
    birth_date VARCHAR(20),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date VARCHAR(20),
    user_segment VARCHAR(50),
    income_band VARCHAR(30)
);

CREATE TABLE european_users (
    id INT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(255),
    birth_date VARCHAR(20),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date VARCHAR(20),
    user_segment VARCHAR(50),
    income_band VARCHAR(30)
);

-- importiamo los csv
SHOW VARIABLES LIKE 'local_infile';
-- activo 
SET GLOBAL local_infile = ON;
-- verifico
SHOW VARIABLES LIKE 'local_infile';

-- Importo los datos del archivo N1-Ex.8__american_users.csv
LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__american_users.csv'
INTO TABLE american_users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    name,
    surname,
    phone,
    email,
    birth_date,
    country,
    city,
    postal_code,
    address,
    signup_date,
    user_segment,
    income_band
);

-- verifico los regigistros 
SELECT COUNT(*) AS total_users
FROM american_users;

-- Importo los datos del archivo N1-Ex.8__european_users.csv
LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__european_users.csv'
INTO TABLE european_users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    name,
    surname,
    phone,
    email,
    birth_date,
    country,
    city,
    postal_code,
    address,
    signup_date,
    user_segment,
    income_band
);

-- verifico
SELECT COUNT(*) AS total_users
FROM european_users;

-- Compruebo si existen id dupicados
SELECT id
FROM american_users
WHERE id IN (
    SELECT id
    FROM european_users
);

SELECT id
FROM european_users
WHERE id IN (
    SELECT id
    FROM american_users
);

-- Compruebo que no existan identificadores duplicados o nulos dentro de cada tabla
SELECT
    id,
    COUNT(*) AS occurrences
FROM american_users
GROUP BY id
HAVING COUNT(*) > 1;

SELECT
    id,
    COUNT(*) AS occurrences
FROM european_users
GROUP BY id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS null_ids
FROM american_users
WHERE id IS NULL;

SELECT COUNT(*) AS null_ids
FROM european_users
WHERE id IS NULL;

-- Creo la tabla definitiva users
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(255),
    birth_date VARCHAR(20),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date VARCHAR(20),
    user_segment VARCHAR(50),
    income_band VARCHAR(30),
    region VARCHAR(20)
);

-- Unifico los datos

INSERT INTO users (
    id,
    name,
    surname,
    phone,
    email,
    birth_date,
    country,
    city,
    postal_code,
    address,
    signup_date,
    user_segment,
    income_band,
    region
)
SELECT
    id,
    name,
    surname,
    phone,
    email,
    birth_date,
    country,
    city,
    postal_code,
    address,
    signup_date,
    user_segment,
    income_band,
    'America'
FROM american_users

UNION ALL

SELECT
    id,
    name,
    surname,
    phone,
    email,
    birth_date,
    country,
    city,
    postal_code,
    address,
    signup_date,
    user_segment,
    income_band,
    'Europe'
FROM european_users;

-- verifico los datos por region
SELECT
    region,
    COUNT(*) AS total_users
FROM users
GROUP BY region;

-- Creo la tabla companies
CREATE TABLE companies (
    company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(150),
    phone VARCHAR(30),
    email VARCHAR(255),
    country VARCHAR(100),
    website VARCHAR(255),
    merchant_category VARCHAR(100),
    merchant_price_position VARCHAR(50)
);


-- Importo los datos del archivo N1-Ex.8__companies.csv

LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__companies.csv'
INTO TABLE companies
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    company_id,
    company_name,
    phone,
    email,
    country,
    website,
    merchant_category,
    merchant_price_position
);

-- verifico el numero de companies
SELECT COUNT(*) AS total_companies
FROM companies;

-- Creo la tabla credit_cards
CREATE TABLE credit_cards (
    id VARCHAR(20),
    user_id INT,
    iban VARCHAR(34),
    expiring_date VARCHAR(20),
    card_type VARCHAR(50),
    card_renewal_flag VARCHAR(20)
);

-- Importo los registros
LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_cards
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    user_id,
    iban,
    @pan,
    @pin,
    @cvv,
    @track1,
    @track2,
    expiring_date,
    card_type,
    card_renewal_flag
);

-- verifico los registros
SELECT COUNT(*) AS total_cards
FROM credit_cards;

-- Creo transactions
CREATE TABLE transactions (
    id VARCHAR(36) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp DATETIME,
    amount DECIMAL(10,2),
    declined TINYINT,
    product_ids VARCHAR(255),
    user_id INT,
    lat DECIMAL(18,15),
    longitude DECIMAL(18,15),
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    channel VARCHAR(30),
    campaign_id VARCHAR(50),
    device_type VARCHAR(30),
    is_international TINYINT,
    decline_reason VARCHAR(100),
    distance_km DECIMAL(10,2)
);

-- Importo los registros
LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__transactions.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    card_id,
    business_id,
    timestamp,
    amount,
    declined,
    product_ids,
    user_id,
    lat,
    longitude,
    discount_amount,
    tax_amount,
    shipping_amount,
    channel,
    campaign_id,
    device_type,
    is_international,
    decline_reason,
    distance_km
);

-- verifico la longitude
CREATE TEMPORARY TABLE temp_longitudes (
    longitude_raw VARCHAR(50)
);


LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__transactions.csv'
INTO TABLE temp_longitudes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @id,
    @card_id,
    @business_id,
    @timestamp,
    @amount,
    @declined,
    @product_ids,
    @user_id,
    @lat,
    longitude_raw,
    @discount_amount,
    @tax_amount,
    @shipping_amount,
    @channel,
    @campaign_id,
    @device_type,
    @is_international,
    @decline_reason,
    @distance_km
);

SELECT
    MAX(
        LENGTH(SUBSTRING_INDEX(longitude_raw, '.', -1))
    ) AS max_decimali,
    MAX(
        LENGTH(
            SUBSTRING_INDEX(longitude_raw, '.', 1)
        ) - (LEFT(longitude_raw, 1) = '-')
    ) AS max_cifre_intere
FROM temp_longitudes
WHERE longitude_raw LIKE '%.%';

-- modificamos la tabla con los decimales correctos
ALTER TABLE transactions
MODIFY longitude DECIMAL(23,20);

-- vaciamo la tabla transactions
TRUNCATE TABLE transactions;

-- Repetimos l'importacion de los registros

LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__transactions.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    card_id,
    business_id,
    timestamp,
    amount,
    declined,
    product_ids,
    user_id,
    lat,
    longitude,
    discount_amount,
    tax_amount,
    shipping_amount,
    channel,
    campaign_id,
    device_type,
    is_international,
    decline_reason,
    distance_km
);

-- verifico el error 
SELECT longitude_raw
FROM temp_longitudes
LIMIT 1 OFFSET 34687;

-- Verifico si hay otros registros similares
SELECT
    COUNT(*) AS valores_notacion_cientifica
FROM temp_longitudes
WHERE LOWER(longitude_raw) LIKE '%e%';

-- converto el valor en notacion scientifica
SELECT
    longitude_raw,
    CAST(longitude_raw AS DECIMAL(23,21)) AS longitude_convertida
FROM temp_longitudes
WHERE LOWER(longitude_raw) LIKE '%e%';

-- modifico de nuevo  los decimales
ALTER TABLE transactions
MODIFY longitude DECIMAL(24,21);

-- elimino de  nuevo los registros
TRUNCATE TABLE transactions;

-- vuelvo a importar los datos del archivo
LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__transactions.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    card_id,
    business_id,
    timestamp,
    amount,
    declined,
    product_ids,
    user_id,
    lat,
    longitude,
    discount_amount,
    tax_amount,
    shipping_amount,
    channel,
    campaign_id,
    device_type,
    is_international,
    decline_reason,
    distance_km
);

-- verifico el valor
SELECT
    longitude
FROM transactions
WHERE longitude BETWEEN -0.000011 AND -0.000010;

-- compruebo que no hay datos nulos
SELECT
    COUNT(*) AS no_user
FROM transactions AS t
LEFT JOIN users AS u
    ON t.user_id = u.id
WHERE u.id IS NULL;

SELECT
    COUNT(*) AS no_company
FROM transactions AS t
LEFT JOIN companies AS c
    ON t.business_id = c.company_id
WHERE c.company_id IS NULL;

SELECT
    COUNT(*) AS no_card
FROM transactions AS t
LEFT JOIN credit_cards AS cc
    ON t.card_id = cc.id
WHERE cc.id IS NULL;

-- verifico valores valores unicos
SELECT
    COUNT(*) AS total_cards,
    COUNT(id) AS cards_with_id,
    COUNT(DISTINCT id) AS unique_ids
FROM credit_cards;

-- modifico la tabla y le doy clave primaria
ALTER TABLE credit_cards
ADD PRIMARY KEY (id);

-- Creo claves foranes
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users
    FOREIGN KEY (user_id)
    REFERENCES users(id),
ADD CONSTRAINT fk_transactions_companies
    FOREIGN KEY (business_id)
    REFERENCES companies(company_id),
ADD CONSTRAINT fk_transactions_credit_cards
    FOREIGN KEY (card_id)
    REFERENCES credit_cards(id);
    
-- verifico vinculos
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'transactions_new'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;


-- Exercici 9

SELECT
    u.id,
    u.name,
    u.surname,
    u.email
FROM users AS u
WHERE u.id IN (
    SELECT
        t.user_id
    FROM transactions AS t
    GROUP BY t.user_id
    HAVING COUNT(*) > 80
);

-- Exercici 10

SELECT
    cc.iban,
    AVG(t.amount) AS average_amount
FROM transactions AS t
INNER JOIN credit_cards AS cc
    ON t.card_id = cc.id
INNER JOIN companies AS c
    ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban
ORDER BY average_amount DESC;

-- Nivell 2 - Exercici 1

SELECT
    DATE(timestamp) AS transaction_date,
    SUM(amount) AS total_sales
FROM transactions
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY total_sales DESC
LIMIT 5;

-- Execici 2
SELECT
    c.company_name,
    c.phone,
    c.country,
    DATE(t.timestamp) AS transaction_date,
    t.amount
FROM transactions AS t
INNER JOIN companies AS c
    ON t.business_id = c.company_id
WHERE t.amount BETWEEN 350 AND 400
  AND DATE(t.timestamp) IN (
      '2015-04-29',
      '2018-07-20',
      '2024-03-13'
  )
ORDER BY t.amount DESC;

-- Exercici 3
SELECT
    c.company_id,
    c.company_name,
    COUNT(t.id) AS total_transactions,
    CASE
        WHEN COUNT(t.id) >= 400 THEN '400 o más'
        ELSE 'Menos de 400'
    END AS classification
FROM companies AS c
LEFT JOIN transactions AS t
    ON c.company_id = t.business_id
GROUP BY
    c.company_id,
    c.company_name
ORDER BY total_transactions DESC;

-- Exercici 4 

DELETE FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- verifico
SELECT *
FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Exercici 5
-- creo la vista
CREATE VIEW VistaMarketing AS
SELECT
    c.company_name,
    c.phone,
    c.country,
    AVG(t.amount) AS average_purchase
FROM companies AS c
INNER JOIN transactions AS t
    ON c.company_id = t.business_id
GROUP BY
    c.company_id,
    c.company_name,
    c.phone,
    c.country;
    
-- verifico
SELECT *
FROM VistaMarketing
ORDER BY average_purchase DESC;

-- Nivell 3

-- Exercici 1


CREATE TABLE card_status AS
WITH ranked_transactions AS (
    SELECT
        t.card_id,
        t.timestamp,
        t.id,
        t.declined,
        ROW_NUMBER() OVER (
            PARTITION BY t.card_id
            ORDER BY t.timestamp DESC, t.id DESC
        ) AS transaction_rank
    FROM transactions AS t
)
SELECT
    card_id,
    CASE
        WHEN SUM(declined) = 3 THEN 'Inactive'
        ELSE 'Active'
    END AS card_status
FROM ranked_transactions
WHERE transaction_rank <= 3
GROUP BY card_id
HAVING COUNT(*) = 3;

-- contar activas
SELECT
    COUNT(*) AS active_cards
FROM card_status
WHERE card_status = 'Active';


-- Exercici 2

CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(150),
    price DECIMAL(10,2),
    colour VARCHAR(7),
    weight DECIMAL(5,2),
    warehouse_id VARCHAR(20),
    category VARCHAR(50),
    brand VARCHAR(100),
    cost DECIMAL(10,2),
    launch_date DATE
);

--  importo los datos
LOAD DATA LOCAL INFILE 'C:/Users/giusa/Downloads/N1-Ex.8__products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    product_name,
    @price,
    colour,
    weight,
    warehouse_id,
    category,
    brand,
    @cost,
    launch_date
)
SET
    price = REPLACE(@price, '$', ''),
    cost = REPLACE(@cost, '$', '');

-- controlo tabla
SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT id) AS unique_ids,
    COUNT(price) AS products_with_price,
    COUNT(cost) AS products_with_cost
FROM products;

-- controlo ids
SELECT product_ids
FROM transactions
WHERE product_ids IS NOT NULL
LIMIT 10;

-- creo tabla intermedia
CREATE TABLE transaction_products (
    transaction_id VARCHAR(36),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id)
        REFERENCES transactions(id),
    FOREIGN KEY (product_id)
        REFERENCES products(id)
);

-- dividos registros
INSERT INTO transaction_products (transaction_id, product_id)
SELECT
    t.id,
    jt.product_id
FROM transactions AS t
JOIN JSON_TABLE(
    CONCAT(
        '[',
        REPLACE(REPLACE(t.product_ids, ' ', ''), ',', ','),
        ']'
    ),
    '$[*]' COLUMNS (
        product_id INT PATH '$'
    )
) AS jt
WHERE t.product_ids IS NOT NULL
  AND TRIM(t.product_ids) <> '';
  
-- verifico integridad
SELECT COUNT(*) AS products_without_match
FROM transaction_products AS tp
LEFT JOIN products AS p
    ON tp.product_id = p.id
WHERE p.id IS NULL;

-- relaciono la tabla products con transaction_products
SELECT
    p.id,
    p.product_name,
    COUNT(*) AS times_sold
FROM products AS p
INNER JOIN transaction_products AS tp
    ON p.id = tp.product_id
GROUP BY
    p.id,
    p.product_name
ORDER BY times_sold DESC;