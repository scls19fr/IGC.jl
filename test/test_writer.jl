@testset "test_writer" begin
    @testset "write latitude" begin
        lat = IGCLatitude(51.29971666666667)
        s_expected_lat = "5117983N"
        @test string(lat) == s_expected_lat

        lat = IGCLatitude(-33.94611666666667)
        s_expected_lat = "3356767S"
        @test string(lat) == s_expected_lat
    end

    @testset "write longitude" begin
        long = IGCLongitude(6.956383333333333)
        s_expected_long = "00657383E"
        @test string(long) == s_expected_long

        long = IGCLongitude(-99.71176666666666)
        s_expected_long = "09942706W"
        @test string(long) == s_expected_long
    end

    @testset "write time" begin
        t = Time(16, 2, 45)
        s_expected_time = "160245"
        @test string(t, IGCTimeFormat) == s_expected_time
    end
    
    @testset "write date" begin
        d = Date(2019, 8, 20)
        s_expected_date = "200819"
        @test string(d, IGCDateFormat) == s_expected_date
    end

    @testset "write pressure altitude" begin
        alt = IGCPressureAltitude(288)
        s_expected_alt = "00288"
        @test string(alt) == s_expected_alt
    end


    @testset "write GPS altitude" begin
        alt = IGCGpsAltitude(429)
        s_expected_alt = "00429"
        @test string(alt) == s_expected_alt
    end

    @testset "write FixValidity" begin
        fv = FixValidity.Fix3D
        io = IOBuffer()
        FixValidity.write(io, fv)
        @test String(take!(io)) == "A"
        @test FixValidity.string(fv) == "A"

        fv = FixValidity.Fix2D
        io = IOBuffer()
        FixValidity.write(io, fv)
        @test String(take!(io)) == "V"
        @test FixValidity.string(fv) == "V"
    end

    @testset "write A record" begin
        rec = A_record(
            "XXX",
            "ABC",
            "FLIGHT:1"
        )
        s_expected_rec = "AXXXABC FLIGHT:1"
        @test string(rec) == s_expected_rec
    end

    @testset "write B record" begin
        rec = B_record(
            Time(16, 2, 45),
            IGCLatitude(51.118766666666666),
            IGCLongitude(-1.8216666666666668),
            FixValidity.parse('A'),
            IGCPressureAltitude(288),
            IGCGpsAltitude(429),
            36,
            "19509020"
        )
        s_expected_rec = "B1602455107126N00149300WA002880042919509020"
        @test string(rec) == s_expected_rec
    end

    @testset "write C record task info" begin
        rec = C_record_task_info(
            Date(2001, 7, 15),  # declaration_date
            Time(21, 38, 41),  # declaration_time
            Date(2001, 7, 16),  # flight_date
            "0001",  # number
            2,  # num_turnpoints
            "500K Tri"  # description
        )
        s_expected_rec = "C150701213841160701000102 500K Tri"
        @test string(rec) == s_expected_rec
    end

    @testset "write C record waypoint info" begin
        rec = C_record_waypoint_info(
            IGCLatitude(51.18931666666667),  # latitude
            IGCLongitude(-1.03165),  # longitude
            "Lasham Clubhouse"  # description
        )
        s_expected_rec = "C5111359N00101899W Lasham Clubhouse"
        @test string(rec) == s_expected_rec
    end

    @testset "write GpsQualifier" begin
        qual = GpsQualifier.GPS
        io = IOBuffer()
        GpsQualifier.write(io, qual)
        @test String(take!(io)) == "1"

        qual = GpsQualifier.DGPS
        io = IOBuffer()
        GpsQualifier.write(io, qual)
        @test String(take!(io)) == "2"
    end

    @testset "write D record" begin
        rec = D_record(
            GpsQualifier.DGPS,  # qualifier
            "0331"  # station_id
        )
        s_expected_rec = "D20331"
        @test string(rec) == s_expected_rec
        
        rec = D_record(
            GpsQualifier.GPS,  # qualifier
            "9999"  # station_id
        )
        s_expected_rec = "D19999"
        @test string(rec) == s_expected_rec
    end

    @testset "write E record" begin
        rec = E_record(
            Time(16, 2, 45),  # time
            "PEV",  # tlc
            ""  # extension_string
        )
        s_expected_rec = "E160245PEV"
        @test string(rec) == s_expected_rec
    end

    @testset "write F record" begin
        rec = F_record(
            Time(16, 2, 40),  # time
            ["04", "06", "09", "12", "36", "24", "22", "18", "21"]  # satellites
        )
        s_expected_rec = "F160240040609123624221821"
        @test string(rec) == s_expected_rec
    end

    @testset "write G record" begin
        rec = G_record(
            "REJNGJERJKNJKRE31895478537H43982FJN9248F942389T433T"
        )
        s_expected_rec = "GREJNGJERJKNJKRE31895478537H43982FJN9248F942389T433T"
        @test string(rec) == s_expected_rec
    end

    @testset "write I record" begin
        rec = I_record([
            IGCExtension(36:38, "FXA"),
            IGCExtension(39:40, "SIU"),
            IGCExtension(41:43, "ENL")
        ])
        s_expected_rec = "I033638FXA3940SIU4143ENL"
        @test string(rec) == s_expected_rec
    end

    @testset "write J record" begin
        rec = J_record([
            IGCExtension(8:12, "HDT")
        ])
        s_expected_rec = "J010812HDT"
        @test string(rec) == s_expected_rec
    end

    @testset "write K record" begin
        rec = K_record(
            Time(16, 2, 48),
            "00090",
            7  # tofix: is it really necessary?
        )
        s_expected_rec = "K16024800090"
        @test string(rec) == s_expected_rec
    end

    @testset "write L record" begin
        rec = L_record(
            "XXX",
            "RURITANIAN STANDARD NATIONALS DAY 1"
        )
        s_expected_rec = "LXXXRURITANIAN STANDARD NATIONALS DAY 1"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record fix accuracy" begin
        rec = H_record_FiXAccuracy(35)
        s_expected_rec = "HFFXA035"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record utc date" begin
        rec = H_record_DaTE(2001, 7, 16)
        s_expected_rec = "HFDTE160701"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record pilot" begin
        rec = H_record_PiLoT("Bloggs Bill D")
        s_expected_rec = "HFPLTPILOTINCHARGE:Bloggs Bill D"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record copilot" begin
        rec = H_record_Copilot("Smith-Barry John A")
        s_expected_rec = "HFCM2CREW2:Smith-Barry John A"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record glider type" begin
        rec = H_record_GliderType("Schleicher ASH-25")
        s_expected_rec = "HFGTYGLIDERTYPE:Schleicher ASH-25"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record glider registration" begin
        rec = H_record_GliderRegistration("ABCD-1234")
        s_expected_rec = "HFGIDGLIDERID:ABCD-1234"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record gps datum" begin
        rec = H_record_GpsDatum("WGS-1984")
        s_expected_rec = "HFDTM100GPSDATUM:WGS-1984"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record firmware revision" begin
        rec = H_record_FirmwareRevision("6.4")
        s_expected_rec = "HFRFWFIRMWAREVERSION:6.4"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record hardware revision" begin
        rec = H_record_HardwareRevision("3.0")
        s_expected_rec = "HFRHWHARDWAREVERSION:3.0"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record manufacturer model" begin
        rec = H_record_ManufacturerModel("Manufacturer", "Model")
        s_expected_rec = "HFFTYFRTYPE:Manufacturer,Model"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record gps receiver" begin
        rec = H_record_GpsReceiver(
            "MarconiCanada",
            "Superstar",
            12,
            MaxAlt(10000, "m")
        )
        s_expected_rec = "HFGPS:MarconiCanada,Superstar,12ch,max10000m"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record pressure sensor" begin
        rec = H_record_PressureAltitudeSensor(
            "Sensyn",
            "XYZ1111",
            MaxAlt(11000, "m")
        )
        s_expected_rec = "HFPRSPRESSALTSENSOR:Sensyn,XYZ1111,max11000m"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record competition id" begin
        rec = H_record_CompetitionId("XYZ-78910")
        s_expected_rec = "HFCIDCOMPETITIONID:XYZ-78910"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record competition class" begin
        rec = H_record_CompetitionClass("15m Motor Glider")
        s_expected_rec = "HFCCLCOMPETITIONCLASS:15m Motor Glider"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record time zone offset" begin
        rec = H_record_TimeZoneOffset(3 * 60)
        s_expected_rec = "HFTZNTIMEZONE:3"
        @test string(rec) == s_expected_rec

        rec = H_record_TimeZoneOffset(-(3 * 60 + 30))
        s_expected_rec = "HFTZNTIMEZONE:-3.30"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record mop sensor" begin
        rec = H_record_MeansOfPropulsion("MOP-(SN:1,ET=1375,0,1375,0,3.05V,p=0),Ver:0")
        s_expected_rec = "HFMOPSENSOR:MOP-(SN:1,ET=1375,0,1375,0,3.05V,p=0),Ver:0"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record site" begin
        rec = H_record_Site("lk15comp")
        s_expected_rec = "HFSITSite:lk15comp"
        @test string(rec) == s_expected_rec
    end

    @testset "write H record units of measure" begin
        rec = H_record_UnitsOfMeasure(["km", "ft", "kt"])
        s_expected_rec = "HFUNTUnits:km,ft,kt"
        @test string(rec) == s_expected_rec
    end

    @testset "write IGCDocument" begin
        io = IOBuffer()  # this buffer is filled at each update! call

        igcdoc = IGCDocument(stream = io, parsing_mode = IGC.ParsingMode.STRICT)
        
        update!(igcdoc, A_record("XXX", "ABC", "FLIGHT:1"))
        s_expected = """AXXXABC FLIGHT:1"""

        update!(igcdoc, H_record_FiXAccuracy('F', 35))
        update!(igcdoc, H_record_DaTE('F', Date(2001, 07, 16)))
        update!(igcdoc, H_record_PiLoT('F', "Bloggs Bill D"))
        update!(igcdoc, H_record_Copilot('F', "Smith-Barry John A"))
        update!(igcdoc, H_record_GliderType('F', "Schleicher ASH-25"))
        update!(igcdoc, H_record_GliderRegistration('F', "ABCD-1234"))
        update!(igcdoc, H_record_GpsDatum('F', "WGS-1984"))
        update!(igcdoc, H_record_FirmwareRevision('F', "6.4"))
        update!(igcdoc, H_record_HardwareRevision('F', "3.0"))
        update!(igcdoc, H_record_ManufacturerModel('F', "Manufacturer", "Model"))
        update!(igcdoc, H_record_GpsReceiver('F', "MarconiCanada", "Superstar", 12, MaxAlt(10000, "m")))
        update!(igcdoc, H_record_PressureAltitudeSensor('F', "Sensyn", "XYZ1111", MaxAlt(11000, "m")))
        update!(igcdoc, H_record_CompetitionId('F', "XYZ-78910"))
        update!(igcdoc, H_record_CompetitionClass('F', "15m Motor Glider"))
        s_expected = s_expected * EOL_DEFAULT * """HFFXA035
HFDTE160701
HFPLTPILOTINCHARGE:Bloggs Bill D
HFCM2CREW2:Smith-Barry John A
HFGTYGLIDERTYPE:Schleicher ASH-25
HFGIDGLIDERID:ABCD-1234
HFDTM100GPSDATUM:WGS-1984
HFRFWFIRMWAREVERSION:6.4
HFRHWHARDWAREVERSION:3.0
HFFTYFRTYPE:Manufacturer,Model
HFGPS:MarconiCanada,Superstar,12ch,max10000m
HFPRSPRESSALTSENSOR:Sensyn,XYZ1111,max11000m
HFCIDCOMPETITIONID:XYZ-78910
HFCCLCOMPETITIONCLASS:15m Motor Glider"""

        rec = I_record([IGCExtension(36:38, "FXA"), IGCExtension(39:40, "SIU"), IGCExtension(41:43, "ENL")])
        update!(igcdoc, rec)
        s_expected = s_expected * EOL_DEFAULT * "I033638FXA3940SIU4143ENL"

        rec = J_record([IGCExtension(8:12, "HDT")])
        update!(igcdoc, rec)
        s_expected = s_expected * EOL_DEFAULT * "J010812HDT"

        rec = C_record_task_info(Date(2001, 7, 15), Time(21, 38, 41), Date(2001, 7, 16), "0001", 2, "500K Tri")
        update!(igcdoc, rec)
        s_expected = s_expected * EOL_DEFAULT * """C150701213841160701000102 500K Tri"""

        records = [
            C_record_waypoint_info(IGCLatitude(51.18931666666667), IGCLongitude(-1.03165), "Lasham Clubhouse"),
            C_record_waypoint_info(IGCLatitude(51.16965), IGCLongitude(-1.0440666666666667), "Lasham Start S, Start"),
            C_record_waypoint_info(IGCLatitude(52.15153333333333), IGCLongitude(-2.9204499999999998), "Sarnesfield, TP1"),
            C_record_waypoint_info(IGCLatitude(52.50245), IGCLongitude(-0.2935333333333333), "Norman Cross, TP2"),
            C_record_waypoint_info(IGCLatitude(51.16965), IGCLongitude(-1.0440666666666667), "Lasham Start S, Finish"),
            C_record_waypoint_info(IGCLatitude(51.18931666666667), IGCLongitude(-1.03165), "Lasham Clubhouse")
        ]
        update!(igcdoc, records)
        s_expected = s_expected * EOL_DEFAULT * """C5111359N00101899W Lasham Clubhouse
C5110179N00102644W Lasham Start S, Start
C5209092N00255227W Sarnesfield, TP1
C5230147N00017612W Norman Cross, TP2
C5110179N00102644W Lasham Start S, Finish
C5111359N00101899W Lasham Clubhouse"""

        rec = F_record(Time(16, 02, 40), ["04", "06", "09", "12", "36", "24", "22", "18", "21"])
        update!(igcdoc, rec)
        s_expected = s_expected * EOL_DEFAULT * "F160240040609123624221821"

        records = [
            B_record(Time(16, 02, 40), IGCLatitude(54.11868333333334), IGCLongitude(-2.8223666666666665), FixValidity.Fix3D, IGCPressureAltitude(280), IGCGpsAltitude(421), 36, "20509950"),
            D_record(GpsQualifier.DGPS, "0331"),
            E_record(Time(16, 02, 45), "PEV", ""),
            B_record(Time(16, 02, 45), IGCLatitude(51.118766666666666), IGCLongitude(-1.8216666666666668), FixValidity.Fix3D, IGCPressureAltitude(288), IGCGpsAltitude(429), 36, "19509020"),
            B_record(Time(16, 02, 50), IGCLatitude(51.1189), IGCLongitude(-1.8213833333333334), FixValidity.Fix3D, IGCPressureAltitude(290), IGCGpsAltitude(432), 36, "21009015"),
            B_record(Time(16, 02, 55), IGCLatitude(51.119), IGCLongitude(-1.82035), FixValidity.Fix3D, IGCPressureAltitude(290), IGCGpsAltitude(430), 36, "20009012"),
            F_record(Time(16, 03, 00), ["06", "09", "12", "36", "24", "22", "18", "21"]),
            B_record(Time(16, 03, 00), IGCLatitude(51.119166666666665), IGCLongitude(-1.8200333333333334), FixValidity.Fix3D, IGCPressureAltitude(291), IGCGpsAltitude(432), 36, "25608009"),
            E_record(Time(16, 03, 05), "PEV", ""),
            B_record(Time(16, 03, 05), IGCLatitude(51.11966666666667), IGCLongitude(-1.81975), FixValidity.Fix3D, IGCPressureAltitude(291), IGCGpsAltitude(435), 36, "21008015"),
            B_record(Time(16, 03, 10), IGCLatitude(51.1202), IGCLongitude(-1.8195666666666668), FixValidity.Fix3D, IGCPressureAltitude(293), IGCGpsAltitude(435), 36, "19608024"),
            K_record(Time(16, 02, 48), "00090", 7),
            B_record(Time(16, 02, 48), IGCLatitude(51.120333333333335), IGCLongitude(-1.8191666666666666), FixValidity.Fix3D, IGCPressureAltitude(494), IGCGpsAltitude(436), 36, "19008018"),
            B_record(Time(16, 02, 52), IGCLatitude(51.122166666666665), IGCLongitude(-1.8187833333333334), FixValidity.Fix3D, IGCPressureAltitude(496), IGCGpsAltitude(439), 36, "19508015")
        ]
        update!(igcdoc, records)
        s_expected = s_expected * EOL_DEFAULT * """B1602405407121N00249342WA002800042120509950
D20331
E160245PEV
B1602455107126N00149300WA002880042919509020
B1602505107134N00149283WA002900043221009015
B1602555107140N00149221WA002900043020009012
F1603000609123624221821
B1603005107150N00149202WA002910043225608009
E160305PEV
B1603055107180N00149185WA002910043521008015
B1603105107212N00149174WA002930043519608024
K16024800090
B1602485107220N00149150WA004940043619008018
B1602525107330N00149127WA004960043919508015"""


        records = [
            L_record("XXX", "RURITANIAN STANDARD NATIONALS DAY 1"),
            L_record("XXX", "FLIGHT TIME: 4:14:25, TASK SPEED:58.48KTS")
        ]
        update!(igcdoc, records)
        s_expected = s_expected * EOL_DEFAULT * """LXXXRURITANIAN STANDARD NATIONALS DAY 1
LXXXFLIGHT TIME: 4:14:25, TASK SPEED:58.48KTS"""

        records = [
            G_record("REJNGJERJKNJKRE31895478537H43982FJN9248F942389T433T"),
            G_record("JNJK2489IERGNV3089IVJE9GO398535J3894N358954983O0934"),
            G_record("SKTO5427FGTNUT5621WKTC6714FT8957FGMKJ134527FGTR6751"),
            G_record("K2489IERGNV3089IVJE39GO398535J3894N358954983FTGY546"),
            G_record("12560DJUWT28719GTAOL5628FGWNIST78154INWTOLP7815FITN")
        ]
        update!(igcdoc, records)
        s_expected = s_expected * EOL_DEFAULT * """GREJNGJERJKNJKRE31895478537H43982FJN9248F942389T433T
GJNJK2489IERGNV3089IVJE9GO398535J3894N358954983O0934
GSKTO5427FGTNUT5621WKTC6714FT8957FGMKJ134527FGTR6751
GK2489IERGNV3089IVJE39GO398535J3894N358954983FTGY546
G12560DJUWT28719GTAOL5628FGWNIST78154INWTOLP7815FITN"""
        @test String(take!(io)) == s_expected

        # this buffer is filled only at end of file
        io_at_end = IOBuffer()
        write(io_at_end, igcdoc)
        #@test String(take!(io_at_end)) == s_expected
    end

end
