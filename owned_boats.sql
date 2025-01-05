CREATE TABLE IF NOT EXISTS `owned_boats` (
    `id` int NOT NULL AUTO_INCREMENT,
    `owner` varchar(50) NOT NULL,
    `plate` varchar(20) NOT NULL UNIQUE,
    `vehicle` longtext NOT NULL,
    `stored` int NOT NULL DEFAULT 1,
    `parking` varchar(50) DEFAULT NULL,
    `pound` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
);
