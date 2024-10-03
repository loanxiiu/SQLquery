---
create function GET_MONTH(@DATE datetime)
returns int
as
begin
	declare @KQ int
	set @KQ = format(@DATE, 'yyyyMM')
	return @KQ
end

select NgayBan, DBO.GET_MONTH(NgayBan) from tHoaDonBan


DROP FUNCTION GET_MONTH

-- VÍ DỤ 2: Trả ra giá trị '[MASP]' đem lại SLSP cao nhất
-- input: @THANG int;
-- output: N'BB01 đem lại SLSP cao nhất là 50'
drop function GET_VALUES

create function GET_VALUES(@THANG int)
returns nvarchar(max)
as
begin
	declare @MASP nvarchar(max), @SLSP nvarchar(max)
	select @MASP = MaSach, @SLSP = SLSP
	from
	(
		select top 1 MaSach, SUM(SLBan) as SLSP
		from tHoaDonBan A
		left join  tChiTietHDB B
		on A.SoHDB = B.SoHDB
		where DBO.GET_MONTH(A.NgayBan) = @THANG
		group by MaSach
	) A
	declare @KQ nvarchar(max)
	set @KQ = N''+ @MASP +N' đem lại SLSP cao nhất là '+ @SLSP 
	return @KQ
end

select NgayBan, DBO.GET_MONTH(NgayBan), DBO.GET_VALUES(DBO.GET_MONTH(NgayBan)) from tHoaDonBan

-- A. TABLE-VALUED FUNCTIONS
-- TABLE-VALUED FUNCTION không có biến
-- Tạo function để hiển thị thông tin cho bảng CTHD