----- TỔNG HỢP STORED PROCEDURE, FUNCTIONS, WHILE ----

-- EXAMPLE 1: Tạo thủ tục lưu trữ để INSERT INTO vào bảng trống (tự đặt tên) bao gồm các thông tin sau:
-- MONTH: Tháng thống kê - 1
-- REVENUE: Doanh số theo tháng - 1
-- TENSP: Tên SP bán được số lượng nhiều nhất trong tháng - 2
-- SLSP: Số lượng sp bán tương ứng với TENSP - 2
-- SP_DOANHSO: Doanh số tên sp bán được nhiều nhất trong tháng - 2
-- MAKH: Mã KH có doanh số cao nhất theo tháng - 3
-- TENKH: Tên KH có doanh số cao nhất theo tháng - 3
-- TUOI: Tuổi KH có doanh số cao nhất theo tháng - 3

--Sau đó dùng vòng lặp để cập nhất bảng trống đã định nghĩa ở trên

drop table EX_TABLE_FINAL
create table EX_TABLE_FINAL(THANG_HD int, REVENUE float, TENSP nvarchar(max),
							MAKH nvarchar(max))
select * from EX_TABLE_FINAL

--I. SOLUTION:
--- 1. Tạo function GET_MONTH()

create function GET_MONTH(@DATE date)
returns int
begin
	return format(@DATE, 'yyyyMM')
end

--- 2. Tạo function bảng doanh số theo tháng --- table_valued function
create function GET_REVENUE(@THANG int)
returns table
as
return
(
	select  @THANG as THANG, sum(SLBan * DonGiaBan) as REVENUE
	from tHoaDonBan HDB
	left join tChiTietHDB CT on HDB.SoHDB = CT.SoHDB
	left join tSach S on CT.MaSach = S.MaSach
	where DBO.GET_MONTH(NgayBan) = @THANG
)

select * from GET_REVENUE(201403)


-- 3. Tạo function bảng TENSP bán được tốt nhất trong tháng
drop function GET_TENSP
create function GET_TENSP (@THANG int)
returns table
as
return
(
	select top 1 TenSach, @THANG as THANG
	from tHoaDonBan HDB
	left join tChiTietHDB CT on HDB.SoHDB = CT.SoHDB
	left join tSach S on CT.MaSach = S.MaSach
	where DBO.GET_MONTH(NgayBan) = @THANG
	group by TenSach
	order by sum(SLBan) desc
)

select * from DBO.GET_TENSP(201403)


-- 4. Tạo function bảng KHACHHANG đem lại nhiều doanh thu nhất trong tháng
drop function GET_KH
create function GET_KH(@THANG int)
returns table
as return 
( 
	select * from
	(
		select MaKH, @THANG as THANG,
			   row_number() over (partition by MaKH order by sum(SLBan * DonGiaBan) desc) as RN
		from tHoaDonBan HDB
		left join tChiTietHDB CT on HDB.SoHDB = CT.SoHDB
		left join tSach S on CT.MaSach = S.MaSach
		where DBO.GET_MONTH(NgayBan) = @THANG
		GROUP BY MaKH
	) A
	where RN = 1
)

select * from GET_KH(201403)

-- 5. Tạo function bảng nhân viên bán tốt nhất trong tháng


-- 6. Tạo function bảng tổng hợp --- Join 4 function đã tạo ở trên
-- GET_REVENUE()
-- GET_TENSP()
-- GET_KHACHHANG()
-- GET_NHANVIEN()

drop function TONG_HOP
create function TONG_HOP(@THANG int)
returns table
as return
(
	select A.*, B.TenSach, C.MaKH 
	from GET_REVENUE(@THANG) A
	left join GET_TENSP(@THANG) B on A.THANG = B.THANG
	left join GET_KH(@THANG) C ON B.THANG = C.THANG
)

SELECT * FROM DBO.TONG_HOP(201403)


-- 7. Tạo thủ tục lưu trữ thao tác cập nhật hàng tháng

drop proc INSERT_EX_TABLE_FINAL
create proc INSERT_EX_TABLE_FINAL(@THANG int)
as 
begin
	delete from EX_TABLE_FINAL where THANG_HD = @THANG
	insert into EX_TABLE_FINAL
	select * from TONG_HOP(@THANG)
end
exec INSERT_EX_TABLE_FINAL 201403
select * from EX_TABLE_FINAL



-- 8. Sử dụng vọng lặp cập nhật hàng tháng
--- Procedure: EX_PROC(@MONTH)
--- Table: EX_TABLE_FINAL, HOADON


declare CUR cursor for
	select distinct DBO.GET_MONTH(NgayBan) as THANG_HD from tHoaDonBan
open CUR
declare @THANG int
fetch next from CUR into @THANG
while @@FETCH_STATUS =0
begin
	exec INSERT_EX_TABLE_FINAL @THANG
	fetch next from CUR into @THANG
end
close CUR
deallocate CUR