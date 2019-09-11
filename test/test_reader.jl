@testset "test_reader" begin
    @testset "parse latitude" begin
        s_lat = "5117983N"
        parsed_lat = parse(IGCLatitude, s_lat)
        expected_lat = IGCLatitude(51.29971666666667)
        @test parsed_lat == expected_lat

        s_lat = "3356767S"
        parsed_lat = parse(IGCLatitude, s_lat)
        expected_lat = IGCLatitude(-33.94611666666667)
        @test parsed_lat == expected_lat
    end

    @testset "parse longitude" begin
        s_long = "00657383E"
        parsed_long = parse(IGCLongitude, s_long)
        expected_long = IGCLongitude(6.956383333333333)
        @test parsed_long == expected_long

        s_long = "09942706W"
        parsed_long = parse(IGCLongitude, s_long)
        expected_long = IGCLongitude(-99.71176666666666)
        @test parsed_long == expected_long
    end

    @testset "empty A record" begin
        rec = A_record()
        @test isempty(rec)

        rec = A_record("XXX", "ABC", "FLIGHT:1")
        @test !isempty(rec)
    end

    @testset "parse A record" begin
        line = "AXXXABC FLIGHT:1\r\n"
        parsed_result = parse(Abstract_IGC_record, line)
        expected_result = A_record(
            "XXX",
            "ABC",
            "FLIGHT:1"
        )
        @test flc(parsed_result) == 'A'
        # @test parsed_result == expected_result  # ToFix
        @test parsed_result.manufacturer == expected_result.manufacturer
        @test parsed_result.id == expected_result.id
        @test parsed_result.id_addition == expected_result.id_addition
    end

    @testset "Empty Time" begin
        t = EmptyTime()
        @test t == Time(0, 0, 0)
    end

    @testset "parse time" begin
        s = "160245"
        expected_result = Time(16, 2, 45)

        parsed_result = parse(Time, s, IGCTimeFormat)
        @test parsed_result == expected_result

        @test string(parsed_result, IGCTimeFormat) == s
    end

    @testset "Empty Date" begin
        d = EmptyDate()
        @test d == Date(0, 1, 1)
    end
    
    @testset "parse date" begin
        s = "200819"
        expected_result = Date(2019, 8, 20)

        parsed_result = parse(Date, s, IGCDateFormat)
        @test parsed_result == expected_result

        @test string(parsed_result, IGCDateFormat) == s
    end

    @testset "parse/write ZonedDateTime" begin
        s_d = "200819"
        d = parse(Date, s_d, IGCDateFormat)
        s_t = "160245"
        t = parse(Time, s_t, IGCTimeFormat)
        dt = ZonedDateTime(d + t, TZ)
        @test dt == ZonedDateTime(2019, 8, 20, 16, 2, 45, TZ)
        @test string(dt, IGCDateFormat) == s_d
        @test string(dt, IGCTimeFormat) == s_t
    end

    @testset "parse pressure altitude" begin
        @test parse(IGCPressureAltitude, "00288") == IGCPressureAltitude(288)
    end

    @testset "parse GPS altitude" begin
        @test parse(IGCGpsAltitude, "00429") == IGCGpsAltitude(429)
    end

    @testset "parse FixValidity" begin
        @test FixValidity.parse('A') == FixValidity.Fix3D
        @test FixValidity.parse('V') == FixValidity.Fix2D
    end

    @testset "parse B record" begin
        line = "B1602455107126N00149300WA002880042919509020\r\n"
        expected_result = B_record(
            Time(16, 2, 45),
            IGCLatitude(51.118766666666666),
            IGCLongitude(-1.8216666666666668),
            FixValidity.parse('A'),
            IGCPressureAltitude(288),
            IGCGpsAltitude(429),
            36,
            "19509020"
        )
        parsed_result = parse(Abstract_IGC_record, line)
        
        @test flc(parsed_result) == 'B'

        # @test parsed_result == expected_result  # tofix because of extensions

        @test parsed_result.time == expected_result.time
        @test parsed_result.latitude == expected_result.latitude
        @test parsed_result.longitude == expected_result.longitude
        @test parsed_result.validity == expected_result.validity
        @test parsed_result.pressure_alt == expected_result.pressure_alt
        @test parsed_result.gps_alt == expected_result.gps_alt
        @test parsed_result.start_index_extensions == parsed_result.start_index_extensions
        @test parsed_result.extensions_string == parsed_result.extensions_string
    end

    @testset "process B record" begin
        """Check whether correct extension information is taken from B record"""

        s_i_record = join(["I08", "3638FXA", "3941ENL", "4246TAS", "4751GSP", "5254TRT", "5559VAT", "6063OAT", "6467ACZ"])

        fix_record_extensions = parse(I_record, s_i_record)

        # split up per 10 to enable easy counting
        s_b_record = join(["B093232520", "2767N00554", "786EA00128", "0019600600", "1145771529", "3177005930", "2770090"])
    
        decoded_b_record = parse(B_record, s_b_record)
        processed_b_record = update(decoded_b_record, fix_record_extensions)

        # split per extension: 006 001 14577 15293 177 00593 0277 0090
        expected_values = [
            ("FXA", 36:38, 6),
            ("ENL", 39:41, 1),
            ("TAS", 42:46, 14577),
            ("GSP", 47:51, 15293),
            ("TRT", 52:54, 177),
            ("VAT", 55:59, 593),
            ("OAT", 60:63, 277),
            ("ACZ", 64:67, 90),
        ]

        # ToDo!!!!
    
        for (extension_tlc, bytes, expected_value) in expected_values
            extension = IGCExtension(bytes, extension_tlc)
            @test extension in fix_record_extensions.extensions
            #@test extension_tlc in processed_b_record.extensions
            #@test expected_value == processed_b_record[extension_tlc]
        end

    end

    @testset "decode C record task info" begin
        line = "C150701213841160701000102 500K Tri\r\n"
        expected_result = C_record_task_info(
            Date(2001, 7, 15),  # declaration_date
            Time(21, 38, 41),  # declaration_time
            Date(2001, 7, 16),  # flight_date
            "0001",  # number
            2,  # num_turnpoints
            "500K Tri"  # description
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'C'
        @test parsed_result == expected_result

        @test ZonedDateTime(parsed_result.declaration, TZ) == ZonedDateTime(2001, 7, 15, 21, 38, 41, TZ)
    end

    @testset "decode C record waypoint info" begin
        line = "C5111359N00101899W Lasham Clubhouse\r\n"
        expected_result = C_record_waypoint_info(
            IGCLatitude(51.18931666666667),  # latitude
            IGCLongitude(-1.03165),  # longitude
            "Lasham Clubhouse"  # description
        )
        @test parse(Abstract_IGC_record, line) == expected_result
    end

    @testset "parse/decode GpsQualifier" begin
        @test GpsQualifier.parse('1') == GpsQualifier.GPS
        @test GpsQualifier.parse('2') == GpsQualifier.DGPS
        @test GpsQualifier.decode(1) == GpsQualifier.GPS
        @test GpsQualifier.decode(2) == GpsQualifier.DGPS
    end

    @testset "decode D record" begin
        line = "D20331\r\n"
        expected_result = D_record(
            GpsQualifier.DGPS,  # qualifier
            "0331"  # station_id
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'D'
        @test parsed_result == expected_result

        line = "D19999\r\n"
        expected_result = D_record(
            GpsQualifier.GPS,  # qualifier
            "9999"  # station_id
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test parsed_result == expected_result
    end

    @testset "decode E record" begin
        line = "E160245PEV\r\n"
        expected_result = E_record(
            Time(16, 2, 45),  # time
            "PEV",  # tlc
            ""  # extension_string
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'E'
        @test parsed_result == expected_result
    end

    @testset "decode F record" begin
        line = "F160240040609123624221821\r\n"
        expected_result = F_record(
            Time(16, 2, 40),  # time
            ["04", "06", "09", "12", "36", "24", "22", "18", "21"]  # satellites
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'F'
        # @test parse(F_record, line) == expected_result  # ToFix doesn't work - replaced by 2 tests
        @test parsed_result.time == expected_result.time
        @test parsed_result.satellites == expected_result.satellites
    end

    @testset "decode G record" begin
        line = "GREJNGJERJKNJKRE31895478537H43982FJN9248F942389T433T\r\n"
        expected_result = G_record(
            "REJNGJERJKNJKRE31895478537H43982FJN9248F942389T433T"
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'G'
        @test parsed_result == expected_result
    end

    @testset "decode I record" begin
        line = "I033638FXA3940SIU4143ENL\r\n"
        expected_extensions = [
            IGCExtension(36:38, "FXA"),
            IGCExtension(39:40, "SIU"),
            IGCExtension(41:43, "ENL")
        ]
        expected_result = I_record(expected_extensions)
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'I'
        @test length(parsed_result.extensions) == 3
        # @test parsed_result == expected_result
        for (i, extension) in enumerate(parsed_result.extensions)
            @test extension.bytes == expected_extensions[i].bytes
            @test extension.type == expected_extensions[i].type
        end
    end

    @testset "decode J record" begin
        line = "J010812HDT\r\n"
        expected_extensions = [
            IGCExtension(8:12, "HDT")
        ]
        expected_result = J_record(expected_extensions)
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'J'
        @test length(parsed_result.extensions) == 1
        # @test parsed_result == expected_result  # ToFix
        for (i, extension) in enumerate(parsed_result.extensions)
            @test extension.bytes == expected_extensions[i].bytes
            @test extension.type == expected_extensions[i].type
        end
    end

    @testset "decode H record fix accuracy" begin
        line = "HFFXA035\r\n"
        parsed_result = parse(Abstract_IGC_record, line)
        expected_result = H_record_FiXAccuracy(35)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result

        line = "HFFXA\r\n"
        expected_result = H_record_FiXAccuracy(missing)
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
        @test parsed_result.source == DEFAULT_SOURCE
        @test ismissing(parsed_result.value)
    end

    @testset "decode H record utc date" begin
        line = "HFDTE160701\r\n"
        expected_result = H_record_DaTE(2001, 7, 16)
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record pilot" begin
        line = "HFPLTPILOTINCHARGE: Bloggs Bill D\r\n"
        expected_result = H_record_PiLoT("Bloggs Bill D")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record pilot pwca header" begin
        line = "HFPLTPILOT: Bloggs Bill D\r\n"
        expected_result = H_record_PiLoT("Bloggs Bill D")
        parsed_result = parse(Abstract_IGC_record, line)
        @test parsed_result == expected_result
    end

    @testset "decode H record pilot unknown header" begin
        line = "HFPLT XXX : Bloggs Bill D\r\n"
        expected_result = H_record_PiLoT("Bloggs Bill D")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record copilot" begin
        line = "HFCM2CREW2: Smith-Barry John A\r\n"
        expected_result = H_record_Copilot("Smith-Barry John A")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record glider type" begin
        line = "HFGTYGLIDERTYPE: Schleicher ASH-25\r\n"
        expected_result = H_record_GliderType("Schleicher ASH-25")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record glider registration" begin
        line = "HFGIDGLIDERID: ABCD-1234\r\n"
        expected_result = H_record_GliderRegistration("ABCD-1234")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record gps datum" begin
        line = "HFDTM100GPSDATUM: WGS-1984\r\n"
        expected_result = H_record_GpsDatum("WGS-1984")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record firmware revision" begin
        line = "HFRFWFIRMWAREVERSION:6.4\r\n"
        expected_result = H_record_FirmwareRevision("6.4")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record hardware revision" begin
        line = "HFRHWHARDWAREVERSION:3.0\r\n"
        expected_result = H_record_HardwareRevision("3.0")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record manufacturer model" begin
        line = "HFFTYFRTYPE: Manufacturer, Model\r\n"
        expected_result = H_record_ManufacturerModel("Manufacturer", "Model")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record gps receiver" begin
        line = "HFGPS:MarconiCanada, Superstar, 12ch, max10000m\r\n"
        parsed_result = parse(Abstract_IGC_record, line)
        expected_result = H_record_GpsReceiver(
            "MarconiCanada",
            "Superstar",
            12,
            MaxAlt(10000, "m")
        )
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record gps receiver2" begin
        line = "HFGPS:GLOBALTOP,FGPMMOPA6,66,max18000m\r\n"
        expected_result = H_record_GpsReceiver(
            "GLOBALTOP",
            "FGPMMOPA6",
            66,
            MaxAlt(18000, "m")
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H_record gps receiver3" begin
        line = "HFGPS:GlobalTopPA6B,66ch,max18000m\r\n"
        expected_result = H_record_GpsReceiver(
            "GlobalTopPA6B",
            "",
            66,
            MaxAlt(18000, "m")
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record gps receiver4" begin
        line = "HFGPS:UBLOX,NEO-6G,16Ch,50000\r\n"
        expected_result = H_record_GpsReceiver(
            "UBLOX",
            "NEO-6G",
            16,
            MaxAlt(50000, "m")
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record gps receiver5" begin
        line = "HFGPS:LX\r\n"
        expected_result = H_record_GpsReceiver(
            "LX",
            "",
            missing,
            MaxAlt(missing, "")
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record gps receiver6" begin
        line = "HFGPS:Cambridge 302,\r\n"
        expected_result = H_record_GpsReceiver(
            "Cambridge 302",
            "",
            missing,
            MaxAlt()
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record pressure sensor" begin
        line = "HFPRSPRESSALTSENSOR: Sensyn, XYZ1111, max11000m\r\n"
        expected_result = H_record_PressureAltitudeSensor(
            "Sensyn",
            "XYZ1111",
            MaxAlt(11000, "m")
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record pressure sensor2" begin
        line = "HFPRSPressAltSensor:Intersema MS5534B,8191\r\n"
        expected_result = H_record_PressureAltitudeSensor(
            "Intersema MS5534B",
            "8191",
            MaxAlt()
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record competition id" begin
        line = "HFCIDCOMPETITIONID: XYZ-78910\r\n"
        expected_result = H_record_CompetitionId("XYZ-78910")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record competition class" begin
        line = "HFCCLCOMPETITIONCLASS:15m Motor Glider\r\n"
        expected_result = H_record_CompetitionClass("15m Motor Glider")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record time zone offset" begin
        line = "HFTZNTIMEZONE:3\r\n"
        expected_result = H_record_TimeZoneOffset(3 * 60)
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record time zone offset2" begin
        line = "HFTZNTIMEZONE:11.00\r\n"
        expected_result = H_record_TimeZoneOffset(11 * 60)
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record time zone offset3" begin
        line = "HFTZNTIMEZONE:-3.30\r\n"
        expected_result = H_record_TimeZoneOffset(-(3 * 60 + 30))
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record mop sensor" begin
        line = "HFMOPSENSOR:MOP-(SN:1,ET=1375,0,1375,0,3.05V,p=0),Ver:0\r\n"
        expected_result = H_record_MeansOfPropulsion("MOP-(SN:1,ET=1375,0,1375,0,3.05V,p=0),Ver:0")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record site" begin
        line = "HFSITSite: lk15comp\r\n"
        expected_result = H_record_Site("lk15comp")
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result == expected_result
    end

    @testset "decode H record units of measure" begin
        line = "HFUNTUnits: km,ft,kt"
        expected_result = H_record_UnitsOfMeasure(["km", "ft", "kt"])
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'H'
        @test parsed_result.value == expected_result.value
    end

    @testset "decode K record" begin
        line = "K16024800090\r\n"
        expected_result = K_record(
            Time(16, 2, 48),
            "00090",
            7
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'K'
        @test parsed_result == expected_result
    end

    @testset "decode L record" begin
        line = "LXXXRURITANIAN STANDARD NATIONALS DAY 1\r\n"
        expected_result = L_record(
            "XXX",
            "RURITANIAN STANDARD NATIONALS DAY 1"
        )
        parsed_result = parse(Abstract_IGC_record, line)
        @test flc(parsed_result) == 'L'
        @test parsed_result == expected_result
    end

    @testset "read igc file" begin
        fname = joinpath("data", "example.igc")
        igcdoc = read(fname, IGCDocument)

        for err in igcdoc.errors
            # println(err)
            showerror(stdout, err); println()
        end
        @test length(igcdoc.errors) == 0  # when every line are parsed correctly

        # A record
        record = igcdoc.logger_id
        @test record.manufacturer == "XXX"
        @test record.id == "ABC"
        @test record.id_addition == "FLIGHT:1"

        # B records
        records = igcdoc.fix_records
        @test length(records) == 9
        # tofix : because of vector of extensions test of equality
        # @test records[1] == B_record(Time(16, 02, 40), IGCLatitude(54.11868333333334), IGCLongitude(-2.8223666666666665), FixValidity.Fix3D, IGCPressureAltitude(280), IGCGpsAltitude(421), 36, "20509950")
        # @test records[2] == B_record(Time(16, 02, 45), IGCLatitude(51.118766666666666), IGCLongitude(-1.8216666666666668), FixValidity.Fix3D, IGCPressureAltitude(288), IGCGpsAltitude(429), 36, "19509020", IGCExtension[])
        # @test records[3] == B_record(Time(16, 02, 50), IGCLatitude(51.1189), IGCLongitude(-1.8213833333333334), FixValidity.Fix3D, IGCPressureAltitude(290), IGCGpsAltitude(432), 36, "21009015", IGCExtension[])
        # @test records[4] == B_record(Time(16, 02, 55), IGCLatitude(51.119), IGCLongitude(-1.82035), FixValidity.Fix3D, IGCPressureAltitude(290), IGCGpsAltitude(430), 36, "20009012", IGCExtension[])
        # @test records[5] == B_record(Time(16, 03, 00), IGCLatitude(51.119166666666665), IGCLongitude(-1.8200333333333334), FixValidity.Fix3D, IGCPressureAltitude(291), IGCGpsAltitude(432), 36, "25608009", IGCExtension[])
        # @test records[6] == B_record(Time(16, 03, 05), IGCLatitude(51.11966666666667), IGCLongitude(-1.81975), FixValidity.Fix3D, IGCPressureAltitude(291), IGCGpsAltitude(435), 36, "21008015", IGCExtension[])
        # @test records[7] == B_record(Time(16, 03, 10), IGCLatitude(51.1202), IGCLongitude(-1.8195666666666668), FixValidity.Fix3D, IGCPressureAltitude(293), IGCGpsAltitude(435), 36, "19608024", IGCExtension[])
        # @test records[8] == B_record(Time(16, 02, 48), IGCLatitude(51.120333333333335), IGCLongitude(-1.8191666666666666), FixValidity.Fix3D, IGCPressureAltitude(494), IGCGpsAltitude(436), 36, "19008018", IGCExtension[])
        # @test records[9] == B_record(Time(16, 02, 52), IGCLatitude(51.122166666666665), IGCLongitude(-1.8187833333333334), FixValidity.Fix3D, IGCPressureAltitude(496), IGCGpsAltitude(439), 36, "19508015", IGCExtension[])

        # C records
        # task = igcdoc.tasks[1]
        # @test length(igcdoc.tasks) == 1
        task = igcdoc.task
        @test task.info.declaration.date == Date(2001, 7, 15)
        @test task.info.declaration.time == Time(21, 38, 41)
        @test task.info.flight_date == Date(2001, 7, 16)
        @test task.info.number == "0001"
        @test task.info.num_turnpoints == 2
        @test task.info.description == "500K Tri"
        @test length(task.waypoints) == 6
        @test task.waypoints[1] == C_record_waypoint_info(IGCLatitude(51.18931666666667), IGCLongitude(-1.03165), "Lasham Clubhouse")
        @test task.waypoints[2] == C_record_waypoint_info(IGCLatitude(51.16965), IGCLongitude(-1.0440666666666667), "Lasham Start S, Start")
        @test task.waypoints[3] == C_record_waypoint_info(IGCLatitude(52.15153333333333), IGCLongitude(-2.9204499999999998), "Sarnesfield, TP1")
        @test task.waypoints[4] == C_record_waypoint_info(IGCLatitude(52.50245), IGCLongitude(-0.2935333333333333), "Norman Cross, TP2")
        @test task.waypoints[5] == C_record_waypoint_info(IGCLatitude(51.16965), IGCLongitude(-1.0440666666666667), "Lasham Start S, Finish")
        @test task.waypoints[6] == C_record_waypoint_info(IGCLatitude(51.18931666666667), IGCLongitude(-1.03165), "Lasham Clubhouse")

        # D records
        records = igcdoc.dgps_records
        @test length(records) == 1
        @test records[1] ==  D_record(GpsQualifier.DGPS, "0331")

        # E records
        records = igcdoc.event_records
        @test length(records) == 2
        @test records[1] == E_record(Time(16, 02, 45), "PEV", "")
        @test records[2] == E_record(Time(16, 03, 05), "PEV", "")

        # F records
        records = igcdoc.satellite_records
        @test length(records) == 2
        #@test records[1] == F_record(Time(16, 02, 40), ["04", "06", "09", "12", "36", "24", "22", "18", "21"])
        #@test records[2] == F_record(Time(16, 03, 00), ["06", "09", "12", "36", "24", "22", "18", "21"])

        # G records
        records = igcdoc.security_records
        @test length(records) == 5
        @test records[1].value == "REJNGJERJKNJKRE31895478537H43982FJN9248F942389T433T"
        @test records[2].value == "JNJK2489IERGNV3089IVJE9GO398535J3894N358954983O0934"
        @test records[3].value == "SKTO5427FGTNUT5621WKTC6714FT8957FGMKJ134527FGTR6751"
        @test records[4].value == "K2489IERGNV3089IVJE39GO398535J3894N358954983FTGY546"
        @test records[5].value == "12560DJUWT28719GTAOL5628FGWNIST78154INWTOLP7815FITN"

        # H records
        header = igcdoc.header
        @test header.competition_class.value == "15m Motor Glider"
        @test header.competition_id.value == "XYZ-78910"
        @test header.crew2.value == "Smith-Barry John A"
        @test header.firmware_version.value == "6.4"
        @test header.fix_accuracy.value == 35
        @test header.glider_type.value == "Schleicher ASH-25"
        @test header.glider_id.value == "ABCD-1234"
        @test header.gps_datum.value == "WGS-1984"
        @test header.gps_receiver.channels == 12
        @test header.gps_receiver.manufacturer == "MarconiCanada"
        @test header.gps_receiver.model == "Superstar"
        @test header.gps_receiver.max_alt.value == 10000
        @test header.gps_receiver.max_alt.unit == "m"
        @test header.hardware_version.value == "3.0"
        @test header.flight_recorder_type.manufacturer == "Manufacturer"
        @test header.flight_recorder_type.model == "Model"
        @test header.pilot_in_charge.value == "Bloggs Bill D"
        @test header.pressure_altitude_sensor.model == "XYZ1111"
        @test header.pressure_altitude_sensor.manufacturer == "Sensyn"
        @test header.pressure_altitude_sensor.max_alt.value == 11000
        @test header.pressure_altitude_sensor.max_alt.unit == "m"
        @test header.date.value == Date(2001, 7, 16)

        # I record
        extensions = igcdoc.fix_record_extensions.extensions
        @test length(extensions) == 3
        @test extensions[1] == IGCExtension(36:38, "FXA")
        @test extensions[2] == IGCExtension(39:40, "SIU")
        @test extensions[3] == IGCExtension(41:43, "ENL")

        # J records
        extensions = igcdoc.k_record_extensions.extensions
        @test length(extensions) == 1
        @test extensions[1] == IGCExtension(8:12, "HDT")

        # K records
        records = igcdoc.k_records
        @test length(records) == 1
        @test records[1] == K_record(Time(16, 02, 48), "00090", 7)

        # L records
        records = igcdoc.comment_records
        @test length(records) == 2
        @test records[1] == L_record("XXX", "RURITANIAN STANDARD NATIONALS DAY 1")
        @test records[2] == L_record("XXX", "FLIGHT TIME: 4:14:25, TASK SPEED:58.48KTS")

        # End of file / statistics
        #@test igcdoc.dt_first == ZonedDateTime(2001, 7, 16, 16, 2, 24, TZ)
        #@test igcdoc.dt_last == ZonedDateTime(2001, 7, 16, 16, 2, 52, TZ)
    end

    @testset "low level parse to vector of records" begin
        fname = joinpath("data", "example.igc")

        lines = readlines(fname)
        records = parse.(Abstract_IGC_record, lines)
        @test length(records) == 46

        lines = read(fname, String)
        records = parse(Vector{Abstract_IGC_record}, lines)
        @test length(records) == 46
    end

end
