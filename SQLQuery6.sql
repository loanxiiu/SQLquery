create table khach_hang
(
	MaKH varchar(10),
	TenKH nvarchar(50),
	DiachiKH nvarchar(30),
	TuoiKH int
)
select * from khach_hang

insert into khach_hang (MaKH, TenKH, DiachiKH, TuoiKH) values ('M01', N'Lê Tu?n D?ng', N'Hà Nam', 18),
															  ('M02', N'Ðào Th? Hà', N'Hà Giang', 24),
															  ('M03', N'Nguy?n Th? Huy?n', N'Hà N?i', 26),
															  ('M04', N'Ph?m Th? Phýõng Lan', N'Hà N?i', 24)
create table order_kh
(
	order_ID int,
	MaKH varchar(10),
	SoLuong int
)
insert into order_kh (order_ID, MaKH, SoLuong) values (1, 'M01', 500),
													  (2, 'M01', 400),
													  (3, 'M02', 400),
													  (4, 'M03', 600)
select * from order_kh
Select * 
from khach_hang as KH Join order_kh as OD on KH.MaKH= OD.MaKH

select * 
from khach_hang KH full join order_kh OD on KH.MaKH = OD.MaKH

select * 
from khach_hang KH left join order_kh OD on KH.MaKH = OD.MaKH

select * 
from khach_hang KH right join order_kh OD on KH.MaKH = OD.MaKH


select isnull(1,2)
select isnull(1,null)
select isnull(null,2)
select isnull(null,null)