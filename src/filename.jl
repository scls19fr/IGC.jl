function year_to_short_string(y)
    y = y % 10
    return "$y"
end

function number_to_char(n::Number)::Char
    if n >= 0 && n <= 9
        return Char(codepoint('0') + n)
    else
        return Char(codepoint('A') + n - 10)
    end
end

function char_to_number(c::Char)::UInt32
    if c >= '0' && c <= '9'
        return codepoint(c) - codepoint('0')
    else
        return codepoint(c) - codepoint('A') + 10
    end
end

struct IGCShortFilename
    date::Date
    manufacturer::Char
    serial_id::String
    flight_of_day::UInt64
end

struct IGCLongFilename
    date::Date
    manufacturer::String
    serial_id::String
    flight_of_day::UInt64
end

"""
    filename(f::IGCShortFilename)::String

Return a short filename as string
YMDCXXXF.IGC
    Y: year; value 0 to 9, cycling every 10 years
    M: month; value 1 to 9 then A for 10, B=11, C=12
    D: day; value 1 to 9 then A=10, B=11, C=12, D=13, E=14, F=15, G=16, H=17, I=18, J=19, 
        K=20, L=21, M=22, N=23, O=24, P=25, Q=26, R=27, S=28, T=29, U=30, V=31.
    C: manufacturer's single-letter IGC identifier
    XXX: unique flight recorder Serial ID (S/ID); 3 alphanumeric characters

Example
56HCXXX2.IGC
"""
function filename(f::IGCShortFilename)::String
    d = f.date
    Y = year_to_short_string(Dates.year(d))
    M = number_to_char(Dates.month(d))
    D = number_to_char(Dates.day(d))
    C = f.manufacturer[1]
    XXX = f.serial_id[1:3]
    F = number_to_char(f.flight_of_day)
    ext = ".IGC"
    return Y * M * D * C * XXX * F * ext
end

function decade(y)
    return y - y % 10
end

function parse(::Type{IGCShortFilename}, s::String; year=Dates.year(Dates.today()))
    year = decade(year)
    pattern = r"(.)(.)(.)(.)(...)(.).IGC"
    m = match(pattern, s)
    Y = year + parse(Int, m[1])
    M = char_to_number(m[2][1])
    D = char_to_number(m[3][1])
    C = m[4][1]
    XXX = m[5]
    F = char_to_number(m[6][1])
    return IGCShortFilename(
        Date(Y, M, D),
        C,
        XXX,
        F
    )
end

"""
    filename(f::IGCLongFilename)::String

Return a long filename as string
YYYY-MM-DD-MMM-XXX-FF.IGC
    YYYY: year
    MM: month
    DD: day
    MMM: manufacturer
    XXX: unique flight recorder Serial ID (S/ID); 3 alphanumeric characters
    FF: flight of the day

Example
2015-06-17-MMM-XXX-02.IGC
"""
function filename(f::IGCLongFilename)::String
    d = f.date
    YYYY = lpad(Dates.year(d) % 10000, 4, "0")
    MM = lpad(Dates.month(d), 2, "0")
    DD = lpad(Dates.day(d), 2, "0")
    MMM = f.manufacturer[1:3]
    XXX = f.serial_id[1:3]
    FF = lpad(f.flight_of_day % 100, 2, "0")
    return "$YYYY-$MM-$DD-$MMM-$XXX-$FF.IGC"
end

function parse(::Type{IGCLongFilename}, s::String)
    pattern = r"(\d\d\d\d)-(\d\d)-(\d\d)-(.{1,3})-(.{1,3})-(\d\d).IGC"
    m = match(pattern, s)
    YYYY = parse(Int, m[1])
    MM = parse(Int, m[2])
    DD = parse(Int, m[3])
    MMM = m[4]
    XXX = m[5]
    FF = parse(Int, m[6])
    return IGCLongFilename(
        Date(YYYY, MM, DD),
        MMM,
        XXX,
        FF
    )
end