-- ~/v2.10.0rc2/tools/dsqgen -DIRECTORY ../query_templates  -INPUT ../query_templates/templates.lst -DIALECT netezza  -SCALE 10000 -OUTPUT_DIR ~/tpcds-2.10-queries/redshift-10T -STREAM 11

/* Disable results caching */
set enable_result_cache_for_session to off;

set query_group to 'TPC-DS query56.tpl stream.2.1';
with /* TPC-DS query56.tpl 0.83 */ ss as (
 select i_item_id,sum(ss_ext_sales_price) total_sales
 from
 	store_sales,
 	date_dim,
         customer_address,
         item
 where i_item_id in (select
     i_item_id
from item
where i_color in ('thistle','blush','hot'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 2002
 and     d_moy                   = 7
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 cs as (
 select i_item_id,sum(cs_ext_sales_price) total_sales
 from
 	catalog_sales,
 	date_dim,
         customer_address,
         item
 where
         i_item_id               in (select
  i_item_id
from item
where i_color in ('thistle','blush','hot'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 2002
 and     d_moy                   = 7
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 ws as (
 select i_item_id,sum(ws_ext_sales_price) total_sales
 from
 	web_sales,
 	date_dim,
         customer_address,
         item
 where
         i_item_id               in (select
  i_item_id
from item
where i_color in ('thistle','blush','hot'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 2002
 and     d_moy                   = 7
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_item_id)
  select  i_item_id ,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_item_id
 order by total_sales,
          i_item_id
 limit 100;

-- end query 1 in stream 2 using template query56.tpl
set query_group to 'TPC-DS query98.tpl stream.2.2';
select /* TPC-DS query98.tpl 0.32 */ i_item_id
      ,i_item_desc 
      ,i_category 
      ,i_class 
      ,i_current_price
      ,sum(ss_ext_sales_price) as itemrevenue 
      ,sum(ss_ext_sales_price)*100/sum(sum(ss_ext_sales_price)) over
          (partition by i_class) as revenueratio
from	
	store_sales
    	,item 
    	,date_dim
where 
	ss_item_sk = i_item_sk 
  	and i_category in ('Men', 'Home', 'Jewelry')
  	and ss_sold_date_sk = d_date_sk
	and d_date between cast('1999-02-04' as date) 
				and dateadd(day,30,cast('1999-02-04' as date))
group by 
	i_item_id
        ,i_item_desc 
        ,i_category
        ,i_class
        ,i_current_price
order by 
	i_category
        ,i_class
        ,i_item_id
        ,i_item_desc
        ,revenueratio;

-- end query 2 in stream 2 using template query98.tpl
set query_group to 'TPC-DS query59.tpl stream.2.3';
with /* TPC-DS query59.tpl 0.30 */ wss as 
 (select d_week_seq,
        ss_store_sk,
        sum(case when (d_day_name='Sunday') then ss_sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then ss_sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then ss_sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then ss_sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then ss_sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then ss_sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then ss_sales_price else null end) sat_sales
 from store_sales,date_dim
 where d_date_sk = ss_sold_date_sk
 group by d_week_seq,ss_store_sk
 )
  select  s_store_name1,s_store_id1,d_week_seq1
       ,sun_sales1/sun_sales2,mon_sales1/mon_sales2
       ,tue_sales1/tue_sales2,wed_sales1/wed_sales2,thu_sales1/thu_sales2
       ,fri_sales1/fri_sales2,sat_sales1/sat_sales2
 from
 (select s_store_name s_store_name1,wss.d_week_seq d_week_seq1
        ,s_store_id s_store_id1,sun_sales sun_sales1
        ,mon_sales mon_sales1,tue_sales tue_sales1
        ,wed_sales wed_sales1,thu_sales thu_sales1
        ,fri_sales fri_sales1,sat_sales sat_sales1
  from wss,store,date_dim d
  where d.d_week_seq = wss.d_week_seq and
        ss_store_sk = s_store_sk and 
        d_month_seq between 1186 and 1186 + 11) y,
 (select s_store_name s_store_name2,wss.d_week_seq d_week_seq2
        ,s_store_id s_store_id2,sun_sales sun_sales2
        ,mon_sales mon_sales2,tue_sales tue_sales2
        ,wed_sales wed_sales2,thu_sales thu_sales2
        ,fri_sales fri_sales2,sat_sales sat_sales2
  from wss,store,date_dim d
  where d.d_week_seq = wss.d_week_seq and
        ss_store_sk = s_store_sk and 
        d_month_seq between 1186+ 12 and 1186 + 23) x
 where s_store_id1=s_store_id2
   and d_week_seq1=d_week_seq2-52
 order by s_store_name1,s_store_id1,d_week_seq1
limit 100;

-- end query 3 in stream 2 using template query59.tpl
set query_group to 'TPC-DS query24.tpl stream.2.4';
with /* TPC-DS query24.tpl 0.92 */ ssales as
(select c_last_name
      ,c_first_name
      ,s_store_name
      ,ca_state
      ,s_state
      ,i_color
      ,i_current_price
      ,i_manager_id
      ,i_units
      ,i_size
      ,sum(ss_ext_sales_price) netpaid
from store_sales
    ,store_returns
    ,store
    ,item
    ,customer
    ,customer_address
where ss_ticket_number = sr_ticket_number
  and ss_item_sk = sr_item_sk
  and ss_customer_sk = c_customer_sk
  and ss_item_sk = i_item_sk
  and ss_store_sk = s_store_sk
  and c_current_addr_sk = ca_address_sk
  and c_birth_country <> upper(ca_country)
  and s_zip = ca_zip
and s_market_id=5
group by c_last_name
        ,c_first_name
        ,s_store_name
        ,ca_state
        ,s_state
        ,i_color
        ,i_current_price
        ,i_manager_id
        ,i_units
        ,i_size)
select c_last_name
      ,c_first_name
      ,s_store_name
      ,sum(netpaid) paid
from ssales
where i_color = 'gainsboro'
group by c_last_name
        ,c_first_name
        ,s_store_name
having sum(netpaid) > (select 0.05*avg(netpaid)
                                 from ssales)
order by c_last_name
        ,c_first_name
        ,s_store_name
;
with /* TPC-DS query24.tpl 0.92 part2 */ ssales as
(select c_last_name
      ,c_first_name
      ,s_store_name
      ,ca_state
      ,s_state
      ,i_color
      ,i_current_price
      ,i_manager_id
      ,i_units
      ,i_size
      ,sum(ss_ext_sales_price) netpaid
from store_sales
    ,store_returns
    ,store
    ,item
    ,customer
    ,customer_address
where ss_ticket_number = sr_ticket_number
  and ss_item_sk = sr_item_sk
  and ss_customer_sk = c_customer_sk
  and ss_item_sk = i_item_sk
  and ss_store_sk = s_store_sk
  and c_current_addr_sk = ca_address_sk
  and c_birth_country <> upper(ca_country)
  and s_zip = ca_zip
  and s_market_id = 5
group by c_last_name
        ,c_first_name
        ,s_store_name
        ,ca_state
        ,s_state
        ,i_color
        ,i_current_price
        ,i_manager_id
        ,i_units
        ,i_size)
select c_last_name
      ,c_first_name
      ,s_store_name
      ,sum(netpaid) paid
from ssales
where i_color = 'medium'
group by c_last_name
        ,c_first_name
        ,s_store_name
having sum(netpaid) > (select 0.05*avg(netpaid)
                           from ssales)
order by c_last_name
        ,c_first_name
        ,s_store_name
;

-- end query 4 in stream 2 using template query24.tpl
set query_group to 'TPC-DS query88.tpl stream.2.5';
select  /* TPC-DS query88.tpl 0.66 */ *
from
 (select count(*) h8_30_to_9
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk   
     and ss_hdemo_sk = household_demographics.hd_demo_sk 
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 8
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2)) 
     and store.s_store_name = 'ese') s1,
 (select count(*) h9_to_9_30 
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk 
     and time_dim.t_hour = 9 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2))
     and store.s_store_name = 'ese') s2,
 (select count(*) h9_30_to_10 
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 9
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2))
     and store.s_store_name = 'ese') s3,
 (select count(*) h10_to_10_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2))
     and store.s_store_name = 'ese') s4,
 (select count(*) h10_30_to_11
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2))
     and store.s_store_name = 'ese') s5,
 (select count(*) h11_to_11_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk 
     and time_dim.t_hour = 11
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2))
     and store.s_store_name = 'ese') s6,
 (select count(*) h11_30_to_12
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 11
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2))
     and store.s_store_name = 'ese') s7,
 (select count(*) h12_to_12_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 12
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2))
     and store.s_store_name = 'ese') s8
;

-- end query 5 in stream 2 using template query88.tpl
set query_group to 'TPC-DS query2.tpl stream.2.6';
with /* TPC-DS query2.tpl 0.84 */ wscs as
 (select sold_date_sk
        ,sales_price
  from  (select ws_sold_date_sk sold_date_sk
              ,ws_ext_sales_price sales_price
        from web_sales
        union all
        select cs_sold_date_sk sold_date_sk
              ,cs_ext_sales_price sales_price
        from catalog_sales)),
 wswscs as 
 (select d_week_seq,
        sum(case when (d_day_name='Sunday') then sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then sales_price else null end) sat_sales
 from wscs
     ,date_dim
 where d_date_sk = sold_date_sk
 group by d_week_seq)
 select d_week_seq1
       ,round(sun_sales1/sun_sales2,2)
       ,round(mon_sales1/mon_sales2,2)
       ,round(tue_sales1/tue_sales2,2)
       ,round(wed_sales1/wed_sales2,2)
       ,round(thu_sales1/thu_sales2,2)
       ,round(fri_sales1/fri_sales2,2)
       ,round(sat_sales1/sat_sales2,2)
 from
 (select wswscs.d_week_seq d_week_seq1
        ,sun_sales sun_sales1
        ,mon_sales mon_sales1
        ,tue_sales tue_sales1
        ,wed_sales wed_sales1
        ,thu_sales thu_sales1
        ,fri_sales fri_sales1
        ,sat_sales sat_sales1
  from wswscs,date_dim 
  where date_dim.d_week_seq = wswscs.d_week_seq and
        d_year = 2000) y,
 (select wswscs.d_week_seq d_week_seq2
        ,sun_sales sun_sales2
        ,mon_sales mon_sales2
        ,tue_sales tue_sales2
        ,wed_sales wed_sales2
        ,thu_sales thu_sales2
        ,fri_sales fri_sales2
        ,sat_sales sat_sales2
  from wswscs
      ,date_dim 
  where date_dim.d_week_seq = wswscs.d_week_seq and
        d_year = 2000+1) z
 where d_week_seq1=d_week_seq2-53
 order by d_week_seq1;

-- end query 6 in stream 2 using template query2.tpl
set query_group to 'TPC-DS query5a.tpl stream.2.7';
with /* TPC-DS query5a.tpl 0.98 */ ssr as
 (select s_store_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  ss_store_sk as store_sk,
            ss_sold_date_sk  as date_sk,
            ss_ext_sales_price as sales_price,
            ss_net_profit as profit,
            cast(0 as decimal(7,2)) as return_amt,
            cast(0 as decimal(7,2)) as net_loss
    from store_sales
    union all
    select sr_store_sk as store_sk,
           sr_returned_date_sk as date_sk,
           cast(0 as decimal(7,2)) as sales_price,
           cast(0 as decimal(7,2)) as profit,
           sr_return_amt as return_amt,
           sr_net_loss as net_loss
    from store_returns
   ) salesreturns,
     date_dim,
     store
 where date_sk = d_date_sk
       and d_date between cast('1998-08-02' as date) 
                  and dateadd(day,14,cast('1998-08-02' as date))
       and store_sk = s_store_sk
 group by s_store_id)
 ,
 csr as
 (select cp_catalog_page_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  cs_catalog_page_sk as page_sk,
            cs_sold_date_sk  as date_sk,
            cs_ext_sales_price as sales_price,
            cs_net_profit as profit,
            cast(0 as decimal(7,2)) as return_amt,
            cast(0 as decimal(7,2)) as net_loss
    from catalog_sales
    union all
    select cr_catalog_page_sk as page_sk,
           cr_returned_date_sk as date_sk,
           cast(0 as decimal(7,2)) as sales_price,
           cast(0 as decimal(7,2)) as profit,
           cr_return_amount as return_amt,
           cr_net_loss as net_loss
    from catalog_returns
   ) salesreturns,
     date_dim,
     catalog_page
 where date_sk = d_date_sk
       and d_date between cast('1998-08-02' as date)
                  and dateadd(day,14,cast('1998-08-02' as date))
       and page_sk = cp_catalog_page_sk
 group by cp_catalog_page_id)
 ,
 wsr as
 (select web_site_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  ws_web_site_sk as wsr_web_site_sk,
            ws_sold_date_sk  as date_sk,
            ws_ext_sales_price as sales_price,
            ws_net_profit as profit,
            cast(0 as decimal(7,2)) as return_amt,
            cast(0 as decimal(7,2)) as net_loss
    from web_sales
    union all
    select ws_web_site_sk as wsr_web_site_sk,
           wr_returned_date_sk as date_sk,
           cast(0 as decimal(7,2)) as sales_price,
           cast(0 as decimal(7,2)) as profit,
           wr_return_amt as return_amt,
           wr_net_loss as net_loss
    from web_returns left outer join web_sales on
         ( wr_item_sk = ws_item_sk
           and wr_order_number = ws_order_number)
   ) salesreturns,
     date_dim,
     web_site
 where date_sk = d_date_sk
       and d_date between cast('1998-08-02' as date)
                  and dateadd(day,14,cast('1998-08-02' as date))
       and wsr_web_site_sk = web_site_sk
 group by web_site_id)
 ,
 results as
 (select channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , 'store' || s_store_id as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from   ssr
 union all
 select 'catalog channel' as channel
        , 'catalog_page' || cp_catalog_page_id as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from  csr
 union all
 select 'web channel' as channel
        , 'web_site' || web_site_id as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from   wsr
 ) x
 group by channel, id)
 select  channel, id, sales, returns, profit from ( 
  select channel, id, sales, returns, profit from results
  union
  select channel, null as id, sum(sales), sum(returns), sum(profit) from results group by channel
  union
  select null as channel, null as id, sum(sales), sum(returns), sum(profit) from results) foo
order by channel, id
limit 100;

-- end query 7 in stream 2 using template query5a.tpl
set query_group to 'TPC-DS query6.tpl stream.2.8';
select /* TPC-DS query6.tpl 0.58 */  a.ca_state state, count(*) cnt
 from customer_address a
     ,customer c
     ,store_sales s
     ,date_dim d
     ,item i
 where       a.ca_address_sk = c.c_current_addr_sk
 	and c.c_customer_sk = s.ss_customer_sk
 	and s.ss_sold_date_sk = d.d_date_sk
 	and s.ss_item_sk = i.i_item_sk
 	and d.d_month_seq = 
 	     (select distinct (d_month_seq)
 	      from date_dim
               where d_year = 2000
 	        and d_moy = 3 )
 	and i.i_current_price > 1.2 * 
             (select avg(j.i_current_price) 
 	     from item j 
 	     where j.i_category = i.i_category)
 group by a.ca_state
 having count(*) >= 10
 order by cnt, a.ca_state 
 limit 100;

-- end query 8 in stream 2 using template query6.tpl
set query_group to 'TPC-DS query27a.tpl stream.2.9';
with /* TPC-DS query27a.tpl 0.16 */ results as
 (select i_item_id,
        s_state, 0 as g_state,
        ss_quantity agg1,
        ss_list_price agg2,
        ss_coupon_amt agg3,
        ss_sales_price agg4
 from store_sales, customer_demographics, date_dim, store, item
 where ss_sold_date_sk = d_date_sk and
       ss_item_sk = i_item_sk and
       ss_store_sk = s_store_sk and
       ss_cdemo_sk = cd_demo_sk and
       cd_gender = 'F' and
       cd_marital_status = 'M' and
       cd_education_status = 'College' and
       d_year = 2000 and
       s_state in ('SC','TN', 'IN', 'IN', 'NE', 'OK')
 )

  select  i_item_id,
  s_state, g_state, agg1, agg2, agg3, agg4
   from (
        select i_item_id, s_state, 0 as g_state, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3, avg(agg4) agg4 from results
        group by i_item_id, s_state
         union all
        select i_item_id, NULL AS s_state, 1 AS g_state, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
         avg(agg4) agg4 from results
        group by i_item_id
         union all
        select NULL AS i_item_id, NULL as s_state, 1 as g_state, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
         avg(agg4) agg4 from results
        ) foo
  order by i_item_id, s_state
 limit 100;

-- end query 9 in stream 2 using template query27a.tpl
set query_group to 'TPC-DS query87.tpl stream.2.10';
select /* TPC-DS query87.tpl 0.77 */ count(*) 
from ((select distinct c_last_name, c_first_name, d_date
       from store_sales, date_dim, customer
       where store_sales.ss_sold_date_sk = date_dim.d_date_sk
         and store_sales.ss_customer_sk = customer.c_customer_sk
         and d_month_seq between 1221 and 1221+11)
       except
      (select distinct c_last_name, c_first_name, d_date
       from catalog_sales, date_dim, customer
       where catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
         and catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
         and d_month_seq between 1221 and 1221+11)
       except
      (select distinct c_last_name, c_first_name, d_date
       from web_sales, date_dim, customer
       where web_sales.ws_sold_date_sk = date_dim.d_date_sk
         and web_sales.ws_bill_customer_sk = customer.c_customer_sk
         and d_month_seq between 1221 and 1221+11)
) cool_cust
;

-- end query 10 in stream 2 using template query87.tpl
set query_group to 'TPC-DS query90.tpl stream.2.11';
select /* TPC-DS query90.tpl 0.40 */  cast(amc as decimal(15,4))/cast(pmc as decimal(15,4)) am_pm_ratio
 from ( select count(*) amc
       from web_sales, household_demographics , time_dim, web_page
       where ws_sold_time_sk = time_dim.t_time_sk
         and ws_ship_hdemo_sk = household_demographics.hd_demo_sk
         and ws_web_page_sk = web_page.wp_web_page_sk
         and time_dim.t_hour between 6 and 6+1
         and household_demographics.hd_dep_count = 4
         and web_page.wp_char_count between 5000 and 5200) at,
      ( select count(*) pmc
       from web_sales, household_demographics , time_dim, web_page
       where ws_sold_time_sk = time_dim.t_time_sk
         and ws_ship_hdemo_sk = household_demographics.hd_demo_sk
         and ws_web_page_sk = web_page.wp_web_page_sk
         and time_dim.t_hour between 19 and 19+1
         and household_demographics.hd_dep_count = 4
         and web_page.wp_char_count between 5000 and 5200) pt
 order by am_pm_ratio
 limit 100;

-- end query 11 in stream 2 using template query90.tpl
set query_group to 'TPC-DS query83.tpl stream.2.12';
with /* TPC-DS query83.tpl 0.96 */ sr_items as
 (select i_item_id item_id,
        sum(sr_return_quantity) sr_item_qty
 from store_returns,
      item,
      date_dim
 where sr_item_sk = i_item_sk
 and   d_date    in 
	(select d_date
	from date_dim
	where d_week_seq in 
		(select d_week_seq
		from date_dim
	  where d_date in ('1999-04-20','1999-09-24','1999-11-20')))
 and   sr_returned_date_sk   = d_date_sk
 group by i_item_id),
 cr_items as
 (select i_item_id item_id,
        sum(cr_return_quantity) cr_item_qty
 from catalog_returns,
      item,
      date_dim
 where cr_item_sk = i_item_sk
 and   d_date    in 
	(select d_date
	from date_dim
	where d_week_seq in 
		(select d_week_seq
		from date_dim
	  where d_date in ('1999-04-20','1999-09-24','1999-11-20')))
 and   cr_returned_date_sk   = d_date_sk
 group by i_item_id),
 wr_items as
 (select i_item_id item_id,
        sum(wr_return_quantity) wr_item_qty
 from web_returns,
      item,
      date_dim
 where wr_item_sk = i_item_sk
 and   d_date    in 
	(select d_date
	from date_dim
	where d_week_seq in 
		(select d_week_seq
		from date_dim
		where d_date in ('1999-04-20','1999-09-24','1999-11-20')))
 and   wr_returned_date_sk   = d_date_sk
 group by i_item_id)
  select  sr_items.item_id
       ,sr_item_qty
       ,sr_item_qty/(sr_item_qty+cr_item_qty+wr_item_qty)/3.0 * 100 sr_dev
       ,cr_item_qty
       ,cr_item_qty/(sr_item_qty+cr_item_qty+wr_item_qty)/3.0 * 100 cr_dev
       ,wr_item_qty
       ,wr_item_qty/(sr_item_qty+cr_item_qty+wr_item_qty)/3.0 * 100 wr_dev
       ,(sr_item_qty+cr_item_qty+wr_item_qty)/3.0 average
 from sr_items
     ,cr_items
     ,wr_items
 where sr_items.item_id=cr_items.item_id
   and sr_items.item_id=wr_items.item_id 
 order by sr_items.item_id
         ,sr_item_qty
 limit 100;

-- end query 12 in stream 2 using template query83.tpl
set query_group to 'TPC-DS query91.tpl stream.2.13';
select /* TPC-DS query91.tpl 0.13 */ 
        cc_call_center_id Call_Center,
        cc_name Call_Center_Name,
        cc_manager Manager,
        sum(cr_net_loss) Returns_Loss
from
        call_center,
        catalog_returns,
        date_dim,
        customer,
        customer_address,
        customer_demographics,
        household_demographics
where
        cr_call_center_sk       = cc_call_center_sk
and     cr_returned_date_sk     = d_date_sk
and     cr_returning_customer_sk= c_customer_sk
and     cd_demo_sk              = c_current_cdemo_sk
and     hd_demo_sk              = c_current_hdemo_sk
and     ca_address_sk           = c_current_addr_sk
and     d_year                  = 1999 
and     d_moy                   = 11
and     ( (cd_marital_status       = 'M' and cd_education_status     = 'Unknown')
        or(cd_marital_status       = 'W' and cd_education_status     = 'Advanced Degree'))
and     hd_buy_potential like '501-1000%'
and     ca_gmt_offset           = -7
group by cc_call_center_id,cc_name,cc_manager,cd_marital_status,cd_education_status
order by sum(cr_net_loss) desc;

-- end query 13 in stream 2 using template query91.tpl
set query_group to 'TPC-DS query28.tpl stream.2.14';
select /* TPC-DS query28.tpl 0.36 */  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 57 and 57+10 
             or ss_coupon_amt between 2576 and 2576+1000
             or ss_wholesale_cost between 1 and 1+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 60 and 60+10
          or ss_coupon_amt between 11057 and 11057+1000
          or ss_wholesale_cost between 34 and 34+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 121 and 121+10
          or ss_coupon_amt between 13936 and 13936+1000
          or ss_wholesale_cost between 29 and 29+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 43 and 43+10
          or ss_coupon_amt between 10022 and 10022+1000
          or ss_wholesale_cost between 5 and 5+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 32 and 32+10
          or ss_coupon_amt between 5202 and 5202+1000
          or ss_wholesale_cost between 8 and 8+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 62 and 62+10
          or ss_coupon_amt between 11695 and 11695+1000
          or ss_wholesale_cost between 58 and 58+20)) B6
limit 100;

-- end query 14 in stream 2 using template query28.tpl
set query_group to 'TPC-DS query68.tpl stream.2.15';
select /* TPC-DS query68.tpl 0.95 */  c_last_name
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,extended_price
       ,extended_tax
       ,list_price
 from (select ss_ticket_number
             ,ss_customer_sk
             ,ca_city bought_city
             ,sum(ss_ext_sales_price) extended_price 
             ,sum(ss_ext_list_price) list_price
             ,sum(ss_ext_tax) extended_tax 
       from store_sales
           ,date_dim
           ,store
           ,household_demographics
           ,customer_address 
       where store_sales.ss_sold_date_sk = date_dim.d_date_sk
         and store_sales.ss_store_sk = store.s_store_sk  
        and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
        and store_sales.ss_addr_sk = customer_address.ca_address_sk
        and date_dim.d_dom between 1 and 2 
        and (household_demographics.hd_dep_count = 2 or
             household_demographics.hd_vehicle_count= -1)
        and date_dim.d_year in (1999,1999+1,1999+2)
        and store.s_city in ('Hickory Grove','Mechanicsville')
       group by ss_ticket_number
               ,ss_customer_sk
               ,ss_addr_sk,ca_city) dn
      ,customer
      ,customer_address current_addr
 where ss_customer_sk = c_customer_sk
   and customer.c_current_addr_sk = current_addr.ca_address_sk
   and current_addr.ca_city <> bought_city
 order by c_last_name
         ,ss_ticket_number
 limit 100;

-- end query 15 in stream 2 using template query68.tpl
set query_group to 'TPC-DS query8.tpl stream.2.16';
select /* TPC-DS query8.tpl 0.63 */  s_store_name
      ,sum(ss_net_profit)
 from store_sales
     ,date_dim
     ,store,
     (select ca_zip
     from (
      SELECT substring(ca_zip,1,5) ca_zip
      FROM customer_address
      WHERE substring(ca_zip,1,5) IN (
                          '74665','11475','18978','48210','45625','74831',
                          '43389','58955','67595','32231','98949',
                          '57952','64215','82848','88717','82708',
                          '35974','68967','37475','63388','51260',
                          '57330','69950','71206','71566','67144',
                          '12580','87610','37181','32218','15118',
                          '80629','37203','49510','18738','61669',
                          '77973','74751','38515','84352','74652',
                          '88291','20485','17419','51831','88832',
                          '79324','97956','94047','90736','71146',
                          '41065','77287','33485','80565','52010',
                          '95899','80823','90890','39280','62955',
                          '95780','94814','62259','20649','39798',
                          '24246','67790','23883','21244','27262',
                          '22437','42259','44002','61162','75049',
                          '82051','89472','48545','62300','26531',
                          '58965','63448','80325','32541','25403',
                          '96700','64520','72309','42127','71108',
                          '70861','74164','54614','86637','36640',
                          '60844','30208','13152','68873','37582',
                          '67094','92581','95861','70417','85625',
                          '95282','46295','69309','90234','42697',
                          '27483','90286','46846','21128','52709',
                          '66864','30920','77293','77325','24471',
                          '39915','58791','18324','94746','53923',
                          '49588','16151','98747','60961','29363',
                          '34726','40905','24507','59901','39533',
                          '23833','71552','64936','40746','86024',
                          '58798','19338','55872','11623','14460',
                          '14946','13741','22550','78604','65794',
                          '39562','49068','55645','85973','90344',
                          '69629','33245','64227','58412','92948',
                          '17384','76335','20886','12864','77399',
                          '20493','43546','54512','92197','33391',
                          '10454','99531','77346','97567','17948',
                          '72760','78668','45584','68049','12273',
                          '69537','28790','84199','87745','90016',
                          '65953','27105','52830','18179','83869',
                          '24746','32493','54888','56202','62073',
                          '66948','11591','31310','56203','65560',
                          '93968','97037','17196','91149','96926',
                          '35161','43743','72695','24090','33742',
                          '74770','67230','93814','23867','43878',
                          '59772','98105','58080','76350','50703',
                          '67843','66708','14204','92923','92334',
                          '24904','23677','60147','67262','95031',
                          '42251','85321','29894','91354','63750',
                          '90547','68577','72223','95107','35521',
                          '83015','90094','44395','72193','61777',
                          '29842','17748','77964','91678','82090',
                          '23411','87484','95435','26077','41432',
                          '68852','53678','45665','13612','96563',
                          '13144','31213','74128','41340','20673',
                          '63979','40887','69473','91222','27083',
                          '11576','27211','85515','66078','90879',
                          '27613','74031','70958','84578','14534',
                          '19483','11085','39931','96670','78521',
                          '49523','67543','85765','20172','52488',
                          '48467','17672','21150','75347','39317',
                          '85509','83177','63008','53027','17318',
                          '50316','57029','74745','19555','69145',
                          '96381','14703','95369','98780','84642',
                          '85260','71161','93738','80859','25430',
                          '91005','26952','25059','79117','46094',
                          '82559','41468','31009','63767','28566',
                          '77961','22202','31765','12607','91899',
                          '95698','23928','26312','17707','35396',
                          '36972','58883','73382','70684','50936',
                          '62820','46244','51226','37661','76326',
                          '84075','84456','72062','63706','79735',
                          '85801','75204','93560','62676','67170',
                          '91030','47603','60950','73412','61851',
                          '17686','66428','41256','61260','35756',
                          '89047','21910','51929','30206','88852',
                          '23270','55767','51248','23914','98956',
                          '86513','40753','99383','81798','52356',
                          '52118','81121','52727','45314','67218',
                          '23779','19610','69088','70669','22163',
                          '78486','77013','46970','53381','69264',
                          '69874','85571','82924','94991')
     intersect
      select ca_zip
      from (SELECT substring(ca_zip,1,5) ca_zip,count(*) cnt
            FROM customer_address, customer
            WHERE ca_address_sk = c_current_addr_sk and
                  c_preferred_cust_flag='Y'
            group by ca_zip
            having count(*) > 10)A1)A2) V1
 where ss_store_sk = s_store_sk
  and ss_sold_date_sk = d_date_sk
  and d_qoy = 1 and d_year = 1999
  and (substring(s_zip,1,2) = substring(V1.ca_zip,1,2))
 group by s_store_name
 order by s_store_name
 limit 100;

-- end query 16 in stream 2 using template query8.tpl
set query_group to 'TPC-DS query76.tpl stream.2.17';
select /* TPC-DS query76.tpl 0.99 */  channel, col_name, d_year, d_qoy, i_category, COUNT(*) sales_cnt, SUM(ext_sales_price) sales_amt FROM (
        SELECT 'store' as channel, 'ss_addr_sk' col_name, d_year, d_qoy, i_category, ss_ext_sales_price ext_sales_price
         FROM store_sales, item, date_dim
         WHERE ss_addr_sk IS NULL
           AND ss_sold_date_sk=d_date_sk
           AND ss_item_sk=i_item_sk
        UNION ALL
        SELECT 'web' as channel, 'ws_ship_mode_sk' col_name, d_year, d_qoy, i_category, ws_ext_sales_price ext_sales_price
         FROM web_sales, item, date_dim
         WHERE ws_ship_mode_sk IS NULL
           AND ws_sold_date_sk=d_date_sk
           AND ws_item_sk=i_item_sk
        UNION ALL
        SELECT 'catalog' as channel, 'cs_ship_customer_sk' col_name, d_year, d_qoy, i_category, cs_ext_sales_price ext_sales_price
         FROM catalog_sales, item, date_dim
         WHERE cs_ship_customer_sk IS NULL
           AND cs_sold_date_sk=d_date_sk
           AND cs_item_sk=i_item_sk) foo
GROUP BY channel, col_name, d_year, d_qoy, i_category
ORDER BY channel, col_name, d_year, d_qoy, i_category
limit 100;

-- end query 17 in stream 2 using template query76.tpl
set query_group to 'TPC-DS query75.tpl stream.2.18';
WITH /* TPC-DS query75.tpl 0.3 */ all_sales AS (
 SELECT d_year
       ,i_brand_id
       ,i_class_id
       ,i_category_id
       ,i_manufact_id
       ,SUM(sales_cnt) AS sales_cnt
       ,SUM(sales_amt) AS sales_amt
 FROM (SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,cs_quantity - COALESCE(cr_return_quantity,0) AS sales_cnt
             ,cs_ext_sales_price - COALESCE(cr_return_amount,0.0) AS sales_amt
       FROM catalog_sales JOIN item ON i_item_sk=cs_item_sk
                          JOIN date_dim ON d_date_sk=cs_sold_date_sk
                          LEFT JOIN catalog_returns ON (cs_order_number=cr_order_number 
                                                    AND cs_item_sk=cr_item_sk)
       WHERE i_category='Music'
       UNION
       SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,ss_quantity - COALESCE(sr_return_quantity,0) AS sales_cnt
             ,ss_ext_sales_price - COALESCE(sr_return_amt,0.0) AS sales_amt
       FROM store_sales JOIN item ON i_item_sk=ss_item_sk
                        JOIN date_dim ON d_date_sk=ss_sold_date_sk
                        LEFT JOIN store_returns ON (ss_ticket_number=sr_ticket_number 
                                                AND ss_item_sk=sr_item_sk)
       WHERE i_category='Music'
       UNION
       SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,ws_quantity - COALESCE(wr_return_quantity,0) AS sales_cnt
             ,ws_ext_sales_price - COALESCE(wr_return_amt,0.0) AS sales_amt
       FROM web_sales JOIN item ON i_item_sk=ws_item_sk
                      JOIN date_dim ON d_date_sk=ws_sold_date_sk
                      LEFT JOIN web_returns ON (ws_order_number=wr_order_number 
                                            AND ws_item_sk=wr_item_sk)
       WHERE i_category='Music') sales_detail
 GROUP BY d_year, i_brand_id, i_class_id, i_category_id, i_manufact_id)
 SELECT  prev_yr.d_year AS prev_year
                          ,curr_yr.d_year AS year
                          ,curr_yr.i_brand_id
                          ,curr_yr.i_class_id
                          ,curr_yr.i_category_id
                          ,curr_yr.i_manufact_id
                          ,prev_yr.sales_cnt AS prev_yr_cnt
                          ,curr_yr.sales_cnt AS curr_yr_cnt
                          ,curr_yr.sales_cnt-prev_yr.sales_cnt AS sales_cnt_diff
                          ,curr_yr.sales_amt-prev_yr.sales_amt AS sales_amt_diff
 FROM all_sales curr_yr, all_sales prev_yr
 WHERE curr_yr.i_brand_id=prev_yr.i_brand_id
   AND curr_yr.i_class_id=prev_yr.i_class_id
   AND curr_yr.i_category_id=prev_yr.i_category_id
   AND curr_yr.i_manufact_id=prev_yr.i_manufact_id
   AND curr_yr.d_year=2001
   AND prev_yr.d_year=2001-1
   AND CAST(curr_yr.sales_cnt AS DECIMAL(17,2))/CAST(prev_yr.sales_cnt AS DECIMAL(17,2))<0.9
 ORDER BY sales_cnt_diff,sales_amt_diff
 limit 100;

-- end query 18 in stream 2 using template query75.tpl
set query_group to 'TPC-DS query80a.tpl stream.2.19';
with /* TPC-DS query80a.tpl 0.6 */ ssr as
 (select  s_store_id as store_id,
          sum(ss_ext_sales_price) as sales,
          sum(coalesce(sr_return_amt, 0)) as returns,
          sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit
  from store_sales left outer join store_returns on
         (ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number),
     date_dim,
     store,
     item,
     promotion
 where ss_sold_date_sk = d_date_sk
       and d_date between cast('1999-08-09' as date) 
                  and dateadd(day,30,cast('1999-08-09' as date)) 
       and ss_store_sk = s_store_sk
       and ss_item_sk = i_item_sk
       and i_current_price > 50
       and ss_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
 group by s_store_id)
 ,
 csr as
 (select  cp_catalog_page_id as catalog_page_id,
          sum(cs_ext_sales_price) as sales,
          sum(coalesce(cr_return_amount, 0)) as returns,
          sum(cs_net_profit - coalesce(cr_net_loss, 0)) as profit
  from catalog_sales left outer join catalog_returns on
         (cs_item_sk = cr_item_sk and cs_order_number = cr_order_number),
     date_dim,
     catalog_page,
     item,
     promotion
 where cs_sold_date_sk = d_date_sk
       and d_date between cast('1999-08-09' as date)
                  and dateadd(day,30,cast('1999-08-09' as date))
        and cs_catalog_page_sk = cp_catalog_page_sk
       and cs_item_sk = i_item_sk
       and i_current_price > 50
       and cs_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by cp_catalog_page_id)
 ,
 wsr as
 (select  web_site_id,
          sum(ws_ext_sales_price) as sales,
          sum(coalesce(wr_return_amt, 0)) as returns,
          sum(ws_net_profit - coalesce(wr_net_loss, 0)) as profit
  from web_sales left outer join web_returns on
         (ws_item_sk = wr_item_sk and ws_order_number = wr_order_number),
     date_dim,
     web_site,
     item,
     promotion
 where ws_sold_date_sk = d_date_sk
       and d_date between cast('1999-08-09' as date)
                  and dateadd(day,30,cast('1999-08-09' as date))
        and ws_web_site_sk = web_site_sk
       and ws_item_sk = i_item_sk
       and i_current_price > 50
       and ws_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by web_site_id)
,
results as
 (select channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , 'store' || store_id as id
        , sales
        , returns
        , profit
 from   ssr
 union all
 select 'catalog channel' as channel
        , 'catalog_page' || catalog_page_id as id
        , sales
        , returns
        , profit
 from  csr
 union all
 select 'web channel' as channel
        , 'web_site' || web_site_id as id
        , sales
        , returns
        , profit
 from   wsr
 ) x
 group by channel, id)
 
  select  channel
        , id
        , sales
        , returns
        , profit
 from (
   select channel, id, sales, returns, profit from  results
   union
   select channel, NULL AS id, sum(sales) as sales, sum(returns) as returns, sum(profit) as profit from  results group by channel
   union
   select NULL AS channel, NULL AS id, sum(sales) as sales, sum(returns) as returns, sum(profit) as profit from  results
 ) foo
 order by channel, id
 limit 100;

-- end query 19 in stream 2 using template query80a.tpl
set query_group to 'TPC-DS query1.tpl stream.2.20';
with /* TPC-DS query1.tpl 0.12 */ customer_total_return as
(select sr_customer_sk as ctr_customer_sk
,sr_store_sk as ctr_store_sk
,sum(SR_FEE) as ctr_total_return
from store_returns
,date_dim
where sr_returned_date_sk = d_date_sk
and d_year =2000
group by sr_customer_sk
,sr_store_sk)
 select  c_customer_id
from customer_total_return ctr1
,store
,customer
where ctr1.ctr_total_return > (select avg(ctr_total_return)*1.2
from customer_total_return ctr2
where ctr1.ctr_store_sk = ctr2.ctr_store_sk)
and s_store_sk = ctr1.ctr_store_sk
and s_state = 'TX'
and ctr1.ctr_customer_sk = c_customer_sk
order by c_customer_id
limit 100;

-- end query 20 in stream 2 using template query1.tpl
set query_group to 'TPC-DS query69.tpl stream.2.21';
select /* TPC-DS query69.tpl 0.28 */  
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3
 from
  customer c,customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  ca_state in ('AL','IL','NJ') and
  cd_demo_sk = c.c_current_cdemo_sk and 
  exists (select *
          from store_sales,date_dim
          where c.c_customer_sk = ss_customer_sk and
                ss_sold_date_sk = d_date_sk and
                d_year = 2004 and
                d_moy between 3 and 3+2) and
   (not exists (select *
            from web_sales,date_dim
            where c.c_customer_sk = ws_bill_customer_sk and
                  ws_sold_date_sk = d_date_sk and
                  d_year = 2004 and
                  d_moy between 3 and 3+2) and
    not exists (select * 
            from catalog_sales,date_dim
            where c.c_customer_sk = cs_ship_customer_sk and
                  cs_sold_date_sk = d_date_sk and
                  d_year = 2004 and
                  d_moy between 3 and 3+2))
 group by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating
 order by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating
 limit 100;

-- end query 21 in stream 2 using template query69.tpl
set query_group to 'TPC-DS query26.tpl stream.2.22';
select /* TPC-DS query26.tpl 0.85 */  i_item_id, 
        avg(cs_quantity) agg1,
        avg(cs_list_price) agg2,
        avg(cs_coupon_amt) agg3,
        avg(cs_sales_price) agg4 
 from catalog_sales, customer_demographics, date_dim, item, promotion
 where cs_sold_date_sk = d_date_sk and
       cs_item_sk = i_item_sk and
       cs_bill_cdemo_sk = cd_demo_sk and
       cs_promo_sk = p_promo_sk and
       cd_gender = 'F' and 
       cd_marital_status = 'W' and
       cd_education_status = 'Advanced Degree' and
       (p_channel_email = 'N' or p_channel_event = 'N') and
       d_year = 1998 
 group by i_item_id
 order by i_item_id
 limit 100;

-- end query 22 in stream 2 using template query26.tpl
set query_group to 'TPC-DS query11.tpl stream.2.23';
with /* TPC-DS query11.tpl 0.51 */ year_total as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(ss_ext_list_price-ss_ext_discount_amt) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag 
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year 
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(ws_ext_list_price-ws_ext_discount_amt) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag 
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
         )
  select  
                  t_s_secyear.customer_id
                 ,t_s_secyear.customer_first_name
                 ,t_s_secyear.customer_last_name
                 ,t_s_secyear.customer_email_address
 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.sale_type = 's'
         and t_w_firstyear.sale_type = 'w'
         and t_s_secyear.sale_type = 's'
         and t_w_secyear.sale_type = 'w'
         and t_s_firstyear.dyear = 2000
         and t_s_secyear.dyear = 2000+1
         and t_w_firstyear.dyear = 2000
         and t_w_secyear.dyear = 2000+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else 0.0 end
             > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else 0.0 end
 order by t_s_secyear.customer_id
         ,t_s_secyear.customer_first_name
         ,t_s_secyear.customer_last_name
         ,t_s_secyear.customer_email_address
limit 100;

-- end query 23 in stream 2 using template query11.tpl
set query_group to 'TPC-DS query17.tpl stream.2.24';
select /* TPC-DS query17.tpl 0.41 */  i_item_id
       ,i_item_desc
       ,s_state
       ,count(ss_quantity) as store_sales_quantitycount
       ,avg(ss_quantity) as store_sales_quantityave
       ,stddev_samp(ss_quantity) as store_sales_quantitystdev
       ,stddev_samp(ss_quantity)/avg(ss_quantity) as store_sales_quantitycov
       ,count(sr_return_quantity) as store_returns_quantitycount
       ,avg(sr_return_quantity) as store_returns_quantityave
       ,stddev_samp(sr_return_quantity) as store_returns_quantitystdev
       ,stddev_samp(sr_return_quantity)/avg(sr_return_quantity) as store_returns_quantitycov
       ,count(cs_quantity) as catalog_sales_quantitycount ,avg(cs_quantity) as catalog_sales_quantityave
       ,stddev_samp(cs_quantity) as catalog_sales_quantitystdev
       ,stddev_samp(cs_quantity)/avg(cs_quantity) as catalog_sales_quantitycov
 from store_sales
     ,store_returns
     ,catalog_sales
     ,date_dim d1
     ,date_dim d2
     ,date_dim d3
     ,store
     ,item
 where d1.d_quarter_name = '2000Q1'
   and d1.d_date_sk = ss_sold_date_sk
   and i_item_sk = ss_item_sk
   and s_store_sk = ss_store_sk
   and ss_customer_sk = sr_customer_sk
   and ss_item_sk = sr_item_sk
   and ss_ticket_number = sr_ticket_number
   and sr_returned_date_sk = d2.d_date_sk
   and d2.d_quarter_name in ('2000Q1','2000Q2','2000Q3')
   and sr_customer_sk = cs_bill_customer_sk
   and sr_item_sk = cs_item_sk
   and cs_sold_date_sk = d3.d_date_sk
   and d3.d_quarter_name in ('2000Q1','2000Q2','2000Q3')
 group by i_item_id
         ,i_item_desc
         ,s_state
 order by i_item_id
         ,i_item_desc
         ,s_state
limit 100;

-- end query 24 in stream 2 using template query17.tpl
set query_group to 'TPC-DS query63.tpl stream.2.25';
select /* TPC-DS query63.tpl 0.27 */  * 
from (select i_manager_id
             ,sum(ss_sales_price) sum_sales
             ,avg(sum(ss_sales_price)) over (partition by i_manager_id) avg_monthly_sales
      from item
          ,store_sales
          ,date_dim
          ,store
      where ss_item_sk = i_item_sk
        and ss_sold_date_sk = d_date_sk
        and ss_store_sk = s_store_sk
        and d_month_seq in (1188,1188+1,1188+2,1188+3,1188+4,1188+5,1188+6,1188+7,1188+8,1188+9,1188+10,1188+11)
        and ((    i_category in ('Books','Children','Electronics')
              and i_class in ('personal','portable','reference','self-help')
              and i_brand in ('scholaramalgamalg #14','scholaramalgamalg #7',
		                  'exportiunivamalg #9','scholaramalgamalg #9'))
           or(    i_category in ('Women','Music','Men')
              and i_class in ('accessories','classical','fragrances','pants')
              and i_brand in ('amalgimporto #1','edu packscholar #1','exportiimporto #1',
		                 'importoamalg #1')))
group by i_manager_id, d_moy) tmp1
where case when avg_monthly_sales > 0 then abs (sum_sales - avg_monthly_sales) / avg_monthly_sales else null end > 0.1
order by i_manager_id
        ,avg_monthly_sales
        ,sum_sales
limit 100;

-- end query 25 in stream 2 using template query63.tpl
set query_group to 'TPC-DS query77a.tpl stream.2.26';
with /* TPC-DS query77a.tpl 0.78 */ ss as
 (select s_store_sk,
         sum(ss_ext_sales_price) as sales,
         sum(ss_net_profit) as profit
 from store_sales,
      date_dim,
      store
 where ss_sold_date_sk = d_date_sk
       and d_date between cast('2001-08-11' as date) 
                  and dateadd(day,30,cast('2001-08-11' as date))  
       and ss_store_sk = s_store_sk
 group by s_store_sk)
 ,
 sr as
 (select s_store_sk,
         sum(sr_return_amt) as returns,
         sum(sr_net_loss) as profit_loss
 from store_returns,
      date_dim,
      store
 where sr_returned_date_sk = d_date_sk
       and d_date between cast('2001-08-11' as date)
                  and dateadd(day,30,cast('2001-08-11' as date))  
       and sr_store_sk = s_store_sk
 group by s_store_sk), 
 cs as
 (select cs_call_center_sk,
        sum(cs_ext_sales_price) as sales,
        sum(cs_net_profit) as profit
 from catalog_sales,
      date_dim
 where cs_sold_date_sk = d_date_sk
       and d_date between cast('2001-08-11' as date)
                  and dateadd(day,30,cast('2001-08-11' as date))  
 group by cs_call_center_sk 
 ), 
 cr as
 (select cr_call_center_sk,
         sum(cr_return_amount) as returns,
         sum(cr_net_loss) as profit_loss
 from catalog_returns,
      date_dim
 where cr_returned_date_sk = d_date_sk
       and d_date between cast('2001-08-11' as date)
                  and dateadd(day,30,cast('2001-08-11' as date))  
 group by cr_call_center_sk), 
 ws as
 ( select wp_web_page_sk,
        sum(ws_ext_sales_price) as sales,
        sum(ws_net_profit) as profit
 from web_sales,
      date_dim,
      web_page
 where ws_sold_date_sk = d_date_sk
       and d_date between cast('2001-08-11' as date)
                  and dateadd(day,30,cast('2001-08-11' as date))  
       and ws_web_page_sk = wp_web_page_sk
 group by wp_web_page_sk), 
 wr as
 (select wp_web_page_sk,
        sum(wr_return_amt) as returns,
        sum(wr_net_loss) as profit_loss
 from web_returns,
      date_dim,
      web_page
 where wr_returned_date_sk = d_date_sk
       and d_date between cast('2001-08-11' as date)
                  and dateadd(day,30,cast('2001-08-11' as date))  
       and wr_web_page_sk = wp_web_page_sk
 group by wp_web_page_sk)
 ,
 results as
 (select channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , ss.s_store_sk as id
        , sales
        , coalesce(returns, 0) as returns
        , (profit - coalesce(profit_loss,0)) as profit
 from   ss left join sr
        on  ss.s_store_sk = sr.s_store_sk
 union all
 select 'catalog channel' as channel
        , cs_call_center_sk as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from  cs
       , cr
 union all
 select 'web channel' as channel
        , ws.wp_web_page_sk as id
        , sales
        , coalesce(returns, 0) as returns
        , (profit - coalesce(profit_loss,0)) as profit
 from   ws left join wr
        on  ws.wp_web_page_sk = wr.wp_web_page_sk
 ) x
 group by channel, id )

  select  *
 from (
 select channel, id, sales, returns, profit from  results
 union
 select channel, NULL AS id, sum(sales) as sales, sum(returns) as returns, sum(profit) as profit from  results group by channel
 union
 select NULL AS channel, NULL AS id, sum(sales) as sales, sum(returns) as returns, sum(profit) as profit from  results
) foo
order by channel, id
 limit 100;

-- end query 26 in stream 2 using template query77a.tpl
set query_group to 'TPC-DS query19.tpl stream.2.27';
select /* TPC-DS query19.tpl 0.8 */  i_brand_id brand_id, i_brand brand, i_manufact_id, i_manufact,
 	sum(ss_ext_sales_price) ext_price
 from date_dim, store_sales, item,customer,customer_address,store
 where d_date_sk = ss_sold_date_sk
   and ss_item_sk = i_item_sk
   and i_manager_id=32
   and d_moy=12
   and d_year=1999
   and ss_customer_sk = c_customer_sk 
   and c_current_addr_sk = ca_address_sk
   and substring(ca_zip,1,5) <> substring(s_zip,1,5) 
   and ss_store_sk = s_store_sk 
 group by i_brand
      ,i_brand_id
      ,i_manufact_id
      ,i_manufact
 order by ext_price desc
         ,i_brand
         ,i_brand_id
         ,i_manufact_id
         ,i_manufact
limit 100 ;

-- end query 27 in stream 2 using template query19.tpl
set query_group to 'TPC-DS query21.tpl stream.2.28';
select /* TPC-DS query21.tpl 0.14 */  *
 from(select w_warehouse_name
            ,i_item_id
            ,sum(case when (cast(d_date as date) < cast ('2000-04-02' as date))
	                then inv_quantity_on_hand 
                      else 0 end) as inv_before
            ,sum(case when (cast(d_date as date) >= cast ('2000-04-02' as date))
                      then inv_quantity_on_hand 
                      else 0 end) as inv_after
   from inventory
       ,warehouse
       ,item
       ,date_dim
   where i_current_price between 0.99 and 1.49
     and i_item_sk          = inv_item_sk
     and inv_warehouse_sk   = w_warehouse_sk
     and inv_date_sk    = d_date_sk
     and d_date between dateadd(day,-30,cast ('2000-04-02' as date))
                    and dateadd(day,30,cast ('2000-04-02' as date))
   group by w_warehouse_name, i_item_id) x
 where (case when inv_before > 0 
             then inv_after / inv_before 
             else null
             end) between 2.0/3.0 and 3.0/2.0
 order by w_warehouse_name
         ,i_item_id
 limit 100;

-- end query 28 in stream 2 using template query21.tpl
set query_group to 'TPC-DS query31.tpl stream.2.29';
with /* TPC-DS query31.tpl 0.50 */ ss as
 (select ca_county,d_qoy, d_year,sum(ss_ext_sales_price) as store_sales
 from store_sales,date_dim,customer_address
 where ss_sold_date_sk = d_date_sk
  and ss_addr_sk=ca_address_sk
 group by ca_county,d_qoy, d_year),
 ws as
 (select ca_county,d_qoy, d_year,sum(ws_ext_sales_price) as web_sales
 from web_sales,date_dim,customer_address
 where ws_sold_date_sk = d_date_sk
  and ws_bill_addr_sk=ca_address_sk
 group by ca_county,d_qoy, d_year)
 select 
        ss1.ca_county
       ,ss1.d_year
       ,ws2.web_sales/ws1.web_sales web_q1_q2_increase
       ,ss2.store_sales/ss1.store_sales store_q1_q2_increase
       ,ws3.web_sales/ws2.web_sales web_q2_q3_increase
       ,ss3.store_sales/ss2.store_sales store_q2_q3_increase
 from
        ss ss1
       ,ss ss2
       ,ss ss3
       ,ws ws1
       ,ws ws2
       ,ws ws3
 where
    ss1.d_qoy = 1
    and ss1.d_year = 2002
    and ss1.ca_county = ss2.ca_county
    and ss2.d_qoy = 2
    and ss2.d_year = 2002
 and ss2.ca_county = ss3.ca_county
    and ss3.d_qoy = 3
    and ss3.d_year = 2002
    and ss1.ca_county = ws1.ca_county
    and ws1.d_qoy = 1
    and ws1.d_year = 2002
    and ws1.ca_county = ws2.ca_county
    and ws2.d_qoy = 2
    and ws2.d_year = 2002
    and ws1.ca_county = ws3.ca_county
    and ws3.d_qoy = 3
    and ws3.d_year =2002
    and case when ws1.web_sales > 0 then ws2.web_sales/ws1.web_sales else null end 
       > case when ss1.store_sales > 0 then ss2.store_sales/ss1.store_sales else null end
    and case when ws2.web_sales > 0 then ws3.web_sales/ws2.web_sales else null end
       > case when ss2.store_sales > 0 then ss3.store_sales/ss2.store_sales else null end
 order by store_q1_q2_increase;

-- end query 29 in stream 2 using template query31.tpl
set query_group to 'TPC-DS query93.tpl stream.2.30';
select /* TPC-DS query93.tpl 0.52 */  ss_customer_sk
            ,sum(act_sales) sumsales
      from (select ss_item_sk
                  ,ss_ticket_number
                  ,ss_customer_sk
                  ,case when sr_return_quantity is not null then (ss_quantity-sr_return_quantity)*ss_sales_price
                                                            else (ss_quantity*ss_sales_price) end act_sales
            from store_sales left outer join store_returns on (sr_item_sk = ss_item_sk
                                                               and sr_ticket_number = ss_ticket_number)
                ,reason
            where sr_reason_sk = r_reason_sk
              and r_reason_desc = 'reason 50') t
      group by ss_customer_sk
      order by sumsales, ss_customer_sk
limit 100;

-- end query 30 in stream 2 using template query93.tpl
set query_group to 'TPC-DS query54.tpl stream.2.31';
with /* TPC-DS query54.tpl 0.81 */ my_customers as (
 select distinct c_customer_sk
        , c_current_addr_sk
 from   
        ( select cs_sold_date_sk sold_date_sk,
                 cs_bill_customer_sk customer_sk,
                 cs_item_sk item_sk
          from   catalog_sales
          union all
          select ws_sold_date_sk sold_date_sk,
                 ws_bill_customer_sk customer_sk,
                 ws_item_sk item_sk
          from   web_sales
         ) cs_or_ws_sales,
         item,
         date_dim,
         customer
 where   sold_date_sk = d_date_sk
         and item_sk = i_item_sk
         and i_category = 'Men'
         and i_class = 'pants'
         and c_customer_sk = cs_or_ws_sales.customer_sk
         and d_moy = 4
         and d_year = 2001
 )
 , my_revenue as (
 select c_customer_sk,
        sum(ss_ext_sales_price) as revenue
 from   my_customers,
        store_sales,
        customer_address,
        store,
        date_dim
 where  c_current_addr_sk = ca_address_sk
        and ca_county = s_county
        and ca_state = s_state
        and ss_sold_date_sk = d_date_sk
        and c_customer_sk = ss_customer_sk
        and d_month_seq between (select distinct d_month_seq+1
                                 from   date_dim where d_year = 2001 and d_moy = 4)
                           and  (select distinct d_month_seq+3
                                 from   date_dim where d_year = 2001 and d_moy = 4)
 group by c_customer_sk
 )
 , segments as
 (select cast((revenue/50) as int) as segment
  from   my_revenue
 )
  select  segment, count(*) as num_customers, segment*50 as segment_base
 from segments
 group by segment
 order by segment, num_customers
 limit 100;

-- end query 31 in stream 2 using template query54.tpl
set query_group to 'TPC-DS query39.tpl stream.2.32';
with /* TPC-DS query39.tpl 0.5 */ inv as
(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
       ,stdev,mean, case mean when 0 then null else stdev/mean end cov
 from(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
            ,stddev_samp(inv_quantity_on_hand) stdev,avg(inv_quantity_on_hand) mean
      from inventory
          ,item
          ,warehouse
          ,date_dim
      where inv_item_sk = i_item_sk
        and inv_warehouse_sk = w_warehouse_sk
        and inv_date_sk = d_date_sk
        and d_year =1999
      group by w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy) foo
 where case mean when 0 then 0 else stdev/mean end > 1)
select inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean, inv1.cov
        ,inv2.w_warehouse_sk,inv2.i_item_sk,inv2.d_moy,inv2.mean, inv2.cov
from inv inv1,inv inv2
where inv1.i_item_sk = inv2.i_item_sk
  and inv1.w_warehouse_sk =  inv2.w_warehouse_sk
  and inv1.d_moy=3
  and inv2.d_moy=3+1
order by inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean,inv1.cov
        ,inv2.d_moy,inv2.mean, inv2.cov
;
with /* TPC-DS query39.tpl 0.5 part2 */ inv as
(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
       ,stdev,mean, case mean when 0 then null else stdev/mean end cov
 from(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
            ,stddev_samp(inv_quantity_on_hand) stdev,avg(inv_quantity_on_hand) mean
      from inventory
          ,item
          ,warehouse
          ,date_dim
      where inv_item_sk = i_item_sk
        and inv_warehouse_sk = w_warehouse_sk
        and inv_date_sk = d_date_sk
        and d_year =1999
      group by w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy) foo
 where case mean when 0 then 0 else stdev/mean end > 1)
select inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean, inv1.cov
        ,inv2.w_warehouse_sk,inv2.i_item_sk,inv2.d_moy,inv2.mean, inv2.cov
from inv inv1,inv inv2
where inv1.i_item_sk = inv2.i_item_sk
  and inv1.w_warehouse_sk =  inv2.w_warehouse_sk
  and inv1.d_moy=3
  and inv2.d_moy=3+1
  and inv1.cov > 1.5
order by inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean,inv1.cov
        ,inv2.d_moy,inv2.mean, inv2.cov
;

-- end query 32 in stream 2 using template query39.tpl
set query_group to 'TPC-DS query10.tpl stream.2.33';
select /* TPC-DS query10.tpl 0.26 */  
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3,
  cd_dep_count,
  count(*) cnt4,
  cd_dep_employed_count,
  count(*) cnt5,
  cd_dep_college_count,
  count(*) cnt6
 from
  customer c,customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  ca_county in ('Fayette County','Mason County','Prairie County','Washington County','Morris County') and
  cd_demo_sk = c.c_current_cdemo_sk and 
  exists (select *
          from store_sales,date_dim
          where c.c_customer_sk = ss_customer_sk and
                ss_sold_date_sk = d_date_sk and
                d_year = 2002 and
                d_moy between 1 and 1+3) and
   (exists (select *
            from web_sales,date_dim
            where c.c_customer_sk = ws_bill_customer_sk and
                  ws_sold_date_sk = d_date_sk and
                  d_year = 2002 and
                  d_moy between 1 ANd 1+3) or 
    exists (select * 
            from catalog_sales,date_dim
            where c.c_customer_sk = cs_ship_customer_sk and
                  cs_sold_date_sk = d_date_sk and
                  d_year = 2002 and
                  d_moy between 1 and 1+3))
 group by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 order by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
limit 100;

-- end query 33 in stream 2 using template query10.tpl
set query_group to 'TPC-DS query15.tpl stream.2.34';
select /* TPC-DS query15.tpl 0.57 */  ca_zip
       ,sum(cs_sales_price)
 from catalog_sales
     ,customer
     ,customer_address
     ,date_dim
 where cs_bill_customer_sk = c_customer_sk
 	and c_current_addr_sk = ca_address_sk 
 	and ( substring(ca_zip,1,5) in ('85669', '86197','88274','83405','86475',
                                   '85392', '85460', '80348', '81792')
 	      or ca_state in ('CA','WA','GA')
 	      or cs_sales_price > 500)
 	and cs_sold_date_sk = d_date_sk
 	and d_qoy = 2 and d_year = 1999
 group by ca_zip
 order by ca_zip
 limit 100;

-- end query 34 in stream 2 using template query15.tpl
set query_group to 'TPC-DS query55.tpl stream.2.35';
select /* TPC-DS query55.tpl 0.82 */  i_brand_id brand_id, i_brand brand,
 	sum(ss_ext_sales_price) ext_price
 from date_dim, store_sales, item
 where d_date_sk = ss_sold_date_sk
 	and ss_item_sk = i_item_sk
 	and i_manager_id=18
 	and d_moy=12
 	and d_year=2001
 group by i_brand, i_brand_id
 order by ext_price desc, i_brand_id
limit 100 ;

-- end query 35 in stream 2 using template query55.tpl
set query_group to 'TPC-DS query14a.tpl stream.2.36';
with  /* TPC-DS query14a.tpl 0.69 */ cross_items as
 (select i_item_sk ss_item_sk
 from item,
 (select iss.i_brand_id brand_id
     ,iss.i_class_id class_id
     ,iss.i_category_id category_id
 from store_sales
     ,item iss
     ,date_dim d1
 where ss_item_sk = iss.i_item_sk
   and ss_sold_date_sk = d1.d_date_sk
   and d1.d_year between 1999 AND 1999 + 2
 intersect 
 select ics.i_brand_id
     ,ics.i_class_id
     ,ics.i_category_id
 from catalog_sales
     ,item ics
     ,date_dim d2
 where cs_item_sk = ics.i_item_sk
   and cs_sold_date_sk = d2.d_date_sk
   and d2.d_year between 1999 AND 1999 + 2
 intersect
 select iws.i_brand_id
     ,iws.i_class_id
     ,iws.i_category_id
 from web_sales
     ,item iws
     ,date_dim d3
 where ws_item_sk = iws.i_item_sk
   and ws_sold_date_sk = d3.d_date_sk
   and d3.d_year between 1999 AND 1999 + 2) x
 where i_brand_id = brand_id
      and i_class_id = class_id
      and i_category_id = category_id
),
 avg_sales as
 (select avg(quantity*list_price) average_sales
  from (select ss_quantity quantity
             ,ss_list_price list_price
       from store_sales
           ,date_dim
       where ss_sold_date_sk = d_date_sk
         and d_year between 1999 and 2001 
       union all 
       select cs_quantity quantity 
             ,cs_list_price list_price
       from catalog_sales
           ,date_dim
       where cs_sold_date_sk = d_date_sk
         and d_year between 2000 and 2000 + 2 
       union all
       select ws_quantity quantity
             ,ws_list_price list_price
       from web_sales
           ,date_dim
       where ws_sold_date_sk = d_date_sk
         and d_year between 2000 and 2000 + 2) x)
,
  results AS
(select channel, i_brand_id, i_class_id, i_category_id, sum(sales) sum_sales, sum(number_sales) number_sales
 from (
       select 'store' channel, i_brand_id,i_class_id
             ,i_category_id,sum(ss_quantity*ss_list_price) sales
             , count(*) number_sales
       from store_sales
           ,item
           ,date_dim
       where ss_item_sk in (select ss_item_sk from cross_items)
         and ss_item_sk = i_item_sk
         and ss_sold_date_sk = d_date_sk
         and d_year = 2000+2 
         and d_moy = 11
       group by i_brand_id,i_class_id,i_category_id
       having sum(ss_quantity*ss_list_price) > (select average_sales from avg_sales)
       union all
       select 'catalog' channel, i_brand_id,i_class_id,i_category_id, sum(cs_quantity*cs_list_price) sales, count(*) number_sales
       from catalog_sales
           ,item
           ,date_dim
       where cs_item_sk in (select ss_item_sk from cross_items)
         and cs_item_sk = i_item_sk
         and cs_sold_date_sk = d_date_sk
         and d_year = 2000+2 
         and d_moy = 11
       group by i_brand_id,i_class_id,i_category_id
       having sum(cs_quantity*cs_list_price) > (select average_sales from avg_sales)
       union all
       select 'web' channel, i_brand_id,i_class_id,i_category_id, sum(ws_quantity*ws_list_price) sales , count(*) number_sales
       from web_sales
           ,item
           ,date_dim
       where ws_item_sk in (select ss_item_sk from cross_items)
         and ws_item_sk = i_item_sk
         and ws_sold_date_sk = d_date_sk
         and d_year = 2000+2
         and d_moy = 11
       group by i_brand_id,i_class_id,i_category_id
       having sum(ws_quantity*ws_list_price) > (select average_sales from avg_sales)
 ) y
 group by channel, i_brand_id,i_class_id,i_category_id)

 select  channel, i_brand_id, i_class_id, i_category_id, sum_sales, number_sales
from (
      select channel, i_brand_id, i_class_id, i_category_id, sum_sales, number_sales from results
      union
      select channel, i_brand_id, i_class_id,  null as i_category_id, sum(sum_sales), sum(number_sales) from results
      group by channel, i_brand_id, i_class_id
      union
      select channel, i_brand_id, null as i_class_id, null as i_category_id, sum(sum_sales), sum(number_sales) from results
      group by channel, i_brand_id
      union
      select channel, null as i_brand_id, null as i_class_id, null as i_category_id, sum(sum_sales), sum(number_sales) from results
      group by channel
      union
      select null as channel, null as i_brand_id, null as i_class_id, null as i_category_id, sum(sum_sales), sum(number_sales) from results) z
order by channel, i_brand_id, i_class_id, i_category_id
 limit 100;
with  /* TPC-DS query14a.tpl 0.69 part2 */ cross_items as
 (select i_item_sk ss_item_sk
 from item,
 (select iss.i_brand_id brand_id
     ,iss.i_class_id class_id
     ,iss.i_category_id category_id
 from store_sales
     ,item iss
     ,date_dim d1
 where ss_item_sk = iss.i_item_sk
   and ss_sold_date_sk = d1.d_date_sk
   and d1.d_year between 1999 AND 1999 + 2
 intersect
 select ics.i_brand_id
     ,ics.i_class_id
     ,ics.i_category_id
 from catalog_sales
     ,item ics
     ,date_dim d2
 where cs_item_sk = ics.i_item_sk
   and cs_sold_date_sk = d2.d_date_sk
   and d2.d_year between 1999 AND 1999 + 2
 intersect
 select iws.i_brand_id
     ,iws.i_class_id
     ,iws.i_category_id
 from web_sales
     ,item iws
     ,date_dim d3
 where ws_item_sk = iws.i_item_sk
   and ws_sold_date_sk = d3.d_date_sk
   and d3.d_year between 1999 AND 1999 + 2) x
 where i_brand_id = brand_id
      and i_class_id = class_id
      and i_category_id = category_id
),
 avg_sales as
(select avg(quantity*list_price) average_sales
  from (select ss_quantity quantity
             ,ss_list_price list_price
       from store_sales
           ,date_dim
       where ss_sold_date_sk = d_date_sk
         and d_year between 2000 and 2000 + 2
       union all
       select cs_quantity quantity
             ,cs_list_price list_price
       from catalog_sales
           ,date_dim
       where cs_sold_date_sk = d_date_sk
         and d_year between 2000 and 2000 + 2
       union all
       select ws_quantity quantity
             ,ws_list_price list_price
       from web_sales
           ,date_dim
       where ws_sold_date_sk = d_date_sk
         and d_year between 2000 and 2000 + 2) x)
  select  * from
 (select 'store' channel, i_brand_id,i_class_id,i_category_id
        ,sum(ss_quantity*ss_list_price) sales, count(*) number_sales
 from store_sales 
     ,item
     ,date_dim
 where ss_item_sk in (select ss_item_sk from cross_items)
   and ss_item_sk = i_item_sk
   and ss_sold_date_sk = d_date_sk
   and d_week_seq = (select d_week_seq
                     from date_dim
                     where d_year = 2000 + 1
                       and d_moy = 12
                       and d_dom = 21)
 group by i_brand_id,i_class_id,i_category_id
 having sum(ss_quantity*ss_list_price) > (select average_sales from avg_sales)) this_year,
 (select 'store' channel, i_brand_id,i_class_id
        ,i_category_id, sum(ss_quantity*ss_list_price) sales, count(*) number_sales
 from store_sales
     ,item
     ,date_dim
 where ss_item_sk in (select ss_item_sk from cross_items)
   and ss_item_sk = i_item_sk
   and ss_sold_date_sk = d_date_sk
   and d_week_seq = (select d_week_seq
                     from date_dim
                     where d_year = 2000
                       and d_moy = 12
                       and d_dom = 21)
 group by i_brand_id,i_class_id,i_category_id
 having sum(ss_quantity*ss_list_price) > (select average_sales from avg_sales)) last_year
 where this_year.i_brand_id= last_year.i_brand_id
   and this_year.i_class_id = last_year.i_class_id
   and this_year.i_category_id = last_year.i_category_id
 order by this_year.channel, this_year.i_brand_id, this_year.i_class_id, this_year.i_category_id
 limit 100;

-- end query 36 in stream 2 using template query14a.tpl
set query_group to 'TPC-DS query38.tpl stream.2.37';
select /* TPC-DS query38.tpl 0.54 */  count(*) from (
    select distinct c_last_name, c_first_name, d_date
    from store_sales, date_dim, customer
          where store_sales.ss_sold_date_sk = date_dim.d_date_sk
      and store_sales.ss_customer_sk = customer.c_customer_sk
      and d_month_seq between 1215 and 1215 + 11
  intersect
    select distinct c_last_name, c_first_name, d_date
    from catalog_sales, date_dim, customer
          where catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
      and catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
      and d_month_seq between 1215 and 1215 + 11
  intersect
    select distinct c_last_name, c_first_name, d_date
    from web_sales, date_dim, customer
          where web_sales.ws_sold_date_sk = date_dim.d_date_sk
      and web_sales.ws_bill_customer_sk = customer.c_customer_sk
      and d_month_seq between 1215 and 1215 + 11
) hot_cust
limit 100;

-- end query 37 in stream 2 using template query38.tpl
set query_group to 'TPC-DS query42.tpl stream.2.38';
select /* TPC-DS query42.tpl 0.61 */  dt.d_year
 	,item.i_category_id
 	,item.i_category
 	,sum(ss_ext_sales_price)
 from 	date_dim dt
 	,store_sales
 	,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
 	and store_sales.ss_item_sk = item.i_item_sk
 	and item.i_manager_id = 1  	
 	and dt.d_moy=11
 	and dt.d_year=2002
 group by 	dt.d_year
 		,item.i_category_id
 		,item.i_category
 order by       sum(ss_ext_sales_price) desc,dt.d_year
 		,item.i_category_id
 		,item.i_category
limit 100 ;

-- end query 38 in stream 2 using template query42.tpl
set query_group to 'TPC-DS query53.tpl stream.2.39';
select /* TPC-DS query53.tpl 0.88 */  * from 
(select i_manufact_id,
sum(ss_sales_price) sum_sales,
avg(sum(ss_sales_price)) over (partition by i_manufact_id) avg_quarterly_sales
from item, store_sales, date_dim, store
where ss_item_sk = i_item_sk and
ss_sold_date_sk = d_date_sk and
ss_store_sk = s_store_sk and
d_month_seq in (1188,1188+1,1188+2,1188+3,1188+4,1188+5,1188+6,1188+7,1188+8,1188+9,1188+10,1188+11) and
((i_category in ('Books','Children','Electronics') and
i_class in ('personal','portable','reference','self-help') and
i_brand in ('scholaramalgamalg #14','scholaramalgamalg #7',
		'exportiunivamalg #9','scholaramalgamalg #9'))
or(i_category in ('Women','Music','Men') and
i_class in ('accessories','classical','fragrances','pants') and
i_brand in ('amalgimporto #1','edu packscholar #1','exportiimporto #1',
		'importoamalg #1')))
group by i_manufact_id, d_qoy ) tmp1
where case when avg_quarterly_sales > 0 
	then abs (sum_sales - avg_quarterly_sales)/ avg_quarterly_sales 
	else null end > 0.1
order by avg_quarterly_sales,
	 sum_sales,
	 i_manufact_id
limit 100;

-- end query 39 in stream 2 using template query53.tpl
set query_group to 'TPC-DS query45.tpl stream.2.40';
select /* TPC-DS query45.tpl 0.18 */ ca_zip, ca_county, sum(ws_sales_price)
 from web_sales, customer, customer_address, date_dim, item
 where ws_bill_customer_sk = c_customer_sk
 	and c_current_addr_sk = ca_address_sk 
 	and ws_item_sk = i_item_sk 
 	and ( substring(ca_zip,1,5) in ('85669', '86197','88274','83405','86475', '85392', '85460', '80348', '81792')
 	      or 
 	      i_item_id in (select i_item_id
                             from item
                             where i_item_sk in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
                             )
 	    )
 	and ws_sold_date_sk = d_date_sk
 	and d_qoy = 2 and d_year = 2001
 group by ca_zip, ca_county
 order by ca_zip, ca_county
 limit 100;

-- end query 40 in stream 2 using template query45.tpl
set query_group to 'TPC-DS query99.tpl stream.2.41';
select /* TPC-DS query99.tpl 0.94 */  
   substring(w_warehouse_name,1,20)
  ,sm_type
  ,cc_name
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk <= 30 ) then 1 else 0 end)  as "30 days" 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 30) and 
                 (cs_ship_date_sk - cs_sold_date_sk <= 60) then 1 else 0 end )  as "31-60 days" 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 60) and 
                 (cs_ship_date_sk - cs_sold_date_sk <= 90) then 1 else 0 end)  as "61-90 days" 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 90) and
                 (cs_ship_date_sk - cs_sold_date_sk <= 120) then 1 else 0 end)  as "91-120 days" 
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk  > 120) then 1 else 0 end)  as ">120 days" 
from
   catalog_sales
  ,warehouse
  ,ship_mode
  ,call_center
  ,date_dim
where
    d_month_seq between 1221 and 1221 + 11
and cs_ship_date_sk   = d_date_sk
and cs_warehouse_sk   = w_warehouse_sk
and cs_ship_mode_sk   = sm_ship_mode_sk
and cs_call_center_sk = cc_call_center_sk
group by
   substring(w_warehouse_name,1,20)
  ,sm_type
  ,cc_name
order by substring(w_warehouse_name,1,20)
        ,sm_type
        ,cc_name
limit 100;

-- end query 41 in stream 2 using template query99.tpl
set query_group to 'TPC-DS query67a.tpl stream.2.42';
with /* TPC-DS query67a.tpl 0.35 */ results as
(     select i_category ,i_class ,i_brand ,i_product_name ,d_year ,d_qoy ,d_moy ,s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from store_sales ,date_dim ,store ,item
       where  ss_sold_date_sk=d_date_sk
          and ss_item_sk=i_item_sk
          and ss_store_sk = s_store_sk
          and d_month_seq between 1190 and 1190 + 11
       group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy,s_store_id)
 ,
 results_rollup as
 (select i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy, s_store_id, sumsales
  from results
  union all
  select i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy, null s_store_id, sum(sumsales) sumsales
  from results
  group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy
  union all
  select i_category, i_class, i_brand, i_product_name, d_year, d_qoy, null d_moy, null s_store_id, sum(sumsales) sumsales
  from results
  group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy
  union all
  select i_category, i_class, i_brand, i_product_name, d_year, null d_qoy, null d_moy, null s_store_id, sum(sumsales) sumsales
  from results
  group by i_category, i_class, i_brand, i_product_name, d_year
  union all
  select i_category, i_class, i_brand, i_product_name, null d_year, null d_qoy, null d_moy, null s_store_id, sum(sumsales) sumsales
  from results
  group by i_category, i_class, i_brand, i_product_name
  union all
  select i_category, i_class, i_brand, null i_product_name, null d_year, null d_qoy, null d_moy, null s_store_id, sum(sumsales) sumsales
  from results
  group by i_category, i_class, i_brand
  union all
  select i_category, i_class, null i_brand, null i_product_name, null d_year, null d_qoy, null d_moy, null s_store_id, sum(sumsales) sumsales
  from results
  group by i_category, i_class
  union all
  select i_category, null i_class, null i_brand, null i_product_name, null d_year, null d_qoy, null d_moy, null s_store_id, sum(sumsales) sumsales
  from results
  group by i_category
  union all
  select null i_category, null i_class, null i_brand, null i_product_name, null d_year, null d_qoy, null d_moy, null s_store_id, sum(sumsales) sumsales
  from results)

 select  *
from (select i_category
            ,i_class
            ,i_brand
            ,i_product_name
            ,d_year
            ,d_qoy
            ,d_moy
            ,s_store_id
            ,sumsales
            ,rank() over (partition by i_category order by sumsales desc) rk
      from results_rollup) dw2
where rk <= 100
order by i_category
        ,i_class
        ,i_brand
        ,i_product_name
        ,d_year
        ,d_qoy
        ,d_moy
        ,s_store_id
        ,sumsales
        ,rk
limit 100;

-- end query 42 in stream 2 using template query67a.tpl
set query_group to 'TPC-DS query23.tpl stream.2.43';
with /* TPC-DS query23.tpl 0.68 */ frequent_ss_items as 
 (select substring(i_item_desc,1,30) itemdesc,i_item_sk item_sk,d_date solddate,count(*) cnt
  from store_sales
      ,date_dim 
      ,item
  where ss_sold_date_sk = d_date_sk
    and ss_item_sk = i_item_sk 
    and d_year in (1998,1998+1,1998+2,1998+3)
  group by substring(i_item_desc,1,30),i_item_sk,d_date
  having count(*) >4),
 max_store_sales as
 (select max(csales) tpcds_cmax 
  from (select c_customer_sk,sum(ss_quantity*ss_sales_price) csales
        from store_sales
            ,customer
            ,date_dim 
        where ss_customer_sk = c_customer_sk
         and ss_sold_date_sk = d_date_sk
         and d_year in (1998,1998+1,1998+2,1998+3) 
        group by c_customer_sk)),
 best_ss_customer as
 (select c_customer_sk,sum(ss_quantity*ss_sales_price) ssales
  from store_sales
      ,customer
  where ss_customer_sk = c_customer_sk
  group by c_customer_sk
  having sum(ss_quantity*ss_sales_price) > (95/100.0) * (select
  *
from
 max_store_sales))
  select  sum(sales)
 from (select cs_quantity*cs_list_price sales
       from catalog_sales
           ,date_dim 
       where d_year = 1998 
         and d_moy = 3 
         and cs_sold_date_sk = d_date_sk 
         and cs_item_sk in (select item_sk from frequent_ss_items)
         and cs_bill_customer_sk in (select c_customer_sk from best_ss_customer)
      union all
      select ws_quantity*ws_list_price sales
       from web_sales 
           ,date_dim 
       where d_year = 1998 
         and d_moy = 3 
         and ws_sold_date_sk = d_date_sk 
         and ws_item_sk in (select item_sk from frequent_ss_items)
         and ws_bill_customer_sk in (select c_customer_sk from best_ss_customer)) 
 limit 100;
with /* TPC-DS query23.tpl 0.68 part2 */ frequent_ss_items as
 (select substring(i_item_desc,1,30) itemdesc,i_item_sk item_sk,d_date solddate,count(*) cnt
  from store_sales
      ,date_dim
      ,item
  where ss_sold_date_sk = d_date_sk
    and ss_item_sk = i_item_sk
    and d_year in (1998,1998 + 1,1998 + 2,1998 + 3)
  group by substring(i_item_desc,1,30),i_item_sk,d_date
  having count(*) >4),
 max_store_sales as
 (select max(csales) tpcds_cmax
  from (select c_customer_sk,sum(ss_quantity*ss_sales_price) csales
        from store_sales
            ,customer
            ,date_dim 
        where ss_customer_sk = c_customer_sk
         and ss_sold_date_sk = d_date_sk
         and d_year in (1998,1998+1,1998+2,1998+3)
        group by c_customer_sk)),
 best_ss_customer as
 (select c_customer_sk,sum(ss_quantity*ss_sales_price) ssales
  from store_sales
      ,customer
  where ss_customer_sk = c_customer_sk
  group by c_customer_sk
  having sum(ss_quantity*ss_sales_price) > (95/100.0) * (select
  *
 from max_store_sales))
  select  c_last_name,c_first_name,sales
 from (select c_last_name,c_first_name,sum(cs_quantity*cs_list_price) sales
        from catalog_sales
            ,customer
            ,date_dim 
        where d_year = 1998 
         and d_moy = 3 
         and cs_sold_date_sk = d_date_sk 
         and cs_item_sk in (select item_sk from frequent_ss_items)
         and cs_bill_customer_sk in (select c_customer_sk from best_ss_customer)
         and cs_bill_customer_sk = c_customer_sk 
       group by c_last_name,c_first_name
      union all
      select c_last_name,c_first_name,sum(ws_quantity*ws_list_price) sales
       from web_sales
           ,customer
           ,date_dim 
       where d_year = 1998 
         and d_moy = 3 
         and ws_sold_date_sk = d_date_sk 
         and ws_item_sk in (select item_sk from frequent_ss_items)
         and ws_bill_customer_sk in (select c_customer_sk from best_ss_customer)
         and ws_bill_customer_sk = c_customer_sk
       group by c_last_name,c_first_name) 
     order by c_last_name,c_first_name,sales
  limit 100;

-- end query 43 in stream 2 using template query23.tpl
set query_group to 'TPC-DS query62.tpl stream.2.44';
select /* TPC-DS query62.tpl 0.24 */  
   substring(w_warehouse_name,1,20)
  ,sm_type
  ,web_name
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk <= 30 ) then 1 else 0 end)  as "30 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 30) and 
                 (ws_ship_date_sk - ws_sold_date_sk <= 60) then 1 else 0 end )  as "31-60 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 60) and 
                 (ws_ship_date_sk - ws_sold_date_sk <= 90) then 1 else 0 end)  as "61-90 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 90) and
                 (ws_ship_date_sk - ws_sold_date_sk <= 120) then 1 else 0 end)  as "91-120 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk  > 120) then 1 else 0 end)  as ">120 days" 
from
   web_sales
  ,warehouse
  ,ship_mode
  ,web_site
  ,date_dim
where
    d_month_seq between 1183 and 1183 + 11
and ws_ship_date_sk   = d_date_sk
and ws_warehouse_sk   = w_warehouse_sk
and ws_ship_mode_sk   = sm_ship_mode_sk
and ws_web_site_sk    = web_site_sk
group by
   substring(w_warehouse_name,1,20)
  ,sm_type
  ,web_name
order by substring(w_warehouse_name,1,20)
        ,sm_type
       ,web_name
limit 100;

-- end query 44 in stream 2 using template query62.tpl
set query_group to 'TPC-DS query30.tpl stream.2.45';
with /* TPC-DS query30.tpl 0.75 */ customer_total_return as
 (select wr_returning_customer_sk as ctr_customer_sk
        ,ca_state as ctr_state, 
 	sum(wr_return_amt) as ctr_total_return
 from web_returns
     ,date_dim
     ,customer_address
 where wr_returned_date_sk = d_date_sk 
   and d_year =1999
   and wr_returning_addr_sk = ca_address_sk 
 group by wr_returning_customer_sk
         ,ca_state)
  select  c_customer_id,c_salutation,c_first_name,c_last_name,c_preferred_cust_flag
       ,c_birth_day,c_birth_month,c_birth_year,c_birth_country,c_login,c_email_address
       ,c_last_review_date_sk,ctr_total_return
 from customer_total_return ctr1
     ,customer_address
     ,customer
 where ctr1.ctr_total_return > (select avg(ctr_total_return)*1.2
 			  from customer_total_return ctr2 
                  	  where ctr1.ctr_state = ctr2.ctr_state)
       and ca_address_sk = c_current_addr_sk
       and ca_state = 'ME'
       and ctr1.ctr_customer_sk = c_customer_sk
 order by c_customer_id,c_salutation,c_first_name,c_last_name,c_preferred_cust_flag
                  ,c_birth_day,c_birth_month,c_birth_year,c_birth_country,c_login,c_email_address
                  ,c_last_review_date_sk,ctr_total_return
limit 100;

-- end query 45 in stream 2 using template query30.tpl
set query_group to 'TPC-DS query86a.tpl stream.2.46';
with /* TPC-DS query86a.tpl 0.11 */ results as
( select sum(ws_net_paid) as total_sum, i_category, i_class, 0 as g_category, 0 as g_class 
 from
    web_sales
   ,date_dim       d1
   ,item
 where
    d1.d_month_seq between 1211 and 1211+11
 and d1.d_date_sk = ws_sold_date_sk
 and i_item_sk  = ws_item_sk
 group by i_category,i_class
 ) ,

 results_rollup as
( select total_sum ,i_category ,i_class, g_category, g_class, 0 as lochierarchy from results
  union
  select sum(total_sum) as total_sum, i_category, NULL as i_class, 0 as g_category, 1 as g_class, 1 as lochierarchy from results group by i_category
  union
  select sum(total_sum) as total_sum, NULL as i_category, NULL as i_class, 1 as g_category, 1 as g_class, 2 as lochierarchy from results)
 select 
 total_sum ,i_category ,i_class, lochierarchy 
   ,rank() over (
 	partition by lochierarchy,
 	case when g_class = 0 then i_category end 
 	order by total_sum desc) as rank_within_parent
 from
 results_rollup
 order by
   lochierarchy desc,
   case when lochierarchy = 0 then i_category end,
   rank_within_parent 
 limit 100;

-- end query 46 in stream 2 using template query86a.tpl
set query_group to 'TPC-DS query82.tpl stream.2.47';
select /* TPC-DS query82.tpl 0.67 */  i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, store_sales
 where i_current_price between 54 and 54+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('2002-01-11' as date) and dateadd(day,60,cast('2002-01-11' as date))
 and i_manufact_id in (532,880,52,639)
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;

-- end query 47 in stream 2 using template query82.tpl
set query_group to 'TPC-DS query25.tpl stream.2.48';
select /* TPC-DS query25.tpl 0.9 */  
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 ,stddev_samp(ss_net_profit) as store_sales_profit
 ,stddev_samp(sr_net_loss) as store_returns_loss
 ,stddev_samp(cs_net_profit) as catalog_sales_profit
 from
 store_sales
 ,store_returns
 ,catalog_sales
 ,date_dim d1
 ,date_dim d2
 ,date_dim d3
 ,store
 ,item
 where
 d1.d_moy = 4
 and d1.d_year = 1999
 and d1.d_date_sk = ss_sold_date_sk
 and i_item_sk = ss_item_sk
 and s_store_sk = ss_store_sk
 and ss_customer_sk = sr_customer_sk
 and ss_item_sk = sr_item_sk
 and ss_ticket_number = sr_ticket_number
 and sr_returned_date_sk = d2.d_date_sk
 and d2.d_moy               between 4 and  10
 and d2.d_year              = 1999
 and sr_customer_sk = cs_bill_customer_sk
 and sr_item_sk = cs_item_sk
 and cs_sold_date_sk = d3.d_date_sk
 and d3.d_moy               between 4 and  10 
 and d3.d_year              = 1999
 group by
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 order by
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 limit 100;

-- end query 48 in stream 2 using template query25.tpl
set query_group to 'TPC-DS query16.tpl stream.2.49';
select /* TPC-DS query16.tpl 0.25 */  
   count(distinct cs_order_number) as "order count"
  ,sum(cs_ext_ship_cost) as "total shipping cost"
  ,sum(cs_net_profit) as "total net profit"
from
   catalog_sales cs1
  ,date_dim
  ,customer_address
  ,call_center
where
    d_date between '2001-5-01' and 
           dateadd(day, 60, cast('2001-5-01' as date))
and cs1.cs_ship_date_sk = d_date_sk
and cs1.cs_ship_addr_sk = ca_address_sk
and ca_state = 'KS'
and cs1.cs_call_center_sk = cc_call_center_sk
and cc_county in ('Perry County','Gogebic County','Kittitas County','Jefferson Davis Parish',
                  'Mobile County'
)
and exists (select *
            from catalog_sales cs2
            where cs1.cs_order_number = cs2.cs_order_number
              and cs1.cs_warehouse_sk <> cs2.cs_warehouse_sk)
and not exists(select *
               from catalog_returns cr1
               where cs1.cs_order_number = cr1.cr_order_number)
order by count(distinct cs_order_number)
limit 100;

-- end query 49 in stream 2 using template query16.tpl
set query_group to 'TPC-DS query81.tpl stream.2.50';
with /* TPC-DS query81.tpl 0.37 */ customer_total_return as
 (select cr_returning_customer_sk as ctr_customer_sk
        ,ca_state as ctr_state, 
 	sum(cr_return_amt_inc_tax) as ctr_total_return
 from catalog_returns
     ,date_dim
     ,customer_address
 where cr_returned_date_sk = d_date_sk 
   and d_year =1999
   and cr_returning_addr_sk = ca_address_sk 
 group by cr_returning_customer_sk
         ,ca_state )
  select  c_customer_id,c_salutation,c_first_name,c_last_name,ca_street_number,ca_street_name
                   ,ca_street_type,ca_suite_number,ca_city,ca_county,ca_state,ca_zip,ca_country,ca_gmt_offset
                  ,ca_location_type,ctr_total_return
 from customer_total_return ctr1
     ,customer_address
     ,customer
 where ctr1.ctr_total_return > (select avg(ctr_total_return)*1.2
 			  from customer_total_return ctr2 
                  	  where ctr1.ctr_state = ctr2.ctr_state)
       and ca_address_sk = c_current_addr_sk
       and ca_state = 'TX'
       and ctr1.ctr_customer_sk = c_customer_sk
 order by c_customer_id,c_salutation,c_first_name,c_last_name,ca_street_number,ca_street_name
                   ,ca_street_type,ca_suite_number,ca_city,ca_county,ca_state,ca_zip,ca_country,ca_gmt_offset
                  ,ca_location_type,ctr_total_return
 limit 100;

-- end query 50 in stream 2 using template query81.tpl
set query_group to 'TPC-DS query40.tpl stream.2.51';
select /* TPC-DS query40.tpl 0.86 */  
   w_state
  ,i_item_id
  ,sum(case when (cast(d_date as date) < cast ('2001-05-16' as date)) 
 		then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_before
  ,sum(case when (cast(d_date as date) >= cast ('2001-05-16' as date)) 
 		then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_after
 from
   catalog_sales left outer join catalog_returns on
       (cs_order_number = cr_order_number 
        and cs_item_sk = cr_item_sk)
  ,warehouse 
  ,item
  ,date_dim
 where
     i_current_price between 0.99 and 1.49
 and i_item_sk          = cs_item_sk
 and cs_warehouse_sk    = w_warehouse_sk 
 and cs_sold_date_sk    = d_date_sk
 and d_date between dateadd(day,-30,cast ('2001-05-16' as date))
                and dateadd(day,30,cast ('2001-05-16' as date))
 group by
    w_state,i_item_id
 order by w_state,i_item_id
limit 100;

-- end query 51 in stream 2 using template query40.tpl
set query_group to 'TPC-DS query44.tpl stream.2.52';
select /* TPC-DS query44.tpl 0.4 */  asceding.rnk, i1.i_product_name best_performing, i2.i_product_name worst_performing
from(select *
     from (select item_sk,rank() over (order by rank_col asc) rnk
           from (select ss_item_sk item_sk,avg(ss_net_profit) rank_col 
                 from store_sales ss1
                 where ss_store_sk = 417
                 group by ss_item_sk
                 having avg(ss_net_profit) > 0.90*(select avg(ss_net_profit) rank_col
                                                  from store_sales
                                                  where ss_store_sk = 417
                                                    and ss_promo_sk is null
                                                  group by ss_store_sk))V1)V11
     where rnk  < 11) asceding,
    (select *
     from (select item_sk,rank() over (order by rank_col desc) rnk
           from (select ss_item_sk item_sk,avg(ss_net_profit) rank_col
                 from store_sales ss1
                 where ss_store_sk = 417
                 group by ss_item_sk
                 having avg(ss_net_profit) > 0.90*(select avg(ss_net_profit) rank_col
                                                  from store_sales
                                                  where ss_store_sk = 417
                                                    and ss_promo_sk is null
                                                  group by ss_store_sk))V2)V21
     where rnk  < 11) descending,
item i1,
item i2
where asceding.rnk = descending.rnk 
  and i1.i_item_sk=asceding.item_sk
  and i2.i_item_sk=descending.item_sk
order by asceding.rnk
limit 100;

-- end query 52 in stream 2 using template query44.tpl
set query_group to 'TPC-DS query50.tpl stream.2.53';
select /* TPC-DS query50.tpl 0.60 */  
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk <= 30 ) then 1 else 0 end)  as "30 days" 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 30) and 
                 (sr_returned_date_sk - ss_sold_date_sk <= 60) then 1 else 0 end )  as "31-60 days" 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 60) and 
                 (sr_returned_date_sk - ss_sold_date_sk <= 90) then 1 else 0 end)  as "61-90 days" 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 90) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 120) then 1 else 0 end)  as "91-120 days" 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk  > 120) then 1 else 0 end)  as ">120 days" 
from
   store_sales
  ,store_returns
  ,store
  ,date_dim d1
  ,date_dim d2
where
    d2.d_year = 2001
and d2.d_moy  = 8
and ss_ticket_number = sr_ticket_number
and ss_item_sk = sr_item_sk
and ss_sold_date_sk   = d1.d_date_sk
and sr_returned_date_sk   = d2.d_date_sk
and ss_customer_sk = sr_customer_sk
and ss_store_sk = s_store_sk
group by
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
order by s_store_name
        ,s_company_id
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
limit 100;

-- end query 53 in stream 2 using template query50.tpl
set query_group to 'TPC-DS query61.tpl stream.2.54';
select /* TPC-DS query61.tpl 0.97 */  promotions,total,cast(promotions as decimal(15,4))/cast(total as decimal(15,4))*100
from
  (select sum(ss_ext_sales_price) promotions
   from  store_sales
        ,store
        ,promotion
        ,date_dim
        ,customer
        ,customer_address 
        ,item
   where ss_sold_date_sk = d_date_sk
   and   ss_store_sk = s_store_sk
   and   ss_promo_sk = p_promo_sk
   and   ss_customer_sk= c_customer_sk
   and   ca_address_sk = c_current_addr_sk
   and   ss_item_sk = i_item_sk 
   and   ca_gmt_offset = -7
   and   i_category = 'Jewelry'
   and   (p_channel_dmail = 'Y' or p_channel_email = 'Y' or p_channel_tv = 'Y')
   and   s_gmt_offset = -7
   and   d_year = 2002
   and   d_moy  = 11) promotional_sales,
  (select sum(ss_ext_sales_price) total
   from  store_sales
        ,store
        ,date_dim
        ,customer
        ,customer_address
        ,item
   where ss_sold_date_sk = d_date_sk
   and   ss_store_sk = s_store_sk
   and   ss_customer_sk= c_customer_sk
   and   ca_address_sk = c_current_addr_sk
   and   ss_item_sk = i_item_sk
   and   ca_gmt_offset = -7
   and   i_category = 'Jewelry'
   and   s_gmt_offset = -7
   and   d_year = 2002
   and   d_moy  = 11) all_sales
order by promotions, total
limit 100;

-- end query 54 in stream 2 using template query61.tpl
set query_group to 'TPC-DS query85.tpl stream.2.55';
select /* TPC-DS query85.tpl 0.33 */  substring(r_reason_desc,1,20)
       ,avg(ws_quantity)
       ,avg(wr_refunded_cash)
       ,avg(wr_fee)
 from web_sales, web_returns, web_page, customer_demographics cd1,
      customer_demographics cd2, customer_address, date_dim, reason 
 where ws_web_page_sk = wp_web_page_sk
   and ws_item_sk = wr_item_sk
   and ws_order_number = wr_order_number
   and ws_sold_date_sk = d_date_sk and d_year = 1999
   and cd1.cd_demo_sk = wr_refunded_cdemo_sk 
   and cd2.cd_demo_sk = wr_returning_cdemo_sk
   and ca_address_sk = wr_refunded_addr_sk
   and r_reason_sk = wr_reason_sk
   and
   (
    (
     cd1.cd_marital_status = 'W'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = 'Secondary'
     and 
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 100.00 and 150.00
    )
   or
    (
     cd1.cd_marital_status = 'M'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = 'Primary' 
     and
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 50.00 and 100.00
    )
   or
    (
     cd1.cd_marital_status = 'S'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = 'College'
     and
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 150.00 and 200.00
    )
   )
   and
   (
    (
     ca_country = 'United States'
     and
     ca_state in ('MN', 'AR', 'IA')
     and ws_net_profit between 100 and 200  
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('AL', 'OK', 'AK')
     and ws_net_profit between 150 and 300  
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('IL', 'GA', 'ME')
     and ws_net_profit between 50 and 250  
    )
   )
group by r_reason_desc
order by substring(r_reason_desc,1,20)
        ,avg(ws_quantity)
        ,avg(wr_refunded_cash)
        ,avg(wr_fee)
limit 100;

-- end query 55 in stream 2 using template query85.tpl
set query_group to 'TPC-DS query73.tpl stream.2.56';
select /* TPC-DS query73.tpl 0.79 */ c_last_name
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag 
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and date_dim.d_dom between 1 and 2 
    and (household_demographics.hd_buy_potential = '>10000' or
         household_demographics.hd_buy_potential = 'Unknown')
    and household_demographics.hd_vehicle_count > 0
    and case when household_demographics.hd_vehicle_count > 0 then 
             household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count else null end > 1
    and date_dim.d_year in (2000,2000+1,2000+2)
    and store.s_county in ('Kootenai County','Van Buren County','Franklin Parish','Denali Borough')
    group by ss_ticket_number,ss_customer_sk) dj,customer
    where ss_customer_sk = c_customer_sk
      and cnt between 1 and 5
    order by cnt desc, c_last_name asc;

-- end query 56 in stream 2 using template query73.tpl
set query_group to 'TPC-DS query95.tpl stream.2.57';
with /* TPC-DS query95.tpl 0.43 */ ws_wh as
(select ws1.ws_order_number,ws1.ws_warehouse_sk wh1,ws2.ws_warehouse_sk wh2
 from web_sales ws1,web_sales ws2
 where ws1.ws_order_number = ws2.ws_order_number
   and ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
 select  
   count(distinct ws_order_number) as "order count"
  ,sum(ws_ext_ship_cost) as "total shipping cost"
  ,sum(ws_net_profit) as "total net profit"
from
   web_sales ws1
  ,date_dim
  ,customer_address
  ,web_site
where
    d_date between '2002-4-01' and 
           dateadd(day,60,cast('2002-4-01' as date))
and ws1.ws_ship_date_sk = d_date_sk
and ws1.ws_ship_addr_sk = ca_address_sk
and ca_state = 'KS'
and ws1.ws_web_site_sk = web_site_sk
and web_company_name = 'pri'
and ws1.ws_order_number in (select ws_order_number
                            from ws_wh)
and ws1.ws_order_number in (select wr_order_number
                            from web_returns,ws_wh
                            where wr_order_number = ws_wh.ws_order_number)
order by count(distinct ws_order_number)
limit 100;

-- end query 57 in stream 2 using template query95.tpl
set query_group to 'TPC-DS query84.tpl stream.2.58';
select /* TPC-DS query84.tpl 0.80 */  c_customer_id as customer_id
       , coalesce(c_last_name,'') || ', ' || coalesce(c_first_name,'') as customername
 from customer
     ,customer_address
     ,customer_demographics
     ,household_demographics
     ,income_band
     ,store_returns
 where ca_city	        =  'Red Hill'
   and c_current_addr_sk = ca_address_sk
   and ib_lower_bound   >=  42576
   and ib_upper_bound   <=  42576 + 50000
   and ib_income_band_sk = hd_income_band_sk
   and cd_demo_sk = c_current_cdemo_sk
   and hd_demo_sk = c_current_hdemo_sk
   and sr_cdemo_sk = cd_demo_sk
 order by c_customer_id
 limit 100;

-- end query 58 in stream 2 using template query84.tpl
set query_group to 'TPC-DS query4.tpl stream.2.59';
with /* TPC-DS query4.tpl 0.93 */ year_total as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(((ss_ext_list_price-ss_ext_wholesale_cost-ss_ext_discount_amt)+ss_ext_sales_price)/2) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((cs_ext_list_price-cs_ext_wholesale_cost-cs_ext_discount_amt)+cs_ext_sales_price)/2) ) year_total
       ,'c' sale_type
 from customer
     ,catalog_sales
     ,date_dim
 where c_customer_sk = cs_bill_customer_sk
   and cs_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((ws_ext_list_price-ws_ext_wholesale_cost-ws_ext_discount_amt)+ws_ext_sales_price)/2) ) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
         )
  select  
                  t_s_secyear.customer_id
                 ,t_s_secyear.customer_first_name
                 ,t_s_secyear.customer_last_name
                 ,t_s_secyear.customer_preferred_cust_flag
 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_c_firstyear
     ,year_total t_c_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
   and t_s_firstyear.customer_id = t_c_secyear.customer_id
   and t_s_firstyear.customer_id = t_c_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_secyear.customer_id
   and t_s_firstyear.sale_type = 's'
   and t_c_firstyear.sale_type = 'c'
   and t_w_firstyear.sale_type = 'w'
   and t_s_secyear.sale_type = 's'
   and t_c_secyear.sale_type = 'c'
   and t_w_secyear.sale_type = 'w'
   and t_s_firstyear.dyear =  1998
   and t_s_secyear.dyear = 1998+1
   and t_c_firstyear.dyear =  1998
   and t_c_secyear.dyear =  1998+1
   and t_w_firstyear.dyear = 1998
   and t_w_secyear.dyear = 1998+1
   and t_s_firstyear.year_total > 0
   and t_c_firstyear.year_total > 0
   and t_w_firstyear.year_total > 0
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
 order by t_s_secyear.customer_id
         ,t_s_secyear.customer_first_name
         ,t_s_secyear.customer_last_name
         ,t_s_secyear.customer_preferred_cust_flag
limit 100;

-- end query 59 in stream 2 using template query4.tpl
set query_group to 'TPC-DS query37.tpl stream.2.60';
select /* TPC-DS query37.tpl 0.31 */  i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, catalog_sales
 where i_current_price between 53 and 53 + 30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('2001-06-13' as date) and dateadd(day,60,cast('2001-06-13' as date))
 and i_manufact_id in (970,929,945,709)
 and inv_quantity_on_hand between 100 and 500
 and cs_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;

-- end query 60 in stream 2 using template query37.tpl
set query_group to 'TPC-DS query35.tpl stream.2.61';
select /* TPC-DS query35.tpl 0.47 */   
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  count(*) cnt1,
  avg(cd_dep_count),
  stddev_samp(cd_dep_count),
  min(cd_dep_count),
  cd_dep_employed_count,
  count(*) cnt2,
  avg(cd_dep_employed_count),
  stddev_samp(cd_dep_employed_count),
  min(cd_dep_employed_count),
  cd_dep_college_count,
  count(*) cnt3,
  avg(cd_dep_college_count),
  stddev_samp(cd_dep_college_count),
  min(cd_dep_college_count)
 from
  customer c,customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  cd_demo_sk = c.c_current_cdemo_sk and 
  exists (select *
          from store_sales,date_dim
          where c.c_customer_sk = ss_customer_sk and
                ss_sold_date_sk = d_date_sk and
                d_year = 2000 and
                d_qoy < 4) and
   (exists (select *
            from web_sales,date_dim
            where c.c_customer_sk = ws_bill_customer_sk and
                  ws_sold_date_sk = d_date_sk and
                  d_year = 2000 and
                  d_qoy < 4) or 
    exists (select * 
            from catalog_sales,date_dim
            where c.c_customer_sk = cs_ship_customer_sk and
                  cs_sold_date_sk = d_date_sk and
                  d_year = 2000 and
                  d_qoy < 4))
 group by ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 order by ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 limit 100;

-- end query 61 in stream 2 using template query35.tpl
set query_group to 'TPC-DS query94.tpl stream.2.62';
select /* TPC-DS query94.tpl 0.17 */  
   count(distinct ws_order_number) as "order count"
  ,sum(ws_ext_ship_cost) as "total shipping cost"
  ,sum(ws_net_profit) as "total net profit"
from
   web_sales ws1
  ,date_dim
  ,customer_address
  ,web_site
where
    d_date between '1999-3-01' and 
           dateadd(day,60,cast('1999-3-01' as date))
and ws1.ws_ship_date_sk = d_date_sk
and ws1.ws_ship_addr_sk = ca_address_sk
and ca_state = 'TN'
and ws1.ws_web_site_sk = web_site_sk
and web_company_name = 'pri'
and exists (select *
            from web_sales ws2
            where ws1.ws_order_number = ws2.ws_order_number
              and ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
and not exists(select *
               from web_returns wr1
               where ws1.ws_order_number = wr1.wr_order_number)
order by count(distinct ws_order_number)
limit 100;

-- end query 62 in stream 2 using template query94.tpl
set query_group to 'TPC-DS query58.tpl stream.2.63';
with /* TPC-DS query58.tpl 0.19 */ ss_items as
 (select i_item_id item_id
        ,sum(ss_ext_sales_price) ss_item_rev 
 from store_sales
     ,item
     ,date_dim
 where ss_item_sk = i_item_sk
   and d_date in (select d_date
                  from date_dim
                  where d_week_seq = (select d_week_seq 
                                      from date_dim
                                      where d_date = '2000-06-05'))
   and ss_sold_date_sk   = d_date_sk
 group by i_item_id),
 cs_items as
 (select i_item_id item_id
        ,sum(cs_ext_sales_price) cs_item_rev
  from catalog_sales
      ,item
      ,date_dim
 where cs_item_sk = i_item_sk
  and  d_date in (select d_date
                  from date_dim
                  where d_week_seq = (select d_week_seq 
                                      from date_dim
                                      where d_date = '2000-06-05'))
  and  cs_sold_date_sk = d_date_sk
 group by i_item_id),
 ws_items as
 (select i_item_id item_id
        ,sum(ws_ext_sales_price) ws_item_rev
  from web_sales
      ,item
      ,date_dim
 where ws_item_sk = i_item_sk
  and  d_date in (select d_date
                  from date_dim
                  where d_week_seq =(select d_week_seq 
                                     from date_dim
                                     where d_date = '2000-06-05'))
  and ws_sold_date_sk   = d_date_sk
 group by i_item_id)
  select  ss_items.item_id
       ,ss_item_rev
       ,ss_item_rev/((ss_item_rev+cs_item_rev+ws_item_rev)/3) * 100 ss_dev
       ,cs_item_rev
       ,cs_item_rev/((ss_item_rev+cs_item_rev+ws_item_rev)/3) * 100 cs_dev
       ,ws_item_rev
       ,ws_item_rev/((ss_item_rev+cs_item_rev+ws_item_rev)/3) * 100 ws_dev
       ,(ss_item_rev+cs_item_rev+ws_item_rev)/3 average
 from ss_items,cs_items,ws_items
 where ss_items.item_id=cs_items.item_id
   and ss_items.item_id=ws_items.item_id 
   and ss_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
   and ss_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
   and cs_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
   and cs_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
   and ws_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
   and ws_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
 order by item_id
         ,ss_item_rev
 limit 100;

-- end query 63 in stream 2 using template query58.tpl
set query_group to 'TPC-DS query96.tpl stream.2.64';
select /* TPC-DS query96.tpl 0.1 */  count(*) 
from store_sales
    ,household_demographics 
    ,time_dim, store
where ss_sold_time_sk = time_dim.t_time_sk   
    and ss_hdemo_sk = household_demographics.hd_demo_sk 
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and household_demographics.hd_dep_count = 4
    and store.s_store_name = 'ese'
order by count(*)
limit 100;

-- end query 64 in stream 2 using template query96.tpl
set query_group to 'TPC-DS query12.tpl stream.2.65';
select /* TPC-DS query12.tpl 0.64 */  i_item_id
      ,i_item_desc 
      ,i_category 
      ,i_class 
      ,i_current_price
      ,sum(ws_ext_sales_price) as itemrevenue 
      ,sum(ws_ext_sales_price)*100/sum(sum(ws_ext_sales_price)) over
          (partition by i_class) as revenueratio
from	
	web_sales
    	,item 
    	,date_dim
where 
	ws_item_sk = i_item_sk 
  	and i_category in ('Children', 'Sports', 'Music')
  	and ws_sold_date_sk = d_date_sk
	and d_date between cast('2001-04-23' as date) 
				and dateadd(day,30,cast('2001-04-23' as date))
group by 
	i_item_id
        ,i_item_desc 
        ,i_category
        ,i_class
        ,i_current_price
order by 
	i_category
        ,i_class
        ,i_item_id
        ,i_item_desc
        ,revenueratio
limit 100;

-- end query 65 in stream 2 using template query12.tpl
set query_group to 'TPC-DS query29.tpl stream.2.66';
select /* TPC-DS query29.tpl 0.53 */   
     i_item_id
    ,i_item_desc
    ,s_store_id
    ,s_store_name
    ,min(ss_quantity)        as store_sales_quantity
    ,min(sr_return_quantity) as store_returns_quantity
    ,min(cs_quantity)        as catalog_sales_quantity
 from
    store_sales
   ,store_returns
   ,catalog_sales
   ,date_dim             d1
   ,date_dim             d2
   ,date_dim             d3
   ,store
   ,item
 where
     d1.d_moy               = 4 
 and d1.d_year              = 1998
 and d1.d_date_sk           = ss_sold_date_sk
 and i_item_sk              = ss_item_sk
 and s_store_sk             = ss_store_sk
 and ss_customer_sk         = sr_customer_sk
 and ss_item_sk             = sr_item_sk
 and ss_ticket_number       = sr_ticket_number
 and sr_returned_date_sk    = d2.d_date_sk
 and d2.d_moy               between 4 and  4 + 3 
 and d2.d_year              = 1998
 and sr_customer_sk         = cs_bill_customer_sk
 and sr_item_sk             = cs_item_sk
 and cs_sold_date_sk        = d3.d_date_sk     
 and d3.d_year              in (1998,1998+1,1998+2)
 group by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
 order by
    i_item_id 
   ,i_item_desc
   ,s_store_id
   ,s_store_name
 limit 100;

-- end query 66 in stream 2 using template query29.tpl
set query_group to 'TPC-DS query22a.tpl stream.2.67';
with /* TPC-DS query22a.tpl 0.55 */ results as 
(select  i_product_name
             ,i_brand
             ,i_class
             ,i_category
             ,avg(inv_quantity_on_hand) qoh
       from inventory
           ,date_dim
           ,item
           ,warehouse
       where  inv_date_sk=d_date_sk
              and inv_item_sk=i_item_sk
              and inv_warehouse_sk = w_warehouse_sk
              and d_month_seq between 1176 and 1176 + 11
       group by i_product_name,i_brand,i_class,i_category),
results_rollup as 
(select i_product_name, i_brand, i_class, i_category,avg(qoh) qoh 
from results 
group by i_product_name,i_brand,i_class,i_category
union all 
select i_product_name, i_brand, i_class, null i_category,avg(qoh) qoh 
from results
group by i_product_name,i_brand,i_class
union all 
select i_product_name, i_brand, null i_class, null i_category,avg(qoh) qoh 
from results
group by i_product_name,i_brand
union all 
select i_product_name, null i_brand, null i_class, null i_category,avg(qoh)  qoh 
from results
group by i_product_name
union all 
select null i_product_name, null i_brand, null i_class, null i_category,avg(qoh) qoh 
from results)
 select  i_product_name, i_brand, i_class, i_category,qoh
      from results_rollup
      order by qoh, i_product_name, i_brand, i_class, i_category
limit 100;

-- end query 67 in stream 2 using template query22a.tpl
set query_group to 'TPC-DS query51.tpl stream.2.68';
WITH /* TPC-DS query51.tpl 0.46 */ web_v1 as (
select
  ws_item_sk item_sk, d_date,
  sum(sum(ws_sales_price))
      over (partition by ws_item_sk order by d_date rows between unbounded preceding and current row) cume_sales
from web_sales
    ,date_dim
where ws_sold_date_sk=d_date_sk
  and d_month_seq between 1177 and 1177+11
  and ws_item_sk is not NULL
group by ws_item_sk, d_date),
store_v1 as (
select
  ss_item_sk item_sk, d_date,
  sum(sum(ss_sales_price))
      over (partition by ss_item_sk order by d_date rows between unbounded preceding and current row) cume_sales
from store_sales
    ,date_dim
where ss_sold_date_sk=d_date_sk
  and d_month_seq between 1177 and 1177+11
  and ss_item_sk is not NULL
group by ss_item_sk, d_date)
 select  *
from (select item_sk
     ,d_date
     ,web_sales
     ,store_sales
     ,max(web_sales)
         over (partition by item_sk order by d_date rows between unbounded preceding and current row) web_cumulative
     ,max(store_sales)
         over (partition by item_sk order by d_date rows between unbounded preceding and current row) store_cumulative
     from (select case when web.item_sk is not null then web.item_sk else store.item_sk end item_sk
                 ,case when web.d_date is not null then web.d_date else store.d_date end d_date
                 ,web.cume_sales web_sales
                 ,store.cume_sales store_sales
           from web_v1 web full outer join store_v1 store on (web.item_sk = store.item_sk
                                                          and web.d_date = store.d_date)
          )x )y
where web_cumulative > store_cumulative
order by item_sk
        ,d_date
limit 100;

-- end query 68 in stream 2 using template query51.tpl
set query_group to 'TPC-DS query36a.tpl stream.2.69';
with /* TPC-DS query36a.tpl 0.21 */ results as
 (select 
    sum(ss_net_profit) as ss_net_profit, sum(ss_ext_sales_price) as ss_ext_sales_price,
    sum(ss_net_profit)/sum(ss_ext_sales_price) as gross_margin
   ,i_category
   ,i_class
   ,0 as g_category, 0 as g_class
 from
    store_sales
   ,date_dim       d1
   ,item
   ,store
 where
    d1.d_year = 2000 
    and d1.d_date_sk = ss_sold_date_sk
    and i_item_sk  = ss_item_sk 
    and s_store_sk  = ss_store_sk
    and s_state in ('MN','IL','MN','NM',
                 'KY','NE','GA','MI')
 group by i_category,i_class)
 ,
 results_rollup as
 (select gross_margin ,i_category ,i_class,0 as t_category, 0 as t_class, 0 as lochierarchy from results
 union
 select sum(ss_net_profit)/sum(ss_ext_sales_price) as gross_margin,
   i_category, NULL AS i_class, 0 as t_category, 1 as t_class, 1 as lochierarchy from results group by i_category
 union
 select sum(ss_net_profit)/sum(ss_ext_sales_price) as gross_margin,
   NULL AS i_category ,NULL AS i_class, 1 as t_category, 1 as t_class, 2 as lochierarchy from results)
  select 
  gross_margin ,i_category ,i_class, lochierarchy,rank() over (
 	partition by lochierarchy, case when t_class = 0 then i_category end 
 	order by gross_margin asc) as rank_within_parent
 from results_rollup
 order by
   lochierarchy desc
  ,case when lochierarchy = 0 then i_category end
  ,rank_within_parent
  limit 100;

-- end query 69 in stream 2 using template query36a.tpl
set query_group to 'TPC-DS query43.tpl stream.2.70';
select /* TPC-DS query43.tpl 0.15 */  s_store_name, s_store_id,
        sum(case when (d_day_name='Sunday') then ss_sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then ss_sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then ss_sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then ss_sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then ss_sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then ss_sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then ss_sales_price else null end) sat_sales
 from date_dim, store_sales, store
 where d_date_sk = ss_sold_date_sk and
       s_store_sk = ss_store_sk and
       s_gmt_offset = -5 and
       d_year = 1998 
 group by s_store_name, s_store_id
 order by s_store_name, s_store_id,sun_sales,mon_sales,tue_sales,wed_sales,thu_sales,fri_sales,sat_sales
 limit 100;

-- end query 70 in stream 2 using template query43.tpl
set query_group to 'TPC-DS query64.tpl stream.2.71';
with /* TPC-DS query64.tpl 0.20 */ cs_ui as
 (select cs_item_sk
        ,sum(cs_ext_list_price) as sale,sum(cr_refunded_cash+cr_reversed_charge+cr_store_credit) as refund
  from catalog_sales
      ,catalog_returns
  where cs_item_sk = cr_item_sk
    and cs_order_number = cr_order_number
  group by cs_item_sk
  having sum(cs_ext_list_price)>2*sum(cr_refunded_cash+cr_reversed_charge+cr_store_credit)),
cross_sales as
 (select i_product_name product_name
     ,i_item_sk item_sk
     ,s_store_name store_name
     ,s_zip store_zip
     ,ad1.ca_street_number b_street_number
     ,ad1.ca_street_name b_street_name
     ,ad1.ca_city b_city
     ,ad1.ca_zip b_zip
     ,ad2.ca_street_number c_street_number
     ,ad2.ca_street_name c_street_name
     ,ad2.ca_city c_city
     ,ad2.ca_zip c_zip
     ,d1.d_year as syear
     ,d2.d_year as fsyear
     ,d3.d_year s2year
     ,count(*) cnt
     ,sum(ss_wholesale_cost) s1
     ,sum(ss_list_price) s2
     ,sum(ss_coupon_amt) s3
  FROM   store_sales
        ,store_returns
        ,cs_ui
        ,date_dim d1
        ,date_dim d2
        ,date_dim d3
        ,store
        ,customer
        ,customer_demographics cd1
        ,customer_demographics cd2
        ,promotion
        ,household_demographics hd1
        ,household_demographics hd2
        ,customer_address ad1
        ,customer_address ad2
        ,income_band ib1
        ,income_band ib2
        ,item
  WHERE  ss_store_sk = s_store_sk AND
         ss_sold_date_sk = d1.d_date_sk AND
         ss_customer_sk = c_customer_sk AND
         ss_cdemo_sk= cd1.cd_demo_sk AND
         ss_hdemo_sk = hd1.hd_demo_sk AND
         ss_addr_sk = ad1.ca_address_sk and
         ss_item_sk = i_item_sk and
         ss_item_sk = sr_item_sk and
         ss_ticket_number = sr_ticket_number and
         ss_item_sk = cs_ui.cs_item_sk and
         c_current_cdemo_sk = cd2.cd_demo_sk AND
         c_current_hdemo_sk = hd2.hd_demo_sk AND
         c_current_addr_sk = ad2.ca_address_sk and
         c_first_sales_date_sk = d2.d_date_sk and
         c_first_shipto_date_sk = d3.d_date_sk and
         ss_promo_sk = p_promo_sk and
         hd1.hd_income_band_sk = ib1.ib_income_band_sk and
         hd2.hd_income_band_sk = ib2.ib_income_band_sk and
         cd1.cd_marital_status <> cd2.cd_marital_status and
         i_color in ('khaki','tomato','metallic','mint','deep','papaya') and
         i_current_price between 0 and 0 + 10 and
         i_current_price between 0 + 1 and 0 + 15
group by i_product_name
       ,i_item_sk
       ,s_store_name
       ,s_zip
       ,ad1.ca_street_number
       ,ad1.ca_street_name
       ,ad1.ca_city
       ,ad1.ca_zip
       ,ad2.ca_street_number
       ,ad2.ca_street_name
       ,ad2.ca_city
       ,ad2.ca_zip
       ,d1.d_year
       ,d2.d_year
       ,d3.d_year
)
select cs1.product_name
     ,cs1.store_name
     ,cs1.store_zip
     ,cs1.b_street_number
     ,cs1.b_street_name
     ,cs1.b_city
     ,cs1.b_zip
     ,cs1.c_street_number
     ,cs1.c_street_name
     ,cs1.c_city
     ,cs1.c_zip
     ,cs1.syear
     ,cs1.cnt
     ,cs1.s1 as s11
     ,cs1.s2 as s21
     ,cs1.s3 as s31
     ,cs2.s1 as s12
     ,cs2.s2 as s22
     ,cs2.s3 as s32
     ,cs2.syear
     ,cs2.cnt
from cross_sales cs1,cross_sales cs2
where cs1.item_sk=cs2.item_sk and
     cs1.syear = 2000 and
     cs2.syear = 2000 + 1 and
     cs2.cnt <= cs1.cnt and
     cs1.store_name = cs2.store_name and
     cs1.store_zip = cs2.store_zip
order by cs1.product_name
       ,cs1.store_name
       ,cs2.cnt
       ,cs1.s1
       ,cs2.s1;

-- end query 71 in stream 2 using template query64.tpl
set query_group to 'TPC-DS query20.tpl stream.2.72';
select /* TPC-DS query20.tpl 0.65 */  i_item_id
       ,i_item_desc 
       ,i_category 
       ,i_class 
       ,i_current_price
       ,sum(cs_ext_sales_price) as itemrevenue 
       ,sum(cs_ext_sales_price)*100/sum(sum(cs_ext_sales_price)) over
           (partition by i_class) as revenueratio
 from	catalog_sales
     ,item 
     ,date_dim
 where cs_item_sk = i_item_sk 
   and i_category in ('Books', 'Women', 'Men')
   and cs_sold_date_sk = d_date_sk
 and d_date between cast('2002-01-12' as date) 
 				and dateadd(day,30,cast('2002-01-12' as date))
 group by i_item_id
         ,i_item_desc 
         ,i_category
         ,i_class
         ,i_current_price
 order by i_category
         ,i_class
         ,i_item_id
         ,i_item_desc
         ,revenueratio
limit 100;

-- end query 72 in stream 2 using template query20.tpl
set query_group to 'TPC-DS query57.tpl stream.2.73';
with /* TPC-DS query57.tpl 0.70 */ v1 as(
 select i_category, i_brand,
        cc_name,
        d_year, d_moy,
        sum(cs_sales_price) sum_sales,
        avg(sum(cs_sales_price)) over
          (partition by i_category, i_brand,
                     cc_name, d_year)
          avg_monthly_sales,
        rank() over
          (partition by i_category, i_brand,
                     cc_name
           order by d_year, d_moy) rn
 from item, catalog_sales, date_dim, call_center
 where cs_item_sk = i_item_sk and
       cs_sold_date_sk = d_date_sk and
       cc_call_center_sk= cs_call_center_sk and
       (
         d_year = 2000 or
         ( d_year = 2000-1 and d_moy =12) or
         ( d_year = 2000+1 and d_moy =1)
       )
 group by i_category, i_brand,
          cc_name , d_year, d_moy),
 v2 as(
 select v1.i_category, v1.i_brand, v1.cc_name
        ,v1.d_year, v1.d_moy
        ,v1.avg_monthly_sales
        ,v1.sum_sales, v1_lag.sum_sales psum, v1_lead.sum_sales nsum
 from v1, v1 v1_lag, v1 v1_lead
 where v1.i_category = v1_lag.i_category and
       v1.i_category = v1_lead.i_category and
       v1.i_brand = v1_lag.i_brand and
       v1.i_brand = v1_lead.i_brand and
       v1. cc_name = v1_lag. cc_name and
       v1. cc_name = v1_lead. cc_name and
       v1.rn = v1_lag.rn + 1 and
       v1.rn = v1_lead.rn - 1)
  select  *
 from v2
 where  d_year = 2000 and
        avg_monthly_sales > 0 and
        case when avg_monthly_sales > 0 then abs(sum_sales - avg_monthly_sales) / avg_monthly_sales else null end > 0.1
 order by sum_sales - avg_monthly_sales, 3
 limit 100;

-- end query 73 in stream 2 using template query57.tpl
set query_group to 'TPC-DS query9.tpl stream.2.74';
select /* TPC-DS query9.tpl 0.49 */ case when (select count(*) 
                  from store_sales 
                  where ss_quantity between 1 and 20) > 14527649
            then (select avg(ss_ext_tax) 
                  from store_sales 
                  where ss_quantity between 1 and 20) 
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 1 and 20) end bucket1 ,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 21 and 40) > 1132094339
            then (select avg(ss_ext_tax)
                  from store_sales
                  where ss_quantity between 21 and 40) 
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 21 and 40) end bucket2,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 41 and 60) > 793402512
            then (select avg(ss_ext_tax)
                  from store_sales
                  where ss_quantity between 41 and 60)
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 41 and 60) end bucket3,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 61 and 80) > 958016730
            then (select avg(ss_ext_tax)
                  from store_sales
                  where ss_quantity between 61 and 80)
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 61 and 80) end bucket4,
       case when (select count(*)
                  from store_sales
                  where ss_quantity between 81 and 100) > 581012800
            then (select avg(ss_ext_tax)
                  from store_sales
                  where ss_quantity between 81 and 100)
            else (select avg(ss_net_paid)
                  from store_sales
                  where ss_quantity between 81 and 100) end bucket5
from reason
where r_reason_sk = 1
;

-- end query 74 in stream 2 using template query9.tpl
set query_group to 'TPC-DS query52.tpl stream.2.75';
select /* TPC-DS query52.tpl 0.59 */  dt.d_year
 	,item.i_brand_id brand_id
 	,item.i_brand brand
 	,sum(ss_ext_sales_price) ext_price
 from date_dim dt
     ,store_sales
     ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
    and store_sales.ss_item_sk = item.i_item_sk
    and item.i_manager_id = 1
    and dt.d_moy=11
    and dt.d_year=2002
 group by dt.d_year
 	,item.i_brand
 	,item.i_brand_id
 order by dt.d_year
 	,ext_price desc
 	,brand_id
limit 100 ;

-- end query 75 in stream 2 using template query52.tpl
set query_group to 'TPC-DS query49.tpl stream.2.76';
select /* TPC-DS query49.tpl 0.48 */  channel, item, return_ratio, return_rank, currency_rank from
 (select
 'web' as channel
 ,web.item
 ,web.return_ratio
 ,web.return_rank
 ,web.currency_rank
 from (
 	select 
 	 item
 	,return_ratio
 	,currency_ratio
 	,rank() over (order by return_ratio) as return_rank
 	,rank() over (order by currency_ratio) as currency_rank
 	from
 	(	select ws.ws_item_sk as item
 		,(cast(sum(coalesce(wr.wr_return_quantity,0)) as decimal(15,4))/
 		cast(sum(coalesce(ws.ws_quantity,0)) as decimal(15,4) )) as return_ratio
 		,(cast(sum(coalesce(wr.wr_return_amt,0)) as decimal(15,4))/
 		cast(sum(coalesce(ws.ws_net_paid,0)) as decimal(15,4) )) as currency_ratio
 		from 
 		 web_sales ws left outer join web_returns wr 
 			on (ws.ws_order_number = wr.wr_order_number and 
 			ws.ws_item_sk = wr.wr_item_sk)
                 ,date_dim
 		where 
 			wr.wr_return_amt > 10000 
 			and ws.ws_net_profit > 1
                         and ws.ws_net_paid > 0
                         and ws.ws_quantity > 0
                         and ws_sold_date_sk = d_date_sk
                         and d_year = 1998
                         and d_moy = 12
 		group by ws.ws_item_sk
 	) in_web
 ) web
 where 
 (
 web.return_rank <= 10
 or
 web.currency_rank <= 10
 )
 union
 select 
 'catalog' as channel
 ,catalog.item
 ,catalog.return_ratio
 ,catalog.return_rank
 ,catalog.currency_rank
 from (
 	select 
 	 item
 	,return_ratio
 	,currency_ratio
 	,rank() over (order by return_ratio) as return_rank
 	,rank() over (order by currency_ratio) as currency_rank
 	from
 	(	select 
 		cs.cs_item_sk as item
 		,(cast(sum(coalesce(cr.cr_return_quantity,0)) as decimal(15,4))/
 		cast(sum(coalesce(cs.cs_quantity,0)) as decimal(15,4) )) as return_ratio
 		,(cast(sum(coalesce(cr.cr_return_amount,0)) as decimal(15,4))/
 		cast(sum(coalesce(cs.cs_net_paid,0)) as decimal(15,4) )) as currency_ratio
 		from 
 		catalog_sales cs left outer join catalog_returns cr
 			on (cs.cs_order_number = cr.cr_order_number and 
 			cs.cs_item_sk = cr.cr_item_sk)
                ,date_dim
 		where 
 			cr.cr_return_amount > 10000 
 			and cs.cs_net_profit > 1
                         and cs.cs_net_paid > 0
                         and cs.cs_quantity > 0
                         and cs_sold_date_sk = d_date_sk
                         and d_year = 1998
                         and d_moy = 12
                 group by cs.cs_item_sk
 	) in_cat
 ) catalog
 where 
 (
 catalog.return_rank <= 10
 or
 catalog.currency_rank <=10
 )
 union
 select 
 'store' as channel
 ,store.item
 ,store.return_ratio
 ,store.return_rank
 ,store.currency_rank
 from (
 	select 
 	 item
 	,return_ratio
 	,currency_ratio
 	,rank() over (order by return_ratio) as return_rank
 	,rank() over (order by currency_ratio) as currency_rank
 	from
 	(	select sts.ss_item_sk as item
 		,(cast(sum(coalesce(sr.sr_return_quantity,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_quantity,0)) as decimal(15,4) )) as return_ratio
 		,(cast(sum(coalesce(sr.sr_return_amt,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_net_paid,0)) as decimal(15,4) )) as currency_ratio
 		from 
 		store_sales sts left outer join store_returns sr
 			on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)
                ,date_dim
 		where 
 			sr.sr_return_amt > 10000 
 			and sts.ss_net_profit > 1
                         and sts.ss_net_paid > 0 
                         and sts.ss_quantity > 0
                         and ss_sold_date_sk = d_date_sk
                         and d_year = 1998
                         and d_moy = 12
 		group by sts.ss_item_sk
 	) in_store
 ) store
 where  (
 store.return_rank <= 10
 or 
 store.currency_rank <= 10
 )
 )
 order by 1,4,5,2
 limit 100;

-- end query 76 in stream 2 using template query49.tpl
set query_group to 'TPC-DS query71.tpl stream.2.77';
select /* TPC-DS query71.tpl 0.72 */ i_brand_id brand_id, i_brand brand,t_hour,t_minute,
 	sum(ext_price) ext_price
 from item, (select ws_ext_sales_price as ext_price, 
                        ws_sold_date_sk as sold_date_sk,
                        ws_item_sk as sold_item_sk,
                        ws_sold_time_sk as time_sk  
                 from web_sales,date_dim
                 where d_date_sk = ws_sold_date_sk
                   and d_moy=12
                   and d_year=2002
                 union all
                 select cs_ext_sales_price as ext_price,
                        cs_sold_date_sk as sold_date_sk,
                        cs_item_sk as sold_item_sk,
                        cs_sold_time_sk as time_sk
                 from catalog_sales,date_dim
                 where d_date_sk = cs_sold_date_sk
                   and d_moy=12
                   and d_year=2002
                 union all
                 select ss_ext_sales_price as ext_price,
                        ss_sold_date_sk as sold_date_sk,
                        ss_item_sk as sold_item_sk,
                        ss_sold_time_sk as time_sk
                 from store_sales,date_dim
                 where d_date_sk = ss_sold_date_sk
                   and d_moy=12
                   and d_year=2002
                 ) tmp,time_dim
 where
   sold_item_sk = i_item_sk
   and i_manager_id=1
   and time_sk = t_time_sk
   and (t_meal_time = 'breakfast' or t_meal_time = 'dinner')
 group by i_brand, i_brand_id,t_hour,t_minute
 order by ext_price desc, i_brand_id
 ;

-- end query 77 in stream 2 using template query71.tpl
set query_group to 'TPC-DS query72.tpl stream.2.78';
select /* TPC-DS query72.tpl 0.87 */  i_item_desc
      ,w_warehouse_name
      ,d1.d_week_seq
      ,sum(case when p_promo_sk is null then 1 else 0 end) no_promo
      ,sum(case when p_promo_sk is not null then 1 else 0 end) promo
      ,count(*) total_cnt
from catalog_sales
join inventory on (cs_item_sk = inv_item_sk)
join warehouse on (w_warehouse_sk=inv_warehouse_sk)
join item on (i_item_sk = cs_item_sk)
join customer_demographics on (cs_bill_cdemo_sk = cd_demo_sk)
join household_demographics on (cs_bill_hdemo_sk = hd_demo_sk)
join date_dim d1 on (cs_sold_date_sk = d1.d_date_sk)
join date_dim d2 on (inv_date_sk = d2.d_date_sk)
join date_dim d3 on (cs_ship_date_sk = d3.d_date_sk)
left outer join promotion on (cs_promo_sk=p_promo_sk)
left outer join catalog_returns on (cr_item_sk = cs_item_sk and cr_order_number = cs_order_number)
where d1.d_week_seq = d2.d_week_seq
  and inv_quantity_on_hand < cs_quantity 
  and d3.d_date > d1.d_date + 5
  and hd_buy_potential = '1001-5000'
  and d1.d_year = 1999
  and cd_marital_status = 'U'
group by i_item_desc,w_warehouse_name,d1.d_week_seq
order by total_cnt desc, i_item_desc, w_warehouse_name, d_week_seq
limit 100;

-- end query 78 in stream 2 using template query72.tpl
set query_group to 'TPC-DS query70a.tpl stream.2.79';
with /* TPC-DS query70a.tpl 0.34 */ results as
( select
    sum(ss_net_profit) as total_sum ,s_state ,s_county, 0 as gstate, 0 as g_county
 from
    store_sales
  ,date_dim      d1
  ,store
 where
    d1.d_month_seq between 1208 and 1208 + 11
 and d1.d_date_sk = ss_sold_date_sk
 and s_store_sk  = ss_store_sk
 and s_state in
            ( select s_state
              from  (select s_state as s_state,
                 rank() over ( partition by s_state order by sum(ss_net_profit) desc) as ranking
                      from  store_sales, store, date_dim
                      where d_month_seq between 1208 and 1208 + 11
                 and d_date_sk = ss_sold_date_sk
                 and s_store_sk  = ss_store_sk
                      group by s_state
                    ) tmp1 
              where ranking <= 5)
  group by s_state,s_county) ,  
 results_rollup as 
(select total_sum ,s_state ,s_county, 0 as g_state, 0 as g_county, 0 as lochierarchy from results
 union
 select sum(total_sum) as total_sum,s_state, NULL as s_county, 0 as g_state, 1 as g_county, 1 as lochierarchy from results group by s_state
 union
 select sum(total_sum) as total_sum ,NULL as s_state ,NULL as s_county, 1 as g_state, 1 as g_county, 2 as lochierarchy from results)
  select  total_sum ,s_state ,s_county, lochierarchy 
  ,rank() over (
     partition by lochierarchy, 
     case when g_county = 0 then s_state end 
     order by total_sum desc) as rank_within_parent
 from results_rollup
 order by
  lochierarchy desc
  ,case when lochierarchy = 0 then s_state end
  ,rank_within_parent
 limit 100;

-- end query 79 in stream 2 using template query70a.tpl
set query_group to 'TPC-DS query7.tpl stream.2.80';
select /* TPC-DS query7.tpl 0.2 */  i_item_id, 
        avg(ss_quantity) agg1,
        avg(ss_list_price) agg2,
        avg(ss_coupon_amt) agg3,
        avg(ss_sales_price) agg4 
 from store_sales, customer_demographics, date_dim, item, promotion
 where ss_sold_date_sk = d_date_sk and
       ss_item_sk = i_item_sk and
       ss_cdemo_sk = cd_demo_sk and
       ss_promo_sk = p_promo_sk and
       cd_gender = 'M' and 
       cd_marital_status = 'W' and
       cd_education_status = 'Advanced Degree' and
       (p_channel_email = 'N' or p_channel_event = 'N') and
       d_year = 2000 
 group by i_item_id
 order by i_item_id
 limit 100;

-- end query 80 in stream 2 using template query7.tpl
set query_group to 'TPC-DS query97.tpl stream.2.81';
with /* TPC-DS query97.tpl 0.38 */ ssci as (
select ss_customer_sk customer_sk
      ,ss_item_sk item_sk
from store_sales,date_dim
where ss_sold_date_sk = d_date_sk
  and d_month_seq between 1221 and 1221 + 11
group by ss_customer_sk
        ,ss_item_sk),
csci as(
 select cs_bill_customer_sk customer_sk
      ,cs_item_sk item_sk
from catalog_sales,date_dim
where cs_sold_date_sk = d_date_sk
  and d_month_seq between 1221 and 1221 + 11
group by cs_bill_customer_sk
        ,cs_item_sk)
 select  sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 else 0 end) store_only
      ,sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1 else 0 end) catalog_only
      ,sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 else 0 end) store_and_catalog
from ssci full outer join csci on (ssci.customer_sk=csci.customer_sk
                               and ssci.item_sk = csci.item_sk)
limit 100;

-- end query 81 in stream 2 using template query97.tpl
set query_group to 'TPC-DS query33.tpl stream.2.82';
with /* TPC-DS query33.tpl 0.22 */ ss as (
 select
          i_manufact_id,sum(ss_ext_sales_price) total_sales
 from
 	store_sales,
 	date_dim,
         customer_address,
         item
 where
         i_manufact_id in (select
  i_manufact_id
from
 item
where i_category in ('Home'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 2000
 and     d_moy                   = 7
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_manufact_id),
 cs as (
 select
          i_manufact_id,sum(cs_ext_sales_price) total_sales
 from
 	catalog_sales,
 	date_dim,
         customer_address,
         item
 where
         i_manufact_id               in (select
  i_manufact_id
from
 item
where i_category in ('Home'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 2000
 and     d_moy                   = 7
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_manufact_id),
 ws as (
 select
          i_manufact_id,sum(ws_ext_sales_price) total_sales
 from
 	web_sales,
 	date_dim,
         customer_address,
         item
 where
         i_manufact_id               in (select
  i_manufact_id
from
 item
where i_category in ('Home'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 2000
 and     d_moy                   = 7
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_manufact_id)
  select  i_manufact_id ,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_manufact_id
 order by total_sales
limit 100;

-- end query 82 in stream 2 using template query33.tpl
set query_group to 'TPC-DS query79.tpl stream.2.83';
select /* TPC-DS query79.tpl 0.89 */ 
  c_last_name,c_first_name,substring(s_city,1,30),ss_ticket_number,amt,profit
  from
   (select ss_ticket_number
          ,ss_customer_sk
          ,store.s_city
          ,sum(ss_coupon_amt) amt
          ,sum(ss_net_profit) profit
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (household_demographics.hd_dep_count = 7 or household_demographics.hd_vehicle_count > 3)
    and date_dim.d_dow = 1
    and date_dim.d_year in (1999,1999+1,1999+2) 
    and store.s_number_employees between 200 and 295
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk,store.s_city) ms,customer
    where ss_customer_sk = c_customer_sk
 order by c_last_name,c_first_name,substring(s_city,1,30), profit
limit 100;

-- end query 83 in stream 2 using template query79.tpl
set query_group to 'TPC-DS query32.tpl stream.2.84';
select /* TPC-DS query32.tpl 0.7 */  sum(cs_ext_discount_amt)  as "excess discount amount" 
from 
   catalog_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 731
and i_item_sk = cs_item_sk 
and d_date between '2001-01-20' and 
        dateadd(day,90,cast('2001-01-20' as date))
and d_date_sk = cs_sold_date_sk 
and cs_ext_discount_amt  
     > ( 
         select 
            1.3 * avg(cs_ext_discount_amt) 
         from 
            catalog_sales 
           ,date_dim
         where 
              cs_item_sk = i_item_sk 
          and d_date between '2001-01-20' and
                             dateadd(day,90,cast('2001-01-20' as date))
          and d_date_sk = cs_sold_date_sk 
      ) 
limit 100;

-- end query 84 in stream 2 using template query32.tpl
set query_group to 'TPC-DS query78.tpl stream.2.85';
with /* TPC-DS query78.tpl 0.10 */ ws as
  (select d_year AS ws_sold_year, ws_item_sk,
    ws_bill_customer_sk ws_customer_sk,
    sum(ws_quantity) ws_qty,
    sum(ws_wholesale_cost) ws_wc,
    sum(ws_sales_price) ws_sp
   from web_sales
   left join web_returns on wr_order_number=ws_order_number and ws_item_sk=wr_item_sk
   join date_dim on ws_sold_date_sk = d_date_sk
   where wr_order_number is null
   group by d_year, ws_item_sk, ws_bill_customer_sk
   ),
cs as
  (select d_year AS cs_sold_year, cs_item_sk,
    cs_bill_customer_sk cs_customer_sk,
    sum(cs_quantity) cs_qty,
    sum(cs_wholesale_cost) cs_wc,
    sum(cs_sales_price) cs_sp
   from catalog_sales
   left join catalog_returns on cr_order_number=cs_order_number and cs_item_sk=cr_item_sk
   join date_dim on cs_sold_date_sk = d_date_sk
   where cr_order_number is null
   group by d_year, cs_item_sk, cs_bill_customer_sk
   ),
ss as
  (select d_year AS ss_sold_year, ss_item_sk,
    ss_customer_sk,
    sum(ss_quantity) ss_qty,
    sum(ss_wholesale_cost) ss_wc,
    sum(ss_sales_price) ss_sp
   from store_sales
   left join store_returns on sr_ticket_number=ss_ticket_number and ss_item_sk=sr_item_sk
   join date_dim on ss_sold_date_sk = d_date_sk
   where sr_ticket_number is null
   group by d_year, ss_item_sk, ss_customer_sk
   )
 select 
ss_sold_year, ss_item_sk, ss_customer_sk,
round(ss_qty/(coalesce(ws_qty,0)+coalesce(cs_qty,0)),2) ratio,
ss_qty store_qty, ss_wc store_wholesale_cost, ss_sp store_sales_price,
coalesce(ws_qty,0)+coalesce(cs_qty,0) other_chan_qty,
coalesce(ws_wc,0)+coalesce(cs_wc,0) other_chan_wholesale_cost,
coalesce(ws_sp,0)+coalesce(cs_sp,0) other_chan_sales_price
from ss
left join ws on (ws_sold_year=ss_sold_year and ws_item_sk=ss_item_sk and ws_customer_sk=ss_customer_sk)
left join cs on (cs_sold_year=ss_sold_year and cs_item_sk=ss_item_sk and cs_customer_sk=ss_customer_sk)
where (coalesce(ws_qty,0)>0 or coalesce(cs_qty, 0)>0) and ss_sold_year=2002
order by 
  ss_sold_year, ss_item_sk, ss_customer_sk,
  ss_qty desc, ss_wc desc, ss_sp desc,
  other_chan_qty,
  other_chan_wholesale_cost,
  other_chan_sales_price,
  ratio
limit 100;

-- end query 85 in stream 2 using template query78.tpl
set query_group to 'TPC-DS query18a.tpl stream.2.86';
with /* TPC-DS query18a.tpl 0.90 */ results as
 (select i_item_id,
        ca_country,
        ca_state, 
        ca_county,
        cast(cs_quantity as decimal(12,2)) agg1,
        cast(cs_list_price as decimal(12,2)) agg2,
        cast(cs_coupon_amt as decimal(12,2)) agg3,
        cast(cs_sales_price as decimal(12,2)) agg4,
        cast(cs_net_profit as decimal(12,2)) agg5,
        cast(c_birth_year as decimal(12,2)) agg6,
        cast(cd1.cd_dep_count as decimal(12,2)) agg7
 from catalog_sales, customer_demographics cd1, customer_demographics cd2, customer, customer_address, date_dim, item
 where cs_sold_date_sk = d_date_sk and
       cs_item_sk = i_item_sk and
       cs_bill_cdemo_sk = cd1.cd_demo_sk and
       cs_bill_customer_sk = c_customer_sk and
       cd1.cd_gender = 'F' and 
       cd1.cd_education_status = 'College' and
       c_current_cdemo_sk = cd2.cd_demo_sk and
       c_current_addr_sk = ca_address_sk and
       c_birth_month in (7,5,3,1,10,2) and
       d_year = 2000 and
       ca_state in ('IN','IL','CA','TX','OK','MS','NE')
 )
  select  i_item_id, ca_country, ca_state, ca_county, agg1, agg2, agg3, agg4, agg5, agg6, agg7
 from (
 	select i_item_id, ca_country, ca_state, ca_county, avg(agg1) agg1, 
 		avg(agg2) agg2, avg(agg3) agg3, avg(agg4) agg4, avg(agg5) agg5, avg(agg6) agg6, avg(agg7) agg7 
 	from results
	group by i_item_id, ca_country, ca_state, ca_county
 	union all
 	select i_item_id, ca_country, ca_state, NULL as county, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
		avg(agg4) agg4, avg(agg5) agg5, avg(agg6) agg6, avg(agg7) agg7 
	from results
	group by i_item_id, ca_country, ca_state
 	union all
	select i_item_id, ca_country, NULL as ca_state, NULL as county, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
		avg(agg4) agg4, avg(agg5) agg5, avg(agg6) agg6, avg(agg7) agg7 
	from results
 	group by i_item_id, ca_country
 	union all
 	select i_item_id, NULL as ca_country, NULL as ca_state, NULL as county, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
		avg(agg4) agg4, avg(agg5) agg5, avg(agg6) agg6, avg(agg7) agg7 
	from results
	group by i_item_id
	union all
	select NULL AS i_item_id, NULL as ca_country, NULL as ca_state, NULL as county, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
		avg(agg4) agg4, avg(agg5) agg5, avg(agg6) agg6, avg(agg7) agg7 
	from results
 ) foo
 order by ca_country, ca_state, ca_county, i_item_id
 limit 100;

-- end query 86 in stream 2 using template query18a.tpl
set query_group to 'TPC-DS query65.tpl stream.2.87';
select /* TPC-DS query65.tpl 0.71 */ 
	s_store_name,
	i_item_desc,
	sc.revenue,
	i_current_price,
	i_wholesale_cost,
	i_brand
 from store, item,
     (select ss_store_sk, avg(revenue) as ave
 	from
 	    (select  ss_store_sk, ss_item_sk, 
 		     sum(ss_sales_price) as revenue
 		from store_sales, date_dim
 		where ss_sold_date_sk = d_date_sk and d_month_seq between 1209 and 1209+11
 		group by ss_store_sk, ss_item_sk) sa
 	group by ss_store_sk) sb,
     (select  ss_store_sk, ss_item_sk, sum(ss_sales_price) as revenue
 	from store_sales, date_dim
 	where ss_sold_date_sk = d_date_sk and d_month_seq between 1209 and 1209+11
 	group by ss_store_sk, ss_item_sk) sc
 where sb.ss_store_sk = sc.ss_store_sk and 
       sc.revenue <= 0.1 * sb.ave and
       s_store_sk = sc.ss_store_sk and
       i_item_sk = sc.ss_item_sk
 order by s_store_name, i_item_desc
limit 100;

-- end query 87 in stream 2 using template query65.tpl
set query_group to 'TPC-DS query60.tpl stream.2.88';
with /* TPC-DS query60.tpl 0.29 */ ss as (
 select
          i_item_id,sum(ss_ext_sales_price) total_sales
 from
 	store_sales,
 	date_dim,
         customer_address,
         item
 where
         i_item_id in (select
  i_item_id
from
 item
where i_category in ('Men'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 1998
 and     d_moy                   = 10
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 cs as (
 select
          i_item_id,sum(cs_ext_sales_price) total_sales
 from
 	catalog_sales,
 	date_dim,
         customer_address,
         item
 where
         i_item_id               in (select
  i_item_id
from
 item
where i_category in ('Men'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 1998
 and     d_moy                   = 10
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 ws as (
 select
          i_item_id,sum(ws_ext_sales_price) total_sales
 from
 	web_sales,
 	date_dim,
         customer_address,
         item
 where
         i_item_id               in (select
  i_item_id
from
 item
where i_category in ('Men'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 1998
 and     d_moy                   = 10
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_item_id)
  select   
  i_item_id
,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_item_id
 order by i_item_id
      ,total_sales
 limit 100;

-- end query 88 in stream 2 using template query60.tpl
set query_group to 'TPC-DS query34.tpl stream.2.89';
select /* TPC-DS query34.tpl 0.73 */ c_last_name
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (date_dim.d_dom between 1 and 3 or date_dim.d_dom between 25 and 28)
    and (household_demographics.hd_buy_potential = '501-1000' or
         household_demographics.hd_buy_potential = 'Unknown')
    and household_demographics.hd_vehicle_count > 0
    and (case when household_demographics.hd_vehicle_count > 0 
	then household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count 
	else null 
	end)  > 1.2
    and date_dim.d_year in (2000,2000+1,2000+2)
    and store.s_county in ('La Crosse County','Mercer County','Sibley County','Appanoose County',
                           'Ashley County','Price County','Coal County','Lea County')
    group by ss_ticket_number,ss_customer_sk) dn,customer
    where ss_customer_sk = c_customer_sk
      and cnt between 15 and 20
    order by c_last_name,c_first_name,c_salutation,c_preferred_cust_flag desc, ss_ticket_number;

-- end query 89 in stream 2 using template query34.tpl
set query_group to 'TPC-DS query3.tpl stream.2.90';
select /* TPC-DS query3.tpl 0.45 */  dt.d_year 
       ,item.i_brand_id brand_id 
       ,item.i_brand brand
       ,sum(ss_net_profit) sum_agg
 from  date_dim dt 
      ,store_sales
      ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and item.i_manufact_id = 280
   and dt.d_moy=12
 group by dt.d_year
      ,item.i_brand
      ,item.i_brand_id
 order by dt.d_year
         ,sum_agg desc
         ,brand_id
 limit 100;

-- end query 90 in stream 2 using template query3.tpl
set query_group to 'TPC-DS query13.tpl stream.2.91';
select /* TPC-DS query13.tpl 0.91 */ avg(ss_quantity)
       ,avg(ss_ext_sales_price)
       ,avg(ss_ext_wholesale_cost)
       ,sum(ss_ext_wholesale_cost)
 from store_sales
     ,store
     ,customer_demographics
     ,household_demographics
     ,customer_address
     ,date_dim
 where s_store_sk = ss_store_sk
 and  ss_sold_date_sk = d_date_sk and d_year = 2001
 and((ss_hdemo_sk=hd_demo_sk
  and cd_demo_sk = ss_cdemo_sk
  and cd_marital_status = 'W'
  and cd_education_status = 'Advanced Degree'
  and ss_sales_price between 100.00 and 150.00
  and hd_dep_count = 3   
     )or
     (ss_hdemo_sk=hd_demo_sk
  and cd_demo_sk = ss_cdemo_sk
  and cd_marital_status = 'D'
  and cd_education_status = 'Primary'
  and ss_sales_price between 50.00 and 100.00   
  and hd_dep_count = 1
     ) or 
     (ss_hdemo_sk=hd_demo_sk
  and cd_demo_sk = ss_cdemo_sk
  and cd_marital_status = 'S'
  and cd_education_status = '2 yr Degree'
  and ss_sales_price between 150.00 and 200.00 
  and hd_dep_count = 1  
     ))
 and((ss_addr_sk = ca_address_sk
  and ca_country = 'United States'
  and ca_state in ('NE', 'AR', 'CO')
  and ss_net_profit between 100 and 200  
     ) or
     (ss_addr_sk = ca_address_sk
  and ca_country = 'United States'
  and ca_state in ('KY', 'MO', 'MD')
  and ss_net_profit between 150 and 300  
     ) or
     (ss_addr_sk = ca_address_sk
  and ca_country = 'United States'
  and ca_state in ('MS', 'OK', 'KS')
  and ss_net_profit between 50 and 250  
     ))
;

-- end query 91 in stream 2 using template query13.tpl
set query_group to 'TPC-DS query41.tpl stream.2.92';
select /* TPC-DS query41.tpl 0.62 */  distinct(i_product_name)
 from item i1
 where i_manufact_id between 993 and 993+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'cornflower' or i_color = 'forest') and 
        (i_units = 'Ton' or i_units = 'Carton') and
        (i_size = 'small' or i_size = 'economy')
        ) or
        (i_category = 'Women' and
        (i_color = 'rose' or i_color = 'cream') and
        (i_units = 'Each' or i_units = 'Lb') and
        (i_size = 'medium' or i_size = 'petite')
        ) or
        (i_category = 'Men' and
        (i_color = 'firebrick' or i_color = 'goldenrod') and
        (i_units = 'Oz' or i_units = 'Pallet') and
        (i_size = 'extra large' or i_size = 'N/A')
        ) or
        (i_category = 'Men' and
        (i_color = 'orchid' or i_color = 'grey') and
        (i_units = 'Gross' or i_units = 'Dram') and
        (i_size = 'small' or i_size = 'economy')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'drab' or i_color = 'metallic') and 
        (i_units = 'Case' or i_units = 'Ounce') and
        (i_size = 'small' or i_size = 'economy')
        ) or
        (i_category = 'Women' and
        (i_color = 'violet' or i_color = 'moccasin') and
        (i_units = 'Bunch' or i_units = 'Tsp') and
        (i_size = 'medium' or i_size = 'petite')
        ) or
        (i_category = 'Men' and
        (i_color = 'snow' or i_color = 'midnight') and
        (i_units = 'Gram' or i_units = 'N/A') and
        (i_size = 'extra large' or i_size = 'N/A')
        ) or
        (i_category = 'Men' and
        (i_color = 'navajo' or i_color = 'spring') and
        (i_units = 'Unknown' or i_units = 'Bundle') and
        (i_size = 'small' or i_size = 'economy')
        )))) > 0
 order by i_product_name
 limit 100;

-- end query 92 in stream 2 using template query41.tpl
set query_group to 'TPC-DS query92.tpl stream.2.93';
select /* TPC-DS query92.tpl 0.44 */  
   sum(ws_ext_discount_amt)  as "Excess Discount Amount" 
from 
    web_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 602
and i_item_sk = ws_item_sk 
and d_date between '2000-03-17' and 
        dateadd(day,90,cast('2000-03-17' as date))
and d_date_sk = ws_sold_date_sk 
and ws_ext_discount_amt  
     > ( 
         SELECT 
            1.3 * avg(ws_ext_discount_amt) 
         FROM 
            web_sales 
           ,date_dim
         WHERE 
              ws_item_sk = i_item_sk 
          and d_date between '2000-03-17' and
                             dateadd(day,90,cast('2000-03-17' as date))
          and d_date_sk = ws_sold_date_sk 
      ) 
order by sum(ws_ext_discount_amt)
limit 100;

-- end query 93 in stream 2 using template query92.tpl
set query_group to 'TPC-DS query74.tpl stream.2.94';
with /* TPC-DS query74.tpl 0.76 */ year_total as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,max(ss_net_paid) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
   and d_year in (2001,2001+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,max(ws_net_paid) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
   and d_year in (2001,2001+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year
         )
  select 
        t_s_secyear.customer_id, t_s_secyear.customer_first_name, t_s_secyear.customer_last_name
 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.sale_type = 's'
         and t_w_firstyear.sale_type = 'w'
         and t_s_secyear.sale_type = 's'
         and t_w_secyear.sale_type = 'w'
         and t_s_firstyear.year = 2001
         and t_s_secyear.year = 2001+1
         and t_w_firstyear.year = 2001
         and t_w_secyear.year = 2001+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
 order by 1,3,2
limit 100;

-- end query 94 in stream 2 using template query74.tpl
set query_group to 'TPC-DS query46.tpl stream.2.95';
select /* TPC-DS query46.tpl 0.23 */  c_last_name
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,amt,profit 
 from
   (select ss_ticket_number
          ,ss_customer_sk
          ,ca_city bought_city
          ,sum(ss_coupon_amt) amt
          ,sum(ss_net_profit) profit
    from store_sales,date_dim,store,household_demographics,customer_address 
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and store_sales.ss_addr_sk = customer_address.ca_address_sk
    and (household_demographics.hd_dep_count = 5 or
         household_demographics.hd_vehicle_count= 4)
    and date_dim.d_dow in (6,0)
    and date_dim.d_year in (1999,1999+1,1999+2) 
    and store.s_city in ('Hopewell','Walker','Avon','Crossroads','Forest Park') 
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk,ca_city) dn,customer,customer_address current_addr
    where ss_customer_sk = c_customer_sk
      and customer.c_current_addr_sk = current_addr.ca_address_sk
      and current_addr.ca_city <> bought_city
  order by c_last_name
          ,c_first_name
          ,ca_city
          ,bought_city
          ,ss_ticket_number
  limit 100;

-- end query 95 in stream 2 using template query46.tpl
set query_group to 'TPC-DS query89.tpl stream.2.96';
select /* TPC-DS query89.tpl 0.56 */  *
from(
select i_category, i_class, i_brand,
       s_store_name, s_company_name,
       d_moy,
       sum(ss_sales_price) sum_sales,
       avg(sum(ss_sales_price)) over
         (partition by i_category, i_brand, s_store_name, s_company_name)
         avg_monthly_sales
from item, store_sales, date_dim, store
where ss_item_sk = i_item_sk and
      ss_sold_date_sk = d_date_sk and
      ss_store_sk = s_store_sk and
      d_year in (1998) and
        ((i_category in ('Sports','Home','Books') and
          i_class in ('camping','lighting','cooking')
         )
      or (i_category in ('Shoes','Women','Children') and
          i_class in ('womens','dresses','school-uniforms') 
        ))
group by i_category, i_class, i_brand,
         s_store_name, s_company_name, d_moy) tmp1
where case when (avg_monthly_sales <> 0) then (abs(sum_sales - avg_monthly_sales) / avg_monthly_sales) else null end > 0.1
order by sum_sales - avg_monthly_sales, s_store_name
limit 100;

-- end query 96 in stream 2 using template query89.tpl
set query_group to 'TPC-DS query47.tpl stream.2.97';
with /* TPC-DS query47.tpl 0.42 */ v1 as(
 select i_category, i_brand,
        s_store_name, s_company_name,
        d_year, d_moy,
        sum(ss_sales_price) sum_sales,
        avg(sum(ss_sales_price)) over
          (partition by i_category, i_brand,
                     s_store_name, s_company_name, d_year)
          avg_monthly_sales,
        rank() over
          (partition by i_category, i_brand,
                     s_store_name, s_company_name
           order by d_year, d_moy) rn
 from item, store_sales, date_dim, store
 where ss_item_sk = i_item_sk and
       ss_sold_date_sk = d_date_sk and
       ss_store_sk = s_store_sk and
       (
         d_year = 1999 or
         ( d_year = 1999-1 and d_moy =12) or
         ( d_year = 1999+1 and d_moy =1)
       )
 group by i_category, i_brand,
          s_store_name, s_company_name,
          d_year, d_moy),
 v2 as(
 select v1.i_category, v1.i_brand, v1.s_store_name, v1.s_company_name
        ,v1.d_year
        ,v1.avg_monthly_sales
        ,v1.sum_sales, v1_lag.sum_sales psum, v1_lead.sum_sales nsum
 from v1, v1 v1_lag, v1 v1_lead
 where v1.i_category = v1_lag.i_category and
       v1.i_category = v1_lead.i_category and
       v1.i_brand = v1_lag.i_brand and
       v1.i_brand = v1_lead.i_brand and
       v1.s_store_name = v1_lag.s_store_name and
       v1.s_store_name = v1_lead.s_store_name and
       v1.s_company_name = v1_lag.s_company_name and
       v1.s_company_name = v1_lead.s_company_name and
       v1.rn = v1_lag.rn + 1 and
       v1.rn = v1_lead.rn - 1)
  select  *
 from v2
 where  d_year = 1999 and    
        avg_monthly_sales > 0 and
        case when avg_monthly_sales > 0 then abs(sum_sales - avg_monthly_sales) / avg_monthly_sales else null end > 0.1
 order by sum_sales - avg_monthly_sales, 3
 limit 100;

-- end query 97 in stream 2 using template query47.tpl
set query_group to 'TPC-DS query66.tpl stream.2.98';
select /* TPC-DS query66.tpl 0.39 */   
         w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
        ,ship_carriers
        ,year
 	,sum(jan_sales) as jan_sales
 	,sum(feb_sales) as feb_sales
 	,sum(mar_sales) as mar_sales
 	,sum(apr_sales) as apr_sales
 	,sum(may_sales) as may_sales
 	,sum(jun_sales) as jun_sales
 	,sum(jul_sales) as jul_sales
 	,sum(aug_sales) as aug_sales
 	,sum(sep_sales) as sep_sales
 	,sum(oct_sales) as oct_sales
 	,sum(nov_sales) as nov_sales
 	,sum(dec_sales) as dec_sales
 	,sum(jan_sales/w_warehouse_sq_ft) as jan_sales_per_sq_foot
 	,sum(feb_sales/w_warehouse_sq_ft) as feb_sales_per_sq_foot
 	,sum(mar_sales/w_warehouse_sq_ft) as mar_sales_per_sq_foot
 	,sum(apr_sales/w_warehouse_sq_ft) as apr_sales_per_sq_foot
 	,sum(may_sales/w_warehouse_sq_ft) as may_sales_per_sq_foot
 	,sum(jun_sales/w_warehouse_sq_ft) as jun_sales_per_sq_foot
 	,sum(jul_sales/w_warehouse_sq_ft) as jul_sales_per_sq_foot
 	,sum(aug_sales/w_warehouse_sq_ft) as aug_sales_per_sq_foot
 	,sum(sep_sales/w_warehouse_sq_ft) as sep_sales_per_sq_foot
 	,sum(oct_sales/w_warehouse_sq_ft) as oct_sales_per_sq_foot
 	,sum(nov_sales/w_warehouse_sq_ft) as nov_sales_per_sq_foot
 	,sum(dec_sales/w_warehouse_sq_ft) as dec_sales_per_sq_foot
 	,sum(jan_net) as jan_net
 	,sum(feb_net) as feb_net
 	,sum(mar_net) as mar_net
 	,sum(apr_net) as apr_net
 	,sum(may_net) as may_net
 	,sum(jun_net) as jun_net
 	,sum(jul_net) as jul_net
 	,sum(aug_net) as aug_net
 	,sum(sep_net) as sep_net
 	,sum(oct_net) as oct_net
 	,sum(nov_net) as nov_net
 	,sum(dec_net) as dec_net
 from (
     select 
 	w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
 	,'GREAT EASTERN' || ',' || 'BOXBUNDLES' as ship_carriers
       ,d_year as year
 	,sum(case when d_moy = 1 
 		then ws_sales_price* ws_quantity else 0 end) as jan_sales
 	,sum(case when d_moy = 2 
 		then ws_sales_price* ws_quantity else 0 end) as feb_sales
 	,sum(case when d_moy = 3 
 		then ws_sales_price* ws_quantity else 0 end) as mar_sales
 	,sum(case when d_moy = 4 
 		then ws_sales_price* ws_quantity else 0 end) as apr_sales
 	,sum(case when d_moy = 5 
 		then ws_sales_price* ws_quantity else 0 end) as may_sales
 	,sum(case when d_moy = 6 
 		then ws_sales_price* ws_quantity else 0 end) as jun_sales
 	,sum(case when d_moy = 7 
 		then ws_sales_price* ws_quantity else 0 end) as jul_sales
 	,sum(case when d_moy = 8 
 		then ws_sales_price* ws_quantity else 0 end) as aug_sales
 	,sum(case when d_moy = 9 
 		then ws_sales_price* ws_quantity else 0 end) as sep_sales
 	,sum(case when d_moy = 10 
 		then ws_sales_price* ws_quantity else 0 end) as oct_sales
 	,sum(case when d_moy = 11
 		then ws_sales_price* ws_quantity else 0 end) as nov_sales
 	,sum(case when d_moy = 12
 		then ws_sales_price* ws_quantity else 0 end) as dec_sales
 	,sum(case when d_moy = 1 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as jan_net
 	,sum(case when d_moy = 2
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as feb_net
 	,sum(case when d_moy = 3 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as mar_net
 	,sum(case when d_moy = 4 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as apr_net
 	,sum(case when d_moy = 5 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as may_net
 	,sum(case when d_moy = 6 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as jun_net
 	,sum(case when d_moy = 7 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as jul_net
 	,sum(case when d_moy = 8 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as aug_net
 	,sum(case when d_moy = 9 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as sep_net
 	,sum(case when d_moy = 10 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as oct_net
 	,sum(case when d_moy = 11
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as nov_net
 	,sum(case when d_moy = 12
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as dec_net
     from
          web_sales
         ,warehouse
         ,date_dim
         ,time_dim
 	  ,ship_mode
     where
            ws_warehouse_sk =  w_warehouse_sk
        and ws_sold_date_sk = d_date_sk
        and ws_sold_time_sk = t_time_sk
 	and ws_ship_mode_sk = sm_ship_mode_sk
        and d_year = 1998
 	and t_time between 36325 and 36325+28800 
 	and sm_carrier in ('GREAT EASTERN','BOXBUNDLES')
     group by 
        w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
       ,d_year
 union all
     select 
 	w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
 	,'GREAT EASTERN' || ',' || 'BOXBUNDLES' as ship_carriers
       ,d_year as year
 	,sum(case when d_moy = 1 
 		then cs_ext_sales_price* cs_quantity else 0 end) as jan_sales
 	,sum(case when d_moy = 2 
 		then cs_ext_sales_price* cs_quantity else 0 end) as feb_sales
 	,sum(case when d_moy = 3 
 		then cs_ext_sales_price* cs_quantity else 0 end) as mar_sales
 	,sum(case when d_moy = 4 
 		then cs_ext_sales_price* cs_quantity else 0 end) as apr_sales
 	,sum(case when d_moy = 5 
 		then cs_ext_sales_price* cs_quantity else 0 end) as may_sales
 	,sum(case when d_moy = 6 
 		then cs_ext_sales_price* cs_quantity else 0 end) as jun_sales
 	,sum(case when d_moy = 7 
 		then cs_ext_sales_price* cs_quantity else 0 end) as jul_sales
 	,sum(case when d_moy = 8 
 		then cs_ext_sales_price* cs_quantity else 0 end) as aug_sales
 	,sum(case when d_moy = 9 
 		then cs_ext_sales_price* cs_quantity else 0 end) as sep_sales
 	,sum(case when d_moy = 10 
 		then cs_ext_sales_price* cs_quantity else 0 end) as oct_sales
 	,sum(case when d_moy = 11
 		then cs_ext_sales_price* cs_quantity else 0 end) as nov_sales
 	,sum(case when d_moy = 12
 		then cs_ext_sales_price* cs_quantity else 0 end) as dec_sales
 	,sum(case when d_moy = 1 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as jan_net
 	,sum(case when d_moy = 2 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as feb_net
 	,sum(case when d_moy = 3 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as mar_net
 	,sum(case when d_moy = 4 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as apr_net
 	,sum(case when d_moy = 5 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as may_net
 	,sum(case when d_moy = 6 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as jun_net
 	,sum(case when d_moy = 7 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as jul_net
 	,sum(case when d_moy = 8 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as aug_net
 	,sum(case when d_moy = 9 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as sep_net
 	,sum(case when d_moy = 10 
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as oct_net
 	,sum(case when d_moy = 11
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as nov_net
 	,sum(case when d_moy = 12
 		then cs_net_paid_inc_tax * cs_quantity else 0 end) as dec_net
     from
          catalog_sales
         ,warehouse
         ,date_dim
         ,time_dim
 	 ,ship_mode
     where
            cs_warehouse_sk =  w_warehouse_sk
        and cs_sold_date_sk = d_date_sk
        and cs_sold_time_sk = t_time_sk
 	and cs_ship_mode_sk = sm_ship_mode_sk
        and d_year = 1998
 	and t_time between 36325 AND 36325+28800 
 	and sm_carrier in ('GREAT EASTERN','BOXBUNDLES')
     group by 
        w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
       ,d_year
 ) x
 group by 
        w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
 	,ship_carriers
       ,year
 order by w_warehouse_name
 limit 100;

-- end query 98 in stream 2 using template query66.tpl
set query_group to 'TPC-DS query48.tpl stream.2.99';
select /* TPC-DS query48.tpl 0.74 */ sum (ss_quantity)
 from store_sales, store, customer_demographics, customer_address, date_dim
 where s_store_sk = ss_store_sk
 and  ss_sold_date_sk = d_date_sk and d_year = 1998
 and  
 (
  (
   cd_demo_sk = ss_cdemo_sk
   and 
   cd_marital_status = 'U'
   and 
   cd_education_status = 'Primary'
   and 
   ss_sales_price between 100.00 and 150.00  
   )
 or
  (
  cd_demo_sk = ss_cdemo_sk
   and 
   cd_marital_status = 'D'
   and 
   cd_education_status = '4 yr Degree'
   and 
   ss_sales_price between 50.00 and 100.00   
  )
 or 
 (
  cd_demo_sk = ss_cdemo_sk
  and 
   cd_marital_status = 'S'
   and 
   cd_education_status = 'Secondary'
   and 
   ss_sales_price between 150.00 and 200.00  
 )
 )
 and
 (
  (
  ss_addr_sk = ca_address_sk
  and
  ca_country = 'United States'
  and
  ca_state in ('AL', 'TN', 'LA')
  and ss_net_profit between 0 and 2000  
  )
 or
  (ss_addr_sk = ca_address_sk
  and
  ca_country = 'United States'
  and
  ca_state in ('TX', 'NC', 'WA')
  and ss_net_profit between 150 and 3000 
  )
 or
  (ss_addr_sk = ca_address_sk
  and
  ca_country = 'United States'
  and
  ca_state in ('VA', 'NE', 'SD')
  and ss_net_profit between 50 and 25000 
  )
 )
;

-- end query 99 in stream 2 using template query48.tpl
