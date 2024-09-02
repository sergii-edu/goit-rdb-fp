# 1

CREATE SCHEMA IF NOT EXISTS pandemic;

# імпортувати дані

USE pandemic;

SELECT * FROM infectious_cases LIMIT 10;


# 2

CREATE TABLE IF NOT EXISTS Entity (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS Code (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE
);

INSERT INTO Entity (name)
SELECT DISTINCT ic.Entity 
FROM infectious_cases ic
ON DUPLICATE KEY UPDATE name = ic.Entity;

INSERT INTO Code (code)
SELECT DISTINCT ic.Code 
FROM infectious_cases ic
ON DUPLICATE KEY UPDATE code = ic.Code;

ALTER TABLE infectious_cases
ADD COLUMN entity_id INT,
ADD COLUMN code_id INT;

UPDATE infectious_cases ic
JOIN Entity e ON ic.Entity = e.name
SET ic.entity_id = e.id;

UPDATE infectious_cases ic
JOIN Code c ON ic.Code = c.code
SET ic.code_id = c.id;

ALTER TABLE infectious_cases
DROP COLUMN Entity,
DROP COLUMN Code;

SELECT * FROM infectious_cases LIMIT 10;


# 3

SELECT 
    e.name AS Entity, 
    c.code AS Code, 
    AVG(ic.number_rabies) AS avg_rabies, 
    MIN(ic.number_rabies) AS min_rabies, 
    MAX(ic.number_rabies) AS max_rabies, 
    SUM(ic.number_rabies) AS sum_rabies
FROM 
    infectious_cases ic
JOIN 
    Entity e ON ic.entity_id = e.id
JOIN 
    Code c ON ic.code_id = c.id
WHERE 
    ic.number_rabies IS NOT NULL
GROUP BY 
    e.name, c.code
ORDER BY 
    avg_rabies DESC
LIMIT 10;


# 4

ALTER TABLE infectious_cases
ADD COLUMN first_jan_date DATE;

UPDATE infectious_cases
SET first_jan_date = STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d');

ALTER TABLE infectious_cases
ADD COLUMN current_dt DATE;

UPDATE infectious_cases
SET current_dt = CURDATE();

ALTER TABLE infectious_cases
ADD COLUMN year_diff INT;

UPDATE infectious_cases
SET year_diff = TIMESTAMPDIFF(YEAR, first_jan_date, current_dt);

SELECT * FROM infectious_cases LIMIT 10;


# 5

DELIMITER //

CREATE FUNCTION calculate_year_diff(input_year INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE year_start DATE;
    DECLARE year_difference INT;
    
    SET year_start = STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d');
    
    SET year_difference = TIMESTAMPDIFF(YEAR, year_start, CURDATE());
    
    RETURN year_difference;
END //

DELIMITER ;

ALTER TABLE infectious_cases
ADD COLUMN calculated_year_diff INT;

UPDATE infectious_cases
SET calculated_year_diff = calculate_year_diff(Year);

SELECT * FROM infectious_cases LIMIT 10;