drop table if exists aa
select piv.*
into aa
from (
	select * from bang1
	) src
pivot (
	sum(MucToiThieu) for MucToiDa in ([4], [3], [6])
	) piv

drop table if exists bb
select unpiv.* 
into  bb
from (
	select * from aa
	) src
unpivot(
	MucToiThieu for MucToiDa in ([4], [3],[6])
	)  unpiv
	order by Product

select * from bang1
select * from aa
select * from bb