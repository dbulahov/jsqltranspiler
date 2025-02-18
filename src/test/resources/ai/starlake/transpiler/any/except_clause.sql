-- provided
SELECT TOP 10 * EXCEPT( salesid, listid, sellerid) REPLACE( eventid AS eventid)
FROM sales;

-- expected
SELECT * EXCLUDE( salesid, listid, sellerid) REPLACE( eventid AS eventid)
FROM sales
LIMIT 10;

-- result
"buyerid","eventid","dateid","qtysold","pricepaid","commission","saletime"
"21191","7872","1875","4","728.0","109.2","2008-02-18 02:36:48.0"
"11498","4337","1983","2","76.0","11.4","2008-06-06 05:00:16.0"
"17433","8647","1983","2","350.0","52.5","2008-06-06 08:26:17.0"
"19715","8647","1986","1","175.0","26.25","2008-06-09 08:38:52.0"
"14115","8240","2069","2","154.0","23.1","2008-08-31 09:17:02.0"
"24888","3375","2023","2","394.0","59.1","2008-07-16 11:59:24.0"
"7952","3375","2003","4","788.0","118.2","2008-06-26 12:56:06.0"
"19715","3375","2017","1","197.0","29.55","2008-07-10 02:12:36.0"
"29891","3375","2029","3","591.0","88.65","2008-07-22 02:23:17.0"
"10542","4769","2044","1","65.0","9.75","2008-08-06 02:51:55.0"
