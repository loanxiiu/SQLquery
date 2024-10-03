select * from bang1

update bang1
set Product = replace(Product,'eGf','')

update bang1 
set Product = concat(Product, '@gmail')
where Product = '3'

select replace(Product, '@gmail',''),charindex('@',Product), * from bang1

update bang1 
set Product = left( product, charindex('@', Product) -1)

select * from
(
select replace(Product, '@gmail','') col_1, left(Product, charindex('@', Product)-1) col_2,
iif(replace(Product, '@gmail', '') = left(Product, charindex('@', Product)-1),'true','fail') AB
from bang1
) A
where AB <> 'true'