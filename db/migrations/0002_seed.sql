-- Forward-only migration 0002: reference data so a new environment is not empty.
-- Re-runnable: each row is inserted only when its title is absent.
INSERT INTO capture (title, reference, status, priority)
SELECT 'Sample Capture 1', 'C-0001', 'new', 'low'
WHERE NOT EXISTS (SELECT 1 FROM capture WHERE title = 'Sample Capture 1');
INSERT INTO capture (title, reference, status, priority)
SELECT 'Sample Capture 2', 'C-0002', 'in-progress', 'normal'
WHERE NOT EXISTS (SELECT 1 FROM capture WHERE title = 'Sample Capture 2');
INSERT INTO capture (title, reference, status, priority)
SELECT 'Sample Capture 3', 'C-0003', 'complete', 'high'
WHERE NOT EXISTS (SELECT 1 FROM capture WHERE title = 'Sample Capture 3');
INSERT INTO capture (title, reference, status, priority)
SELECT 'Sample Capture 4', 'C-0004', 'new', 'low'
WHERE NOT EXISTS (SELECT 1 FROM capture WHERE title = 'Sample Capture 4');
