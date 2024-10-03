select *
from 
 ( 
	select *, row_number() over ( partition by SoHDB order by MaSach) STT
	from tChiTietHDB
	) A
	Where STT = 1
