-- provided
WITH polygon AS (SELECT 'POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))' AS p)
SELECT
  ST_CONTAINS(ST_GEOGFROMTEXT(p), ST_GEOGPOINT(1, 1)) AS fromtext_default,
  ST_CONTAINS(ST_GEOGFROMTEXT(p, oriented => FALSE), ST_GEOGPOINT(1, 1)) AS non_oriented,
  ST_CONTAINS(ST_GEOGFROMTEXT(p, oriented => TRUE),  ST_GEOGPOINT(1, 1)) AS oriented
FROM polygon;

-- expected
WITH polygon AS (SELECT 'POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))' AS p)
SELECT
  ST_CONTAINS(ST_GEOMFROMTEXT(p), ST_POINT(1, 1)) AS fromtext_default,
  /*Warning: ORIENTED, PLANAR, MAKE_VALID parameters unsupported.*/ ST_CONTAINS(ST_GEOmFROMTEXT(p, oriented => FALSE), ST_POINT(1, 1)) AS non_oriented,
  /*Warning: ORIENTED, PLANAR, MAKE_VALID parameters unsupported.*/ ST_CONTAINS(ST_GEOmFROMTEXT(p, oriented => TRUE),  ST_POINT(1, 1)) AS oriented
FROM polygon;

-- result
"fromtext_default","non_oriented","oriented"
"true","true","true"


-- provided
select ST_GEOGFROMGEOJSON('{
    "type": "Point",
    "coordinates": [30.0, 10.0]}') as p;

-- expected
select ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [30.0, 10.0]}') as p;

-- result
"p"
"POINT (30 10)"


--provided
WITH wkb_data AS (
  SELECT '010200000002000000feffffffffffef3f000000000000f03f01000000000008400000000000000040' geo
)
SELECT
  ST_GeogFromWkb(geo, planar=>TRUE) AS from_planar,
  ST_GeogFromWkb(geo, planar=>FALSE) AS from_geodesic
FROM wkb_data
;

-- expected
WITH wkb_data AS (
        SELECT '010200000002000000feffffffffffef3f000000000000f03f01000000000008400000000000000040' geo  )
SELECT  /*Warning: ORIENTED, PLANAR, MAKE_VALID parameters unsupported.*/ If( Regexp_Matches( geo, '^[0-9A-Fa-f]+$' ), St_Geomfromhexewkb( geo ), St_Geomfromwkb( geo::BLOB ) ) AS from_planar
        , /*Warning: ORIENTED, PLANAR, MAKE_VALID parameters unsupported.*/  If( Regexp_Matches( geo, '^[0-9A-Fa-f]+$' ), St_Geomfromhexewkb( geo ), St_Geomfromwkb( geo::BLOB ) ) AS from_geodesic
FROM wkb_data
;

-- result
"from_planar","from_geodesic"
"LINESTRING (1 1, 3 2)","LINESTRING (1 1, 3 2)"


--provided
SELECT
  -- num_seg_quarter_circle=2
  ST_NUMPOINTS(ST_BUFFER(ST_GEOGFROMTEXT('POINT(1 2)'), 50, 2)) AS eight_sides,
  -- num_seg_quarter_circle=8, since 8 is the default
  ST_NUMPOINTS(ST_BUFFER(ST_GEOGFROMTEXT('POINT(100 2)'), 50)) AS thirty_two_sides;

-- expected
SELECT  St_Numpoints( St_Buffer( St_Geomfromtext( 'POINT(1 2)' )::GEOMETRY, 50, 2 )::GEOMETRY ) AS eight_sides
        , St_Numpoints( St_Buffer( St_Geomfromtext( 'POINT(100 2)' )::GEOMETRY, 50 )::GEOMETRY ) AS thirty_two_sides
;

-- result
"eight_sides","thirty_two_sides"
"9","33"


-- provided
WITH Geographies AS
 (SELECT ST_GEOGFROMTEXT('POINT(1 1)') AS g UNION ALL
  SELECT ST_GEOGFROMTEXT('LINESTRING(1 1, 2 2)') AS g UNION ALL
  SELECT ST_GEOGFROMTEXT('MULTIPOINT(2 11, 4 12, 0 15, 1 9, 1 12)') AS g)
SELECT
  g AS input_geography,
  ST_CONVEXHULL(g) AS convex_hull
FROM Geographies;

-- expected
WITH Geographies AS
 (SELECT ST_GEOMFROMTEXT('POINT(1 1)') AS g UNION ALL
  SELECT ST_GEOMFROMTEXT('LINESTRING(1 1, 2 2)') AS g UNION ALL
  SELECT ST_GEOMFROMTEXT('MULTIPOINT(2 11, 4 12, 0 15, 1 9, 1 12)') AS g)
SELECT
  g AS input_geography,
  ST_CONVEXHULL(g) AS convex_hull
FROM Geographies;

-- result
"input_geography","convex_hull"
"POINT (1 1)","POINT (1 1)"
"LINESTRING (1 1, 2 2)","LINESTRING (1 1, 2 2)"
"MULTIPOINT (2 11, 4 12, 0 15, 1 9, 1 12)","POLYGON ((1 9, 0 15, 4 12, 1 9))"


-- provided
SELECT
  ST_GEOGPOINT(i, i) AS p,
  ST_COVERS(ST_GEOGFROMTEXT('POLYGON((1 1, 20 1, 10 20, 1 1))'),
            ST_GEOGPOINT(i, i)) AS `covers`
FROM UNNEST([0, 1, 10]) AS i;

-- expected
SELECT
  ST_POINT(i, i) AS p,
  ST_COVERS(ST_GEOMFROMTEXT('POLYGON((1 1, 20 1, 10 20, 1 1))'),
            ST_POINT(i, i)) AS "covers"
FROM (select UNNEST([0, 1, 10]) AS i) AS i;

-- result
"p","covers"
"POINT (0 0)","false"
"POINT (1 1)","true"
"POINT (10 10)","true"


-- provided
SELECT
  ST_DIFFERENCE(
      ST_GEOGFROMTEXT('POLYGON((0 0, 10 0, 10 10, 0 0))'),
      ST_GEOGFROMTEXT('POLYGON((4 2, 6 2, 8 6, 4 2))')
  ) diff;


-- expected
SELECT
  ST_DIFFERENCE(
      ST_GEOMFROMTEXT('POLYGON((0 0, 10 0, 10 10, 0 0))'),
      ST_GEOMFROMTEXT('POLYGON((4 2, 6 2, 8 6, 4 2))')
  ) diff;

-- result
"diff"
"POLYGON ((10 10, 10 0, 0 0, 10 10), (6 2, 8 6, 4 2, 6 2))"


-- provided
WITH example AS (
  SELECT ST_GEOGFROMTEXT('POINT(0 0)') AS geography
  UNION ALL
  SELECT ST_GEOGFROMTEXT('MULTIPOINT(0 0, 1 1)') AS geography
  UNION ALL
  SELECT ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))'))
SELECT
  geography AS original_geography,
  ST_DUMP(geography) AS dumped_geographies
FROM example;


-- expected
WITH example AS (
  SELECT ST_GEOMFROMTEXT('POINT(0 0)') AS geography
  UNION ALL
  SELECT ST_GEOMFROMTEXT('MULTIPOINT(0 0, 1 1)') AS geography
  UNION ALL
  SELECT ST_GEOMFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))'))
SELECT
  geography AS original_geography,
  ST_DUMP(geography) AS dumped_geographies
FROM example;

-- result
"original_geography","dumped_geographies"
"POINT (0 0)","[{geom=POINT (0 0), path=[]}]"
"MULTIPOINT (0 0, 1 1)","[{geom=POINT (0 0), path=[1]}, {geom=POINT (1 1), path=[2]}]"
"GEOMETRYCOLLECTION (POINT (0 0), LINESTRING (1 2, 2 1))","[{geom=POINT (0 0), path=[1]}, {geom=LINESTRING (1 2, 2 1), path=[2]}]"


-- provided
SELECT ST_ENDPOINT(ST_GEOGFROMTEXT('LINESTRING(1 1, 2 1, 3 2, 3 3)')) `last`;

-- expected
SELECT ST_ENDPOINT(ST_GEOMFROMTEXT('LINESTRING(1 1, 2 1, 3 2, 3 3)')) "last";

-- result
"last"
"POINT (3 3)"


-- provided
WITH data AS (
  SELECT 1 id, ST_GEOGFROMTEXT('POLYGON((-125 48, -124 46, -117 46, -117 49, -125 48))') g
  UNION ALL
  SELECT 2 id, ST_GEOGFROMTEXT('POLYGON((172 53, -130 55, -141 70, 172 53))') g
  UNION ALL
  SELECT 3 id, ST_GEOGFROMTEXT('POINT EMPTY') g
  UNION ALL
  SELECT 4 id, ST_GEOGFROMTEXT('POLYGON((172 53, -141 70, -130 55, 172 53))', oriented => TRUE)
)
SELECT id, ST_BOUNDINGBOX(g) AS box
FROM data;

-- expected
WITH data AS (
  SELECT 1 id, ST_GEOMFROMTEXT('POLYGON((-125 48, -124 46, -117 46, -117 49, -125 48))') g
  UNION ALL
  SELECT 2 id, ST_GEOMFROMTEXT('POLYGON((172 53, -130 55, -141 70, 172 53))') g
  UNION ALL
  SELECT 3 id, ST_GEOMFROMTEXT('POINT EMPTY') g
  UNION ALL
  SELECT 4 id, ST_GEOMFROMTEXT('POLYGON((172 53, -141 70, -130 55, 172 53))', oriented => TRUE)
)
SELECT id, ST_EXTENT(g) AS box
FROM data;

-- result
"id","box"
"1","BOX(-125 46, -117 49)"
"2","BOX(-141 53, 172 70)"
"3",""
"4","BOX(-141 53, 172 70)"


-- provided
WITH data AS (
  SELECT 1 id, ST_GEOMFROMTEXT('POLYGON((-125 48, -124 46, -117 46, -117 49, -125 48))') g
  UNION ALL
  SELECT 2 id, ST_GEOMFROMTEXT('POLYGON((172 53, -130 55, -141 70, 172 53))') g
  UNION ALL
  SELECT 3 id, ST_GEOMFROMTEXT('POINT EMPTY') g
)
SELECT ST_EXTENT(g) AS box
FROM data;

-- expected
WITH data AS (
  SELECT 1 id, ST_GEOMFROMTEXT('POLYGON((-125 48, -124 46, -117 46, -117 49, -125 48))') g
  UNION ALL
  SELECT 2 id, ST_GEOMFROMTEXT('POLYGON((172 53, -130 55, -141 70, 172 53))') g
  UNION ALL
  SELECT 3 id, ST_GEOMFROMTEXT('POINT EMPTY') g
)
SELECT ST_Extent_Agg(g) AS box
FROM data;

-- result
"box"
"POLYGON ((-141 46, -141 70, 172 70, 172 46, -141 46))"


-- provided
WITH geo as
 (SELECT ST_GEOGFROMTEXT('POLYGON((0 0, 1 4, 2 2, 0 0))') AS g UNION ALL
  SELECT ST_GEOGFROMTEXT('POLYGON((1 1, 1 10, 5 10, 5 1, 1 1),
                                  (2 2, 3 4, 2 4, 2 2))') as g)
SELECT ST_EXTERIORRING(g) AS ring FROM geo;

-- expected
WITH geo as
 (SELECT ST_GEOMFROMTEXT('POLYGON((0 0, 1 4, 2 2, 0 0))') AS g UNION ALL
  SELECT ST_GEOMFROMTEXT('POLYGON((1 1, 1 10, 5 10, 5 1, 1 1),
                                  (2 2, 3 4, 2 4, 2 2))') as g)
SELECT ST_EXTERIORRING(g) AS ring FROM geo;

-- result
"ring"
"LINESTRING (0 0, 1 4, 2 2, 0 0)"
"LINESTRING (1 1, 1 10, 5 10, 5 1, 1 1)"


-- provided
WITH example AS(
  SELECT ST_GEOGFROMTEXT('POINT(0 1)') AS geography
  UNION ALL
  SELECT ST_GEOGFROMTEXT('MULTILINESTRING((2 2, 3 4), (5 6, 7 7))')
  UNION ALL
  SELECT ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(MULTIPOINT(-1 2, 0 12), LINESTRING(-2 4, 0 6))')
  UNION ALL
  SELECT ST_GEOGFROMTEXT('GEOMETRYCOLLECTION EMPTY'))
SELECT
  geography AS WKT,
  ST_GEOMETRYTYPE(geography) AS geometry_type_name
FROM example;

-- expected
WITH example AS(
  SELECT ST_GEOMFROMTEXT('POINT(0 1)') AS geography
  UNION ALL
  SELECT ST_GEOMFROMTEXT('MULTILINESTRING((2 2, 3 4), (5 6, 7 7))')
  UNION ALL
  SELECT ST_GEOMFROMTEXT('GEOMETRYCOLLECTION(MULTIPOINT(-1 2, 0 12), LINESTRING(-2 4, 0 6))')
  UNION ALL
  SELECT ST_GEOMFROMTEXT('GEOMETRYCOLLECTION EMPTY'))
SELECT
  geography AS WKT,
  ST_GEOMETRYTYPE(geography) AS geometry_type_name
FROM example;

-- result
"WKT","geometry_type_name"
"POINT (0 1)","POINT"
"MULTILINESTRING ((2 2, 3 4), (5 6, 7 7))","MULTILINESTRING"
"GEOMETRYCOLLECTION (MULTIPOINT (-1 2, 0 12), LINESTRING (-2 4, 0 6))","GEOMETRYCOLLECTION"
"GEOMETRYCOLLECTION EMPTY","GEOMETRYCOLLECTION"


-- provided
WITH example AS(
  SELECT ST_GEOGFROMTEXT('POINT(5 0)') AS geography
  UNION ALL
  SELECT ST_GEOGFROMTEXT('MULTIPOINT(0 1, 4 3, 2 6)') AS geography
  UNION ALL
  SELECT ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') AS geography
  UNION ALL
  SELECT ST_GEOGFROMTEXT('GEOMETRYCOLLECTION EMPTY'))
SELECT
  geography,
  ST_NUMGEOMETRIES(geography) AS num_geometries
FROM example;

-- expected
WITH example AS(
  SELECT ST_GEOMFROMTEXT('POINT(5 0)') AS geography
  UNION ALL
  SELECT ST_GEOMFROMTEXT('MULTIPOINT(0 1, 4 3, 2 6)') AS geography
  UNION ALL
  SELECT ST_GEOMFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') AS geography
  UNION ALL
  SELECT ST_GEOMFROMTEXT('GEOMETRYCOLLECTION EMPTY'))
SELECT
  geography,
  ST_NUMGEOMETRIES(geography) AS num_geometries
FROM example;

-- result
"geography","num_geometries"
"POINT (5 0)","1"
"MULTIPOINT (0 1, 4 3, 2 6)","3"
"GEOMETRYCOLLECTION (POINT (0 0), LINESTRING (1 2, 2 1))","2"
"GEOMETRYCOLLECTION EMPTY","0"


-- provided
WITH linestring AS (
    SELECT ST_GEOGFROMTEXT('LINESTRING(1 1, 2 1, 3 2, 3 3)') g
)
SELECT ST_POINTN(g, 1) AS first, ST_POINTN(g, -1) AS last,
    ST_POINTN(g, 2) AS second, ST_POINTN(g, -2) AS second_to_last
FROM linestring;

-- expected
WITH linestring AS (
    SELECT ST_GEOMFROMTEXT('LINESTRING(1 1, 2 1, 3 2, 3 3)') g
)
SELECT ST_POINTN(g, 1) AS first, ST_POINTN(g, -1) AS last,
    ST_POINTN(g, 2) AS second, ST_POINTN(g, -2) AS second_to_last
FROM linestring;

-- result
"first","last","second","second_to_last"
"POINT (1 1)","POINT (3 3)","POINT (2 1)","POINT (3 2)"


-- provided
WITH example AS
 (SELECT ST_GEOGFROMTEXT('LINESTRING(0 0, 0.05 0, 0.1 0, 0.15 0, 2 0)') AS line)
SELECT
   line AS original_line,
   ST_SIMPLIFY(line, 1) AS simplified_line
FROM example;

-- expected
WITH example AS
 (SELECT ST_GEOMFROMTEXT('LINESTRING(0 0, 0.05 0, 0.1 0, 0.15 0, 2 0)') AS line)
SELECT
   line AS original_line,
   ST_SIMPLIFY(line, 1) AS simplified_line
FROM example;

-- result
"original_line","simplified_line"
"LINESTRING (0 0, 0.05 0, 0.1 0, 0.15 0, 2 0)","LINESTRING (0 0, 2 0)"


-- provided
SELECT ST_STARTPOINT(ST_GEOGFROMTEXT('LINESTRING(1 1, 2 1, 3 2, 3 3)')) `first`;

-- expected
SELECT ST_STARTPOINT(ST_GEOMFROMTEXT('LINESTRING(1 1, 2 1, 3 2, 3 3)')) "first";

-- result
"first"
"POINT (1 1)"


-- provided
SELECT ST_UNION(
  ST_GEOGFROMTEXT('LINESTRING(-122.12 47.67, -122.19 47.69)'),
  ST_GEOGFROMTEXT('LINESTRING(-122.12 47.67, -100.19 47.69)')
) AS results;

-- expected
SELECT ST_UNION(
  ST_GEOMFROMTEXT('LINESTRING(-122.12 47.67, -122.19 47.69)'),
  ST_GEOMFROMTEXT('LINESTRING(-122.12 47.67, -100.19 47.69)')
) AS results;

-- result
"results"
"MULTILINESTRING ((-122.12 47.67, -122.19 47.69), (-122.12 47.67, -100.19 47.69))"


-- provided
SELECT ST_UNION_AGG(items) AS results
FROM UNNEST([
  ST_GEOGFROMTEXT('LINESTRING(-122.12 47.67, -122.19 47.69)'),
  ST_GEOGFROMTEXT('LINESTRING(-122.12 47.67, -100.19 47.69)'),
  ST_GEOGFROMTEXT('LINESTRING(-122.12 47.67, -122.19 47.69)')]) as items;

-- expected
SELECT ST_UNION_AGG(items) AS results
FROM (SELECT UNNEST([
  ST_GEOMFROMTEXT('LINESTRING(-122.12 47.67, -122.19 47.69)'),
  ST_GEOMFROMTEXT('LINESTRING(-122.12 47.67, -100.19 47.69)'),
  ST_GEOMFROMTEXT('LINESTRING(-122.12 47.67, -122.19 47.69)')]) as items) as items;

-- result
"results"
"MULTILINESTRING ((-122.12 47.67, -122.19 47.69), (-122.12 47.67, -100.19 47.69))"


-- provided
WITH points AS
   (SELECT ST_GEOGPOINT(i, i + 1) AS p FROM UNNEST([0, 5, 12]) AS i)
 SELECT
   p,
   ST_X(p) as longitude,
   ST_Y(p) as latitude
FROM points;


-- expected
WITH points AS
   (SELECT ST_POINT(i, i + 1) AS p FROM (Select UNNEST([0, 5, 12]) AS i) AS i)
 SELECT
   p,
   ST_X(p) as longitude,
   ST_Y(p) as latitude
FROM points;

-- result
"p","longitude","latitude"
"POINT (0 1)","0.0","1.0"
"POINT (5 6)","5.0","6.0"
"POINT (12 13)","12.0","13.0"

-- provided
select st_area(ST_GEOGFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))')) as area

-- expected
SELECT /*APPROXIMATION: SPHERE */ ST_Area_Spheroid(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))')) as area

-- results
"area"
12308778361.469452

-- provided
select st_asbinary(ST_GEOGFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))')) as wkb

-- expected
SELECT ST_aswkb(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))')) as wkb

-- results
"wkb"
"POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))"

-- provided
select ST_BUFFER(ST_GEOGFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 20) as buffer

-- expected
SELECT /*APPROXIMATION: ST_BUFFER IN METER */ ST_ASGEOJSON(ST_TRANSFORM(ST_BUFFER(ST_TRANSFORM(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 'EPSG:4326', 'EPSG:6933'), 20), 'EPSG:6933', 'EPSG:4326'))  as buffer

-- count
1

-- provided
select ST_BUFFERWITHTOLERANCE(ST_GEOGFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 20, tolerance_meters => 10) as buffer

-- expected
SELECT /*APPROXIMATION: ST_BUFFERWITHTOLERANCE AS ST_BUFFER IN METER */ ST_ASGEOJSON(ST_TRANSFORM(ST_BUFFER(ST_TRANSFORM(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 'EPSG:4326', 'EPSG:6933'), 20), 'EPSG:6933', 'EPSG:4326'))  as buffer

-- count
    1

-- provided
select ST_CLOSESTPOINT(ST_GEOGFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), ST_GEOGFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))')) as closest_point

-- expected
select ST_STARTPOINT(ST_ShortestLine(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), ST_GEOMFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))'))) as closest_point

-- results
"closest_point"
"POINT (1 1)"

-- provided
select ST_DISTANCE(ST_GEOGFROMTEXT('POINT(2.3058359 48.858904)'),ST_GEOGFROMTEXT('POINT(11.4594367 48.1549958)'), true) / 1000 as km

-- expected
select st_distance_spheroid(
               st_startpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POINT(2.3058359 48.858904)'),ST_GEOMFROMTEXT('POINT(11.4594367 48.1549958)')))),
               st_endpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POINT(2.3058359 48.858904)'),ST_GEOMFROMTEXT('POINT(11.4594367 48.1549958)'))))
       ) / 1000 AS km

-- results
"km"
680.463998149257

-- provided
select ST_DISTANCE(ST_GEOGFROMTEXT('POINT(2.3058359 48.858904)'),ST_GEOGFROMTEXT('POINT(11.4594367 48.1549958)')) / 1000 as km

-- expected
select st_distance_sphere(
               st_startpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POINT(2.3058359 48.858904)'),ST_GEOMFROMTEXT('POINT(11.4594367 48.1549958)')))),
               st_endpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POINT(2.3058359 48.858904)'),ST_GEOMFROMTEXT('POINT(11.4594367 48.1549958)'))))
       ) / 1000 AS km

-- results
"km"
678.4515514892884

-- provided
select 'in' AS label, st_dwithin(ST_GEOGFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'),ST_GEOGFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))'), 157226) AS within_distance
UNION ALL
select 'out' AS label, st_dwithin(ST_GEOGFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'),ST_GEOGFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))'), 157225) AS within_distance

-- expected
select 'in' AS label, COALESCE(st_distance_sphere(
                                       st_startpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'),ST_GEOMFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))')))),
                                       st_endpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'),ST_GEOMFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))'))))) <= 157226, FALSE) AS within_distance
UNION ALL
select 'out' AS label, COALESCE(st_distance_sphere(
                                        st_startpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'),ST_GEOMFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))')))),
                                        st_endpoint(ST_FLIPCOORDINATES(ST_SHORTESTLINE(ST_GEOMFROMTEXT('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'),ST_GEOMFROMTEXT('POLYGON((2 2, 2 3, 3 3, 3 2, 2 2))'))))) <= 157225, FALSE) AS within_distance

-- results
"label","within_distance"
"in","true"
"out","false"

-- provided
SELECT ST_GEOGFROMWKB(FROM_HEX('010100000000000000000000400000000000001040')) AS geo

-- expected
SELECT
    CASE TYPEOF(FROM_HEX('010100000000000000000000400000000000001040'))
        WHEN 'VARCHAR' THEN ST_GeomFromHEXWKB(FROM_HEX('010100000000000000000000400000000000001040')::VARCHAR)
        ELSE ST_GeomFromWKB(FROM_HEX('010100000000000000000000400000000000001040')::BLOB)
    END AS geo

-- results
"geo"
"POINT (2 4)"

-- provided
SELECT ST_GEOGFROMWKB('010100000000000000000000400000000000001040') AS geo

-- expected
SELECT
    CASE TYPEOF('010100000000000000000000400000000000001040')
        WHEN 'VARCHAR' THEN ST_GeomFromHEXWKB('010100000000000000000000400000000000001040'::VARCHAR)
        ELSE ST_GeomFromWKB('010100000000000000000000400000000000001040'::BLOB)
    END AS geo

-- results
"geo"
"POINT (2 4)"

-- provided
SELECT "Point" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "Point", "coordinates": [30.0, 10.0]}')) as geo
UNION ALL
SELECT "LineString" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "LineString", "coordinates": [[30.0, 10.0],[10.0, 30.0],[40.0, 40.0]]}'))
UNION ALL
SELECT "Polygon1" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "Polygon", "coordinates": [[[30.0, 10.0],[40.0, 40.0],[20.0, 40.0],[10.0, 20.0],[30.0, 10.0]]]}'))
UNION ALL
SELECT "Polygon2" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "Polygon", "coordinates": [[[35.0, 10.0],[45.0, 45.0],[15.0, 40.0],[10.0, 20.0],[35.0, 10.0]],[[20.0, 30.0],[35.0, 35.0],[30.0, 20.0],[20.0, 30.0]]]}'))
UNION ALL
SELECT "MultiPoint" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "MultiPoint", "coordinates": [[10.0, 40.0],[40.0, 30.0],[20.0, 20.0],[30.0, 10.0]]}'))
UNION ALL
SELECT "MultiLineString" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "MultiLineString", "coordinates": [[[10.0, 10.0],[20.0, 20.0],[10.0, 40.0]],[[40.0, 40.0],[30.0, 30.0],[40.0, 20.0],[30.0, 10.0]]]}'))
UNION ALL
SELECT "MultiPolygon" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "MultiPolygon", "coordinates": [[[[40.0, 40.0],[20.0, 45.0],[45.0, 30.0],[40.0, 40.0]]], [[[20.0, 35.0],[10.0, 30.0],[10.0, 10.0],[30.0, 5.0],[45.0, 20.0],[20.0, 35.0]],[[30.0, 20.0],[20.0, 15.0],[20.0, 25.0],[30.0, 20.0]]]]}'))
UNION ALL
SELECT "GeometryCollection" as type, ST_ISCOLLECTION(ST_GEOGFROMGEOJSON('{"type": "GeometryCollection","geometries": [{"type": "Point","coordinates": [40.0, 10.0]},{"type": "LineString","coordinates": [[10.0, 10.0],[20.0, 20.0],[10.0, 40.0]]},{"type": "Polygon","coordinates": [[[40.0, 40.0],[20.0, 45.0],[45.0, 30.0],[40.0, 40.0]]]}]}'))
UNION ALL
SELECT "Empty GeometryCollection" as type, ST_ISCOLLECTION(ST_GEOGFROMTEXT('GEOMETRYCOLLECTION EMPTY'))

-- expected
SELECT 'Point' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "Point", "coordinates": [30.0, 10.0]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "Point", "coordinates": [30.0, 10.0]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'LineString' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "LineString", "coordinates": [[30.0, 10.0],[10.0, 30.0],[40.0, 40.0]]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "LineString", "coordinates": [[30.0, 10.0],[10.0, 30.0],[40.0, 40.0]]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'Polygon1' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "Polygon", "coordinates": [[[30.0, 10.0],[40.0, 40.0],[20.0, 40.0],[10.0, 20.0],[30.0, 10.0]]]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "Polygon", "coordinates": [[[30.0, 10.0],[40.0, 40.0],[20.0, 40.0],[10.0, 20.0],[30.0, 10.0]]]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'Polygon2' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "Polygon", "coordinates": [[[35.0, 10.0],[45.0, 45.0],[15.0, 40.0],[10.0, 20.0],[35.0, 10.0]],[[20.0, 30.0],[35.0, 35.0],[30.0, 20.0],[20.0, 30.0]]]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "Polygon", "coordinates": [[[35.0, 10.0],[45.0, 45.0],[15.0, 40.0],[10.0, 20.0],[35.0, 10.0]],[[20.0, 30.0],[35.0, 35.0],[30.0, 20.0],[20.0, 30.0]]]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'MultiPoint' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "MultiPoint", "coordinates": [[10.0, 40.0],[40.0, 30.0],[20.0, 20.0],[30.0, 10.0]]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "MultiPoint", "coordinates": [[10.0, 40.0],[40.0, 30.0],[20.0, 20.0],[30.0, 10.0]]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'MultiLineString' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "MultiLineString", "coordinates": [[[10.0, 10.0],[20.0, 20.0],[10.0, 40.0]],[[40.0, 40.0],[30.0, 30.0],[40.0, 20.0],[30.0, 10.0]]]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "MultiLineString", "coordinates": [[[10.0, 10.0],[20.0, 20.0],[10.0, 40.0]],[[40.0, 40.0],[30.0, 30.0],[40.0, 20.0],[30.0, 10.0]]]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'MultiPolygon' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "MultiPolygon", "coordinates": [[[[40.0, 40.0],[20.0, 45.0],[45.0, 30.0],[40.0, 40.0]]], [[[20.0, 35.0],[10.0, 30.0],[10.0, 10.0],[30.0, 5.0],[45.0, 20.0],[20.0, 35.0]],[[30.0, 20.0],[20.0, 15.0],[20.0, 25.0],[30.0, 20.0]]]]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "MultiPolygon", "coordinates": [[[[40.0, 40.0],[20.0, 45.0],[45.0, 30.0],[40.0, 40.0]]], [[[20.0, 35.0],[10.0, 30.0],[10.0, 10.0],[30.0, 5.0],[45.0, 20.0],[20.0, 35.0]],[[30.0, 20.0],[20.0, 15.0],[20.0, 25.0],[30.0, 20.0]]]]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'GeometryCollection' as type, NOT ST_ISEMPTY(ST_GEOMFROMGEOJSON('{"type": "GeometryCollection","geometries": [{"type": "Point","coordinates": [40.0, 10.0]},{"type": "LineString","coordinates": [[10.0, 10.0],[20.0, 20.0],[10.0, 40.0]]},{"type": "Polygon","coordinates": [[[40.0, 40.0],[20.0, 45.0],[45.0, 30.0],[40.0, 40.0]]]}]}')) AND ST_GEOMETRYTYPE(ST_GEOMFROMGEOJSON('{"type": "GeometryCollection","geometries": [{"type": "Point","coordinates": [40.0, 10.0]},{"type": "LineString","coordinates": [[10.0, 10.0],[20.0, 20.0],[10.0, 40.0]]},{"type": "Polygon","coordinates": [[[40.0, 40.0],[20.0, 45.0],[45.0, 30.0],[40.0, 40.0]]]}]}')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')
UNION ALL
SELECT 'Empty GeometryCollection' AS TYPE, NOT ST_ISEMPTY(ST_GEOMFROMTEXT('GEOMETRYCOLLECTION EMPTY')) AND ST_GEOMETRYTYPE(ST_GEOMFROMTEXT('GEOMETRYCOLLECTION EMPTY')) IN ('MULTIPOINT', 'GEOMETRYCOLLECTION', 'MULTILINESTRING', 'MULTIPOLYGON')

-- results
"type","geo"
Point,false
LineString,false
Polygon1,false
Polygon2,false
MultiPoint,true
MultiLineString,true
MultiPolygon,true
GeometryCollection,true
Empty GeometryCollection,false

-- provided
SELECT st_length(st_geogfromtext("LINESTRING(0 0, 0 1, 1 1, 1 0, 0 0)")) as geo

-- expected
SELECT /* APPROXIMATION: ST_LENGTH SPHERE */ st_length_spheroid(st_flipcoordinates(st_geomfromtext('LINESTRING(0 0, 0 1, 1 1, 1 0, 0 0)'))) as geo

-- results
"geo"
443770.91724830196

-- provided
SELECT st_maxdistance(st_geogfromtext('LINESTRING(0 0, 0 1, 1 1, 1 0, 0 0)'), st_geogfromtext('LINESTRING(10 0, 10 1, 11 1, 11 0, 10 0)'))

-- expected
SELECT max(ST_DISTANCE_SPHERE(ST_FlipCoordinates(g1.UNNEST.geom), ST_FlipCoordinates(g2.UNNEST.geom))) AS max_distance FROM UNNEST(st_dump(st_points(st_geomfromtext('LINESTRING(0 0, 0 1, 1 1, 1 0, 0 0)')))) AS g1, UNNEST(st_dump(st_points(st_geomfromtext('LINESTRING(10 0, 10 1, 11 1, 11 0, 10 0)')))) g2

-- results
"max_distance"
1228126.109277834

-- provided
SELECT st_perimeter(st_geogfromtext('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))')) as perimeter

-- expected
SELECT st_perimeter_spheroid(st_geomfromtext('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))')) as perimeter

-- results
"perimeter"
443770.91724830196

-- provided
WITH DATA AS (
	SELECT '010100000000000000000000400000000000001040' AS INPUT
	UNION ALL
	SELECT 'POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'
	UNION ALL
	SELECT '{ "type": "Polygon", "coordinates": [ [ [2, 0], [2, 2], [1, 2], [0, 2], [0, 0], [2, 0] ] ] }'
)
SELECT
    ST_GEOGFROM(INPUT) AS geo
FROM DATA

-- expected
WITH DATA AS (
	SELECT '010100000000000000000000400000000000001040' AS INPUT
	UNION ALL
	SELECT 'POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'
	UNION ALL
	SELECT '{ "type": "Polygon", "coordinates": [ [ [2, 0], [2, 2], [1, 2], [0, 2], [0, 0], [2, 0] ] ] }'
)
SELECT
    CASE typeof(INPUT)
        WHEN 'VARCHAR' THEN
            CASE
                WHEN trim(INPUT::VARCHAR) LIKE '{%' THEN ST_GeomFromGeoJSON(INPUT::VARCHAR)
                WHEN regexp_full_match(upper(INPUT::VARCHAR), '^[0-9a-fA-F]+$') THEN ST_GeomFromHEXWKB(INPUT::VARCHAR)
                ELSE ST_GEOMFROMTEXT(INPUT::VARCHAR)
                --WHEN upper(trim(INPUT::VARCHAR)[0:5]) IN ('POINT', 'LINES', 'POLYG', 'MULTI', 'GEOME', 'CIRCU', 'COMPO', 'CURVE', 'SURFA', 'POLYH', 'TIN', 'TRIAN', 'CIRCL', 'GEODE', 'ELLIP', 'NURBS', 'CLOTH', 'SPIRA', 'BREPS', 'AFFIN') THEN ST_GEOMFROMTEXT(INPUT::VARCHAR)
                END
        ELSE ST_GeomFromWKB(INPUT::BLOB)
        END AS geo
FROM DATA

-- results
"geo"
"POINT(2 4)"
"POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))"
"POLYGON ((2 0, 2 2, 1 2, 0 2, 0 0, 2 0))"