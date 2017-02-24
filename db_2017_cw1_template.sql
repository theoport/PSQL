-- Q1 returns (name,dod)
SELECT 	person_b.name, person_a.dod
FROM 		person AS person_a 
				JOIN person AS person_b
				ON person_a.name = person_b.mother
				AND person_a.dod IS NOT NULL
;
-- Q2 returns (name)

;

-- Q3 returns (name)

;

-- Q4 returns (name,father,mother)

;

-- Q5 returns (name,popularity)

;

-- Q6 returns (name,forties,fifties,sixties)

;


-- Q7 returns (father,mother,child,born)

;

-- Q8 returns (father,mother,male)

;

