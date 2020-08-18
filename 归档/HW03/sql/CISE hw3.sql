--1
SELECT Country.name
FROM Country, Economy
WHERE Country.code=Economy.country AND Economy.agriculture>=50;
--2
SELECT * FROM(SELECT Country.name, Country.population*POWER((1+Population_Growth/100),5) Population,
                     RANK() OVER (ORDER BY Country.population*POWER((1+Population_Growth/100),5) DESC) rnk
              FROM Country, Population
              WHERE Country.code=Population.country AND Population_Growth IS NOT NULL)
WHERE rnk<=5;

--3
SELECT  c1, num1 AS n1, c2, num2 AS n2,num1-num2 AS difference 
FROM(SELECT c.name c1 ,COUNT(p.country) AS num1 
     FROM Politics p, country c
     WHERE p.wasdependent=c.code
     GROUP BY p.wasdependent,c.name
     HAVING p.wasdependent IS NOT NULL),
    (SELECT c.name c2,COUNT(p.country) AS num2 
     FROM Politics p, country c
     WHERE p.dependent=c.code
     GROUP BY p.dependent,c.name
     HAVING p.dependent IS NOT NULL)
WHERE num1=(SELECT MAX (COUNT (country)) 
            FROM Politics 
            GROUP BY wasdependent 
            HAVING wasdependent IS NOT NULL)
AND
      num2=(SELECT MAX (COUNT (country)) 
            FROM Politics 
            GROUP BY dependent 
            HAVING dependent IS NOT NULL);
--4
SELECT name 
FROM(
SELECT c.name name,COUNT(r.name) rn, MAX(r.percentage) max_p
FROM religion r,country c
WHERE r.country=c.code
GROUP BY r.country,c.name
HAVING COUNT(r.name)>4)
WHERE max_p>80;
--5
 SELECT SUM(length) total_length
FROM(SELECT * 
     FROM (SELECT c.name,b.length
           FROM borders b, country c
           WHERE b.country1=c.code)
           UNION ALL
          (SELECT c.name,b.length
           FROM borders b, country c
           WHERE b.country2=c.code))
WHERE name LIKE 'China';    
--6
SELECT * 
FROM(SELECT r.name religion0,
            SUM(((r.percentage)/100)*c.population),
            RANK() OVER (ORDER BY SUM(((r.percentage)/100)*c.population) DESC) rnk
FROM religion r,country c
WHERE r.country = c.code 
GROUP BY r.name)
WHERE rnk <=5;

--7
SELECT DISTINCT lakename 
FROM(SELECT lake.name lakename ,lake.elevation,country.name countryname
     FROM lake, geo_lake,country
     WHERE lake.name=geo_lake.lake 
     AND geo_lake.country=country.code
     AND country.name = 'United States'
     AND lake.elevation>(SELECT AVG(lake.elevation) 
                         FROM lake 
                         WHERE lake.elevation IS NOT NULL));
--8
SELECT p.name province_name ,m.name mountain_name,p.population/p.area pop_density
FROM province p, geo_mountain g, mountain m
WHERE g.mountain = m.name
AND p.name=g.province
AND m.type='volcano'
AND p.population/p.area = (SELECT MAX(p.population/p.area) density 
                              FROM province p, geo_mountain g, mountain m 
                              WHERE g.mountain = m.name
                              AND p.name=g.province
                              AND m.type='volcano') 
;
--9
SELECT gi.province province
FROM geo_island gi, economy e
WHERE gi.country=e.country
AND e.gdp>1000000
GROUP BY gi.province
HAVING COUNT( gi.island)>2;

--10
SELECT rivername , riverlength FROM (SELECT r.name rivername, r.length riverlength, 
RANK() OVER(ORDER BY r.length DESC) rnk
FROM river r, riverthrough rt
WHERE rt.river=r.name
AND r.sea='Atlantic Ocean')
WHERE rnk <3;

--11
SELECT c.name
FROM geo_lake gl, geo_river gr, country c
WHERE c.code=gr.country
AND c.code=gl.country
GROUP BY c.code, c.name
HAVING COUNT(gr.river)>3 AND COUNT(gl.province)>3;

SELECT c.name 
FROM ((SELECT country 
       FROM geo_lake 
       GROUP BY country,lake 
       HAVING COUNT(province)>3)
INTERSECT
       (SELECT country 
       FROM geo_river 
       GROUP BY country 
       HAVING COUNT(DISTINCT(river))>3)) t, Country c
WHERE c.code=t.country;

--12
SELECT c.name names
FROM (SELECT gl.country country, MAX(l.area) 
      FROM lake l, geo_lake gl
      WHERE l.name=gl.lake
      GROUP BY gl.country
      HAVING MAX(l.area)>=ALL(SELECT MAX(l.area)
                              FROM lake l, geo_lake gl
                              WHERE l.name=gl.lake
                              GROUP BY gl.country )) a ,
      country c
      WHERE c.code=a.country;


--13
SELECT MAX(m.elevation) height, e.continent continent_name
FROM mountain m, geo_mountain gm, encompasses e
WHERE m.name=gm.mountain
AND gm.country=e.country
GROUP BY e.continent ;

--14

SELECT  name1, s.deepest, m.highest 
FROM((SELECT c.name name1 , MAX(s.depth) deepest
     FROM sea s, geo_sea gs,country c
     WHERE s.name = gs.sea
     AND gs.country = c.code
     GROUP BY gs.country,c.name) s),
    ((SELECT c.name name2 , MAX(m.elevation) highest
     FROM mountain m, geo_mountain gm,country c
     WHERE m.name= gm.mountain 
     AND gm.country= c.code
     GROUP BY gm.country,c.name) m)
WHERE s.name1=m.name2
AND s.deepest<m.highest;
--15
SELECT c.name cityname, g.zhou continent
FROM(SELECT e.continent zhou, MAX(c.latitude) ml
     FROM city c, encompasses e 
     WHERE c.country=e.country
     AND e.continent !='Asia'
     GROUP BY e.continent) g, city c, encompasses e
     WHERE c.latitude=g.ml
     AND c.country = e.country
     AND g.zhou = e.continent;
--16
SELECT co.name countryname 
FROM country co, city ci
WHERE co.capital=ci.name
AND co.code=ci.country
AND ci.latitude>0
AND ci.population<10000;
--17
SELECT SUM(f.top) top10 ,SUM(e.itop) rest_world, SUM(f.top)-SUM(e.itop) the_difference
FROM (SELECT c.area top,RANK() OVER(ORDER BY c.area DESC) rnk
      FROM country c) f,
      (SELECT d.area itop,RANK() OVER(ORDER BY d.area DESC) ran
      FROM country d) e
      WHERE ran>10
      AND rnk<=10;
 --18
 SELECT distinct c.name
 FROM encompasses e, country c
 WHERE e.country = c.code
 AND e.percentage!=100;
--19
SELECT i.name ,i.area areas
      FROM island i, geo_island gi, encompasses e
      WHERE i.name =gi.island
      AND gi.country=e.country
      AND e.continent='Africa'
      AND i.area>1000 ORDER BY i.area DESC;
      
 --20    
SELECT c.name ,e.gdp
FROM country c,Economy e, religion r, isMember im
WHERE c.code=e.country
AND e.country=r.country
AND r.country=im.country
AND im.organization = 'NATO'
AND im.type='member'
AND r.name='Muslim'
AND r.percentage>5;
      
--21
SELECT s.river 
FROM(select gr.river,gr.country,COUNT(gr.province)
     FROM geo_river gr 
     GROUP BY gr.river,gr.country 
     HAVING COUNT(gr.province)>=12) s;
     
--22
SELECT DISTINCT (r.name), r.length 
FROM river r,geo_river gr, encompasses e
WHERE r.name=gr.river 
AND gr.country = e.country 
AND e.continent ='America'
AND r.length>=ALL(SELECT r.length 
                  FROM river r,geo_river gr, encompasses e
                  WHERE r.name = gr.river 
                  AND gr.country = e.country 
                  AND e.continent ='America');
     
--23
SELECT p.country, s.province, s.num 
FROM province p,(SELECT DISTINCT(gi.province),COUNT(gi.island) num 
                  FROM geo_island gi
                  GROUP BY gi.province
                  HAVING COUNT (gi.island)>=all(SELECT COUNT(gi.island)
                                                FROM geo_island gi GROUP BY gi.province))s
WHERE p.name =s.province;
     
--24
SELECT s.countryname, s.populationdensity,s.population/t.total
FROM (SELECT SUM(c.population) total 
      FROM country c) t,
      (SELECT c.name countryname,c.population/c.area populationdensity,c.population,
      RANK() OVER (ORDER BY c.population/c.area DESC) rank 
      FROM country c) s WHERE s.rank<=10;
     
--25
SELECT name 
FROM(SELECT o.name name 
     FROM organization o,isMember im, encompasses e
     WHERE o.abbreviation = im.organization
     AND im.country=e.country
     AND im.type ='member'
     AND e.continent = 'Asia')
     MINUS
     (SELECT o.name name
     FROM organization o,isMember im, encompasses e
     WHERE o.abbreviation = im.organization
     AND im.country=e.country
     AND im.type ='member'
     AND e.continent != 'Asia');