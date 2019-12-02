using IGC
using Test
import IGC: IGCLatitude, IGCLongitude, IGCDate, IGCTime, IGCFixValidity, IGCPressureAltitude, IGCGpsAltitude
import IGC: A_record, B_record
import IGC: read_igc_file

using Dates

@testset "IGC.jl" begin
    # Write your own tests here.

    @testset "parse latitude" begin
        @test parse(IGCLatitude, "5117983N") == IGCLatitude(51.29971666666667)
        @test parse(IGCLatitude, "3356767S") == IGCLatitude(-33.94611666666667)
    end

    @testset "parse longitude" begin
        @test parse(IGCLongitude, "00657383E") == IGCLongitude(6.956383333333333)
        @test parse(IGCLongitude, "09942706W") == IGCLongitude(-99.71176666666666)
    end

    @testset "parse A record" begin
        line = "AXXXABC FLIGHT:1\r\n"
        expected_result = A_record("XXX", "ABC", "FLIGHT:1")
        @test parse(A_record, line) == expected_result
    end

    @testset "parse time" begin
        s = "160245"
        igc_time = parse(IGCTime, s)
        @test igc_time.val == Time(16, 2, 45)
        @test string(igc_time) == s
    end
            
    @testset "parse date" begin
        s = "200819"
        igc_date = parse(IGCDate, s)
        @test igc_date.val == Date(2019, 8, 20)
        @test string(igc_date) == s
    end

    @testset "parse B record" begin
        line = "B1602455107126N00149300WA002880042919509020\r\n"
        expected_result = B_record(
            IGCTime(16, 2, 45),
            IGCLatitude(51.118766666666666),
            IGCLongitude(-1.8216666666666668),
            IGCFixValidity('A'),
            IGCPressureAltitude(288),
            IGCGpsAltitude(429),
            35,
            "19509020"
        )
        @test parse(B_record, line) == expected_result
    end

    @testset "read igc file" begin
        igcdoc = read_igc_file(joinpath("data", "example.igc"))
        @test length(igcdoc.B_records) == 9
        for err in igcdoc.errors
            # println(err)
            showerror(stdout, err); println()
        end
        # @test length(igcdoc.errors) == 0  # when every line will be parsed correctly
    end
    
    
end
