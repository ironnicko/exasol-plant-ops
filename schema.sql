-- ============================================================
-- Plant Ops Dataset Schema
-- ============================================================

CREATE SCHEMA IF NOT EXISTS PLANT_OPS;

OPEN SCHEMA PLANT_OPS;

-- ============================================================
-- PLANTS
-- ============================================================

CREATE OR REPLACE TABLE PLANTS (
    PLANT_ID        VARCHAR(10) NOT NULL,
    PLANT_NAME      VARCHAR(100) NOT NULL,
    LOCATION        VARCHAR(100),
    TIMEZONE        VARCHAR(50),

    CONSTRAINT PK_PLANTS PRIMARY KEY (PLANT_ID)
);

-- ============================================================
-- PRODUCTION_LINES
-- ============================================================

CREATE OR REPLACE TABLE PRODUCTION_LINES (
    LINE_ID         VARCHAR(10) NOT NULL,
    PLANT_ID        VARCHAR(10) NOT NULL,
    LINE_NAME       VARCHAR(100) NOT NULL,
    PRODUCT_TYPE    VARCHAR(100),

    CONSTRAINT PK_PRODUCTION_LINES PRIMARY KEY (LINE_ID)
);

-- ============================================================
-- MACHINES
-- ============================================================

CREATE OR REPLACE TABLE MACHINES (
    MACHINE_ID              VARCHAR(10) NOT NULL,
    LINE_ID                 VARCHAR(10) NOT NULL,
    MACHINE_NAME            VARCHAR(100) NOT NULL,
    MACHINE_TYPE            VARCHAR(100),
    INSTALL_DATE            DATE,
    STATUS                  VARCHAR(30),
    BASELINE_VIBRATION      DECIMAL(8,2),
    BASELINE_TEMP           DECIMAL(8,2),

    CONSTRAINT PK_MACHINES PRIMARY KEY (MACHINE_ID)
);

-- ============================================================
-- SENSOR_READINGS
-- ============================================================

CREATE OR REPLACE TABLE SENSOR_READINGS (
    READING_ID          VARCHAR(20) NOT NULL,
    MACHINE_ID          VARCHAR(10) NOT NULL,
    READING_TIMESTAMP   TIMESTAMP,
    VIBRATION_MM_S      DECIMAL(10,2),
    TEMPERATURE_C       DECIMAL(10,2),
    PRESSURE_BAR        DECIMAL(10,2),
    RPM                 INTEGER,
    OIL_LEVEL_PCT       DECIMAL(10,2),

    CONSTRAINT PK_SENSOR_READINGS PRIMARY KEY (READING_ID)
);

-- ============================================================
-- ERROR_LOGS
-- ============================================================

CREATE OR REPLACE TABLE ERROR_LOGS (
    ERROR_ID            VARCHAR(20) NOT NULL,
    MACHINE_ID          VARCHAR(10) NOT NULL,
    ERROR_TIMESTAMP     TIMESTAMP,
    ERROR_CODE          VARCHAR(20),
    SEVERITY            VARCHAR(20),
    DESCRIPTION         VARCHAR(500),
    RESOLVED            BOOLEAN,
    RESOLVED_AT         TIMESTAMP,

    CONSTRAINT PK_ERROR_LOGS PRIMARY KEY (ERROR_ID)
);

-- ============================================================
-- DOWNTIME_EVENTS
-- ============================================================

CREATE OR REPLACE TABLE DOWNTIME_EVENTS (
    DOWNTIME_ID             VARCHAR(20) NOT NULL,
    MACHINE_ID              VARCHAR(10) NOT NULL,
    START_TIME              TIMESTAMP,
    END_TIME                TIMESTAMP,
    DURATION_HOURS          DECIMAL(10,2),
    DOWNTIME_TYPE           VARCHAR(50),
    ROOT_CAUSE              VARCHAR(500),
    PRODUCTION_LOSS_UNITS   INTEGER,

    CONSTRAINT PK_DOWNTIME_EVENTS PRIMARY KEY (DOWNTIME_ID)
);

-- ============================================================
-- MAINTENANCE_RECORDS
-- ============================================================

CREATE OR REPLACE TABLE MAINTENANCE_RECORDS (
    MAINTENANCE_ID      VARCHAR(20) NOT NULL,
    MACHINE_ID          VARCHAR(10) NOT NULL,
    MAINTENANCE_DATE    DATE,
    MAINTENANCE_TYPE    VARCHAR(50),
    TECHNICIAN          VARCHAR(100),
    PARTS_REPLACED      VARCHAR(255),
    DURATION_HOURS      DECIMAL(10,2),
    COST_USD            DECIMAL(12,2),
    NOTES               VARCHAR(2000),

    CONSTRAINT PK_MAINTENANCE_RECORDS PRIMARY KEY (MAINTENANCE_ID)
);

-- ============================================================
-- LOGICAL FOREIGN KEYS
-- ============================================================
--
-- Exasol does not enforce referential integrity,
-- but documenting relationships is useful.
--
-- PRODUCTION_LINES.PLANT_ID      -> PLANTS.PLANT_ID
-- MACHINES.LINE_ID              -> PRODUCTION_LINES.LINE_ID
-- SENSOR_READINGS.MACHINE_ID    -> MACHINES.MACHINE_ID
-- ERROR_LOGS.MACHINE_ID         -> MACHINES.MACHINE_ID
-- DOWNTIME_EVENTS.MACHINE_ID    -> MACHINES.MACHINE_ID
-- MAINTENANCE_RECORDS.MACHINE_ID-> MACHINES.MACHINE_ID
--
-- ============================================================

-- Optional performance helpers

CREATE OR REPLACE VIEW MACHINE_HEALTH_OVERVIEW AS
SELECT
    m.MACHINE_ID,
    m.MACHINE_NAME,
    m.MACHINE_TYPE,
    m.STATUS,
    MAX(sr.READING_TIMESTAMP) AS LAST_READING_AT,
    MAX(sr.TEMPERATURE_C) AS MAX_TEMP,
    MAX(sr.VIBRATION_MM_S) AS MAX_VIBRATION
FROM MACHINES m
LEFT JOIN SENSOR_READINGS sr
    ON m.MACHINE_ID = sr.MACHINE_ID
GROUP BY
    m.MACHINE_ID,
    m.MACHINE_NAME,
    m.MACHINE_TYPE,
    m.STATUS;