



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

select top 3 Cust_id, count(Ord_id) sipariþ_sayýsý
from dbo.combined_view
group by Cust_id 
order by sipariþ_sayýsý desc



--/////////////////////////////////
--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.
---3. Combined_table'da, Order_Date ve Ship_Date tarih farkýný içeren DaysTakenForDelivery olarak yeni bir sütun oluþturun.
--"ALTER TABLE", "UPDATE" vb. kullanýn.

--------------------------------------------------------------------------------
update combined_view 
set Order_Date = CONVERT(DATE,SUBSTRING(Order_Date,7,10) + 
					  SUBSTRING(Order_Date,3,4) + SUBSTRING(Order_Date,1,2),23)
update combined_view
set Ship_Date =  CONVERT(DATE,SUBSTRING(Ship_Date,7,10) +
					  SUBSTRING(Ship_Date,3,4) + SUBSTRING(Ship_Date,1,2),23)
--Order_date ve Ship_Date  sutunlarýnýn veri türünü Date cevirip, ifadeyi '2019-01-01' þekliine çevirdik
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
--4. Sipariþinin teslim edilmesi için maksimum süreyi alan müþteriyi bulun.
--"MAX" veya "TOP" kullanýn

select max(DaysTakenForDelivery) maksimum_süreli_sipariþ
from combined_view
---------------------------------------
select top 1 DaysTakenForDelivery
from combined_view
order by DaysTakenForDelivery desc

--////////////////////////////////

--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use date functions and subqueries
--5. Ocak ayýndaki toplam benzersiz müþteri sayýsýný ve 2011'de tüm yýl boyunca her ay kaç tanesinin geri geldiðini sayýn.
--Tarih fonksiyonlarýný ve alt sorgularý kullanabilirsiniz.
--***********************************************************************************************
--2011 ocakayýndaki benzersiz müþ.sayýsý

select count(distinct Cust_id) benzersiz_müþ_sayýsý
from combined_view
where Order_Date > '2010-12-31' and Order_Date < '2011-02-01'
---***************************************************************************************************
--2011 ocak ayýndaki müþ. yýliçinde aylarda dönen sayý

with t1 as (
		select distinct Cust_id,YEAR(Order_Date) Yýl,Month(Order_Date) Ay
		from combined_view
		where Order_Date > '2010-12-31' and Order_Date < '2012-01-01'
		and Cust_id in (
					select Distinct Cust_id  
					from combined_view
					where Order_Date > '2010-12-31' and Order_Date < '2011-02-01')
								)
select distinct t1.yýl, t1.ay, count(t1.Cust_id) over(partition by t1.ay) dönen_2011_aya_göre
from t1

--////////////////////////////////////////////


--6. write a query to return for each user acording to the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions
--6. ilk satýn alma ile üçüncü satýn alma arasýnda geçen süreye göre her kullanýcý için iade edilecek bir sorgu yazabilir,
--Müþteri Kimliðine göre artan sýrada
--Pencere Ýþlevleriyle "MIN" kullanýn

with t1 as (
			select distinct Cust_id, Order_Date
			from combined_view),
		t2 as (
				select *,ROW_NUMBER() over(Partition by Cust_id Order by Order_date) row_num
				from t1
				where Cust_id in (
					select Cust_id
					from (
							select Cust_id, count(Ord_id) Cust_sip_sayýlarý
							from combined_view
							group by Cust_id 
							) a
				where a.Cust_sip_sayýlarý >= 3 )) ,
		t3 as (
				select *
				from t2
				where t2.row_num = 1 or t2.row_num = 3)	,
		t4 as (			
					select *,
						lag(t3.Order_date) over(partition by Cust_id Order By row_num) ilk_sipariþ
					from t3)
select *, datediff(day, ilk_sipariþ, Order_Date) bir_üç_arasý_gün
from t4
where row_num = 3

--ROW_NUMBER() over(Partition by Cust_id Order by Order_date) row_num
--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by all customers.
--Use CASE Expression, CTE, CAST and/or Aggregate Functions
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--7. Hem 11. ürünü hem de 14. ürünü satýn alan müþterileri döndüren bir sorgu yazýn,
----ve bu ürünlerin tüm müþteriler tarafýndan satýn alýnan toplam ürün sayýsýna oraný.
----CASE Ýfadesi, CTE, CAST ve/veya Toplama Ýþlevlerini Kullanýn
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
---1. Müþterilerin ziyaret günlüklerini aylýk olarak tutan bir görünüm oluþturun. (Her log için üç alan tutulur: Cust_id, Year, Month)
--Bu tür tarih fonksiyonlarýný kullanýn. Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.

with t1 as (
			select Cust_id, Customer_Name, year(Order_Date) yýl, month(Order_Date) ay
			from combined_view  
				)
select distinct t1.Cust_id, t1.yýl,t1.ay
from t1

--count(t1.Cust_id) over(partition by t1.Cust_id, t1.Customer_Name, t1.yýl,t1.ay order by t1.Cust_id, t1.Customer_Name, t1.yýl,t1.ay) yýl_ay_geri_dön_sayýlarý
--//////////////////////////////////

--2.Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning  business)
--Don't forget to call up columns you might need later.

--**-*-*-*--*-*-*-*-**-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--

--2.Kullanýcýlarýn aylýk ziyaretlerinin sayýsýný tutan bir "görünüm" oluþturun. (Ýþ baþlangýcýndan itibaren tüm aylarý ayrý ayrý gösterin)
--Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.

with t1 as (
			select A.Cust_id, year(A.Order_Date) yýl,MONTH(A.Order_Date) Month_
			from combined_view A
			)
select distinct t1.Cust_id,t1.yýl, t1.Month_, count(t1.Cust_id) over ( partition by t1.Cust_id, t1.Month_ Order by t1.Cust_id, t1.Month_ ) aylýk_dönüþ_sayýsý
from t1	
order by t1.Cust_id, t1.Month_

--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can order the months using "DENSE_RANK" function.
--then create a new column for each month showing the next month using the order you have made above. (use "LEAD" function.)
--Don't forget to call up columns you might need later.
-------------------------------------------------------------------------------------------------------------------------------------
--3. Müþterilerin her ziyareti için, ziyaretin bir sonraki ayýný ayrý bir sütun olarak oluþturun.
--"DENSE_RANK" fonksiyonunu kullanarak aylarý sýralayabilirsiniz.
--daha sonra yukarýda yaptýðýnýz sýrayý kullanarak her ay için bir sonraki ayý gösteren yeni bir sütun oluþturun. ("KURÞUN" iþlevini kullanýn.)
--Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.

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
SELECT *,LEAD(ilk_ziyaret_ayý ) OVER (PARTITION BY Cust_id ORDER BY ilk_ziyaret_ayý) sonraki_ziyaret_ayý
FROM  (
			SELECT  *,DENSE_RANK () OVER (ORDER BY [YEAR] , [MONTH]) ilk_ziyaret_ayý
			FROM	t2 ) A
			


--/////////////////////////////////



--4. Calculate monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.

--***************************************************************************************************************************

--4. Her müþteri tarafýndan iki ardýþýk ziyaret arasýndaki aylýk zaman aralýðýný hesaplayýn.
--Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.

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
--Labeled as “churn” if the customer hasn't made another purchase for the months since they made their first purchase.
--Labeled as “regular” if the customer has made a purchase every month.
--Etc.
--5.Ortalama zaman boþluklarýný kullanarak müþterileri kategorilere ayýrýn. Size en uygun etiketleme modelini seçin.
--Örneðin:
--Müþteri, ilk satýn alýmýndan bu yana aylar boyunca baþka bir satýn alma iþlemi yapmadýysa, "kayýp" olarak etiketlenir.
--Müþteri her ay bir satýn alma iþlemi yaptýysa "düzenli" olarak etiketlenir.
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

--MONTH-WISE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.
--Ýþin baþlangýcýndan bu yana aylýk müþteri elde tutma oranýný bulun.
-----------------
--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps
---1. Ay bazýnda elde tutulan müþteri sayýsýný bulun. (Zaman boþluklarýný kullanabilirsiniz)
--Zaman Boþluklarýný Kullanýn
-----------------------------------------------------------------------------------
WITH t1 AS (
			SELECT Cust_id, YEAR(Order_Date) yýl, MONTH(Order_Date) ay
			FROM combined_view),
	 t2 as (
		   SELECT distinct *, COUNT(t1.Cust_id) Over ( Partition by t1.Cust_id, t1.yýl,t1.ay) aylýk_sayý,
		        DENSE_RANK() over (order by t1.yýl, t1.ay) current_month
		   from t1),
 	 t3 as (
		   select *,lead(t2.current_month) over(partition by  t2.Cust_id order by t2.Cust_id) sonraki_sipariþ_tar
		   from t2), 
	 t4 as (
		   select *, (t3.sonraki_sipariþ_tar - t3.current_month) sipariþler_arasý_fark
		   from t3)
select distinct t4.yýl,t4.ay, count(Cust_id) over(partition by t4.sonraki_sipariþ_tar) RETENTITON_MONTH_WISE
from t4
where t4.sipariþler_arasý_fark = 1
order by t4.yýl, t4.ay
			
--//////////////////////


--2. Calculate the month-wise retention rate.
--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month
--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.
--You should pay attention to the join type and join columns between your views or tables.
------------------------******************************-------------------------***************************--------------------------******************
---2. Ay bazýnda elde tutma oranýný hesaplayýn.
--Temel formül: o Ay Bazýnda Elde Tutma Oraný = 1.0 * Ýçinde Bulunulan Ayda Elde Tutulan Müþteri Sayýsý / Ýçinde Bulunan Aydaki Toplam Müþteri Sayýsý
--Ýþlemleri tek bir geçici sorgu yerine parçalara bölmek daha kolaydýr. Görünüm'ü kullanmanýz önerilir.
--Ýsterseniz CTE veya Alt Sorgu da kullanabilirsiniz.
--Görünümleriniz veya tablolarýnýz arasýnda birleþtirme türüne ve birleþtirme sütunlarýna dikkat etmelisiniz.

WITH t1 AS(
		  SELECT Cust_id, YEAR(Order_Date) yýl, MONTH(Order_Date) ay
		  FROM combined_view),
	 t2 as (
		  SELECT distinct *, DENSE_RANK() over (order by t1.yýl, t1.ay) current_month
		  from t1),
	 t3 as (
		  select *,lead(t2.current_month) over(partition by  t2.Cust_id order by t2.Cust_id) sonraki_sipariþ_ayý,
						COUNT (t2.cust_id)	OVER (PARTITION BY Current_Month) NEXT_CUST1
		  from t2), 
	 t4 as (
		  select *,((t3.sonraki_sipariþ_ayý) - (t3.current_month)) iki_alýþ_veris_fark
		  from t3),
	 t5 as (
		  select distinct t4.yýl,t4.ay,t4.current_month,t4.iki_alýþ_veris_fark,t4.sonraki_sipariþ_ayý,t4.NEXT_CUST1,COUNT (t4.cust_id)	OVER (PARTITION BY Current_Month) NEXT_CUST
		  from t4
		  where t4.iki_alýþ_veris_fark = 1),
	 t6 as (
		  select *,lag(t5.NEXT_CUST) over(order by t5.current_month) sonraki_ay_gelen_müs_say
		  from t5)
select t6.yýl,t6.ay, (1.0*(t6.NEXT_CUST) /( t6.NEXT_CUST1)) mut_ut_oran
from t6
where t6.current_month > 1









---///////////////////////////////////
--Good luck!