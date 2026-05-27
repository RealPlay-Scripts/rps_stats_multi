-- rps Stats - Database Schema
-- Run this once to create the required table

CREATE TABLE IF NOT EXISTS `rps_player_stats` (
    `id`                INT          NOT NULL AUTO_INCREMENT,
    `discord_id`        VARCHAR(32)  DEFAULT NULL,
    `citizenid`         VARCHAR(64)  DEFAULT NULL,
    `event_type`        ENUM('kill','death') NOT NULL,
    `cause`             VARCHAR(64)  DEFAULT NULL,
    `weapon`            VARCHAR(64)  DEFAULT NULL,
    `killer_discord_id` VARCHAR(32)  DEFAULT NULL,
    `killer_citizenid`  VARCHAR(64)  DEFAULT NULL,
    `killer_name`       VARCHAR(128) DEFAULT NULL,
    `victim_name`       VARCHAR(128) DEFAULT NULL,
    `x`                 FLOAT        DEFAULT NULL,
    `y`                 FLOAT        DEFAULT NULL,
    `z`                 FLOAT        DEFAULT NULL,
    `created_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_discord_id`  (`discord_id`),
    INDEX `idx_citizenid`   (`citizenid`),
    INDEX `idx_event_type`  (`event_type`),
    INDEX `idx_created_at`  (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
