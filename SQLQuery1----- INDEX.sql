----- INDEX, TRANSACTION( COMMIT, ROLLBACK, TRIGGER------
declare @date1 datetime, @date2 datetime
set @date1 = getdate()
select * from khach_hang
where MaKH = 'M01'
set @date2 = getdate()
select datediff(millisecond, @date1, @date2)
 -- 1. Tạo clustered index cho cột [MaKH]
 create clustered index IX_khachhang_MaKH
 on DBO.khach_hang([MaKH])

 -- Xóa chỉ mục cụm hiện tại trên bảng tHoaDonBan
DROP INDEX khach_hang.IX_khachhang_MaKH ;



-- TRIGGER
--Tạo thông báo khi có thao tác thay đổi dữ liệu của bảng
----1. Khởi tạo Trigger
drop trigger TRG_KH
create trigger TRG_KH
on khach_hang
for insert, update, delete
as
begin
	print N'bảng CTHD vừa được thêm dữ liệu'
end

---
begin transaction
insert into khach_hang values('M08', N'Ngyễn Thị Trang', N'Hà Nội', 24)
delete from khach_hang where MaKH = 'M01'
update khach_hang
set MaKH = 'M09' where MaKH = 'M02'
rollback transaction

select * from khach_hang


-- Bảng inserted và bảng deleted trong trigger
drop trigger TRG_KH
create trigger TRG_KH
on khach_hang
for insert, update, delete
as
begin
	select * from inserted
	select * from deleted
end

---
begin transaction
insert into khach_hang values('M08', N'Ngyễn Thị Trang', N'Hà Nội', 24)
delete from khach_hang where MaKH = 'M01'
update khach_hang
set MaKH = 'M09' where MaKH = 'M02'
rollback transaction

select * from khach_hang


-- TẠO TRIGGER CHO BẢNG khach_hang VỚI MỆNH ĐỀ INSERT, DELETE, UPDATE
-- INSERT -> THÊM DỮ LIỆU VÀO BẢNG JOB_LOGS TƯƠNG ỨNG THONG_BAO, TIME_STAMPE GIÁ TRỊ N'BẢNG khach_hang VỪA ĐƯỢC THÊM DỮ LIỆU',

create table JOB_LOGS(THONG_BAO nvarchar(max), TIMR_STAMP datetime)
---
drop trigger TT_KH
create trigger TT_KH
on khach_hang
after insert, update, delete
as 
begin
	if exists (select * from inserted)
		begin
			if exists (select * from inserted)
				insert into JOB_LOGS values(N'Bảng vừa được cập nhật', getdate())
			else
				insert into JOB_LOGS values (N'Bảng vừa được thêm dữ liệu', getdate())
		end
	else
		if exists (select * from deleted)
			insert into JOB_LOGS values(N'Bảng vừa được xóa dữ liệu', getdate())
end

begin transaction
insert into khach_hang values('M05', N'Ngyễn Thanh Thảo', N'Hà Nội', 24)
delete from khach_hang where MaKH = 'M08'
update khach_hang
set MaKH = 'M02' where MaKH = 'M09'
rollback transaction

select * from khach_hang
select * from JOB_LOGS
