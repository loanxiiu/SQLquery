---Biến kiểu bảng---

--EXAMPLE 1: Tạo biến kiểu bảng chứa giá trị là bảng CTHOADONBAN
declare @CTHOADONBAN table
(
	SoHDB varchar(50),
	MaSach varchar(50), 
	SLBan int,
	KhuyenMai varchar
)
insert into @CTHOADONBAN
select SoHDB, MaSach, SLBan, KhuyenMai from tChiTietHDB

select * from @CTHOADONBAN



-- EXAMPLE 4: Tạo hàm để hiển thị danh sách các hóa đơn có tổng SLSP lớn hơn giá trị nhất định
drop function get_hd2
create function get_hd2(@value int)
returns @BIEN_BANG table
(
	SOHD nvarchar(50)
)
begin
	if 1=1
	insert into @BIEN_BANG
		select SoHDB
		from tChiTietHDB
		group by SoHDB
		having sum(SLBan) > @value
		return 
end

select * from get_hd2(20)
select * from get_hd2(10)


-- Biến kiểu bảng sử dụng được if else,.....