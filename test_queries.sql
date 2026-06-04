-- 1. Machines causing highest downtime impact
SELECT 
    m.machine_name,
    SUM(d.duration_hours) AS total_downtime,
    SUM(d.production_loss_units) AS total_loss
FROM PLANT_OPS.DOWNTIME_EVENTS d
JOIN PLANT_OPS.MACHINES m ON d.machine_id = m.machine_id
GROUP BY m.machine_name
ORDER BY total_downtime DESC, total_loss DESC;

-- 2. Error → Downtime correlation (which errors actually caused downtime)
SELECT 
    e.error_code,
    e.severity,
    e.machine_id,
    CASE WHEN d.downtime_id IS NOT NULL THEN 1 ELSE 0 END AS caused_downtime
FROM PLANT_OPS.error_logs e
LEFT JOIN PLANT_OPS.downtime_events d
    ON e.machine_id = d.machine_id
   AND e.ERROR_TIMESTAMP  <= d.start_time;

-- 3. Plant-wise failure intensity (best for dashboard)
SELECT 
    p.plant_name,
    COUNT(d.downtime_id) AS downtime_events,
    SUM(d.production_loss_units) AS total_loss
FROM PLANT_OPS.plants p
JOIN PLANT_OPS.production_lines l ON p.plant_id = l.plant_id
JOIN PLANT_OPS.machines m ON l.line_id = m.line_id
JOIN PLANT_OPS.downtime_events d ON m.machine_id = d.machine_id
GROUP BY p.plant_name
ORDER BY total_loss DESC;