create proc BEST_SALEMEN @thang int
as 
begin
declare @Tennv nvarchar(max), @Doanhso nvarchar(max)
select @Tennv = TenNV, @Doanhso = DoanhSo
from
(
	select top 1 
	format(a.NgayHD, 'yyyyMM') as Thang,
	a.MaNV,
	b.HoTen as TenNV,
	sum(a.TriGia) as DoanhSo
	from HOADON a
	left join NHANVIEN b
	on a.MaNV = b.MaNV
	where format(a.NgayHD, 'yyyyMM') = @thang
	group by a.MaNV, b.HoTen
	order by sum(a.TriGia) desc
) A
print N''+ @Tennv +' đem lại doanh số cao nhất là '+ @Doanhso +'' 
end
go
exec BEST_SALEMEN @thang = 




--2.Tạo thủ tục print ra màn hình TOP 1 MaSP biến động slsp tốt nhất và tệ nhất giữa hai tháng @thang1, @thang2

-- Bước 1: Thống kê SLSP bán ra cho từng MaSP trong tháng 08/ 2006
select 
	CT.MaSP,
	sum(CT.SL) as SoLuong 
into #month_08
from HOADON HD
left join CTHOADON CT 
on HD.SoHD = CT.SoHD
where format(HD.NgayHD, 'yyyyMM') = '200608'
group by CT.MaSP

-- Bước 1: Thống kê SLSP bán ra cho từng MaSP trong tháng 12/ 2006
select 
	CT.MaSP,
	sum(CT.SL) as SoLuong 
into #month_12 --#name bảng tạm
from HOADON HD
left join CTHOADON CT 
on HD.SoHD = CT.SoHD
where format(HD.NgayHD, 'yyyyMM') = '200612'
group by CT.MaSP

-- Bước 3: Tính biến động giữa hai tháng---QUERY OUTPUT:[MASP],[BIENDONG]

select 
	isnull(t8.MaSP, t10.MaSP),
	isnull(t12.SoLuong, 0)-isnull(b.SoLuong, 0) as BIENDONG
into #TEMP3
into #biendong2thang
from #month_08 t8
full join #month_12 t12
on t8.MaSp = t12.MaSP

-- Bước 4: Lấy ra MaSP và giá trị biến động MAX/MIN
-- Bước 5: Đưa ra MaSP và giá trị biến động vào trong chuỗi STRING VÀ PRINT ra màn hình
select * from #TEMP3

declare @MASP1 nvarchar(MAX), @BIENDONG nvarchar(max)
select @MASP1 = MASP, @BIENDONG
from
(
	select top 1 MASP, BIENDONG from #TEMP3
	order by BIENDONG desc
) A
print N''+ @MASP1 +'biến động lớn nhất là '+ @BIENDONG1 +' sản phẩm'

declare @MASP2 nvarchar(MAX), @BIENDONG nvarchar(max)
select @MASP2 = MASP, @BIENDONG
from
(
	select top 1 MASP, BIENDONG from #TEMP3
	order by BIENDONG asc
) A
print N''+ @MASP2 +'biến động tệ nhất là '+ @BIENDONG2 +' sản phẩm'

-- Bước 6: Tạo PROCEDURE

create proc BANGBIENDONG @thang1 int, @thang2 int
as
begin 
select B.MASP,
	   sum(B.SL) as SOLUONG
into #TEMP1
from HOADON A
left join CTHD B
on A.SOHD = B.SOHD
where format(A.NGHD, 'yyyyMM') = @thang1
group by B.MASP

select B.MASP,
	   sum(B.SL) as SOLUONG
into #TEMP2
from HOADON A
left join CTHD B
on A.SOHD = B.SOHD
where format(A.NGHD, 'yyyyMM') = @thang1
group by B.MASP

select 
	isnull (a.MASP, b.MASP) as MaSP,
	isnull(a.SOLUONG, 0) - isnull(b.SOLUONG, 0) as BIENDONG
into #TEMP3
from #TEMP1 as a
full join #TEMP2 as b
on a.MASP = b.MASP

declare @MaSP1 nvarchar(max), @BienDong1 nvarchar(max)
select @MaSP1 = MaSP, @BienDong1 = BienDong
from 
(	
	select top 1 MaSP, BIENDONG from #biendong2thang
	order by BIENDONG desc
) A
print N''+ @MaSP1 +' biến động tốt nhất là '+ @BienDong1 +' sản phẩm'

declare @MaSP2 nvarchar(max), @BienDong2 nvarchar(max)
select @MaSP2 = MaSP, @BienDong2 = BienDong
from 
(	
	select top 2 MaSP, BIENDONG from #biendong2thang
	order by BIENDONG desc
) A
print N''+ @MaSP2 +' biến động tốt nhất là '+ @BienDong2 +' sản phẩm'
end 

exec BANGBIENDONG 200606, 100608


-- VÍ DỤ: Tạo hàm GET_MONTH(@DATE date) -> output: yyyyMM-int

create function GET_MONTH(@DATE date)
returns int
as
begin
	declare @KQ int
	set @KQ = format(@DATE, 'yyyyMM')
	return @KQ
end

select NGHD, DBO.GET_MONTH(NGHD) from HOADON
