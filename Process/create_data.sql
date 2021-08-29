-- tao database - theo thu tu
CREATE TABLE exchange_vn
(
    Exchange_ID   INT         NOT NULL
        PRIMARY KEY,
    Exchange_Name VARCHAR(10) NULL,
    NamThanhLap   YEAR        NULL,
    VONHoa        FLOAT       NULL
);

CREATE TABLE company
(
    Company_ID       INT         NOT NULL
        PRIMARY KEY,
    Com_Name         VARCHAR(50) NULL,
    SymBol           VARCHAR(10) NULL,
    Exchange_ID      INT         NULL,
    NamThanhLap      YEAR        NULL,
    NgayPhatHanhCuoi DATE        NULL,
    VONDieuLe        FLOAT       NULL,
    MaNganh          VARCHAR(30) NULL,
    CONSTRAINT company_exchange_vn_Exchange_ID_fk
        FOREIGN KEY (Exchange_ID) REFERENCES exchange_vn (Exchange_ID)
            ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE public_inforr
(
    Public_ID   INT         NOT NULL
        PRIMARY KEY,
    Public_type VARCHAR(20) NULL,
    Public_DATE DATE        NULL
);

CREATE TABLE people
(
    People_ID   INT         NOT NULL
        PRIMARY KEY,
    People_Name VARCHAR(50) NULL,
    HocVan      VARCHAR(15) NULL,
    Age         INT         NULL,
    TONgTaiSan  FLOAT       NULL
);

CREATE TABLE bctc
(
    Company_ID INT  NULL,
    Public_ID  INT  NULL,
    BCTC_ID    INT  NOT NULL
        PRIMARY KEY,
    YEAR       YEAR NULL,
    Quy        INT  NULL,
    CONSTRAINT bctc_company_Company_ID_fk
        FOREIGN KEY (Company_ID) REFERENCES company (Company_ID)
            ON UPDATE CASCADE,
    CONSTRAINT bctc_public_inforr_Public_ID_fk
        FOREIGN KEY (Public_ID) REFERENCES public_inforr (Public_ID)
            ON UPDATE CASCADE
);

CREATE TABLE niemyet
(
    Public_ID              INT         NOT NULL
        PRIMARY KEY,
    NewListedComSym        VARCHAR(15) NULL,
    ListedPrice            INT         NULL,
    ListedAmount           INT         NULL,
    ListValue              FLOAT       NULL,
    FirstDATE              DATE        NULL,
    FirstDATEOpeningPrice  FLOAT       NULL,
    Listed_Com_Exchange_ID INT         NULL,
    MaNganh                VARCHAR(30) NULL,
    NamThanhLap            YEAR        NULL,
    VONDieuLe              FLOAT       NULL,
    ComNamListed           VARCHAR(50) NULL,
    CONSTRAINT niemyet_exchange_vn_Exchange_ID_fk
        FOREIGN KEY (Listed_Com_Exchange_ID) REFERENCES exchange_vn (Exchange_ID)
            ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT niemyet_public_inforr_Public_ID_fk
        FOREIGN KEY (Public_ID) REFERENCES public_inforr (Public_ID)
            ON UPDATE CASCADE ON DELETE CASCADE
);

-- Trigger
DELIMITER //
CREATE TRIGGER company_ID_run_before_insert
    BEFORE INSERT
    ON niemyet
    FOR EACH ROW
    BEGIN
        SET @lastID = (SELECT Company_ID FROM company ORDER BY Company_ID DESC LIMIT 1);
        IF @lastID IS NULL OR @lastID = '' THEN
            SET @lastID = 0;
        END IF;
        SET @lastID = @lastID +1;
    END//

DELIMITER //
CREATE TRIGGER insert_new_listed_company
    AFTER INSERT
    ON niemyet FOR EACH ROW
    BEGIN
        INSERT INTO company(Company_ID,Symbol, Exchange_ID, NgayPhatHanhCuoi, MaNganh, VONDieuLe, NamThanhLap, Com_Name)
        VALUES (@lastID ,NEW.NewListedComSym, NEW.Listed_Com_Exchange_ID, NEW.FirstDATE, NEW.MaNganh, NEW.VONDieuLe, NEW.NamThanhLap, NEW.ComNamListed);
    END //

CREATE TABLE unlisted
(
    Public_ID        INT         NULL,
    Amount_unlisted  bigINT      NULL,
    Value_unlisted   bigINT      NULL,
    Unlisted_day     DATE        NULL,
    Last_ON_Ex_day   DATE        NULL,
    Last_exchange_ID INT         NULL,
    Unlist_symbol    VARCHAR(10) NULL,
    CONSTRAINT unlisted_exchange_vn_Exchange_ID_fk
        FOREIGN KEY (Last_exchange_ID) REFERENCES exchange_vn (Exchange_ID)
            ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT unlisted_public_inforr_Public_ID_fk
        FOREIGN KEY (Public_ID) REFERENCES public_inforr (Public_ID)
            ON UPDATE CASCADE ON DELETE CASCADE
);


DELIMITER //
CREATE TRIGGER delete_unlisted_comp
    AFTER INSERT
    ON unlisted FOR EACH ROW
    BEGIN
        IF EXISTS (SELECT * FROM company WHERE SymBol = NEW.Unlist_symbol AND Exchange_ID = NEW.Last_exchange_ID) THEN
            DELETE FROM company WHERE SymBol = new.Unlist_symbol;
        END IF;
    END //

CREATE TABLE price_loggg
(
    Log_ID      INT   NOT NULL
        PRIMARY KEY,
    Company_ID  INT   NULL,
    PriceUpDATE FLOAT NULL,
    DATE        DATE  NULL,
    CONSTRAINT price_loggg_company_Company_ID_fk
        FOREIGN KEY (Company_ID) REFERENCES company (Company_ID)
            ON upDATE cascade
);
# khONg chay stock_perform
CREATE TABLE stock_perform
(
    Company_ID    INT   NOT NULL
        PRIMARY KEY,
    `P/B ratio`   FLOAT NULL,
    `PS ratio`    FLOAT NULL,
    Beta_Ratio    FLOAT NULL,
    ThiGiaVON     FLOAT NULL,
    KLTB_10days   FLOAT NULL,
    ROA           FLOAT NULL,
    ROE           FLOAT NULL,
    EPS           FLOAT NULL,
    Current_Price FLOAT NULL,
    CONSTRAINT stock_perform_company_Company_ID_fk
        FOREIGN KEY (Company_ID) REFERENCES company (Company_ID)
            ON UPDATE CASCADE ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER log_ID_run_before_insert
    BEFORE UPDATE
    ON stock_perform
    FOR EACH ROW
    BEGIN
        SET @lastID2 = (SELECT Log_ID FROM price_loggg ORDER BY Company_ID DESC LIMIT 1);
        IF @lastID2 IS NULL OR @lastID = '' THEN
            SET @lastID2 = 0;
        END IF;
        SET @lastID2 = @lastID2 +1;
    END//

DELIMITER //
CREATE TRIGGER insert_log_price
    AFTER UPDATE
    ON stock_perform
    FOR EACH ROW
    BEGIN
        IF (NEW.Current_Price != OLD.Current_Price) THEN
            INSERT INTO price_loggg(PriceUpDATE, DATE, Log_ID, Company_ID)
            VALUE(NEW.Current_Price, CURDATE(), @lastID2, OLD.Company_ID);
        END IF;
    END//

CREATE TABLE balancesheet
(
    BCTC_ID    INT   NOT NULL
        PRIMARY KEY,
    TONgTaiSan FLOAT NULL,
    TONgNo     FLOAT NULL,
    CONSTRAINT balancesheet_bctc_BCTC_ID_fk
        FOREIGN KEY (BCTC_ID) REFERENCES bctc (BCTC_ID)
            ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE bckqhdkd
(
    BCTC_ID         INT   NOT NULL
        PRIMARY KEY,
    Dthu_thuan      FLOAT NULL,
    LoiNhuanHDKD    FLOAT NULL,
    LoiNhuanSauThue FLOAT NULL,
    VayKH           FLOAT NULL,
    TienGuiKH       FLOAT NULL,
    LnLaiVaDV       INT   NULL,
    CONSTRAINT bckqhdkd_bctc_BCTC_ID_fk
        FOREIGN KEY (BCTC_ID) REFERENCES bctc (BCTC_ID)
            ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE divid_
(
    Public_ID    INT         NOT NULL
        PRIMARY KEY,
    NGDKHQ       DATE        NULL,
    Tile         FLOAT       NULL,
    LoaiCoTuc    VARCHAR(19) NULL,
    Dot          INT         NULL,
    Nam          YEAR        NULL,
    NgayThucHien DATE        NULL,
    Company_ID   INT         NULL,
    CONSTRAINT divid__company_Company_ID_fk
        FOREIGN KEY (Company_ID) REFERENCES company (Company_ID)
            ON upDATE cascade,
    CONSTRAINT divid__public_inforr_Public_ID_fk
        FOREIGN KEY (Public_ID) REFERENCES public_inforr (Public_ID)
            ON upDATE cascade
);

CREATE TABLE giaodich
(
    Trans_ID            INT         NOT NULL
        PRIMARY KEY,
    Company_ID          INT         NULL,
    Public_ID           INT         NULL,
    LoaiGD              VARCHAR(30) NULL,
    NguoiThucHien       INT         NULL,
    NguoiThucHien_Types VARCHAR(30) NULL,
    ChucVuNguoiThucHien VARCHAR(20) NULL,
    NguoiLienQuan       VARCHAR(30) NULL,
    ChucVuNLQ           VARCHAR(40) NULL,
    nlqTypes            VARCHAR(40) NULL,
    KLtruocGD           FLOAT       NULL,
    KLDKGD              FLOAT       NULL,
    NgayGiaoDich        DATE        NULL,
    KLsauGD             FLOAT       NULL,
    CONSTRAINT giaodich_company_Company_ID_fk
        FOREIGN KEY (Company_ID) REFERENCES company (Company_ID)
            ON upDATE cascade,
    CONSTRAINT giaodich_public_inforr_Public_ID_fk
        FOREIGN KEY (Public_ID) REFERENCES public_inforr (Public_ID)
            ON upDATE cascade
);

CREATE TABLE khanangsinhloi
(
    Company_ID  INT   NOT NULL
        PRIMARY KEY,
    EBIT        FLOAT NULL,
    TyleLaiRONg FLOAT NULL,
    TyleLaiHDKD FLOAT NULL,
    TyleLaiGop  FLOAT NULL,
    YOEA        FLOAT NULL,
    NIM         FLOAT NULL,
    COF         FLOAT NULL,
    CONSTRAINT khanangsinhloi_company_Company_ID_fk
        FOREIGN KEY (Company_ID) REFERENCES company (Company_ID)
            ON upDATE cascade
);

CREATE TABLE bld
(
    People_ID   INT         NOT NULL
        PRIMARY KEY,
    Company_ID  INT         NULL,
    Chuc_vu     VARCHAR(15) NULL,
    Ti_Le_so_hu FLOAT       NULL,
    CONSTRAINT bld_company_Company_ID_fk
        FOREIGN KEY (Company_ID) REFERENCES company (Company_ID)
            ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT bld_people_People_ID_fk
        FOREIGN KEY (People_ID) REFERENCES people (People_ID)
            ON UPDATE CASCADE ON DELETE CASCADE
);



-- View
-- view P/S ratio (>=3.00)
CREATE OR REPLACE VIEW P_S_CONd AS
SELECT sp.Company_ID, c.Com_Name, c.SymBol, sp.`PS ratio`
FROM company c JOIN stock_perform sp
    ON c.Company_ID = sp.Company_ID
WHERE `PS ratio` >= 3.00
ORDER BY `PS ratio` DESC;

-- view P/B raito (>=3.00)
CREATE OR REPLACE VIEW P_B_cond AS
SELECT sp.Company_ID, c.Com_Name, c.SymBol, sp.`P/B ratio`
FROM company c JOIN stock_perform sp ON c.Company_ID = sp.Company_ID
WHERE `P/B ratio` >= 3.00
ORDER BY `P/B ratio` DESC;

-- View ROA Theo Ngành
CREATE OR REPLACE VIEW ROA_Nganh AS
SELECT c.MaNganh, AVG(ROA) as ROA_av
FROM company c JOIN stock_perform sp ON c.Company_ID = sp.Company_ID
GROUP BY c.MaNganh;

-- View ROE Theo ngành
CREATE OR REPLACE VIEW ROE_Nganh AS
SELECT c.MaNganh, AVG(ROE) as ROE_av
FROM company c JOIN stock_perform sp ON c.Company_ID = sp.Company_ID
GROUP BY c.MaNganh
ORDER BY ROE_av;

CREATE OR REPLACE VIEW Bank_Coef AS
SELECT Com_Name, VayKH, TienGuiKH, LnLaiVaDV, YOEA, NIM, COF
FROM company
JOIN bctc b ON company.Company_ID = b.Company_ID
JOIN khanangsinhloi k ON company.Company_ID = k.Company_ID
JOIN bckqhdkd b2 ON b.BCTC_ID = b2.BCTC_ID
WHERE MaNganh = 'BANK';

CREATE OR REPLACE VIEW price_stat AS
SELECT SymBol, AVG(PriceUpDATE) AS avgPrice, VAR_SAMP(PriceUpDATE) AS variance,
       COUNT(PriceUpDATE) AS NumdayExchange, MIN(PriceUpDATE) AS minPrice,
       MAX(priceUpDATE) AS maxPrice, (VAR_SAMP(PriceUpDATE) / AVG(PriceUpDATE)) AS CoefOfVar
FROM company
JOIN price_loggg pl ON company.Company_ID = pl.Company_ID
GROUP BY SymBol;

-- SELECT
-- 1 tuoi trung binh cac chuc vu
SELECT Chuc_vu, avg(Age) as Avg_age
FROM people
JOIN bld b ON people.People_ID = b.People_ID
GROUP BY Chuc_vu;

-- 2 nhung nguoi co 1000 ty
SELECT People_Name,Chuc_vu, Com_Name, TongTaiSan
FROM people
JOIN bld b ON people.People_ID = b.People_ID
JOIN company c ON b.Company_ID = c.Company_ID
WHERE TongTaiSan >= 1000
ORDER BY TongTaiSan DESC;

-- 3 trong so nhung nguoi co 1000 ty nay, phan hoa chuc vu ra sao
SELECT Chuc_vu,COUNT(*) AS NUMBER
FROM people
JOIN bld b ON people.People_ID = b.People_ID
JOIN company c ON b.Company_ID = c.Company_ID
WHERE TONgTaiSan >= 1000
GROUP BY Chuc_vu;

-- 4 hoc cao len co giup chuc to hon khong
-- lam chu tich hdqt
SELECT Chuc_vu,HocVan,COUNT(HocVan) AS hocvan FROM people
JOIN bld b ON people.People_ID = b.People_ID
WHERE Chuc_vu LIKE 'Chủ tịch HDQT'
GROUP BY HocVan
ORDER BY hocvan DESC ;

-- lam tong giam doc
SELECT Chuc_vu, HocVan, COUNT(HocVan) AS hocvan
FROM people
JOIN bld b ON people.People_ID = b.People_ID
WHERE Chuc_vu LIKE 'Tổng giám đốc'
GROUP BY HocVan
ORDER BY hocvan DESC;

-- thong ke so luong hoc van
SELECT HocVan, count(HocVan)
FROM people
GROUP BY HocVan;

-- 5 hoc van va tong tai san
SELECT HocVan, avg(TongTaiSan) as tongtaisan
FROM people
GROUP BY HocVan
ORDER BY tongtaisan DESC;

-- 6 nganh nao dang co su phat trien
-- thong ke cac ma nganh
SELECT MaNganh, count(MaNganh) as soluONg
FROM company
GROUP BY MaNganh
ORDER BY soluong DESC;

-- nganh nao co roa cao
SELECT MaNganh, avg(EPS) as avg_eps,
       avg(ROA) as avg_roa, avg(ROE) as avg_roe
FROM company
JOIN stock_perform sp ON company.Company_ID = sp.Company_ID
GROUP BY MaNganh
ORDER BY avg_roa DESC;

-- cong ty nao thuoc ma hoa chat co avg_roa can ca nganh
SELECT Com_Name, MaNganh, ROA
FROM company
JOIN stock_perform sp ON company.Company_ID = sp.Company_ID
WHERE MaNganh like 'HoaChat';

-- Ban lanh dao cua cong ty Cao su Phuoc Hoa
SELECT People_Name,Chuc_vu, HocVan, Ti_Le_so_hu
FROM people
JOIN bld b ON people.People_ID = b.People_ID
JOIN company c ON b.Company_ID = c.Company_ID
WHERE Com_Name like 'CTCP Cao su Phước Hòa'
ORDER BY Ti_Le_so_hu DESC ;

-- 7 cong ty co ban lanh dao so huu nhieu ty le so huu thi lam an tot hon
SELECT Com_Name, SUM(Ti_Le_so_hu) as Tyle, ROA, ROE
FROM people
JOIN bld b ON people.People_ID = b.People_ID
JOIN company c ON c.Company_ID = b.Company_ID
JOIN stock_perform sp ON c.Company_ID = sp.Company_ID
GROUP BY Com_Name
ORDER BY Tyle DESC;

-- 8 hoc van va ti le so huu
SELECT HocVan, COUNT(HocVan) as hocvan,
       SUM(Ti_Le_so_hu) as TiLeSoHuu,
       AVG(Ti_Le_so_hu) as TrungBinh
FROM people
JOIN bld b ON people.People_ID = b.People_ID
JOIN company c ON c.Company_ID = b.Company_ID
JOIN stock_perform sp ON c.Company_ID = sp.Company_ID
GROUP BY hocvan
ORDER BY TrungBinh DESC ;

-- hai nguoi trung cap la ai- nam giu nhieu ti le trONg cONg ty
SELECT People_Name,HocVan, Chuc_vu, Com_Name, Ti_Le_so_hu
FROM people
JOIN bld b ON people.People_ID = b.People_ID
JOIN company c ON c.Company_ID = b.Company_ID
WHERE HocVan like 'Trung cấp';

-- Store Procedure
-- Tke dựa vào cổ tức
DELIMITER //
CREATE PROCEDURE divStat(IN div_types VARCHAR(15))
BEGIN
    SELECT SymBol, AVG(PriceUpdate) AS avgPrice, VAR_SAMP(PriceUpdate) AS variance,
           COUNT(PriceUpdate) AS NumdayExchange, MIN(PriceUpdate) AS minPrice,
           MAX(priceUpdate) AS maxPrice, (VAR_SAMP(PriceUpdate) / AVG(PriceUpdate)) AS CoefOfVar
    FROM company
    JOIN price_loggg pl ON company.Company_ID = pl.Company_ID
    JOIN divid_ d ON company.Company_ID = d.Company_ID
    WHERE LoaiCoTuc = div_types
    GROUP BY SymBol;
END //

CALL divStat('Tiền');


-- Nhập tên công ty > chỉ số của công ty + giá hiện tại
DELIMITER //
CREATE PROCEDURE spec_com(IN Ticker VARCHAR(14))
BEGIN
    SELECT Com_Name, `PS ratio`, `P/B ratio`, ROA, ROE, EPS, Current_Price
    FROM company
    JOIN stock_perform sp ON company.Company_ID = sp.Company_ID
    WHERE SymBol = Ticker;
END; //

CALL spec_com('VIC');

-- Nhập số tiền mình đầu tư + chỉ số quan tâm(PS ratio`, `P/B ratio`, ROA, ROE, EPS) > tên công ty có thể mua, xếp theo chỉ số quan tâm
DELIMITER //
CREATE PROCEDURE whichStock(
IN cih float,
IN ratio VARCHAR(20)
)
BEGIN
    DECLARE cih1 FLOAT;
    SET cih1 = cih / 100000;
    IF (ratio = 'DinhGia') THEN
        SELECT Com_Name, SymBol, EPS, `P/B ratio`, `PS ratio`, Current_Price
        FROM company
        JOIN stock_perform sp ON company.Company_ID = sp.Company_ID
        WHERE Current_Price <= cih1
        ORDER BY Current_Price;
    ELSE
        SELECT Com_Name, ROE, ROA, Current_Price
        FROM company
        JOIN stock_perform sp ON company.Company_ID = sp.Company_ID
        WHERE Current_Price <= cih1
        ORDER BY Current_Price;
    END IF;
END//

CALL whichStock(2500000, 'DinhGia');

-- Nhập tổng tài sản mONg muốn > ra tên người, tên cty, học vấn, vị trí, số tuổi, tổng tài sản lớn hơn hoặc bằng mức nhập vào
DELIMITER //
CREATE PROCEDURE assett(
IN valuee FLOAT
)
BEGIN
    SELECT People_Name, Chuc_vu, TONgTaiSan, HocVan, Age,Com_Name
    FROM people
    JOIN bld b ON people.People_ID = b.People_ID
    JOIN company c ON b.Company_ID = c.Company_ID
    WHERE TONgTaiSan >= valuee
    ORDER BY TONgTaiSan DESC ;
END //

CALL assett(10000);

-- nhập tên công ty in ra bld
DELIMITER //
CREATE PROCEDURE findMangementSystem(IN ticker VARCHAR(20))
BEGIN
    SELECT People_Name, Chuc_vu, Ti_Le_so_hu, Com_Name FROM bld
    JOIN company c ON c.Company_ID = bld.Company_ID
    JOIN people p ON p.People_ID = bld.People_ID
    WHERE SymBol = ticker
    ORDER BY Ti_Le_so_hu DESC ;
END //

CALL findMangementSystem('TCH');


