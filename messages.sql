--docker-compose run db createdb -h db -U postgres messages 
--docker-compose run db psql -h db -U postgres messages

--docker exec -i 153369_db_1 pg_restore -h db -U postgres -d messages < "C:\Users\Kemp\Desktop\153369\messages.dump"

-- a
CREATE OR REPLACE FUNCTION get_latest_message(message_id integer)
RETURNS integer AS $$
DECLARE 
	store integer;
BEGIN
	SELECT id
    INTO store 
	FROM messages
	WHERE id = message_id
	ORDER BY created_at DESC 
	LIMIT 1;
	RETURN store;
END;
$$ LANGUAGE plpgsql;

-- b
SELECT ug.name AS name, COUNT(user_group_id) AS "number of users"
FROM users u
JOIN user_group_lists ugl 
ON u.id = ugl.user_id
JOIN user_groups ug
ON ugl.user_group_id = ug.id
GROUP BY name
ORDER BY "number of users" DESC;

-- c
SELECT status, COUNT(status)
FROM get_latest_message(1)
RIGHT JOIN message_items mi
ON message_id = mi.id
GROUP BY status;

-- d
SELECT COUNT(response) AS "number of responses"
FROM get_latest_message(1)
JOIN responses r
ON r.message_id = get_latest_message(message_id);

-- e
SELECT COUNT(mi.user_id) 
FROM responses r
RIGHT JOIN message_items mi
ON r.user_id = mi.user_id
WHERE r.message_item_id IS NULL;

-- f 
SELECT ug.name AS name, ug.total_population AS "total population", 
COUNT(ugl.user_group_id) AS subscribed, 
ug.total_population - COUNT(ugl.user_group_id) AS "not subscribed"
FROM users u
JOIN user_group_lists ugl 
ON u.id = ugl.user_id
JOIN user_groups ug
ON ugl.user_group_id = ug.id
GROUP BY name, "total_population";

-- g
SELECT mi.status, COUNT(mi.user_id)
FROM responses r
RIGHT JOIN message_items mi
ON r.user_id = mi.user_id
WHERE r.message_item_id IS NULL
GROUP BY mi.status;

-- h
CREATE OR REPLACE FUNCTION report_summary()
	RETURNS table ("not subscribed" numeric, "responded" bigint, "invalid number" bigint, "not sent" bigint) AS $$ 
	CREATE OR REPLACE VIEW notsub AS 
    SELECT (ug.total_population - COUNT(ugl.*)) AS ns
	FROM user_groups ug 
	INNER JOIN user_group_lists ugl 
	ON ug.id = ugl.user_group_id
	GROUP BY ug.name, ug.total_population;

CREATE OR REPLACE VIEW responded AS
 	SELECT message_id ,COUNT(*) AS count 
	FROM responses
	WHERE message_id = (SELECT get_latest_message(1))
	GROUP BY message_id;

CREATE OR REPLACE VIEW invalid AS
	SELECT status, COUNT(*) AS count
	FROM message_items
	WHERE status = 'INVALID NUMBER'
	GROUP BY status;	

CREATE OR REPLACE VIEW no AS 
 	SELECT status, COUNT(*) AS count
	FROM message_items
	WHERE status = 'NOT SENT'
	GROUP BY status;	

SELECT SUM(ns.ns) AS "not subscribed", r.count AS "responded", 
i.count AS "invalid number", n.count AS "not sent"
FROM notsub ns, responded r, invalid i, no n
GROUP BY r.count, i.count, n.count;
$$ LANGUAGE SQL;


-- i
SELECT SUBSTRING((SELECT message FROM messages WHERE id=1), 
POSITION(qc.choice IN (SELECT message FROM messages WHERE id=1)) + 6, 15) AS substring, 
COUNT(r.query_choice_id)
FROM responses r
LEFT JOIN query_choices qc ON qc.id = r.query_choice_id
GROUP BY qc.choice;