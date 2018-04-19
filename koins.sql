--docker-compose run db createdb -h db -U postgres koins 
--docker-compose run db psql -h db -U postgres koins

--docker exec -i 153369_db_1 pg_restore -h db -U postgres -d koins < "C:\Users\Kemp\Desktop\153369\koins.dump"


-- a 
SELECT je.post_type , SUM(je.amount) 
FROM journal_entries je
JOIN vouchers v 
ON v.id = je.voucher_id
WHERE v.status = 'approved'
GROUP BY je.post_type;

-- b
SELECT je.accounting_code_id, SUM(je.amount) 
FROM journal_entries je
JOIN accounting_codes ac
ON je.accounting_code_id = ac.id
JOIN vouchers v
ON v.id = je.voucher_id
WHERE v.approved_by IS NOT NULL
GROUP BY je.accounting_code_id
ORDER BY je.accounting_code_id;

-- c 
CREATE OR REPLACE FUNCTION compute_past_due_principal_amount(loan integer, inquiry_date timestamp)
RETURNS numeric AS $$
DECLARE 
	store numeric;
BEGIN
	 SELECT SUM(principal) - SUM(paid_principal) 
	 INTO store
	 FROM ammortization_schedule_entries
	 WHERE loan = loan_id 
	 AND inquiry_date >= created_at;
	 RETURN store;
END;
$$ LANGUAGE plpgsql;
