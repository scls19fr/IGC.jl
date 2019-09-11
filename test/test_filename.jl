using IGC: year_to_short_string, number_to_char, char_to_number
using IGC: IGCLongFilename, IGCShortFilename, filename

@testset "filename" begin
    @testset "short file name" begin
        @testset "year" begin
            @test year_to_short_string(2019) == "9"
        end

        @testset "number_to_char" begin
            @test number_to_char(0) == '0'
            @test number_to_char(9) == '9'
            @test number_to_char(10) == 'A'
            @test number_to_char(31) == 'V'
            @test number_to_char(35) == 'Z'
        end

        @testset "char_to_number" begin
            @test char_to_number('0') == 0
            @test char_to_number('9') == 9
            @test char_to_number('A') == 10
            @test char_to_number('V') == 31
            @test char_to_number('Z') == 35
        end

        @testset "get short file name" begin
            f = IGCShortFilename(
                Date(2015, 06, 17),
                'C',
                "XXX",
                2
            )
            fname_expected = "56HCXXX2.IGC"
            returned_filename = filename(f)
            @test returned_filename == fname_expected
            
            parsed_filename = parse(IGCShortFilename, fname_expected, year=2010)
            @test parsed_filename.date == f.date
            @test parsed_filename.manufacturer == f.manufacturer
            @test parsed_filename.serial_id == f.serial_id
            @test parsed_filename.flight_of_day == f.flight_of_day
        end
    end

    @testset "get long file name" begin
        f = IGCLongFilename(
            Date(2015, 06, 17),
            "MMM",
            "XXX",
            2
        )
        fname_expected = "2015-06-17-MMM-XXX-02.IGC"
        returned_filename = filename(f)
        @test returned_filename == fname_expected

        parsed_filename = parse(IGCLongFilename, fname_expected)
        @test parsed_filename.date == f.date
        @test parsed_filename.manufacturer == f.manufacturer
        @test parsed_filename.serial_id == f.serial_id
        @test parsed_filename.flight_of_day == f.flight_of_day
    end
end
