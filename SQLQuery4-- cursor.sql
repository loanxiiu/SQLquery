-----------------WHILE--
-- ###Đối với chuỗi bao gồm các giá trị là ký tự###

-- WHILE: WHILE được sử dụng khi bạn muốn thực hiện một phép lặp dựa trên một điều kiện logic. 
-- Vòng lặp sẽ tiếp tục cho đến khi điều kiện không còn đúng nữa. 
-- Điều này thường được sử dụng khi bạn cần thực hiện một số lượng lặp không biết trước.

--CURSOR: CURSOR được sử dụng khi bạn cần duyệt qua từng dòng kết quả của một tập hợp dữ liệu (ví dụ: kết quả của một truy vấn SELECT). 
-- CURSOR cho phép bạn thực hiện các thao tác xử lý dữ liệu trên từng dòng một.


-- Cách 1: Sử dụng biến con trỏ cursor

--EXAMPLE 4: Thống kê SLSP bán ra với từng MaSP
-- Hiển thị sòng thông báo N'[MaSP] bán được [SLSP] sản phẩm'
select distinct MaSach from tChiTietHDB

-- Cách 1: Sử dụng biến con trỏ cursor

declare CUR  cursor for --- (1) khai báo biến con trỏ
	select distinct MaSach from tChiTietHDB --- (2) danh sách các giá trị cần thực hiện vòng lặp
open CUR --- (3) kích hoạt biến con trỏ

declare @MASP nvarchar(max) --- (4) khai báo biến chứa giá trị gắp ra bởi con trỏ
fetch next from CUR into @MASP --- (5) truyền giá trị gắp ra từ con trỏ cho biến

while @@FETCH_STATUS = 0 --- (6) điều kiện dừng vòng lặp
begin
	--- (7) nội dung vòng lặp
	declare @SLSP nvarchar(max)
	select @SLSP = sum(SLBan) from tChiTietHDB where  MaSach = @MASP
	print N''+ @MASP +N' bán được '+ @SLSP +N' sản phẩm'
	fetch next from CUR into @MASP --- truyền giá trị tiếp theo từ biến con trỏ cho biến @MASP
end
close CUR --- (8) đóng con trỏ
deallocate CUR --- (9) xóa bỏ con trỏ





-- Cách 2: Không sử dụng biến con trỏ 
drop table #TEMP
select *, ROW_NUMBER() over(order by MaSach) as RN
into #TEMP
from
(
	 select distinct MaSach, sum(SLBan) as SLSP 
	 from tChiTietHDB
	 group by MaSach
) A
declare @RN int =1
declare @MASACH nvarchar(max), @SLSP nvarchar(max)
while @RN <= (select count(*) from #TEMP)
begin
	select @MASACH = MaSach, @SLSP = SLSP
	from #TEMP
	where RN = @RN
	print N''+ @MASACH +N' bán được '+ @SLSP +N' sản phẩm'
	set @RN = @RN + 1
end
select * from #TEMP






-- Ví dụ: Thống kê SLSP bán ra với từng MaNV
-- Hiển thị dòng thông báo N'[MaNV] bán được [SLSP] sản phẩm, có trị giá [DOANH_SO] đồng
-- DOANH_SO = sum(SLBan * DonGiaBan)

-- Cách 1: cursor - con trỏ

declare CUR_MASACH cursor for
	SELECT
		HDB.MaNV,
		sum(CT.SLBan) as SLSP,
		sum(CT.SLBan * S.DonGiaBan) as DOANHSO
		from tHoaDonBan HDB
		left join tChiTietHDB CT on HDB.SoHDB = CT.SoHDB
		left join tSach S on CT.MaSach = S.MaSach
		where MaNV is not null
		group by MaNV
		having sum(CT.SLBan * S.DonGiaBan) is not null
open CUR_MASACH

declare @MANV varchar(4), @SLSP varchar(max), @DOANHSO varchar(max)
fetch next from CUR_MASACH into @MANV, @SLSP, @DOANHSO

while @@FETCH_STATUS = 0
begin
	print(N''+ @MANV +N' bán được '+ @SLSP +N' sản phẩm, có trị giá '+ @DOANHSO +N' đồng')

	fetch next from CUR_MASACH into @MANV, @SLSP, @DOANHSO
end
close CUR_MASACH
deallocate CUR_MASACH


-- Cách 2: không sử dụng biến con trỏ 

drop table #TEMP
select *, row_number() over (order by MaNV) as RN
into #TEMP
from
(
	SELECT
		HDB.MaNV,
		sum(CT.SLBan) as SLSP,
		sum(CT.SLBan * S.DonGiaBan) as DOANHSO
		from tHoaDonBan HDB
		left join tChiTietHDB CT on HDB.SoHDB = CT.SoHDB
		left join tSach S on CT.MaSach = S.MaSach
		where MaNV is not null
		group by MaNV
		having sum(CT.SLBan * S.DonGiaBan) is not null
) A
declare @RN int = 1,
declare @MANV nvarchar(max), @SLSP int, @DOANHSO int
while @RN <= (select count(*) from #TEMP)
	begin 
		select @MANV = MaNV, @SLSP = SLSP, @DOANHSO = DOANHSO
		from #TEMP
		where RN = @RN
		print(N''+ @MANV +N' bán được '+ @SLSP +N' sản phẩm, có trị giá '+ @DOANHSO +N' đồng')
		set @RN +=1
	end

select * from #TEMP