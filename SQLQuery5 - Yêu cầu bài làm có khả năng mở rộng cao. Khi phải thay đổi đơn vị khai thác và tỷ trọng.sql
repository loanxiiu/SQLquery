-- Có  1000 khách hàng được đánh số từ với các nhóm khác nhau như hot, normal, hard rock
-- Cần chia cho 3 đơn vị khai thác kênh khác nhau A, B, C theo tỷ trọng như sau:
-- Nhóm Hot theo tỷ trọng: A-40%, B-30%, C-30%
-- Nhóm Normal theo tỷ trọng: A-30%, B-60%, C-10%
-- Nhóm Hardrock theo tỷ trọng: A-10%, B-40%, C-50%

--Yêu cầu 1: tạo ra 1 bảng chứa danh sách khách hàng tên là NhomKH gồm 2 cột MaKH, Nhom
-- Thêm dữ liệu vào NhomKH 400 khách hàng được đánh số từ 1 -> 400 và đặt vào nhóm Hot
-- Thêm dữ liệu vào NhomKH 350 khách hàng được đánh số từ 401 -> 750 và đặt vào nhóm Normal
-- Thêm dữ liệu vào NhomKH 350 khách hàng được đánh số từ 750 -> 1000 và đặt vào nhóm Hardrock

--Tạo ra 1 bảng kết quả chia các nhóm Hot, Normal, Hardrock theo các nhóm A B C theo tỷ trọng
--Bảng kết quả có dạng như sau:
		-- MaKH		Nhom	NhomCon
		--  1		 Hot		A
		--  2		 Hot		A
		--  3		 Hot		A
		--...........................
		-- 	161 	 Hot		A
		--  162		 Hot		A
		--  163		 Hot		A	
		--...........................

-- Yêu cầu bài làm có khả năng mở rộng cao. Khi phải thay đổi đơn vị khai thác và tỷ trọng
--Ví dụ thay đổi đề bài thành 4 hoặc 5 đơn vị khai thác A, B, C, D, E và tỷ trọng cũng thay đổi thường xuyên

drop table if exists TEST.dbo.KH;
create table TEST.dbo.KH
	(
		MaKH int,
		NhomKH varchar(100)
	)

-- delete from TEST..KH

declare @i int = 1;
while @i <= 1000
begin 
	if @i <= 400
		insert into TEST..KH values (@i,'hot')
	else if @i >= 401 and @i <= 750
		insert into TEST..KH values (@i,'normal')
	else 
		insert into TEST..KH values (@i,'hardrock')
	set @i = @i + 1
end;

select * from TEST..KH

-- Tạo bảng REFERENCE

--C1:
drop table if exists TEST..PhanNhom;

create table TEST..PhanNhom
	(
		MaNhom varchar(100),
		MaNhomCon varchar(100),
		TyTrong float
	)

insert into TEST..PhanNhom values
	('hot', 'A', '0.4'),
	('hot', 'B', '0.3'),
	('hot', 'C', '0.3'),
	('normal', 'A', '0.3'),
	('normal', 'B', '0.6'),
	('normal', 'C', '0.1'),
	('hardrock', 'A', '0.1'),
	('hardrock', 'B', '0.4'),
	('hardrock', 'C', '0.5')

with X as
(
	select
		*,
		(sum(SL) over (partition by MaNhom order by MaNhomCon) - SL) MinValue,
		sum(SL) over (partition by MaNhom order by MaNhomCon) MaxValue
	from
	(	
		select
			a.*,
			(b.SL * a.TyTrong) SL
		from  TEST..PhanNhom a
		left join
			(
				select NhomKH, count(*) SL
				from TEST..KH
				group by NhomKH
			) b 
		on a.MaNhom = b.NhomKH
	) a
), Y as
(
	select
		*,
		row_number() over (partition by NhomKH order by MaKH asc) stt
	from TEST..KH
)

select MaKh, MaNhom, MaNhomCon, stt
from Y a left join X b on a.NhomKH = b.MaNhom and stt > [MinValue] and stt <= [Maxvalue]
order by 1

with tbl as 
(
	select
	*,
	count(*) over (partition by NhomKH) as TSL,
	row_number () over (partition by NhomKH order by MaKH asc) as STT
	from TEST..KH
)
	select 
		*,
		cast(STT as float)/ cast(TSL as float) as Tytrong,
		case 
			when NhomKH = 'hot' and cast (STT as float ) / cast (TSL as float) <= 0.4 then 'A'
			when NhomKH = 'hot' and cast (STT as float ) / cast (TSL as float) <= 0.7 then 'B'
			when NhomKH = 'hot' and cast (STT as float ) / cast (TSL as float) <= 1 then 'C'
			when NhomKH = 'normal' and cast (STT as float ) / cast (TSL as float) <= 0.3 then 'A'
			when NhomKH = 'normal' and cast (STT as float ) / cast (TSL as float) <= 0.9 then 'B'
			when NhomKH = 'normal' and cast (STT as float ) / cast (TSL as float) <= 1 then 'C'
			when NhomKH = 'hardrock' and cast (STT as float ) / cast (TSL as float) <= 0.1 then 'A'
			when NhomKH = 'hardrock' and cast (STT as float ) / cast (TSL as float) <= 0.5 then 'B'
			when NhomKH = 'hardrock' and cast (STT as float ) / cast (TSL as float) <= 1 then 'C'
		end as NhomCon
	from tbl 
	order by MaKH asc
