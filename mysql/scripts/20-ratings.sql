CREATE DATABASE ratings
DEFAULT CHARACTER SET 'utf8';

USE ratings;

CREATE TABLE ratings (
    sku varchar(80) NOT NULL,
    avg_rating DECIMAL(3, 2) NOT NULL,
    rating_count INT NOT NULL,
    PRIMARY KEY (sku)
) ENGINE=InnoDB;

-- Reuse the runtime-managed shipping DB identity; no password is stored here.
GRANT ALL ON ratings.* TO 'shipping'@'%';
