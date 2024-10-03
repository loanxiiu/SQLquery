-- EXAMPLE 1: Tạo hàm để hiển thị bảng thông tin cho từng TenSach
select * from tSach
---
alter function GET_TENSACH(@TENSACH nvarchar(max))
returns table
as
return
(
	select * from tSach
	where TenSach like '%' + @TENSACH + '%'
)
select * from GET_TENSACH('con')


--EXAMPLE 2: Tạo và hiển thị danh sách MaKH mua nhiều hơn N sản phẩm
create function tt (@N int)
returns table
as
return
(
	select MaKH,
		sum(SLBan) as SLSP
	from tHoaDonBan HDB
	right join tChiTietHDB CT
	on  HDB.SoHDB = CT.SoHDB
	group by MaKH
	having sum(SLBan) > @N
)
select * from tt(1)






-- table_valued function bình thường chỉ dùng đc select