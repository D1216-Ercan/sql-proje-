



--E-Commerce Project Solution



--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

update orders_dimen
set Ord_id = REPLACE(Ord_id,'Ord_','')

update cust_dimen
set Cust_id = REPLACE(Cust_id,'Cust_','')

update shipping_dimen
set Ship_id = REPLACE(Ship_id,'SHP_','')

update prod_dimen
set Prod_id = REPLACE(Prod_id,'Prod_','') 

-----
   select * 
   from market_fact

update market_fact
set Ord_id = REPLACE(Ord_id,'Ord_',''),
--set Prod_id = REPLACE(Prod_id,'Prod_',''),
--set Ship_id = REPLACE(Ship_id,'SHP_','')
--set Cust_id = REPLACE(Cust_id,'Cust_','')

alter table market_fact alter column Ord_id int
alter table market_fact alter column Prod_id int
alter table market_fact alter column Ship_id int
alter table market_fact alter column Cust_id int

alter table cust_dimen alter column Cust_id int not null
alter table [dbo].[orders_dimen] alter column Ord_id int not null
alter table [dbo].[prod_dimen] alter column Prod_id int not null
alter table [dbo].[shipping_dimen] alter column Ship_id int not null


select *--, --count(*)
from cust_dimen
group by Cust_id

ALTER TABLE cust_dimen ADD CONSTRAINT pk_cust PRIMARY KEY (Cust_id)
ALTER TABLE orders_dimen ADD CONSTRAINT pk_orders PRIMARY KEY (Ord_id)
ALTER TABLE prod_dimen ADD CONSTRAINT pk_prod PRIMARY KEY (Prod_id)
ALTER TABLE shipping_dimen ADD CONSTRAINT pk_shipping PRIMARY KEY (Ship_id)


select a.*,b.Discount,b.Ord_id,b.Prod_id,b.Product_Base_Margin,d.Product_Sub_Category,
			c.Order_Date,c.Order_Priority,b.Order_Quantity,d.Product_Category,e.Ship_Date,
			e.Ship_Mode,b.Sales,b.Ship_id

--into combined_view

from [dbo].[cust_dimen] a, 
		[dbo].[market_fact] b, 
		[dbo].[orders_dimen] c,
		[dbo].[prod_dimen] d,
		[dbo].[shipping_dimen] e

where a.Cust_id = b.Cust_id
and b.Ord_id = c.Ord_id
and b.Prod_id = d.Prod_id
and b.Ship_id = e.Ship_id
 

--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.

select top 3 Cust_id, count(Ord_id) sipari�_say�s�
from dbo.combined_view
group by Cust_id 
order by sipari�_say�s� desc



--/////////////////////////////////
--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.
---3. Combined_table'da, Order_Date ve Ship_Date tarih fark�n� i�eren DaysTakenForDelivery olarak yeni bir s�tun olu�turun.
--"ALTER TABLE", "UPDATE" vb. kullan�n.

--------------------------------------------------------------------------------
update combined_view 
set Order_Date = CONVERT(DATE,SUBSTRING(Order_Date,7,10) + 
					  SUBSTRING(Order_Date,3,4) + SUBSTRING(Order_Date,1,2),23)
update combined_view
set Ship_Date =  CONVERT(DATE,SUBSTRING(Ship_Date,7,10) +
					  SUBSTRING(Ship_Date,3,4) + SUBSTRING(Ship_Date,1,2),23)
--Order_date ve Ship_Date  sutunlar�n�n veri t�r�n� Date cevirip, ifadeyi '2019-01-01' �ekliine �evirdik
----------------------------------------------------------------------------------
ALTER TABLE combined_view
ADD DaysTakenForDelivery INT
-----------------------------
select datediff(day, Order_Date, Ship_Date ) as fark
FROM combined_view
--------------------------------
UPDATE combined_view
SET DaysTakenForDelivery = datediff(day, Order_Date, Ship_Date )

--////////////////////////////////////

--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"
--4. Sipari�inin teslim edilmesi i�in maksimum s�reyi alan m��teriyi bulun.
--"MAX" veya "TOP" kullan�n

select max(DaysTakenForDelivery) maksimum_s�reli_sipari�
from combined_view
---------------------------------------
select top 1 DaysTakenForDelivery
from combined_view
order by DaysTakenForDelivery desc

--////////////////////////////////

--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use date functions and subqueries
--5. Ocak ay�ndaki toplam benzersiz m��teri say�s�n� ve 2011'de t�m y�l boyunca her ay ka� tanesinin geri geldi�ini say�n.
--Tarih fonksiyonlar�n� ve alt sorgular� kullanabilirsiniz.
--***********************************************************************************************
--2011 ocakay�ndaki benzersiz m��.say�s�

select count(distinct Cust_id) benzersiz_m��_say�s�
from combined_view
where Order_Date > '2010-12-31' and Order_Date < '2011-02-01'
---***************************************************************************************************
--2011 ocak ay�ndaki m��. y�li�inde aylarda d�nen say�

with t1 as (
		select distinct Cust_id,YEAR(Order_Date) Y�l,Month(Order_Date) Ay
		from combined_view
		where Order_Date > '2010-12-31' and Order_Date < '2012-01-01'
		and Cust_id in (
					select Distinct Cust_id  
					from combined_view
					where Order_Date > '2010-12-31' and Order_Date < '2011-02-01')
								)
select distinct t1.y�l, t1.ay, count(t1.Cust_id) over(partition by t1.ay) d�nen_2011_aya_g�re
from t1

--////////////////////////////////////////////


--6. write a query to return for each user acording to the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions
--6. ilk sat�n alma ile ���nc� sat�n alma aras�nda ge�en s�reye g�re her kullan�c� i�in iade edilecek bir sorgu yazabilir,
--M��teri Kimli�ine g�re artan s�rada
--Pencere ��levleriyle "MIN" kullan�n

with t1 as (
			select distinct Cust_id, Order_Date
			from combined_view),
		t2 as (
				select *,ROW_NUMBER() over(Partition by Cust_id Order by Order_date) row_num
				from t1
				where Cust_id in (
					select Cust_id
					from (
							select Cust_id, count(Ord_id) Cust_sip_say�lar�
							from combined_view
							group by Cust_id 
							) a
				where a.Cust_sip_say�lar� >= 3 )) ,
		t3 as (
				select *
				from t2
				where t2.row_num = 1 or t2.row_num = 3)	,
		t4 as (			
					select *,
						lag(t3.Order_date) over(partition by Cust_id Order By row_num) ilk_sipari�
					from t3)
select *, datediff(day, ilk_sipari�, Order_Date) bir_��_aras�_g�n
from t4
where row_num = 3

--ROW_NUMBER() over(Partition by Cust_id Order by Order_date) row_num
--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by all customers.
--Use CASE Expression, CTE, CAST and/or Aggregate Functions
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--7. Hem 11. �r�n� hem de 14. �r�n� sat�n alan m��terileri d�nd�ren bir sorgu yaz�n,
----ve bu �r�nlerin t�m m��teriler taraf�ndan sat�n al�nan toplam �r�n say�s�na oran�.
----CASE �fadesi, CTE, CAST ve/veya Toplama ��levlerini Kullan�n
----------------------------------------
WITH T1 AS
(
SELECT	distinct Cust_id,
		SUM (CASE WHEN Prod_id = '11' THEN Order_Quantity ELSE 0 END) P11,
		SUM (CASE WHEN Prod_id = '14' THEN Order_Quantity ELSE 0 END) P14,
		SUM (Order_Quantity) TOTAL_PROD
FROM	combined_view
GROUP BY Cust_id
HAVING
		SUM (CASE WHEN Prod_id = '11' THEN Order_Quantity ELSE 0 END) >= 1 AND
		SUM (CASE WHEN Prod_id = '14' THEN Order_Quantity ELSE 0 END) >= 1
)

SELECT	Cust_id, P11, P14, TOTAL_PROD,
		CAST (1.0*P11/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P11,
		CAST (1.0*P14/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P14
FROM T1
order by TOTAL_PROD

--/////////////////



--CUSTOMER SEGMENTATION



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.
--***********************************************************************************************************************************************
---1. M��terilerin ziyaret g�nl�klerini ayl�k olarak tutan bir g�r�n�m olu�turun. (Her log i�in �� alan tutulur: Cust_id, Year, Month)
--Bu t�r tarih fonksiyonlar�n� kullan�n. Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.

with t1 as (
			select Cust_id, Customer_Name, year(Order_Date) y�l, month(Order_Date) ay
			from combined_view  
				)
select distinct t1.Cust_id, t1.y�l,t1.ay
from t1

--count(t1.Cust_id) over(partition by t1.Cust_id, t1.Customer_Name, t1.y�l,t1.ay order by t1.Cust_id, t1.Customer_Name, t1.y�l,t1.ay) y�l_ay_geri_d�n_say�lar�
--//////////////////////////////////

--2.Create a �view� that keeps the number of monthly visits by users. (Show separately all months from the beginning  business)
--Don't forget to call up columns you might need later.

--**-*-*-*--*-*-*-*-**-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

--2.Kullan�c�lar�n ayl�k ziyaretlerinin say�s�n� tutan bir "g�r�n�m" olu�turun. (�� ba�lang�c�ndan itibaren t�m aylar� ayr� ayr� g�sterin)
--Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.

with t1 as (
			select A.Cust_id, year(A.Order_Date) y�l,MONTH(A.Order_Date) Month_
			from combined_view A
			)
select distinct t1.Cust_id,t1.y�l, t1.Month_, count(t1.Cust_id) over ( partition by t1.Cust_id, t1.Month_ Order by t1.Cust_id, t1.Month_ ) ayl�k_d�n��_say�s�
from t1	
order by t1.Cust_id, t1.Month_

--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can order the months using "DENSE_RANK" function.
--then create a new column for each month showing the next month using the order you have made above. (use "LEAD" function.)
--Don't forget to call up columns you might need later.
-------------------------------------------------------------------------------------------------------------------------------------
--3. M��terilerin her ziyareti i�in, ziyaretin bir sonraki ay�n� ayr� bir s�tun olarak olu�turun.
--"DENSE_RANK" fonksiyonunu kullanarak aylar� s�ralayabilirsiniz.
--daha sonra yukar�da yapt���n�z s�ray� kullanarak her ay i�in bir sonraki ay� g�steren yeni bir s�tun olu�turun. ("KUR�UN" i�levini kullan�n.)
--Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.

WITH t1 AS (
			SELECT	cust_id,
					YEAR (ORDER_DATE) [YEAR],
					MONTH (ORDER_DATE) [MONTH]
			FROM	combined_view
			), 
		t2 AS (
				SELECT	t1.Cust_id, t1.[YEAR], t1.[MONTH], COUNT(*) NUM_OF_LOG
				FROM	t1
				GROUP BY t1.Cust_id, t1.[YEAR], t1.[MONTH]
				)
SELECT *,LEAD(ilk_ziyaret_ay� ) OVER (PARTITION BY Cust_id ORDER BY ilk_ziyaret_ay�) sonraki_ziyaret_ay�
FROM  (
			SELECT  *,DENSE_RANK () OVER (ORDER BY [YEAR] , [MONTH]) ilk_ziyaret_ay�
			FROM	t2 ) A
			


--/////////////////////////////////



--4. Calculate monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.

--***************************************************************************************************************************

--4. Her m��teri taraf�ndan iki ard���k ziyaret aras�ndaki ayl�k zaman aral���n� hesaplay�n.
--Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.

WITH t1 AS (
			SELECT DISTINCT Cust_id, Order_Date
			FROM combined_view),
	 t2 AS (
			SELECT *, lead(t1.Order_Date) OVER( PARTITION BY t1.Cust_id ORDER BY t1.Order_Date) bir_sonraki_ziyaret
		    FROM t1)
SELECT *,datediff(month,t2.Order_Date,t2.bir_sonraki_ziyaret) fark
FROM t2

--where len(t2.bir_sonraki_ziyaret ) > 1


--///////////////////////////////////


--5.Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--For example: 
--Labeled as �churn� if the customer hasn't made another purchase for the months since they made their first purchase.
--Labeled as �regular� if the customer has made a purchase every month.
--Etc.
--5.Ortalama zaman bo�luklar�n� kullanarak m��terileri kategorilere ay�r�n. Size en uygun etiketleme modelini se�in.
--�rne�in:
--M��teri, ilk sat�n al�m�ndan bu yana aylar boyunca ba�ka bir sat�n alma i�lemi yapmad�ysa, "kay�p" olarak etiketlenir.
--M��teri her ay bir sat�n alma i�lemi yapt�ysa "d�zenli" olarak etiketlenir.
--Vb.	

WITH t1 AS (
			SELECT DISTINCT Cust_id, Order_Date
			FROM combined_view), 
	 t2 AS (
			SELECT *, lead(t1.Order_Date) OVER( PARTITION BY t1.Cust_id ORDER BY t1.Order_Date) bir_sonraki_ziyaret
			FROM t1),
	 t3 AS (
			SELECT *,datediff(month,t2.Order_Date,t2.bir_sonraki_ziyaret) fark
			FROM t2),
	 t4 AS (
			SELECT distinct t3.Cust_id, avg(t3.fark) over (PARTITION BY t3.Cust_id) avg_fark
			FROM t3)
SELECT *, 
CASE WHEN avg_fark = 1 THEN 'retained' 
	 WHEN avg_fark > 1 THEN 'irregular'
	 WHEN avg_fark IS NULL THEN 'Churn'
	 ELSE 'UNKNOWN DATA' END CUST_LABELS
FROM t4
ORDER BY t4.Cust_id

--/////////////////////////////////////

--MONTH-WISE RETENT�ON RATE


--Find month-by-month customer retention rate  since the start of the business.
--��in ba�lang�c�ndan bu yana ayl�k m��teri elde tutma oran�n� bulun.
-----------------
--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps
---1. Ay baz�nda elde tutulan m��teri say�s�n� bulun. (Zaman bo�luklar�n� kullanabilirsiniz)
--Zaman Bo�luklar�n� Kullan�n
-----------------------------------------------------------------------------------
WITH t1 AS (
			SELECT Cust_id, YEAR(Order_Date) y�l, MONTH(Order_Date) ay
			FROM combined_view),
	 t2 as (
		   SELECT distinct *, COUNT(t1.Cust_id) Over ( Partition by t1.Cust_id, t1.y�l,t1.ay) ayl�k_say�,
		        DENSE_RANK() over (order by t1.y�l, t1.ay) current_month
		   from t1),
 	 t3 as (
		   select *,lead(t2.current_month) over(partition by  t2.Cust_id order by t2.Cust_id) sonraki_sipari�_tar
		   from t2), 
	 t4 as (
		   select *, (t3.sonraki_sipari�_tar - t3.current_month) sipari�ler_aras�_fark
		   from t3)
select distinct t4.y�l,t4.ay, count(Cust_id) over(partition by t4.sonraki_sipari�_tar) RETENTITON_MONTH_WISE
from t4
where t4.sipari�ler_aras�_fark = 1
order by t4.y�l, t4.ay
			
--//////////////////////


--2. Calculate the month-wise retention rate.
--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month
--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.
--You should pay attention to the join type and join columns between your views or tables.
------------------------******************************-------------------------***************************--------------------------******************
---2. Ay baz�nda elde tutma oran�n� hesaplay�n.
--Temel form�l: o Ay Baz�nda Elde Tutma Oran� = 1.0 * ��inde Bulunulan Ayda Elde Tutulan M��teri Say�s� / ��inde Bulunan Aydaki Toplam M��teri Say�s�
--��lemleri tek bir ge�ici sorgu yerine par�alara b�lmek daha kolayd�r. G�r�n�m'� kullanman�z �nerilir.
--�sterseniz CTE veya Alt Sorgu da kullanabilirsiniz.
--G�r�n�mleriniz veya tablolar�n�z aras�nda birle�tirme t�r�ne ve birle�tirme s�tunlar�na dikkat etmelisiniz.

WITH t1 AS(
		  SELECT Cust_id, YEAR(Order_Date) y�l, MONTH(Order_Date) ay
		  FROM combined_view),
	 t2 as (
		  SELECT distinct *, DENSE_RANK() over (order by t1.y�l, t1.ay) current_month
		  from t1),
	 t3 as (
		  select *,lead(t2.current_month) over(partition by  t2.Cust_id order by t2.Cust_id) sonraki_sipari�_ay�,
						COUNT (t2.cust_id)	OVER (PARTITION BY Current_Month) NEXT_CUST1
		  from t2), 
	 t4 as (
		  select *,((t3.sonraki_sipari�_ay�) - (t3.current_month)) iki_al��_veris_fark
		  from t3),
	 t5 as (
		  select distinct t4.y�l,t4.ay,t4.current_month,t4.iki_al��_veris_fark,t4.sonraki_sipari�_ay�,t4.NEXT_CUST1,COUNT (t4.cust_id)	OVER (PARTITION BY Current_Month) NEXT_CUST
		  from t4
		  where t4.iki_al��_veris_fark = 1),
	 t6 as (
		  select *,lag(t5.NEXT_CUST) over(order by t5.current_month) sonraki_ay_gelen_m�s_say
		  from t5)
select t6.y�l,t6.ay, (1.0*(t6.NEXT_CUST) /( t6.NEXT_CUST1)) mut_ut_oran
from t6
where t6.current_month > 1









---///////////////////////////////////
--Good luck!