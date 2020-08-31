create FUNCTION terbilang(masukan IN NUMBER)
    RETURN
        VARCHAR2 IS
    -- Setting Parameter
    kata_kata_awal             VARCHAR2(100)  := ' ';
    kata_kata_akhir            VARCHAR2(100)  := ' ';
    kata_kata_bilangan_negatif VARCHAR2(100)  := 'Negatif ';
    Model_bilangan_pecahan     NUMBER(1, 0)   := 1; -- Valid nilai = 1, 2,3
    Pecahan_khusus             BOOLEAN        := TRUE;
    -- Variable internal
    temp_masukan               NUMBER;
    bilangan                   VARCHAR2(40)   := NULL;
    kesalahan                  BOOLEAN        := FALSE;
    hasil_akhir                VARCHAR2(2000) := NULL;
    hasil_sementara            VARCHAR2(2000) := NULL;
    dapat_pecahan_khusus       BOOLEAN        := FALSE;
    FUNCTION Ambil_Satuan(digit IN VARCHAR2) RETURN VARCHAR2 IS
        -- Untuk menerjemahkan satu digit menjadi bilangan untuk satuan 1.. 9
    BEGIN
        IF digit = '1' THEN
            RETURN ('Satu ');
        ELSIF digit = '2' THEN
            RETURN ('Dua ');
        ELSIF digit = '3' THEN
            RETURN ('Tiga ');
        ELSIF digit = '4' THEN
            RETURN ('Empat ');
        ELSIF digit = '5' THEN
            RETURN ('Lima ');
        ELSIF digit = '6' THEN
            RETURN ('Enam ');
        ELSIF digit = '7' THEN
            RETURN ('Tujuh ');
        ELSIF digit = '8' THEN
            RETURN ('Delapan ');
        ELSIF digit = '9' THEN
            RETURN ('Sembilan ');
        END IF;
    END;
    FUNCTION Ambil_Belasan(digit IN VARCHAR2) RETURN VARCHAR2 IS
        -- Untuk menerjemahkan satu digit menjadi bilangan untuk satuan 10 ..19
    BEGIN
        IF digit = '1' THEN
            RETURN ('Sebelas ');
        ELSIF digit = '2' THEN
            RETURN ('Dua Belas ');
        ELSIF digit = '3' THEN
            RETURN ('Tiga Belas ');
        ELSIF digit = '4' THEN
            RETURN ('Empat Belas ');
        ELSIF digit = '5' THEN
            RETURN ('Lima Belas ');
        ELSIF digit = '6' THEN
            RETURN ('Enam Belas ');
        ELSIF digit = '7' THEN
            RETURN ('Tujuh Belas ');
        ELSIF digit = '8' THEN
            RETURN ('Delapan Belas ');
        ELSIF digit = '9' THEN
            RETURN ('Sembilan Belas ');
        ELSIF digit = '0' THEN
            RETURN ('Sepuluh ');
        END IF;
    END;
    FUNCTION Ambil_tiga_digit(digit IN VARCHAR2) RETURN VARCHAR2 IS
        temp           VARCHAR2(200) := NULL;
        temp_satu_char VARCHAR2(1)   := NULL;
    BEGIN
        --------- Proses Ratusan
        temp_satu_char := SUBSTR(digit, 1, 1);
        IF temp_satu_char > '1' THEN
            temp := Ambil_satuan(temp_satu_char) || 'Ratus ';
        ELSIF temp_satu_char = '1' THEN
            temp := 'Seratus ';
            -- nol tidak diproses
        END IF;
        --------- Proses Puluhan dan Belasan
        temp_satu_char := SUBSTR(digit, 2, 1);
        IF temp_satu_char > '1' THEN
            temp := temp || Ambil_satuan(temp_satu_char) || 'Puluh ';
        ELSIF temp_satu_char = '1' THEN
            temp := temp || Ambil_Belasan(SUBSTR(digit, 3, 1));
            -- else nol tidak diproses
        END IF;
        -- Ambil Satuan Kecuali bila belasan (bilangan puluhan = 1)
        temp_satu_char := SUBSTR(digit, 3, 1);
        IF temp_satu_char > '0' AND SUBSTR(digit, 2, 1) <> '1' THEN
            temp := temp || Ambil_satuan(SUBSTR(digit, 3, 1));
        END IF;
        RETURN temp;
    END;
BEGIN
    temp_masukan := masukan;
    IF temp_masukan < 0 THEN
        temp_masukan := ABS(temp_masukan);
        hasil_akhir := kata_kata_bilangan_negatif;
    END IF;
    bilangan := TO_CHAR(temp_masukan, '999999999999990.00');
    /*                                 2345678901234567890
      Format to_char di atas jangan dirubah
          2 3 4 = Trilyun       11 12 13 = Ribu
          5 6 7 = Milyar        14 15 16 = Satuan
          8 9 10 = Juta         18 19 = Pecahan    */
    hasil_sementara := Ambil_tiga_digit(SUBSTR(bilangan, 2, 3));
    IF hasil_sementara IS NOT NULL THEN
        hasil_akhir := hasil_akhir || hasil_sementara || 'Trilyun ';
    END IF;
    hasil_sementara := Ambil_tiga_digit(SUBSTR(bilangan, 5, 3));
    IF hasil_sementara IS NOT NULL THEN
        hasil_akhir := hasil_akhir || hasil_sementara || 'Milyar ';
    END IF;
    hasil_sementara := Ambil_tiga_digit(SUBSTR(bilangan, 8, 3));
    IF hasil_sementara IS NOT NULL THEN
        hasil_akhir := hasil_akhir || hasil_sementara || 'Juta ';
    END IF;
    IF SUBSTR(bilangan, 11, 3) IN ('001', '  1') THEN
        -- Seribu mendapat perlakuan khusus sehingga bukan satu ribu
        hasil_akhir := hasil_akhir || 'Seribu ';
    ELSE
        hasil_sementara := Ambil_tiga_digit(SUBSTR(bilangan, 11, 3));
        IF hasil_sementara IS NOT NULL THEN
            hasil_akhir := hasil_akhir || hasil_sementara || 'Ribu ';
        END IF;
    END IF;
    hasil_sementara := Ambil_tiga_digit(SUBSTR(bilangan, 14, 3));
    IF hasil_sementara IS NOT NULL THEN
        hasil_akhir := hasil_akhir || hasil_sementara;
    END IF;
    IF hasil_akhir IS NULL AND SUBSTR(bilangan, 16, 1) = '0' THEN
        hasil_akhir := 'Nol ';
    END IF;
    --------------------------------------------------------------------
    --  Pemrosesan bilangan pecahan
--------------------------------------------------------------------

    bilangan := SUBSTR(bilangan, 18, 2);
    IF bilangan <> '00' THEN --then proses bilangan pecahan

        hasil_akhir := hasil_akhir || 'Koma ';
        IF SUBSTR(bilangan, 1, 1) > '1' THEN
            hasil_akhir := hasil_akhir || Ambil_satuan(SUBSTR(bilangan, 1, 1)) || 'Puluh ';
        ELSIF SUBSTR(bilangan, 1, 1) = '1' THEN
            hasil_akhir := hasil_akhir || Ambil_Belasan(SUBSTR(bilangan, 2, 1));
        ELSIF SUBSTR(bilangan, 1, 1) = '0' THEN
            hasil_akhir := hasil_akhir || 'Nol ';
        END IF;
        -- Ambil Satuan Kecuali bila belasan (bilangan puluhan = 1)
        IF SUBSTR(bilangan, 2, 1) > '0' AND SUBSTR(bilangan, 1, 1) <> '1' THEN
            hasil_akhir := hasil_akhir || Ambil_satuan(SUBSTR(bilangan, 2, 1));
        END IF;

    END IF;

    hasil_akhir := kata_kata_awal || RTRIM(hasil_akhir) || kata_kata_akhir || 'Rupiah ';
--  dbms_output.put_line(Hasil_akhir);
    RETURN hasil_akhir;
END;
/

