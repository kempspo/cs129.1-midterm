
CREATE TABLE members(
	id SERIAl NOT NULL PRIMARY KEY,
	first_name VARCHAR(45) NOT NULL,  
	last_name VARCHAR(45) NOT NULL,
	info JSONB NOT NULL
	);

INSERT INTO members (first_name, last_name, info) VALUES (
 	'Foo','Bar', 
	'{
		"accounts" : [
		{
			"balance" : 20000.00,
			"account_type": "checking"
		},
		{
			"balance": 5000.00,
			"account_type": "savings"
		}
		]
	}'
),  (
	'Joobs', 'Bau', 
	'{
		"accounts" : [
		{
			"balance": -1000.00,
			"account_type": "savings"
		},
		{
			"balance": 0.00,
			"account_type": "checking"
		}
		]
	}'
);
