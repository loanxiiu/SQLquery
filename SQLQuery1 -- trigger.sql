----TRIGGER---

-- VD1: TẠO TRIGGER CẬP NHẬT DỮ LIỆU CỘT MaKH TRONG BẢNG HOADON, KHI CỘT MaKH TRONG BẢNG KHÁCH HÀNG ĐƯỢC CẬP NHẬT DỮ LIỆU
-- 1. DELETE DỮ LIỆU MaKH BẢNG khach_hang, THÌ CÁC DÒNG CHỨA MaKH TƯƠNG ỨNG TRONG BẢNG HÓA ĐƠN CŨNG ĐƯỢC XÓA
-- 2. UPDATE DỮ LIỆU MaKH BẢNG khach_hang, THÌ CÁC DÒNG CHỨA MaKH TƯƠNG ỨNG TRONG BẢNG HÓA ĐƠN CŨNG ĐƯỢC UPDATE

create table hoa_don
(
	MaKH varchar(10),
	SoHD varchar(10),
	MaNV varchar(10)
)
insert into hoa_don values ('M01', 'S022', 'N03'),
							('M01', 'S032', 'N04'),
							('M02', 'S002', 'N03'),
							('M03', 'S025', 'N03'),
							('M04', 'S026', 'N02'),
							('M05', 'S042', 'N03'),
							('M04', 'S022', 'N01')

select * from hoa_don

---
drop trigger TRG_KH_1
create trigger TRG_KH_1
on khach_hang
for update, delete
as
begin
	if exists(select * from deleted) and not exists (select * from inserted)
		begin
			delete from hoa_don 
			where MaKH in (select MaKH from deleted)
		end
	if exists(select * from deleted) and exists (select * from inserted)
		begin
			update hoa_don 
			set MaKH = (select distinct MaKH from inserted)
			where MaKH in (select MaKH from deleted)
		end
end

begin transaction
delete from khach_hang where MaKH = 'M01'
update khach_hang
set MaKH = 'M03' where MaKH in ('M05', 'M04')
rollback transaction

select * from khach_hang
select * from hoa_don 




-- VD2: TẠO TRIGGER ĐỂ NGĂN VIỆC INSERT, UPDATE GIÁ TRỊ ÂM VÀO CỘT SỐ LƯỢNG TRONG BẢNG CTHOADON
-- THỬ NGHIỆM CHO 1 DÒNG DỮ LIỆU
-- IN RA MÀN HÌNH THÔNG BÁO 'GIÁ TRỊ THÊM/ SỬA ĐỔI LÀ GIÁ TRỊ ÂM TRONG TRƯỜNG GIÁ TRỊ SL INSERT < 0
-- GỢI Ý: SỬ DỤN ROLLBACK TRANSACTION

create table CTHOADON
(
	SoHD varchar(10),
	MaSP varchar(10),
	SoLuong int
)
insert into CTHOADON values
('S022', 'SP1',20),
('S022', 'SP2',2),
('S032', 'SP1',10),
('S032', 'SP3',15),
('S025', 'SP1',2),
('S042', 'SP4',20),
('S026', 'SP5',30),
('S026', 'SP1',2),
('S025', 'SP4',1),
('S022', 'SP5',5)

select * from CTHOADON

drop trigger GTA_CTHD
create trigger GTA_CTHD
on CTHOADON
for update, insert
as
begin
	if (select SoLuong from inserted) < 0
		begin
			print N'giá trị thêm/ sửa đổi là giá trị âm'
			rollback transaction
		end
end

---
begin transaction
	insert into CTHOADON values ('S032', 'SP4', 5)
	insert into CTHOADON values ('S032', 'SP4', -5)
rollback transaction

select * from CTHOADON where SOHD ='S032'



----- 2. TẠO TRIGGER KHI THỰC HIỆN VỚI NHIỀU DÒNG DỮ LIỆU
------- GỢI Ý SỬ DỤNG VÒNG LẶP
-- SỬ DỤNG VÒNG LẶP CHO TRƯỜNG HỢP THÊM SỬA NHIỀU DÒNG CÙNG LÚC


drop trigger GTA_CTHD
create trigger GTA_CTHD
on CTHOADON
for update, insert
as
begin
	declare CUR cursor for
		select distinct SoLuong from inserted
	open CUR

	declare @SL int
	fetch next from CUR into @SL

	while @@fetch_Status =0
	begin
		if @SL < 0
		begin
			print N'Giá trị thêm/ sửa đổi là giá trị âm'
			rollback transaction
		end
		fetch next from CUR into @SL
	end
	close CUR
	deallocate CUR
end

---
begin transaction
	insert into CTHOADON values ('S032', 'SP4', 5)
	insert into CTHOADON values ('S032', 'SP4', -5)

	insert into CTHOADON (SoHD, MaSP, SoLuong)
	select 'S036' as SoHD, MaSP, 
			case 
				when MaSP = 'SP1' then 6 
				else SoLuong 
			end as SoLuong 
	from CTHOADON where SoHD = 'S022'

	update  CTHOADON 
	set SoLuong = -5 where SoLuong = 12
rollback transaction

select * from CTHOADON where SOHD ='S032'
select * from CTHOADON




--VD3: TẠO TRIGGER CẬP NHẬT DỮ LIỆU WAREHOUSE KHI MÀ THÔNG TIN HỢP ĐỒNG ĐƯỢC CẬP NHẠT TRONG BẢNG CTHOASON ( XUẤT/ NHẬP HD)
select distinct MaSP, 50 as Quantity into WAREHOUSE_REMAINING
from CTHOADON

select * from WAREHOUSE_REMAINING -- BẢNG CHỨA SLSP TỒN KHO

--HIỆN TẠI TRONG KHO HÀNG TƯƠNG ỨNG MỖI MaSP, TỒN KHO 50 SP
select * from WAREHOUSE_REMAINING --- HÀNG TỒN KHO
select * from CTHOADON --- PHIẾU XUẤT KHO

-- INSERT INTO CTHOADON -> TRỪ ĐI SLSP MaSP TƯƠNG ỨNG TRONG BẢNG WAREHOUSE_REMAINING
-- DELETE FROM CTHOADON -> CỘNG THÊM SLSP MaSP TƯƠNG ỨNG TRONG BẢNG WAREHOUSE_REMAINING
-- UPDATE CTHOADON -> TRỪ ĐI SLSP MaSP ĐƯỢC THAY THẾ, CỘNG THÊM SLSP MaSP BỊ THAY THẾ TRONG BẢNG WAREHOUSE_REMAINING
-- 1. DELETE FROM CTHOADON WHERE SoHD = 'S032'
-- 2. UPDATE WAREHOUSE_REMAINING
--    SET QUANTITY = 50 WHERE QUANTITY IS NOT NULL
-- 3. -----------
--		B1: TẠO TRIGGER CHO MỆNH ĐỀ INSERT
--		B2: TẠO TRIGGER CHO MỆNH ĐỀ DELETE

-- INSERT INTO CTHOADON -> TRỪ ĐI SLSP MaSP TƯƠNG ỨNG TRONG BẢNG WAREHOUSE_REMAINING

DROP TRIGGER TRG_INSERT
create trigger TRG_INSERT
on CTHOADON
for insert
as
begin
	declare CUR cursor for
		select MaSP, sum(SoLuong) as SLSP
		from inserted
		group by MaSP
	open CUR

	declare @MASP nvarchar(max), @SLSP int
	fetch next from CUR into @MASP, @SLSP

	while @@FETCH_STATUS = 0
		begin
			update WAREHOUSE_REMAINING
			set Quantity = Quantity - @SLSP
			where MaSP = @MASP
			fetch next from CUR into @MASP, @SLSP
		end
	close CUR
	deallocate CUR
end

begin transaction
	insert into CTHOADON
	select 
		'S035' as SoHD,
		MaSP,
		case
			when MaSP = 'SP1' then 10
			else Soluong
		end as SoLuong
	from CTHOADON
	where SoHD = 'S022'
rollback transaction

select * from CTHOADON
select * from WAREHOUSE_REMAINING



-- DELETE FROM CTHOADON -> CỘNG THÊM SLSP MaSP TƯƠNG ỨNG TRONG BẢNG WAREHOUSE_REMAINING

DROP TRIGGER TRG_DELETE
create trigger TRG_DELETE
on CTHOADON
for DELETE
as
begin
	declare CUR cursor for
		select MaSP, sum(SoLuong) as SLSP
		from deleted
		group by MaSP
	open CUR

	declare @MASP nvarchar(max), @SLSP int
	fetch next from CUR into @MASP, @SLSP

	while @@FETCH_STATUS = 0
		begin
			update WAREHOUSE_REMAINING
			set Quantity = Quantity + @SLSP
			where MaSP = @MASP
			fetch next from CUR into @MASP, @SLSP
		end
	close CUR
	deallocate CUR
end

begin transaction
	DELETE from CTHOADON where SoHD = 'S022'
rollback transaction

select * from CTHOADON
select * from WAREHOUSE_REMAINING



-- UPDATE CTHOADON -> TRỪ ĐI SLSP MaSP ĐƯỢC THAY THẾ, CỘNG THÊM SLSP MaSP BỊ THAY THẾ TRONG BẢNG WAREHOUSE_REMAINING
drop trigger TRG_UPDATE
create trigger TRG_UPDATE
on CTHOADON
for update
as
begin
	declare CUR cursor for
		select MaSP, SoLuong from inserted
		union all
		select MaSP, -1*SoLuong from deleted
	open CUR

	declare @MASP nvarchar(max), @SL int
	fetch next from CUR into @MASP, @SL

	while @@FETCH_STATUS = 0
	begin
		update WAREHOUSE_REMAINING
		set Quantity = Quantity - @SL
		where MaSP = @MASP
		fetch next from CUR into @MASP, @SL
	end
	close CUR
	deallocate CUR
end

begin transaction
	update CTHOADON
	set MaSP = 'SP5'
	WHERE MaSP = 'SP1'
rollback transaction

select * from CTHOADON
select * from WAREHOUSE_REMAINING
select * from CTHOADON where MaSP = 'SP1'



-- INSERT INTO CTHOADON -> TRỪ ĐI SLSP MaSP TƯƠNG ỨNG TRONG BẢNG WAREHOUSE_REMAINING
-- THÊM LOGIC ROLLBACK TRANSACTION VÀ IN DÒNG THÔNG BÁO '[MaSP] KHÔNG ĐỦ SỐ LƯỢNG ĐỀ XUẤT

DROP TRIGGER TRG_INSERT
create trigger TRG_INSERT
on CTHOADON
for insert
as
begin
	declare CUR cursor for
		select MaSP, sum(SoLuong) as SLSP
		from inserted
		group by MaSP
	open CUR

	declare @MASP nvarchar(max), @SLSP int
	fetch next from CUR into @MASP, @SLSP

	while @@FETCH_STATUS = 0
		begin
			declare @NEW_QUANTITY INT
			set @NEW_QUANTITY = (select Quantity - @SLSP from WAREHOUSE_REMAINING where MaSP = @MASP)
			if @NEW_QUANTITY < 0
				begin
					print (''+ @MaSP +N' không đủ số lượng đề xuất')
					rollback transaction
				end
			else
				begin
					update WAREHOUSE_REMAINING
					set Quantity = Quantity - @SLSP
					where MaSP = @MASP
				end
			fetch next from CUR into @MASP, @SLSP
		end
	close CUR
	deallocate CUR
end

begin transaction
	insert into CTHOADON
	select 
		'S035' as SoHD,
		MaSP,
		case
			when MaSP = 'SP1' then 20
			else Soluong
		end as SoLuong
	from CTHOADON
	where SoHD = 'S022'
rollback transaction

select * from CTHOADON
select * from WAREHOUSE_REMAINING