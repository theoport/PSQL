--Joins person with itself using aliases
-- Q1 returns (name,dod)
SELECT 	person_b.name, person_a.dod
FROM 		person AS person_a 
				JOIN person AS person_b
				ON person_a.name = person_b.mother
				AND person_a.dod IS NOT NULL
;
--Joins person with itself using aliases, returns all
--names where no row can be found with the same name and father
-- Q2 returns (name)
SELECT 		person.name	
FROM 			person
WHERE NOT EXISTS
(	SELECT	*
	FROM 		person AS person_a JOIN
					person AS person_b
					ON person_a.name=person_b.father
					AND person_a.name=person.name)
AND person.gender='M'
ORDER BY	person.name
;
--Uses Except to check if list is empty after genders of a mothers children have been removed
--If list is empty, mother has children of both gender
-- Q3 returns (name)
SELECT DISTINCT person_a.mother AS name
FROM person AS person_a
WHERE NOT EXISTS
(	SELECT 	person.gender
	FROM		person
	EXCEPT
	SELECT	person.gender
	FROM 		person
	WHERE 	person.mother=person_a.mother)
ORDER BY person_a.mother;
;
--Uses ALL to check that all other dob's lie above the one we are cosidering, which makes it the first-born
-- Q4 returns (name,father,mother)
SELECT name,father,mother	
FROM 	person
WHERE dob <ALL(	SELECT dob
								FROM person AS person_a
								WHERE name<>person.name
								AND father=person.father
								AND mother=person.mother)
AND	mother IS NOT NULL
AND	father IS NOT NULL
ORDER BY name
;
-- Q5 returns (name,popularity)
--After creating a list of only first names, list is grouped by names, which are also counted
SELECT name, COUNT(name)
FROM(	SELECT CASE WHEN POSITION(' ' IN person.name)>0 
			THEN SUBSTRING(person.name FROM 1 
			FOR POSITION(' ' IN person.name)-1)
			ELSE person.name END AS name
			FROM person) AS t
GROUP BY name
HAVING COUNT(t.name)>1
ORDER BY COUNT(t.name) DESC,name
;

--Creates a union between fathers and mothers that have at least two children
--and counts how many children have been born in the appropriate time-periods
-- Q6 returns (name,forties,fifties,sixties)
SELECT 	mother AS name,
				COUNT(CASE WHEN EXTRACT(YEAR FROM dob)BETWEEN 1940 AND 1949
				THEN dob ELSE NULL END) AS forties,
				COUNT(CASE WHEN EXTRACT(YEAR FROM dob)BETWEEN 1950 AND 1959
				THEN dob ELSE NULL END) AS fifties,
				COUNT(CASE WHEN EXTRACT(YEAR FROM dob)BETWEEN 1960 AND 1969
				THEN dob ELSE NULL END) AS sixties
FROM person
WHERE mother IS NOT NULL
GROUP BY mother
HAVING COUNT(dob)>1
UNION
SELECT 	father AS name,
				COUNT(CASE WHEN EXTRACT(YEAR FROM dob)BETWEEN 1940 AND 1949
				THEN dob ELSE NULL END) AS forties,
				COUNT(CASE WHEN EXTRACT(YEAR FROM dob)BETWEEN 1950 AND 1959
				THEN dob ELSE NULL END) AS fifties,
				COUNT(CASE WHEN EXTRACT(YEAR FROM dob)BETWEEN 1960 AND 1969
				THEN dob ELSE NULL END) AS sixties
FROM person
WHERE father IS NOT NULL
GROUP BY father 
HAVING COUNT(dob)>1
ORDER BY name

;
--Joins person with itself, then counts how many children in person_a are younger
--than the child in person_b, after removing rows where parents didnt match up
--and grouping the join list
-- Q7 returns (father,mother,child,born)
SELECT	person_a.father AS father,
				person_a.mother AS mother,
				person_b.name AS child,
				COUNT(CASE WHEN (person_a.dob<=person_b.dob) 
				THEN person_a.dob ELSE NULL END) AS born 
				FROM 	person AS person_a 
							JOIN person AS person_b
				ON person_a.mother IS NOT NULL
				AND	person_a.father IS NOT NULL
				AND person_a.father=person_b.father
				AND person_a.mother=person_b.mother
				GROUP BY person_a.mother,person_a.father,person_b.name
				ORDER BY 	father,mother,
									COUNT(CASE WHEN (person_a.dob<=person_b.dob) 
									THEN person_a.dob ELSE NULL END)	
;
--Uses nested Select to count the number of males and the total number of children
-- Q8 returns (father,mother,male)
SELECT 	father,mother,
				ROUND((100*males)/total,0) AS male
FROM (	SELECT father,mother,
				COUNT(CASE WHEN gender LIKE 'M%' THEN gender ELSE NULL END) AS males,
				COUNT(name) AS total
				FROM person
				GROUP BY father,mother
				HAVING father IS NOT NULL
				AND mother IS NOT NULL) AS t
ORDER BY father,mother
;

