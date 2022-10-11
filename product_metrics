--- ARPU
select sum(summ_with_disc)/count(distinct card) as arpu
from bonuscheques b 
where to_char(datetime, 'YYYY-MM') = '2022-03'
and card like '2000%'

--- Lifetime
with lt as (
select 
	card,
	extract(days from (max(datetime) - min(datetime))) as diff
from bonuscheques b 
where card like '2000%' 
group by card
having min(datetime) < now() - interval '1 month'
)
select avg(diff)
from lt

--- LTV
with lt as (
select 
	card,
	extract(days from (max(datetime) - min(datetime))) as diff
from bonuscheques b 
where card like '2000%' 
group by card
having min(datetime) < now() - interval '1 month'
), 
lifetime as (
	select avg(diff)/30 as lifetime
	from lt
),
arpu as (
	select sum(summ_with_disc)/count(distinct card) as arpu
	from bonuscheques b 
	where to_char(datetime, 'YYYY-MM') = '2022-03'
	and card like '2000%'
)
select lifetime*arpu as ltv
from lifetime, arpu

--- Rolling retention
with first_transaction as (
	select 
		b.card, 
		min(b.datetime) as register
	from bonuscheques b 
	where b.card like '2000%'
	group by b.card
),
transactions as (
	select
    	b.card,
    	date(b.datetime) as entry_at,
		date(f.register) as date_joined,
		b.datetime - f.register as diff,
		to_char(f.register, 'YYYY-MM') as yw
	from bonuscheques b 
	join first_transaction f
	on b.card = f.card
)
select
yw,
count(distinct case when entry_at >= date_joined then card else NULL end) as "day0",
count(distinct case when entry_at >= date_joined + INTERVAL '7 DAY' then card else NULL end) as "day7",
count(distinct case when entry_at >= date_joined + INTERVAL '14 DAY' then card else NULL end) as "day14",
count(distinct case when entry_at >= date_joined + INTERVAL '30 DAY' then card else NULL end) as "day30",
count(distinct case when entry_at >= date_joined + INTERVAL '60 DAY' then card else NULL end) as "day60"
from transactions
group by yw

--- ABC analysis
with product_sales as (
  select
    dr_ndrugs,
    sum(dr_kol) as amount, 
    sum(dr_kol*dr_croz - dr_sdisc) as revenue
  from sales s 
  group by dr_ndrugs 
)
select
  dr_ndrugs,
  amount,
  revenue,
  case 
    when sum(amount) over(order by amount desc) / sum(amount) over() <= 0.8 then 'A'
    when sum(amount) over(order by amount desc) / sum(amount) over() <= 0.95 then 'B'
    else 'C'
  end abc_amount,
  case 
    when sum(revenue) over(order by revenue desc) / sum(revenue) over() <= 0.8 then 'A'
    when sum(revenue) over(order by revenue desc) / sum(revenue) over() <= 0.95 then 'B'
  else 'C'
  end abc_revenue
from product_sales

